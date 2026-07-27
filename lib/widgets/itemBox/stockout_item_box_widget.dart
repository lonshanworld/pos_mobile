import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/services/pos_repository.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/utils/checkout_helpers.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/widgets/checkout_line_detail.dart';
import 'package:pos_mobile/widgets/item_image_widget.dart';

class StockOutItemBoxWidget extends StatefulWidget {
  final ItemModel itemModel;
  final Function(ItemModel itemModel) reduceFunc;
  final Function(UniqueItemModel uniqueItemModel) addFunc;
  final List<UniqueItemModel> selectedUniqueItemList;
  final int startIndex;

  const StockOutItemBoxWidget({
    super.key,
    required this.itemModel,
    required this.reduceFunc,
    required this.addFunc,
    required this.selectedUniqueItemList,
    required this.startIndex,
  });

  @override
  State<StockOutItemBoxWidget> createState() => _StockOutItemBoxWidgetState();
}

class _StockOutItemBoxWidgetState extends State<StockOutItemBoxWidget> {
  late final Future<_StockOutItemParents?> _parentsFuture;

  bool _supportsPartialMeasurementSale(ItemBusinessDetailModel? itemDetail) {
    final rate = itemDetail?.pricePerMeasurementUnit;
    return rate != null &&
        rate > 0 &&
        itemDetail?.measurementLength != null &&
        itemDetail!.measurementLength! > 0 &&
        itemDetail.measurementWidth != null &&
        itemDetail.measurementWidth! > 0;
  }

  @override
  void initState() {
    super.initState();
    _parentsFuture = _loadParents();
  }

  Future<_StockOutItemParents?> _loadParents() async {
    try {
      final TypeModel? typeModel = await PosRepository.instance.fetchTypeById(
        widget.itemModel.typeId,
      );
      if (typeModel == null) {
        debugPrint(
          'StockOutItemBoxWidget: missing type for itemId=${widget.itemModel.id}, typeId=${widget.itemModel.typeId}',
        );
        return null;
      }

      final int? resolvedGroupId =
          widget.itemModel.groupId ?? typeModel.groupId;
      final GroupModel? groupModel = resolvedGroupId == null
          ? null
          : await PosRepository.instance.fetchGroupById(resolvedGroupId);

      final int? resolvedCategoryId =
          widget.itemModel.categoryId ?? groupModel?.categoryId;
      final CategoryModel? categoryModel = resolvedCategoryId == null
          ? null
          : await PosRepository.instance.fetchCategoryById(resolvedCategoryId);

      return _StockOutItemParents(
        typeModel: typeModel,
        groupModel: groupModel,
        categoryModel: categoryModel,
      );
    } catch (err, st) {
      debugPrint(
        'StockOutItemBoxWidget: failed to load parents for itemId=${widget.itemModel.id}',
      );
      debugPrint(err.toString());
      debugPrint(st.toString());
      return null;
    }
  }

  void _showPartialMeasurementDialog({
    required BuildContext context,
    required List<UniqueItemModel> availableUnits,
    required List<UniqueItemModel> cartUnits,
    required ItemBusinessDetailModel? itemDetail,
  }) {
    final pool = availableUnits
        .where((u) => !CheckoutHelpers.isExpired(u))
        .toList();
    if (pool.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No sellable pieces available.')),
      );
      return;
    }

    final accent = UIController.instance.accentColor();
    final double rate = itemDetail?.pricePerMeasurementUnit ?? 0.0;

    if (!_supportsPartialMeasurementSale(itemDetail)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This item is not configured for measurement sale.'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        UniqueItemModel? selectedPiece;
        if (pool.length == 1) {
          selectedPiece = pool.first;
        }

        final formKey = GlobalKey<FormState>();
        final lengthController = TextEditingController();
        final widthController = TextEditingController();
        double calculatedPrice = 0.0;
        double calculatedArea = 0.0;

        if (selectedPiece != null) {
          final existing = cartUnits.firstWhereOrNull(
            (u) => u.id == selectedPiece!.id,
          );
          if (existing != null) {
            lengthController.text = existing.instanceLength?.toString() ?? '';
          }
          widthController.text = selectedPiece.instanceWidth?.toString() ?? '';
        }

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            void updateCalculation(String val) {
              final len = double.tryParse(val) ?? 0.0;
              final width = selectedPiece?.instanceWidth ?? 1.0;
              setStateDialog(() {
                widthController.text = width.toString();
                calculatedArea = len * width;
                calculatedPrice = calculatedArea * rate;
              });
            }

            if (lengthController.text.isNotEmpty && calculatedPrice == 0.0) {
              updateCalculation(lengthController.text);
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).cardColor,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: Text(
                'Per Unit Measurement Purchase',
                style: TextStyle(color: accent, fontWeight: FontWeight.bold),
              ),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 400,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (selectedPiece == null) ...[
                        const Text(
                          'Select a piece to sell from:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 180),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: pool.length,
                            separatorBuilder: (_, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final piece = pool[index];
                              final existing = cartUnits.firstWhereOrNull(
                                (u) => u.id == piece.id,
                              );
                              final bool isInCart = existing != null;
                              final bool isSelected =
                                  selectedPiece?.id == piece.id;

                              return ListTile(
                                dense: true,
                                title: Text(
                                  'Piece #${piece.id}: ${piece.instanceLength} × ${piece.instanceWidth} ${itemDetail?.measurementUnit ?? 'ft'}',
                                  style: TextStyle(
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Text(
                                  'Price: ${CheckoutHelpers.uniqueItemSellPrice(piece).toInt()} MMK${isInCart ? ' (In Cart: ${existing.instanceLength} ${itemDetail?.measurementUnit ?? 'ft'})' : ''}',
                                ),
                                trailing: isSelected
                                    ? Icon(Icons.check_circle, color: accent)
                                    : const Icon(Icons.circle_outlined),
                                onTap: () {
                                  setStateDialog(() {
                                    selectedPiece = piece;
                                    widthController.text =
                                        piece.instanceWidth?.toString() ?? '';
                                    if (isInCart) {
                                      lengthController.text =
                                          existing.instanceLength?.toString() ??
                                          '';
                                    } else {
                                      lengthController.clear();
                                    }
                                    calculatedPrice = 0.0;
                                    calculatedArea = 0.0;
                                  });
                                  if (lengthController.text.isNotEmpty) {
                                    updateCalculation(lengthController.text);
                                  }
                                },
                              );
                            },
                          ),
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Selected Piece #${selectedPiece!.id}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            if (pool.length > 1)
                              TextButton(
                                onPressed: () {
                                  setStateDialog(() {
                                    selectedPiece = null;
                                    lengthController.clear();
                                    widthController.clear();
                                    calculatedPrice = 0.0;
                                    calculatedArea = 0.0;
                                  });
                                },
                                child: const Text('Change Piece'),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Available Size: ${selectedPiece!.instanceLength} × ${selectedPiece!.instanceWidth} ${itemDetail?.measurementUnit ?? 'ft'}',
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Price Rate: ${rate.toInt()} MMK per square ${itemDetail?.measurementUnit ?? 'unit'}',
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: lengthController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText:
                                'Length to sell (${itemDetail?.measurementUnit ?? 'ft'})',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: accent, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: updateCalculation,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter length';
                            }
                            final len = double.tryParse(val);
                            if (len == null || len <= 0) {
                              return 'Enter a valid length > 0';
                            }
                            if (len > (selectedPiece!.instanceLength ?? 0.0)) {
                              return 'Cannot exceed available length (${selectedPiece!.instanceLength})';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: widthController,
                          readOnly: true,
                          decoration: InputDecoration(
                            labelText:
                                'Width used for price (${itemDetail?.measurementUnit ?? 'ft'})',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: accent, width: 2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Width is shown here because cut-piece stock split is currently tracked by length only.',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700]),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Calculated Area:',
                                    style: TextStyle(color: Colors.black54),
                                  ),
                                  Text(
                                    '${calculatedArea.toStringAsFixed(2)} sq ${itemDetail?.measurementUnit ?? 'unit'}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(height: 16),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Total Price:',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${calculatedPrice.toStringAsFixed(0)} MMK',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: accent,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                if (selectedPiece != null)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final inputLength = double.parse(lengthController.text);
                        final double originalLength =
                            selectedPiece!.instanceLength ?? 1.0;
                        final double originalWidth =
                            selectedPiece!.instanceWidth ?? 1.0;
                        final double sourceArea =
                            originalLength * originalWidth;
                        final double soldArea = inputLength * originalWidth;
                        final double sourceOriginalPrice =
                            selectedPiece!.originalPrice;
                        final double cloneOriginalPrice = sourceArea <= 0
                            ? sourceOriginalPrice
                            : sourceOriginalPrice * (soldArea / sourceArea);
                        final double cutSellPrice = soldArea * rate;
                        final double cloneProfitPrice =
                            cutSellPrice - cloneOriginalPrice;

                        final clone = UniqueItemModel(
                          id: selectedPiece!.id,
                          itemId: selectedPiece!.itemId,
                          stockInId: selectedPiece!.stockInId,
                          stockOutId: selectedPiece!.stockOutId,
                          createTime: selectedPiece!.createTime,
                          deleteTime: selectedPiece!.deleteTime,
                          itemExpireDate: selectedPiece!.itemExpireDate,
                          itemManufactureDate:
                              selectedPiece!.itemManufactureDate,
                          code: selectedPiece!.code,
                          createPersonId: selectedPiece!.createPersonId,
                          deletePersonId: selectedPiece!.deletePersonId,
                          getItemFromWhere: selectedPiece!.getItemFromWhere,
                          lastUpdateTime: selectedPiece!.lastUpdateTime,
                          activeStatus: selectedPiece!.activeStatus,
                          originalPrice: cloneOriginalPrice,
                          profitPrice: cloneProfitPrice,
                          taxPercentage: selectedPiece!.taxPercentage,
                          moduleCount: selectedPiece!.moduleCount,
                          instanceLength: inputLength,
                          instanceWidth: selectedPiece!.instanceWidth,
                          instanceBatchNumber:
                              selectedPiece!.instanceBatchNumber,
                        );

                        widget.selectedUniqueItemList.removeWhere(
                          (item) => item.id == selectedPiece!.id,
                        );
                        widget.addFunc(clone);

                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Confirm'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context
        .watch<ThemeCubit>()
        .state
        .themeModeType;
    final BusinessType businessType = context
        .watch<ShopInfoCubit>()
        .state
        .businessType;
    final PromotionModel? promotion = context
        .read<PromotionCubit>()
        .getSinglePromotionFromItemId(widget.itemModel.id);
    final List<UniqueItemModel> uniqueItemList = context
        .read<ItemCubit>()
        .getSelectedUniqueItemList(widget.itemModel.id);
    final itemDetail = context.read<ItemCubit>().getBusinessDetail(
      widget.itemModel.id,
    );
    final cartUnitsForItem = widget.selectedUniqueItemList
        .where((u) => u.itemId == widget.itemModel.id)
        .toList();
    final detailByItemId = {widget.itemModel.id: itemDetail};

    String priceLabel() {
      final nextUnit = CheckoutHelpers.pickNextUnit(
        availableUnits: uniqueItemList,
        cartUnits: widget.selectedUniqueItemList,
        businessType: businessType,
      );
      if (nextUnit != null) {
        return '${CheckoutHelpers.uniqueItemSellPrice(nextUnit).toInt()} MMK';
      }

      if (cartUnitsForItem.isNotEmpty) {
        final prices = cartUnitsForItem
            .map(CheckoutHelpers.uniqueItemSellPrice)
            .toSet();
        if (prices.length == 1) {
          return '${prices.first.toInt()} MMK';
        }
        final minP = prices.reduce((a, b) => a < b ? a : b);
        final maxP = prices.reduce((a, b) => a > b ? a : b);
        return '${minP.toInt()}–${maxP.toInt()} MMK';
      }

      return '${CalculationFormula.getItemSellPrice(originalPrice: widget.itemModel.originalPrice, profitPrice: widget.itemModel.profitPrice, taxPercentage: widget.itemModel.taxPercentage ?? 0).toInt()} MMK';
    }

    String stockStatusLabel(int availableStock, bool outOfStock) {
      if (!widget.itemModel.needStock) {
        return businessType == BusinessType.food ? "Made to order" : "Ready";
      }

      if (outOfStock) {
        switch (businessType) {
          case BusinessType.clothing:
            return "No pieces left";
          case BusinessType.basicPharmacy:
            return "Out of medicine";
          case BusinessType.convenience:
            return "Sold out";
          default:
            return "Out of Stock";
        }
      }

      switch (businessType) {
        case BusinessType.clothing:
          return "$availableStock pieces";
        case BusinessType.basicPharmacy:
          return "$availableStock units";
        case BusinessType.grocery:
          return "$availableStock packs";
        case BusinessType.convenience:
          return "$availableStock ready";
        default:
          return "$availableStock left";
      }
    }

    String availableToAddLabel(int availableStock, bool outOfStock) {
      if (!widget.itemModel.needStock) {
        return "Tap + to add";
      }
      if (outOfStock) {
        switch (businessType) {
          case BusinessType.clothing:
            return "No sellable pieces left";
          case BusinessType.basicPharmacy:
            return "No sellable units left";
          default:
            return "No stock left";
        }
      }

      switch (businessType) {
        case BusinessType.clothing:
          return "$availableStock pieces ready to add";
        case BusinessType.basicPharmacy:
          return "$availableStock units ready to add";
        case BusinessType.grocery:
          return "$availableStock packs ready to add";
        case BusinessType.convenience:
          return "$availableStock items ready to add";
        default:
          return "$availableStock units ready to add";
      }
    }

    int sellableCount() {
      final inCart = widget.selectedUniqueItemList.map((e) => e.id).toSet();
      return uniqueItemList
          .where((u) => !inCart.contains(u.id) && !CheckoutHelpers.isExpired(u))
          .length;
    }

    return FutureBuilder<_StockOutItemParents?>(
      future: _parentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Card(
            elevation: 4,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: UIConstants.mediumBorderRadius,
            ),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final _StockOutItemParents? parents = snapshot.data;
        if (parents == null) {
          return const Card(
            elevation: 4,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(
              borderRadius: UIConstants.mediumBorderRadius,
            ),
            child: Center(child: Text("Missing item relation")),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final String topLabel =
                parents.categoryModel?.name ??
                parents.groupModel?.name ??
                parents.typeModel.name;
            final String relationLabel = [
              if (parents.groupModel != null) parents.groupModel!.name,
              parents.typeModel.name,
            ].join(" > ");
            final double width = constraints.maxWidth;
            final bool compact = width < 220;
            final bool tablet = width >= 220 && width < 290;
            final bool desktop = width >= 290;
            final double iconSize = compact
                ? 32
                : tablet
                ? 42
                : 54;
            final double badgeFontSize = compact
                ? 8
                : tablet
                ? 9
                : 10;
            final double titleFontSize = compact
                ? 13
                : tablet
                ? 14
                : 15;
            final double subtitleFontSize = compact
                ? 10
                : tablet
                ? 11
                : 12;
            final double priceFontSize = compact
                ? 13
                : tablet
                ? 14.5
                : 16.5;
            final double controlHeight = compact
                ? 32
                : tablet
                ? 36
                : 40;
            final EdgeInsets cardPadding = EdgeInsets.all(
              compact
                  ? 6
                  : tablet
                  ? 8
                  : 12,
            );
            final int titleLines = desktop ? 2 : 1;

            final int moreItem = widget.startIndex;
            final int availableStock = sellableCount();
            final bool outOfStock = widget.itemModel.needStock
                ? availableStock <= 0
                : false;
            final UniqueItemModel? nextUnit = widget.itemModel.needStock
                ? CheckoutHelpers.pickNextUnit(
                    availableUnits: uniqueItemList,
                    cartUnits: widget.selectedUniqueItemList,
                    businessType: businessType,
                  )
                : UniqueItemModel(
                    id: DateTime.now().microsecondsSinceEpoch * -1,
                    itemId: widget.itemModel.id,
                    stockInId: 0,
                    stockOutId: null,
                    createTime: DateTime.now(),
                    deleteTime: null,
                    itemExpireDate: null,
                    itemManufactureDate: null,
                    code: widget.itemModel.code ?? '',
                    createPersonId: 0,
                    deletePersonId: null,
                    getItemFromWhere: null,
                    lastUpdateTime: null,
                    activeStatus: true,
                    originalPrice: widget.itemModel.originalPrice,
                    profitPrice: widget.itemModel.profitPrice,
                    taxPercentage: widget.itemModel.taxPercentage ?? 0,
                    moduleCount: null,
                  );

            return GestureDetector(
              onLongPress: () {
                if (businessType == BusinessType.clothing &&
                    !outOfStock &&
                    _supportsPartialMeasurementSale(itemDetail)) {
                  _showPartialMeasurementDialog(
                    context: context,
                    availableUnits: uniqueItemList,
                    cartUnits: widget.selectedUniqueItemList,
                    itemDetail: itemDetail,
                  );
                }
              },
              child: Card(
                elevation: 4,
                shadowColor: Colors.black12,
                shape: const RoundedRectangleBorder(
                  borderRadius: UIConstants.mediumBorderRadius,
                ),
                clipBehavior: Clip.antiAlias,
                child: Container(
                  decoration: BoxDecoration(
                    color: uiController.getpureDirectClr(themeModeType),
                    border: moreItem > 0
                        ? Border.all(color: Colors.amber, width: 2)
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: iconSize + 24,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Container(
                              color: Colors.grey.withValues(alpha: 0.05),
                              child: ItemImageWidget(
                                imageId: widget.itemModel.imageId,
                                imageUrl: widget.itemModel.imageUrl,
                                fallbackIcon: Icons.inventory_2,
                                fallbackIconSize: iconSize,
                              ),
                            ),
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact
                                      ? 6
                                      : tablet
                                      ? 8
                                      : 10,
                                  vertical: compact ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: uiController.getpureOppositeClr(
                                    themeModeType,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  topLabel,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: uiController.getpureDirectClr(
                                      themeModeType,
                                    ),
                                    fontSize: badgeFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: compact
                                      ? 6
                                      : tablet
                                      ? 8
                                      : 10,
                                  vertical: compact ? 2 : 4,
                                ),
                                decoration: BoxDecoration(
                                  color: outOfStock
                                      ? UIConstants.redVioletClr
                                      : UIConstants.goldClr,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  stockStatusLabel(availableStock, outOfStock),
                                  style: TextStyle(
                                    color: outOfStock
                                        ? Colors.white
                                        : Colors.black,
                                    fontSize: titleFontSize,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            if (promotion != null)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Container(
                                  color: Colors.amber.withValues(alpha: 0.9),
                                  padding: EdgeInsets.symmetric(
                                    vertical: compact ? 1 : 2,
                                  ),
                                  child: Text(
                                    "PROMO APPLIED",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: badgeFontSize,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: cardPadding,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.itemModel.name,
                              maxLines: titleLines,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium!
                                  .copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: titleFontSize,
                                    height: 1.1,
                                  ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              relationLabel,
                              maxLines: desktop ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    color: Colors.grey[600],
                                    fontSize: subtitleFontSize,
                                  ),
                            ),
                            CheckoutItemDetailChips(
                              businessType: businessType,
                              detail: itemDetail,
                            ),
                            if (cartUnitsForItem.isNotEmpty)
                              CheckoutCartUnitSummary(
                                businessType: businessType,
                                cartUnitsForItem: cartUnitsForItem,
                                detailByItemId: detailByItemId,
                              ),
                            if (desktop) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.inventory_2_outlined,
                                    size: 14,
                                    color: Colors.grey[600],
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      availableToAddLabel(
                                        availableStock,
                                        outOfStock,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: Colors.grey[600],
                                            fontSize: subtitleFontSize,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              priceLabel(),
                              style: Theme.of(context).textTheme.titleSmall!
                                  .copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: priceFontSize,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: controlHeight,
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(
                                  controlHeight / 2,
                                ),
                                border: Border.all(
                                  color: Colors.grey.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth: compact
                                          ? 28
                                          : tablet
                                          ? 36
                                          : 40,
                                      minHeight: compact
                                          ? 28
                                          : tablet
                                          ? 36
                                          : 40,
                                    ),
                                    iconSize: compact
                                        ? 18
                                        : tablet
                                        ? 20
                                        : 22,
                                    icon: Icon(
                                      Icons.remove,
                                      color: moreItem > 0
                                          ? uiController.getpureOppositeClr(
                                              themeModeType,
                                            )
                                          : Colors.grey,
                                    ),
                                    onPressed: () {
                                      if (moreItem > 0) {
                                        widget.reduceFunc(widget.itemModel);
                                      }
                                    },
                                  ),
                                  FittedBox(
                                    fit: BoxFit.scaleDown,
                                    child: Text(
                                      moreItem.toString(),
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: compact
                                                ? 13
                                                : tablet
                                                ? 15
                                                : 16,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth: compact
                                          ? 28
                                          : tablet
                                          ? 36
                                          : 40,
                                      minHeight: compact
                                          ? 28
                                          : tablet
                                          ? 36
                                          : 40,
                                    ),
                                    iconSize: compact
                                        ? 18
                                        : tablet
                                        ? 20
                                        : 22,
                                    icon: Icon(
                                      Icons.add,
                                      color: outOfStock
                                          ? Colors.grey
                                          : uiController.getpureOppositeClr(
                                              themeModeType,
                                            ),
                                    ),
                                    onPressed: () {
                                      if (!outOfStock && nextUnit != null) {
                                        widget.addFunc(nextUnit);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _StockOutItemParents {
  final TypeModel typeModel;
  final GroupModel? groupModel;
  final CategoryModel? categoryModel;

  const _StockOutItemParents({
    required this.typeModel,
    required this.groupModel,
    required this.categoryModel,
  });
}
