import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/screens/barcode_scanner_screen.dart';
import 'package:pos_mobile/screens/transaction/stockOut/voucher_screen.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtIconBtn_widget.dart';
import 'package:pos_mobile/widgets/itemBox/stockout_item_box_widget.dart';

import '../../../blocs/theme_bloc/theme_cubit.dart';
import '../../../constants/enums.dart';
import '../../../constants/uiConstants.dart';
import '../../../controller/ui_controller.dart';
import '../../../features/cus_showmodelbottomsheet.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';
import '../../../utils/checkout_helpers.dart';
import '../../../utils/txt_formatters.dart';
import '../../../widgets/loading_widget.dart';
import 'add_more_info_stockOut_screen.dart';
import 'package:pos_mobile/constants/business_hierarchy_config.dart';

class StockOutScreen extends StatefulWidget {
  static const String routeName = "/stockoutscreen";

  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final TextEditingController searchController = TextEditingController();
  final TextEditingController barcodeController = TextEditingController();
  int? selectedCategoryId;
  int? selectedGroupId;
  int? selectedTypeId;
  String? selectedColor;
  int currentPage = 1;
  List<ItemModel> sellItemModelList = [];
  List<UniqueItemModel> sellUniqueItemModelList = [];
  bool showLoading = false;

  double? deliveryCharges;
  double taxPercentage = 0;
  double? additionalPromotionAmount;
  String? description;
  String? customerName;
  String? deliveryName;
  ShoppingType shoppingType = ShoppingType.shop;
  PaymentMethod paymentMethod = PaymentMethod.cash;
  PromotionModel? promotion;
  DateTime checkoutTime = DateTime.now();

  @override
  void dispose() {
    searchController.dispose();
    barcodeController.dispose();
    super.dispose();
  }

  void _resetPaging() {
    currentPage = 1;
  }

  void _setSearchValue(String value) {
    if (!mounted) return;
    setState(() {
      _resetPaging();
    });
  }

  void _clearFilters() {
    if (!mounted) return;
    setState(() {
      selectedCategoryId = null;
      selectedGroupId = null;
      selectedTypeId = null;
      selectedColor = null;
      currentPage = 1;
    });
  }

  String _searchHint(BusinessType businessType) {
    switch (businessType) {
      case BusinessType.clothing:
        return "Search fabrics, designs, or colors";
      case BusinessType.basicPharmacy:
        return "Search medicines or treatments";
      case BusinessType.grocery:
        return "Search grocery items or produce";
      case BusinessType.convenience:
        return "Search items or snacks";
      default:
        return "Search items";
    }
  }

  String _scanHint(BusinessType businessType) {
    switch (businessType) {
      case BusinessType.clothing:
        return "Scan piece code or item barcode";
      case BusinessType.basicPharmacy:
        return "Scan batch label or item barcode";
      case BusinessType.grocery:
        return "Scan pack label or item barcode";
      case BusinessType.convenience:
        return "Scan barcode to add item";
      default:
        return "Scan barcode / batch label to add item";
    }
  }

  String _emptyStateMessage(BusinessType businessType, bool hasFilters) {
    if (hasFilters) {
      switch (businessType) {
        case BusinessType.clothing:
          return "No fabrics or designs match the current search and filters";
        case BusinessType.basicPharmacy:
          return "No medicines match the current search and filters";
        case BusinessType.grocery:
          return "No grocery items match the current search and filters";
        case BusinessType.convenience:
          return "No convenience items match the current search and filters";
        default:
          return "No items match the current search and filters";
      }
    }

    switch (businessType) {
      case BusinessType.clothing:
        return "No fabrics available";
      case BusinessType.basicPharmacy:
        return "No medicines available";
      case BusinessType.grocery:
        return "No grocery items available";
      case BusinessType.convenience:
        return "No convenience items available";
      default:
        return "No items available";
    }
  }

  List<ItemModel> _buildFilteredItems({
    required List<ItemModel> activeItemList,
    required Map<int, dynamic> detailByItemId,
    required BusinessType businessType,
  }) {
    final String query = searchController.text.trim().toLowerCase();

    return activeItemList.where((item) {
      if (query.isNotEmpty && !item.name.toLowerCase().contains(query)) {
        return false;
      }

      if (selectedCategoryId != null && item.categoryId != selectedCategoryId) {
        return false;
      }

      if (selectedGroupId != null && item.groupId != selectedGroupId) {
        return false;
      }

      if (selectedTypeId != null && item.typeId != selectedTypeId) {
        return false;
      }

      if (selectedColor != null) {
        final detail = detailByItemId[item.id];
        final String? itemColor = businessType == BusinessType.clothing
            ? detail?.clothingColor
            : detail?.deviceColor;
        if (itemColor != selectedColor) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  Widget _buildFilterDropdown({
    required String label,
    required int? value,
    required List<DropdownMenuItem<int?>> items,
    required ValueChanged<int?> onChanged,
    required double fontSize,
  }) {
    return DropdownButtonFormField<int?>(
      initialValue: value,
      isExpanded: true,
      iconSize: 18,
      style: Theme.of(
        context,
      ).textTheme.bodySmall?.copyWith(fontSize: fontSize),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(
          context,
        ).textTheme.bodySmall?.copyWith(fontSize: fontSize, color: Colors.grey),
        isDense: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      ),
      items: items,
      onChanged: onChanged,
    );
  }

  Widget _buildPaginationControls({
    required int totalItems,
    required int totalPages,
    required int safeCurrentPage,
    required int startItemNumber,
    required int endItemNumber,
  }) {
    final bool canGoBack = safeCurrentPage > 1;
    final bool canGoForward = safeCurrentPage < totalPages;
    final int windowStart = (safeCurrentPage - 2).clamp(1, totalPages);
    final int windowEnd = (windowStart + 4).clamp(1, totalPages);
    final int adjustedWindowStart = (windowEnd - 4).clamp(1, totalPages);

    List<Widget> pageButtons = [];
    if (adjustedWindowStart > 1) {
      pageButtons.add(_buildPageButton(1, safeCurrentPage));
      if (adjustedWindowStart > 2) {
        pageButtons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text("...", style: Theme.of(context).textTheme.bodyMedium),
          ),
        );
      }
    }

    for (int page = adjustedWindowStart; page <= windowEnd; page++) {
      pageButtons.add(_buildPageButton(page, safeCurrentPage));
    }

    if (windowEnd < totalPages) {
      if (windowEnd < totalPages - 1) {
        pageButtons.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text("...", style: Theme.of(context).textTheme.bodyMedium),
          ),
        );
      }
      pageButtons.add(_buildPageButton(totalPages, safeCurrentPage));
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: UIConstants.smallSpace,
        vertical: UIConstants.smallSpace,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            totalItems == 0
                ? "Showing 0 of 0"
                : "Showing $startItemNumber-$endItemNumber of $totalItems",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: UIConstants.smallSpace),
          Row(
            children: [
              IconButton(
                tooltip: "Previous page",
                onPressed: canGoBack
                    ? () {
                        setState(() {
                          currentPage = safeCurrentPage - 1;
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_left),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: pageButtons),
                ),
              ),
              IconButton(
                tooltip: "Next page",
                onPressed: canGoForward
                    ? () {
                        setState(() {
                          currentPage = safeCurrentPage + 1;
                        });
                      }
                    : null,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPageButton(int page, int safeCurrentPage) {
    final bool selected = page == safeCurrentPage;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: TextButton(
        onPressed: selected
            ? null
            : () {
                setState(() {
                  currentPage = page;
                });
              },
        style: TextButton.styleFrom(
          minimumSize: const Size(42, 36),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          backgroundColor: selected
              ? Colors.amber.withValues(alpha: 0.15)
              : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: selected
                  ? Colors.amber
                  : Colors.grey.withValues(alpha: 0.25),
            ),
          ),
        ),
        child: Text(
          page.toString(),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: selected ? Colors.amber.shade800 : null,
          ),
        ),
      ),
    );
  }

  void _showInfoSnack(String txt) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(txt),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ItemState itemState = context.watch<ItemCubit>().state;
    final List<ItemModel> activeItemList = itemState.activeItemList;
    final List<CategoryModel> allActiveCategoryList =
        itemState.allActiveCategoryList;
    final List<GroupModel> allActiveGroupList = itemState.allActiveGroupList;
    final List<TypeModel> allActiveTypeList = itemState.allActiveTypeList;
    final CusShowSheet cusShowModelBottomSheet = CusShowSheet();
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.select(
      (ThemeCubit cubit) => cubit.state.themeModeType,
    );
    final BusinessType businessType = context.select(
      (ShopInfoCubit cubit) => cubit.state.businessType,
    );

    final List<CategoryModel> categoryOptions = allActiveCategoryList;
    final List<GroupModel> groupOptions = allActiveGroupList;
    final List<TypeModel> typeOptions = allActiveTypeList;

    final ItemCubit itemCubit = context.read<ItemCubit>();
    final detailByItemId = {
      for (final item in activeItemList)
        item.id: itemCubit.getBusinessDetail(item.id),
    };

    final List<String> colorOptions =
        activeItemList
            .map((item) {
              final detail = detailByItemId[item.id];
              if (detail == null) return null;
              if (businessType == BusinessType.clothing) {
                return detail.clothingColor;
              }
              if (businessType == BusinessType.phoneLaptopTablets ||
                  businessType == BusinessType.electronics) {
                return detail.deviceColor;
              }
              return null;
            })
            .whereType<String>()
            .where((c) => c.isNotEmpty)
            .toSet()
            .toList()
          ..sort();

    final List<ItemModel> filteredItems = _buildFilteredItems(
      activeItemList: activeItemList,
      detailByItemId: detailByItemId,
      businessType: businessType,
    );

    final int pageSize = UIConstants.stockOutPageLimit;
    final int totalPages = filteredItems.isEmpty
        ? 1
        : ((filteredItems.length + pageSize - 1) ~/ pageSize);
    final int safeCurrentPage = currentPage.clamp(1, totalPages);

    if (safeCurrentPage != currentPage) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          currentPage = safeCurrentPage;
        });
      });
    }

    final int startIndex = (safeCurrentPage - 1) * pageSize;
    final List<ItemModel> itemsToShow = filteredItems
        .skip(startIndex)
        .take(pageSize)
        .toList();
    final int endIndex = filteredItems.isEmpty
        ? 0
        : (startIndex + itemsToShow.length);

    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.grey, width: 1),
      borderRadius: BorderRadius.circular(50),
    );

    void addSellItemModel() {
      if (mounted) {
        sellItemModelList.clear();
      }
      for (int a = 0; a < sellUniqueItemModelList.length; a++) {
        if (!sellItemModelList
            .map((e) => e.id)
            .contains(sellUniqueItemModelList[a].itemId)) {
          ItemModel? item = context.read<ItemCubit>().getItem(
            sellUniqueItemModelList[a].itemId,
          );
          if (item != null) {
            if (mounted) {
              setState(() {
                sellItemModelList.add(item);
              });
            }
          }
        }
      }
    }

    void addSellUniqueItemList(UniqueItemModel data) {
      final BusinessType businessType = context
          .read<ShopInfoCubit>()
          .state
          .businessType;

      if (CheckoutHelpers.isExpired(data)) {
        _showInfoSnack('This unit is expired and cannot be sold.');
        return;
      }

      if ((businessType == BusinessType.grocery ||
              businessType == BusinessType.basicPharmacy) &&
          CheckoutHelpers.isNearExpiry(data) &&
          data.itemExpireDate != null) {
        _showInfoSnack(
          'Near expiry: ${TextFormatters.getDate(data.itemExpireDate!)}',
        );
      }

      if (mounted) {
        setState(() {
          sellUniqueItemModelList.add(data);
        });
      }

      addSellItemModel();
    }

    void handleBarcodeScan(String rawCode) {
      final String code = rawCode.trim();
      if (code.isEmpty) return;

      final BusinessType businessType = context
          .read<ShopInfoCubit>()
          .state
          .businessType;
      final ItemCubit itemCubit = context.read<ItemCubit>();
      final String query = code.toLowerCase();
      final matchedUnit = itemState.activeUniqueItemList
          .where((unit) => !sellUniqueItemModelList.any((e) => e.id == unit.id))
          .firstWhereOrNull((unit) {
            final unitCode = unit.code?.trim().toLowerCase();
            final batchCode = unit.instanceBatchNumber?.trim().toLowerCase();
            return unitCode == query || batchCode == query;
          });

      if (matchedUnit != null) {
        addSellUniqueItemList(matchedUnit);
        _showInfoSnack(
          'Scanned unit code: ${itemCubit.getItem(matchedUnit.itemId)?.name ?? "item"} added to checkout.',
        );
        barcodeController
          ..text = code
          ..selection = TextSelection.collapsed(offset: code.length);
        barcodeController.clear();
        return;
      }

      final matches = CheckoutHelpers.findItemsByBarcode(code, activeItemList);

      if (matches.isEmpty) {
        _showInfoSnack('No item found for barcode "$code".');
        barcodeController.clear();
        return;
      }

      final ItemModel item = matches.first;
      final available = itemCubit.getSelectedUniqueItemList(item.id);
      final next = item.needStock
          ? CheckoutHelpers.pickNextUnit(
              availableUnits: available,
              cartUnits: sellUniqueItemModelList,
              businessType: businessType,
            )
          : UniqueItemModel(
              id: DateTime.now().microsecondsSinceEpoch * -1,
              itemId: item.id,
              stockInId: 0,
              stockOutId: null,
              createTime: DateTime.now(),
              deleteTime: null,
              itemExpireDate: null,
              itemManufactureDate: null,
              code: item.code ?? '',
              createPersonId: 0,
              deletePersonId: null,
              getItemFromWhere: null,
              lastUpdateTime: null,
              activeStatus: true,
              originalPrice: item.originalPrice,
              profitPrice: item.profitPrice,
              taxPercentage: item.taxPercentage ?? 0,
              moduleCount: null,
            );

      if (next == null) {
        _showInfoSnack('No sellable stock for ${item.name}.');
        barcodeController.clear();
        return;
      }

      addSellUniqueItemList(next);
      _showInfoSnack('Scanned item barcode: ${item.name} added to checkout.');
      barcodeController.clear();
    }

    Future<void> openBarcodeScanner() async {
      final scanned = await Navigator.of(context).push<String>(
        MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
      );
      if (!mounted || scanned == null || scanned.trim().isEmpty) return;
      barcodeController.text = scanned;
      handleBarcodeScan(scanned);
    }

    void removeSellUniqueItemList(ItemModel data) {
      List<UniqueItemModel> dataSelection = [];
      for (int i = 0; i < sellUniqueItemModelList.length; i++) {
        if (data.id == sellUniqueItemModelList[i].itemId) {
          dataSelection.add(sellUniqueItemModelList[i]);
        }
      }

      for (int i = 0; i < sellUniqueItemModelList.length; i++) {
        if (sellUniqueItemModelList[i].id == dataSelection.last.id) {
          if (mounted) {
            setState(() {
              sellUniqueItemModelList.removeAt(i);
            });
          }
        }
      }
      addSellItemModel();
    }

    int getSearchIndex(int itemId) {
      List<UniqueItemModel> dataSelection = [];
      for (int i = 0; i < sellUniqueItemModelList.length; i++) {
        if (itemId == sellUniqueItemModelList[i].itemId) {
          dataSelection.add(sellUniqueItemModelList[i]);
        }
      }
      return dataSelection.length;
    }

    void clearAllData() {
      if (mounted) {
        setState(() {
          showLoading = true;
          searchController.clear();
          selectedCategoryId = null;
          selectedGroupId = null;
          selectedTypeId = null;
          currentPage = 1;
          sellItemModelList.clear();
          sellUniqueItemModelList.clear();
          deliveryCharges = null;
          taxPercentage = 0;
          additionalPromotionAmount = null;
          description = null;
          customerName = null;
          deliveryName = null;
          shoppingType = ShoppingType.shop;
          paymentMethod = PaymentMethod.cash;
          promotion = null;
        });
      }
      Future.delayed(const Duration(seconds: 3), () {
        if (!mounted) return;
        setState(() {
          showLoading = false;
        });
      });
    }

    return Scaffold(
      endDrawer: VoucherScreen(
        customerName: customerName,
        deliveryName: deliveryName,
        shoppingType: shoppingType,
        paymentMethod: paymentMethod,
        additionalPromotionAmount: additionalPromotionAmount,
        deliCharges: deliveryCharges,
        description: description,

        taxPercentage: taxPercentage,
        promotionModel: promotion,
        checkoutTime: checkoutTime,
        selectedUniqueItemList: sellUniqueItemModelList,
        selectedItemModelList: sellItemModelList,
        clearDataFunc: () {
          clearAllData();
        },
      ),

      body: showLoading
          ? const Center(child: LoadingWidget())
          : Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: UIConstants.bigSpace,
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: UIConstants.smallSpace,
                          ),
                          child: TextField(
                            controller: searchController,
                            keyboardType: TextInputType.text,
                            style: Theme.of(context).textTheme.bodyMedium,
                            onChanged: (value) => _setSearchValue(value),
                            decoration: InputDecoration(
                              labelText: _searchHint(businessType),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.grey),
                              filled: false,
                              prefixIcon: const Icon(
                                Icons.search,
                                size: UIConstants.mediumIcon,
                                color: Colors.grey,
                              ),
                              border: outlineInputBorder,
                              focusedBorder: outlineInputBorder,
                              enabledBorder: outlineInputBorder,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: UIConstants.mediumSpace,
                                vertical: UIConstants.smallSpace,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(
                            bottom: UIConstants.smallSpace,
                          ),
                          child: TextField(
                            controller: barcodeController,
                            keyboardType: TextInputType.text,
                            textInputAction: TextInputAction.done,
                            style: Theme.of(context).textTheme.bodyMedium,
                            onSubmitted: handleBarcodeScan,
                            decoration: InputDecoration(
                              labelText: _scanHint(businessType),
                              labelStyle: Theme.of(context)
                                  .textTheme
                                  .bodyMedium!
                                  .copyWith(color: Colors.grey),
                              prefixIcon: const Icon(
                                Icons.qr_code_scanner,
                                size: UIConstants.mediumIcon,
                                color: Colors.grey,
                              ),
                              suffixIcon: IconButton(
                                tooltip: "Open scanner",
                                icon: const Icon(
                                  Icons.qr_code_scanner,
                                  color: Colors.blue,
                                ),
                                onPressed: openBarcodeScanner,
                              ),
                              border: outlineInputBorder,
                              focusedBorder: outlineInputBorder,
                              enabledBorder: outlineInputBorder,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: UIConstants.mediumSpace,
                                vertical: UIConstants.smallSpace,
                              ),
                            ),
                          ),
                        ),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final bool isWide = constraints.maxWidth >= 900;
                            final double filterFontSize = isWide ? 12.5 : 11.0;

                            final categoryLabel =
                                BusinessHierarchyConfig.getLabel(
                                  businessType,
                                  HierarchyLevel.category,
                                );
                            final categoryPluralLabel =
                                BusinessHierarchyConfig.getPluralLabel(
                                  businessType,
                                  HierarchyLevel.category,
                                );
                            final groupLabel = BusinessHierarchyConfig.getLabel(
                              businessType,
                              HierarchyLevel.group,
                            );
                            final groupPluralLabel =
                                BusinessHierarchyConfig.getPluralLabel(
                                  businessType,
                                  HierarchyLevel.group,
                                );
                            final typeLabel = BusinessHierarchyConfig.getLabel(
                              businessType,
                              HierarchyLevel.type,
                            );
                            final typePluralLabel =
                                BusinessHierarchyConfig.getPluralLabel(
                                  businessType,
                                  HierarchyLevel.type,
                                );
                            final showColorFilter =
                                businessType == BusinessType.clothing ||
                                businessType == BusinessType.phoneLaptopTablets;

                            final List<Widget> filterWidgets = [
                              _buildFilterDropdown(
                                label: "$categoryLabel Filter",
                                value: selectedCategoryId,
                                fontSize: filterFontSize,
                                items: [
                                  DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text("All $categoryPluralLabel"),
                                  ),
                                  ...categoryOptions.map(
                                    (category) => DropdownMenuItem<int?>(
                                      value: category.id,
                                      child: Text(category.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedCategoryId = value;
                                    currentPage = 1;
                                  });
                                },
                              ),
                              _buildFilterDropdown(
                                label: "$groupLabel Filter",
                                value: selectedGroupId,
                                fontSize: filterFontSize,
                                items: [
                                  DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text("All $groupPluralLabel"),
                                  ),
                                  ...groupOptions.map(
                                    (group) => DropdownMenuItem<int?>(
                                      value: group.id,
                                      child: Text(group.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedGroupId = value;
                                    currentPage = 1;
                                  });
                                },
                              ),
                              _buildFilterDropdown(
                                label: "$typeLabel Filter",
                                value: selectedTypeId,
                                fontSize: filterFontSize,
                                items: [
                                  DropdownMenuItem<int?>(
                                    value: null,
                                    child: Text("All $typePluralLabel"),
                                  ),
                                  ...typeOptions.map(
                                    (type) => DropdownMenuItem<int?>(
                                      value: type.id,
                                      child: Text(type.name),
                                    ),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    selectedTypeId = value;
                                    currentPage = 1;
                                  });
                                },
                              ),
                            ];

                            if (showColorFilter) {
                              filterWidgets.add(
                                DropdownButtonFormField<String?>(
                                  value: selectedColor,
                                  isExpanded: true,
                                  iconSize: 18,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(fontSize: filterFontSize),
                                  decoration: InputDecoration(
                                    labelText: "Color Filter",
                                    labelStyle: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          fontSize: filterFontSize,
                                          color: Colors.grey,
                                        ),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 8,
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String?>(
                                      value: null,
                                      child: Text("All Colors"),
                                    ),
                                    ...colorOptions.map(
                                      (color) => DropdownMenuItem<String?>(
                                        value: color,
                                        child: Text(color),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedColor = value;
                                      currentPage = 1;
                                    });
                                  },
                                ),
                              );
                            }

                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(child: filterWidgets[0]),
                                    const SizedBox(width: 6),
                                    Expanded(child: filterWidgets[1]),
                                    const SizedBox(width: 6),
                                    Expanded(child: filterWidgets[2]),
                                    if (showColorFilter) ...[
                                      const SizedBox(width: 6),
                                      Expanded(child: filterWidgets[3]),
                                    ],
                                  ],
                                ),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton.icon(
                                    onPressed:
                                        (selectedCategoryId != null ||
                                            selectedGroupId != null ||
                                            selectedTypeId != null ||
                                            selectedColor != null)
                                        ? _clearFilters
                                        : null,
                                    icon: const Icon(Icons.filter_alt_off),
                                    label: const Text("Clear filters"),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        _buildPaginationControls(
                          totalItems: filteredItems.length,
                          totalPages: totalPages,
                          safeCurrentPage: safeCurrentPage,
                          startItemNumber: filteredItems.isEmpty
                              ? 0
                              : startIndex + 1,
                          endItemNumber: endIndex,
                        ),
                        Expanded(
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final double screenWidth = MediaQuery.of(
                                context,
                              ).size.width;
                              final bool isWide = screenWidth >= 900;
                              final double footerReserve =
                                  96 + MediaQuery.of(context).padding.bottom;

                              return Padding(
                                padding: EdgeInsets.only(bottom: footerReserve),
                                child: itemsToShow.isEmpty
                                    ? Center(
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.inventory_2_outlined,
                                              size: 64,
                                              color: Colors.grey.withValues(
                                                alpha: 0.5,
                                              ),
                                            ),
                                            const SizedBox(height: 16),
                                            Text(
                                              _emptyStateMessage(
                                                businessType,
                                                searchController.text
                                                        .trim()
                                                        .isNotEmpty ||
                                                    selectedCategoryId !=
                                                        null ||
                                                    selectedGroupId != null ||
                                                    selectedTypeId != null ||
                                                    selectedColor != null,
                                              ),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .titleMedium
                                                  ?.copyWith(
                                                    color: Colors.grey,
                                                  ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                      )
                                    : LayoutBuilder(
                                        builder: (context, constraints) {
                                          final maxCardWidth =
                                              screenWidth >= 1400
                                              ? 260.0
                                              : isWide
                                              ? 230.0
                                              : 190.0;
                                          const spacing =
                                              UIConstants.mediumSpace;
                                          final contentWidth =
                                              constraints.maxWidth -
                                              UIConstants.smallSpace * 2;
                                          final columnCount =
                                              (contentWidth /
                                                      (maxCardWidth + spacing))
                                                  .ceil()
                                                  .clamp(1, 6);
                                          final cardWidth =
                                              (contentWidth -
                                                  (columnCount - 1) * spacing) /
                                              columnCount;

                                          return SingleChildScrollView(
                                            padding: const EdgeInsets.all(
                                              UIConstants.smallSpace,
                                            ),
                                            physics: const BouncingScrollPhysics(
                                              parent:
                                                  AlwaysScrollableScrollPhysics(),
                                            ),
                                            child: Wrap(
                                              spacing: spacing,
                                              runSpacing: spacing,
                                              children: [
                                                for (
                                                  var index = 0;
                                                  index < itemsToShow.length;
                                                  index++
                                                )
                                                  SizedBox(
                                                    width: cardWidth,
                                                    child: RepaintBoundary(
                                                      child: StockOutItemBoxWidget(
                                                        itemModel:
                                                            itemsToShow[index],
                                                        reduceFunc:
                                                            removeSellUniqueItemList,
                                                        addFunc:
                                                            addSellUniqueItemList,
                                                        selectedUniqueItemList:
                                                            sellUniqueItemModelList,
                                                        startIndex:
                                                            getSearchIndex(
                                                              itemsToShow[index]
                                                                  .id,
                                                            ),
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          );
                                        },
                                      ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.only(
                      left: UIConstants.bigSpace,
                      right: UIConstants.bigSpace,
                      top: UIConstants.mediumSpace,
                      bottom: MediaQuery.of(context).padding.bottom > 0
                          ? MediaQuery.of(context).padding.bottom
                          : UIConstants.mediumSpace,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: CusTxtIconElevatedBtn(
                            txt: "Add Details",
                            verticalpadding: 14,
                            horizontalpadding: UIConstants.smallSpace,
                            bdrRadius: UIConstants.smallRadius,
                            txtClr: Colors.white,
                            bgClr: Colors.amber,
                            txtStyle: Theme.of(context).textTheme.titleSmall!
                                .copyWith(fontWeight: FontWeight.bold),
                            func: () {
                              cusShowModelBottomSheet.showCusBottomSheet(
                                AddMoreInfoStockOutScreen(
                                  func:
                                      ({
                                        required double?
                                        additionalPromotionAmountInfo,
                                        required String? customerNameInfo,
                                        required double? deliveryChargesInfo,
                                        required String? deliveryNameInfo,
                                        required String? descriptionInfo,
                                        required PaymentMethod
                                        paymentMethodInfo,
                                        required ShoppingType shoppingTypeInfo,
                                        required double taxPercentageInfo,
                                        required PromotionModel? promotionModel,
                                        required DateTime checkoutTimeInfo,
                                      }) {
                                        if (mounted) {
                                          setState(() {
                                            additionalPromotionAmount =
                                                additionalPromotionAmountInfo;
                                            customerName = customerNameInfo;
                                            deliveryCharges =
                                                deliveryChargesInfo;
                                            deliveryName = deliveryNameInfo;
                                            description = descriptionInfo;
                                            paymentMethod = paymentMethodInfo;
                                            shoppingType = shoppingTypeInfo;
                                            taxPercentage = taxPercentageInfo;
                                            promotion = promotionModel;
                                            checkoutTime = checkoutTimeInfo;
                                          });
                                        }
                                      },
                                  selectedItemModelList: sellItemModelList,
                                  selectedUniqueItemList:
                                      sellUniqueItemModelList,
                                  deliveryChargesInfo: deliveryCharges,
                                  taxPercentageInfo: taxPercentage,
                                  additionalPromotionAmountInfo:
                                      additionalPromotionAmount,
                                  descriptionInfo: description,
                                  customerNameInfo: customerName,
                                  deliveryNameInfo: deliveryName,
                                  shoppingTypeInfo: shoppingType,
                                  paymentMethodInfo: paymentMethod,
                                  promotionModel: promotion,
                                  checkoutTimeInfo: checkoutTime,
                                ),
                              );
                            },
                            icon: Icons.edit_note,
                            iconSize: 22,
                          ),
                        ),
                        const SizedBox(width: UIConstants.mediumSpace),
                        Expanded(
                          flex: 4,
                          child: Builder(
                            builder: (ctx) {
                              return CusTxtIconElevatedBtn(
                                txt:
                                    "Checkout (${sellUniqueItemModelList.length})",
                                verticalpadding: 14,
                                horizontalpadding: UIConstants.smallSpace,
                                bdrRadius: UIConstants.smallRadius,
                                bgClr: uiController.getpureOppositeClr(
                                  themeModeType,
                                ),
                                txtStyle: Theme.of(context)
                                    .textTheme
                                    .titleSmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                                txtClr: uiController.getpureDirectClr(
                                  themeModeType,
                                ),
                                func: () {
                                  if (sellUniqueItemModelList.isEmpty) {
                                    _showInfoSnack(
                                      "Please add at least one item before checkout.",
                                    );
                                    return;
                                  }
                                  Scaffold.of(ctx).openEndDrawer();
                                },
                                icon: Icons.shopping_cart_checkout,
                                iconSize: 22,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
