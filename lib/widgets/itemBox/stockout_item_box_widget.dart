import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/utils/formula.dart';

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

  @override
  void initState() {
    super.initState();
    _parentsFuture = _loadParents();
  }

  Future<_StockOutItemParents?> _loadParents() async {
    try {
      final TypeModel? typeModel = await DBHelper.getTypeById(widget.itemModel.typeId);
      if (typeModel == null) {
        debugPrint('StockOutItemBoxWidget: missing type for itemId=${widget.itemModel.id}, typeId=${widget.itemModel.typeId}');
        return null;
      }

      final GroupModel? groupModel = await DBHelper.getGroupById(typeModel.groupId);
      if (groupModel == null) {
        debugPrint('StockOutItemBoxWidget: missing group for itemId=${widget.itemModel.id}, groupId=${typeModel.groupId}');
        return null;
      }

      final CategoryModel? categoryModel = await DBHelper.getCategoryById(groupModel.categoryId);
      if (categoryModel == null) {
        debugPrint('StockOutItemBoxWidget: missing category for itemId=${widget.itemModel.id}, categoryId=${groupModel.categoryId}');
        return null;
      }

      return _StockOutItemParents(
        typeModel: typeModel,
        groupModel: groupModel,
        categoryModel: categoryModel,
      );
    } catch (err, st) {
      debugPrint('StockOutItemBoxWidget: failed to load parents for itemId=${widget.itemModel.id}');
      debugPrint(err.toString());
      debugPrint(st.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final PromotionModel? promotion = context.read<PromotionCubit>().getSinglePromotionFromItemId(widget.itemModel.id);
    final List<UniqueItemModel> uniqueItemList = context.read<ItemCubit>().getSelectedUniqueItemList(widget.itemModel.id);

    return FutureBuilder<_StockOutItemParents?>(
      future: _parentsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Card(
            elevation: 4,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(borderRadius: UIConstants.mediumBorderRadius),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final _StockOutItemParents? parents = snapshot.data;
        if (parents == null) {
          return const Card(
            elevation: 4,
            shadowColor: Colors.black12,
            shape: RoundedRectangleBorder(borderRadius: UIConstants.mediumBorderRadius),
            child: Center(
              child: Text("Missing item relation"),
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool compact = width < 220;
            final bool tablet = width >= 220 && width < 290;
            final bool desktop = width >= 290;
            final double iconSize = compact ? 32 : tablet ? 42 : 54;
            final double badgeFontSize = compact ? 8 : tablet ? 9 : 10;
            final double titleFontSize = compact ? 13 : tablet ? 14 : 15;
            final double subtitleFontSize = compact ? 10 : tablet ? 11 : 12;
            final double priceFontSize = compact ? 13 : tablet ? 14.5 : 16.5;
            final double controlHeight = compact ? 32 : tablet ? 36 : 40;
            final EdgeInsets cardPadding = EdgeInsets.all(compact ? 6 : tablet ? 8 : 12);
            final int titleLines = desktop ? 2 : 1;

            final int moreItem = widget.startIndex;
            final int availableStock = uniqueItemList.length - moreItem;
            final bool outOfStock = availableStock <= 0;

            return Card(
              elevation: 4,
              shadowColor: Colors.black12,
              shape: const RoundedRectangleBorder(borderRadius: UIConstants.mediumBorderRadius),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  color: uiController.getpureDirectClr(themeModeType),
                  border: moreItem > 0 ? Border.all(color: Colors.amber, width: 2) : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: desktop ? 3 : 3,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Container(
                            color: Colors.grey.withValues(alpha: 0.05),
                            child: Center(
                              child: Icon(
                                Icons.inventory_2,
                                size: iconSize,
                                color: Colors.grey.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: compact ? 6 : tablet ? 8 : 10,
                                vertical: compact ? 2 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: uiController.getpureOppositeClr(themeModeType),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                parents.categoryModel.name,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: TextStyle(
                                  color: uiController.getpureDirectClr(themeModeType),
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
                                horizontal: compact ? 6 : tablet ? 8 : 10,
                                vertical: compact ? 2 : 4,
                              ),
                              decoration: BoxDecoration(
                                color: outOfStock ? UIConstants.redVioletClr : UIConstants.goldClr,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                outOfStock ? "Out of Stock" : "$availableStock left",
                                style: TextStyle(
                                  color: outOfStock ? Colors.white : Colors.black,
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
                                padding: EdgeInsets.symmetric(vertical: compact ? 1 : 2),
                                child: Text(
                                  "PROMO",
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
                    Expanded(
                      flex: desktop ? 7 : 6,
                      child: Padding(
                        padding: cardPadding,
                        child: Column(
                          mainAxisAlignment: desktop ? MainAxisAlignment.spaceEvenly : MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.itemModel.name,
                              maxLines: titleLines,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: titleFontSize,
                                    height: 1.1,
                                  ),
                            ),
                            Text(
                              "${parents.groupModel.name} > ${parents.typeModel.name}",
                              maxLines: desktop ? 2 : 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                    color: Colors.grey[600],
                                    fontSize: subtitleFontSize,
                                  ),
                            ),
                            if (desktop)
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
                                      outOfStock ? "No stock left" : "$availableStock units ready to add",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                                            color: Colors.grey[600],
                                            fontSize: subtitleFontSize,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            Text(
                              "${CalculationFormula.getItemSellPrice(
                                originalPrice: widget.itemModel.originalPrice,
                                profitPrice: widget.itemModel.profitPrice,
                                taxPercentage: widget.itemModel.taxPercentage ?? 0,
                              ).toInt()} MMK",
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.w900,
                                    fontSize: priceFontSize,
                                  ),
                            ),
                            Container(
                              height: controlHeight,
                              decoration: BoxDecoration(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(controlHeight / 2),
                                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth: compact ? 28 : tablet ? 36 : 40,
                                      minHeight: compact ? 28 : tablet ? 36 : 40,
                                    ),
                                    iconSize: compact ? 18 : tablet ? 20 : 22,
                                    icon: Icon(
                                      Icons.remove,
                                      color: moreItem > 0 ? uiController.getpureOppositeClr(themeModeType) : Colors.grey,
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
                                      style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                            fontWeight: FontWeight.bold,
                                            fontSize: compact ? 13 : tablet ? 15 : 16,
                                          ),
                                    ),
                                  ),
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: BoxConstraints(
                                      minWidth: compact ? 28 : tablet ? 36 : 40,
                                      minHeight: compact ? 28 : tablet ? 36 : 40,
                                    ),
                                    iconSize: compact ? 18 : tablet ? 20 : 22,
                                    icon: Icon(
                                      Icons.add,
                                      color: outOfStock ? Colors.grey : uiController.getpureOppositeClr(themeModeType),
                                    ),
                                    onPressed: () {
                                      if (!outOfStock) {
                                        widget.addFunc(uniqueItemList[moreItem]);
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
  final GroupModel groupModel;
  final CategoryModel categoryModel;

  const _StockOutItemParents({
    required this.typeModel,
    required this.groupModel,
    required this.categoryModel,
  });
}
