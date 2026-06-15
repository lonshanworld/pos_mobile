import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/screens/transaction/stockOut/voucher_screen.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtIconBtn_widget.dart';
import 'package:pos_mobile/widgets/itemBox/stockout_item_box_widget.dart';

import '../../../blocs/theme_bloc/theme_cubit.dart';
import '../../../constants/enums.dart';
import '../../../constants/uiConstants.dart';
import '../../../controller/ui_controller.dart';
import '../../../features/cus_showmodelbottomsheet.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';
import '../../../widgets/loading_widget.dart';
import 'add_more_info_stockOut_screen.dart';


class StockOutScreen extends StatefulWidget {
  static const String routeName = "/stockoutscreen";

  const StockOutScreen({super.key});

  @override
  State<StockOutScreen> createState() => _StockOutScreenState();
}

class _StockOutScreenState extends State<StockOutScreen> {
  final TextEditingController searchController = TextEditingController();
  int? selectedCategoryId;
  int? selectedGroupId;
  int? selectedTypeId;
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

  @override
  void dispose() {
    searchController.dispose();
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
      currentPage = 1;
    });
  }

  List<ItemModel> _buildFilteredItems({
    required List<ItemModel> activeItemList,
    required List<CategoryModel> categoryList,
    required List<GroupModel> groupList,
    required List<TypeModel> typeList,
  }) {
    final String query = searchController.text.trim().toLowerCase();
    final Map<int, CategoryModel> categoryById = {
      for (final category in categoryList) category.id: category,
    };
    final Map<int, GroupModel> groupById = {
      for (final group in groupList) group.id: group,
    };
    final Map<int, TypeModel> typeById = {
      for (final type in typeList) type.id: type,
    };

    return activeItemList.where((item) {
      if (query.isNotEmpty && !item.name.toLowerCase().contains(query)) {
        return false;
      }

      final TypeModel? typeModel = typeById[item.typeId];
      final GroupModel? groupModel = typeModel == null ? null : groupById[typeModel.groupId];
      final CategoryModel? categoryModel = groupModel == null ? null : categoryById[groupModel.categoryId];

      if (selectedCategoryId != null && categoryModel?.id != selectedCategoryId) {
        return false;
      }

      if (selectedGroupId != null && groupModel?.id != selectedGroupId) {
        return false;
      }

      if (selectedTypeId != null && typeModel?.id != selectedTypeId) {
        return false;
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
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: fontSize,
          ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: fontSize,
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
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
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
          backgroundColor: selected ? Colors.amber.withValues(alpha: 0.15) : null,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: selected ? Colors.amber : Colors.grey.withValues(alpha: 0.25),
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

  @override
  Widget build(BuildContext context) {
    final ItemState itemState = context.watch<ItemCubit>().state;
    final List<ItemModel> activeItemList = itemState.activeItemList;
    final List<CategoryModel> allActiveCategoryList = itemState.allActiveCategoryList;
    final List<GroupModel> allActiveGroupList = itemState.allActiveGroupList;
    final List<TypeModel> allActiveTypeList = itemState.allActiveTypeList;
    final CusShowSheet cusShowModelBottomSheet = CusShowSheet();
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.select((ThemeCubit cubit) => cubit.state.themeModeType);

    final List<CategoryModel> categoryOptions = allActiveCategoryList;
    final List<GroupModel> groupOptions = selectedCategoryId == null
        ? allActiveGroupList
        : allActiveGroupList
            .where((group) => group.categoryId == selectedCategoryId)
            .toList();
    final List<TypeModel> typeOptions = selectedGroupId == null
        ? allActiveTypeList
        : allActiveTypeList
            .where((type) => type.groupId == selectedGroupId)
            .toList();

    final List<ItemModel> filteredItems = _buildFilteredItems(
      activeItemList: activeItemList,
      categoryList: allActiveCategoryList,
      groupList: allActiveGroupList,
      typeList: allActiveTypeList,
    );

    final int pageSize = UIConstants.stockOutPageLimit;
    final int totalPages = filteredItems.isEmpty ? 1 : ((filteredItems.length + pageSize - 1) ~/ pageSize);
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
    final List<ItemModel> itemsToShow = filteredItems.skip(startIndex).take(pageSize).toList();
    final int endIndex = filteredItems.isEmpty ? 0 : (startIndex + itemsToShow.length);


    OutlineInputBorder outlineInputBorder = OutlineInputBorder(
      borderSide: const BorderSide(
        color: Colors.grey,
        width: 1,
      ),
      borderRadius: BorderRadius.circular(50),
    );

    void addSellItemModel(){
      if(mounted){
        sellItemModelList.clear();
      }
      for(int a = 0; a < sellUniqueItemModelList.length; a++){
        if(!sellItemModelList.map((e) => e.id).contains(sellUniqueItemModelList[a].itemId)){
          ItemModel? item = context.read<ItemCubit>().getItem(sellUniqueItemModelList[a].itemId);
          if(item != null){
            if(mounted){
              setState(() {
                sellItemModelList.add(item);
              });
            }
          }
        }
      }
    }

    void addSellUniqueItemList(UniqueItemModel data){
      if(mounted){
        setState(() {
          sellUniqueItemModelList.add(data);
        });
      }

      addSellItemModel();
    }

    void removeSellUniqueItemList(ItemModel data){
      List<UniqueItemModel> dataSelection = [];
      for(int i = 0; i < sellUniqueItemModelList.length; i++){
        if(data.id == sellUniqueItemModelList[i].itemId){
          dataSelection.add(sellUniqueItemModelList[i]);
        }
      }

      for(int i = 0; i < sellUniqueItemModelList.length; i++){
        if(sellUniqueItemModelList[i].id == dataSelection.last.id){
          if(mounted){
            setState(() {
              sellUniqueItemModelList.removeAt(i);
            });
          }
        }
      }
      addSellItemModel();
    }

  
    int getSearchIndex(int itemId){
      List<UniqueItemModel> dataSelection = [];
      for(int i = 0; i < sellUniqueItemModelList.length; i++){
        if(itemId == sellUniqueItemModelList[i].itemId){
          dataSelection.add(sellUniqueItemModelList[i]);
        }
      }
      return dataSelection.length;
    }

    void showInfoSnack(String txt) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(txt),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
    }

    void clearAllData(){
      if(mounted){
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
      Future.delayed(const Duration(seconds: 3),(){
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
        selectedUniqueItemList: sellUniqueItemModelList,
        selectedItemModelList: sellItemModelList,
        clearDataFunc: (){
          clearAllData();
        },
      ),

      body: showLoading
          ?
      const Center(
        child: LoadingWidget(),
      )
          :
      Stack(
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
                        vertical: UIConstants.smallSpace
                    ),
                    child: TextField(
                      controller: searchController,
                      keyboardType: TextInputType.text,
                      style: Theme.of(context).textTheme.bodyMedium,
                      onChanged: (value) => _setSearchValue(value),
                      decoration: InputDecoration(
                          labelText: "Search Items ...",
                          labelStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Colors.grey,
                          ),
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
                          )
                      ),
                    ),
                  ),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final bool isWide = constraints.maxWidth >= 900;
                      final double filterFontSize = isWide ? 12.5 : 11.0;
                      final List<Widget> filterWidgets = [
                        _buildFilterDropdown(
                          label: "Category Filter",
                          value: selectedCategoryId,
                          fontSize: filterFontSize,
                          items: [
                            const DropdownMenuItem<int?>(  
                              value: null,
                              child: Text("All Categories"),
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
                              selectedGroupId = null;
                              selectedTypeId = null;
                              currentPage = 1;
                            });
                          },
                        ),
                        _buildFilterDropdown(
                          label: "Group Filter",
                          value: selectedGroupId,
                          fontSize: filterFontSize,
                          items: [
                            const DropdownMenuItem<int?>(  
                              value: null,
                              child: Text("All Groups"),
                            ),
                            ...groupOptions.map(
                              (group) => DropdownMenuItem<int?>(
                                value: group.id,
                                child: Text(group.name),
                              ),
                            ),
                          ],
                          onChanged: (value) async {
                            setState(() {
                              selectedGroupId = value;
                              selectedTypeId = null;
                              currentPage = 1;
                            });

                            if (value == null) {
                              return;
                            }

                            try {
                              final GroupModel? groupModel = await DBHelper.getGroupById(value);
                              if (!mounted) return;
                              if (groupModel == null) {
                                debugPrint('StockOutScreen: selected group not found in DB for id=$value');
                                return;
                              }
                              setState(() {
                                selectedCategoryId = groupModel.categoryId;
                              });
                            } catch (err, st) {
                              debugPrint('StockOutScreen: failed to resolve group filter for id=$value');
                              debugPrint(err.toString());
                              debugPrint(st.toString());
                            }
                          },
                        ),
                        _buildFilterDropdown(
                          label: "Type Filter",
                          value: selectedTypeId,
                          fontSize: filterFontSize,
                          items: [
                            const DropdownMenuItem<int?>(  
                              value: null,
                              child: Text("All Types"),
                            ),
                            ...typeOptions.map(
                              (type) => DropdownMenuItem<int?>(
                                value: type.id,
                                child: Text(type.name),
                              ),
                            ),
                          ],
                          onChanged: (value) async {
                            setState(() {
                              selectedTypeId = value;
                              currentPage = 1;
                            });

                            if (value == null) {
                              return;
                            }

                            try {
                              final TypeModel? typeModel = await DBHelper.getTypeById(value);
                              if (!mounted) return;
                              if (typeModel == null) {
                                debugPrint('StockOutScreen: selected type not found in DB for id=$value');
                                return;
                              }

                              final GroupModel? groupModel = await DBHelper.getGroupById(typeModel.groupId);
                              if (!mounted) return;
                              if (groupModel == null) {
                                debugPrint('StockOutScreen: selected type has missing group in DB for groupId=${typeModel.groupId}');
                                return;
                              }

                              setState(() {
                                selectedGroupId = typeModel.groupId;
                                selectedCategoryId = groupModel.categoryId;
                              });
                            } catch (err, st) {
                              debugPrint('StockOutScreen: failed to resolve type filter for id=$value');
                              debugPrint(err.toString());
                              debugPrint(st.toString());
                            }
                          },
                        ),
                      ];

                      return Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: filterWidgets[0]),
                              const SizedBox(width: 6),
                              Expanded(child: filterWidgets[1]),
                              const SizedBox(width: 6),
                              Expanded(child: filterWidgets[2]),
                            ],
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: (selectedCategoryId != null || selectedGroupId != null || selectedTypeId != null)
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
                    startItemNumber: filteredItems.isEmpty ? 0 : startIndex + 1,
                    endItemNumber: endIndex,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final double screenWidth = MediaQuery.of(context).size.width;
                        final bool isWide = screenWidth >= 900;
                        final double footerReserve = 96 + MediaQuery.of(context).padding.bottom;

                        return Padding(
                          padding: EdgeInsets.only(bottom: footerReserve),
                          child: itemsToShow.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.withValues(alpha: 0.5)),
                                      const SizedBox(height: 16),
                                      Text(
                                        searchController.text.trim().isNotEmpty || selectedCategoryId != null || selectedGroupId != null || selectedTypeId != null
                                            ? "No items match the current search and filters"
                                            : "No items available",
                                        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              : GridView.builder(
                                  padding: const EdgeInsets.all(UIConstants.smallSpace),
                                  physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: screenWidth >= 1400
                                        ? 260
                                        : isWide
                                            ? 230
                                            : 190,
                                    childAspectRatio: 1,
                                    crossAxisSpacing: UIConstants.mediumSpace,
                                    mainAxisSpacing: UIConstants.mediumSpace,
                                  ),
                                  itemCount: itemsToShow.length,
                                  itemBuilder: (context, index) {
                                    final item = itemsToShow[index];
                                    return RepaintBoundary(
                                      child: StockOutItemBoxWidget(
                                        itemModel: item,
                                        reduceFunc: removeSellUniqueItemList,
                                        addFunc: addSellUniqueItemList,
                                        selectedUniqueItemList: sellUniqueItemModelList,
                                        startIndex: getSearchIndex(item.id),
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
                      txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      func: () {
                        cusShowModelBottomSheet.showCusBottomSheet(AddMoreInfoStockOutScreen(
                          func: ({
                            required double? additionalPromotionAmountInfo,
                            required String? customerNameInfo,
                            required double? deliveryChargesInfo,
                            required String? deliveryNameInfo,
                            required String? descriptionInfo,
                            required PaymentMethod paymentMethodInfo,
                            required ShoppingType shoppingTypeInfo,
                            required double taxPercentageInfo,
                            required PromotionModel? promotionModel,
                          }) {
                            if (mounted) {
                              setState(() {
                                additionalPromotionAmount = additionalPromotionAmountInfo;
                                customerName = customerNameInfo;
                                deliveryCharges = deliveryChargesInfo;
                                deliveryName = deliveryNameInfo;
                                description = descriptionInfo;
                                paymentMethod = paymentMethodInfo;
                                shoppingType = shoppingTypeInfo;
                                taxPercentage = taxPercentageInfo;
                                promotion = promotionModel;
                              });
                            }
                          },
                          selectedItemModelList: sellItemModelList,
                          selectedUniqueItemList: sellUniqueItemModelList,
                          deliveryChargesInfo: deliveryCharges,
                          taxPercentageInfo: taxPercentage,
                          additionalPromotionAmountInfo: additionalPromotionAmount,
                          descriptionInfo: description,
                          customerNameInfo: customerName,
                          deliveryNameInfo: deliveryName,
                          shoppingTypeInfo: shoppingType,
                          paymentMethodInfo: paymentMethod,
                          promotionModel: promotion,
                        ));
                      },
                      icon: Icons.edit_note,
                      iconSize: 22,
                    ),
                  ),
                  const SizedBox(width: UIConstants.mediumSpace),
                  Expanded(
                    flex: 4,
                    child: Builder(builder: (ctx) {
                      return CusTxtIconElevatedBtn(
                        txt: "Checkout (${sellUniqueItemModelList.length})",
                        verticalpadding: 14,
                        horizontalpadding: UIConstants.smallSpace,
                        bdrRadius: UIConstants.smallRadius,
                        bgClr: uiController.getpureOppositeClr(themeModeType),
                        txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        txtClr: uiController.getpureDirectClr(themeModeType),
                        func: () {
                          if (sellUniqueItemModelList.isEmpty) {
                            showInfoSnack("Please add at least one item before checkout.");
                            return;
                          }
                          Scaffold.of(ctx).openEndDrawer();
                        },
                        icon: Icons.shopping_cart_checkout,
                        iconSize: 22,
                      );
                    }),
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
