import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/features/cus_showmodelbottomsheet.dart";
import "package:pos_mobile/models/item_model_folder/item_model.dart";
import "package:pos_mobile/models/junction_models_folder/promotion_junctions/item_promotion_model.dart";
import "package:pos_mobile/models/promotion_model_folder/promotion_model.dart";
import "package:pos_mobile/screens/transaction/stockIn/item/add_promotion_screen.dart";
import "package:pos_mobile/screens/transaction/stockIn/item/edit_item_screen.dart";
import "package:pos_mobile/screens/transaction/stockIn/uniqueItem/create_unique_stockin_screen.dart";
import "package:pos_mobile/screens/transaction/stockIn/uniqueItem/uniqueitem_screen.dart";

import "../../blocs/loading_bloc/loading_cubit.dart";
import "../../blocs/theme_bloc/theme_cubit.dart";
import "../../blocs/userData_bloc/user_data_cubit.dart";
import "../../constants/enums.dart";
import "../../controller/ui_controller.dart";
import "../../models/user_model_folder/user_model.dart";
import "package:pos_mobile/widgets/business_type_selector.dart";
import '../../screens/confirm_screens_folder/comfirm_screen.dart';
import '../../utils/checkout_helpers.dart';
import "../../utils/formula.dart";
import "../cusPopMenuItem_widget.dart";
import "../item_image_widget.dart";

class ItemBoxWidget extends StatelessWidget {
  final int index;
  final ItemModel itemModel;
  final bool isStorage;
  const ItemBoxWidget({
    super.key,
    required this.index,
    required this.itemModel,
    required this.isStorage,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context
        .watch<ThemeCubit>()
        .state
        .themeModeType;
    final GlobalKey<PopupMenuButtonState> popupMenu =
        GlobalKey<PopupMenuButtonState>();
    final CusShowSheet showSheet = CusShowSheet();
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final itemState = context.read<ItemCubit>().state;
    final int stockCount = context
        .read<ItemCubit>()
        .getSelectedUniqueItemList(itemModel.id)
        .length;
    final bool outOfStock = stockCount <= 0;
    final BusinessType businessType = context
        .watch<ShopInfoCubit>()
        .state
        .businessType;
    final businessDetail = context.read<ItemCubit>().getBusinessDetail(
      itemModel.id,
    );
    final stockUnits = context.read<ItemCubit>().getSelectedUniqueItemList(
      itemModel.id,
    );

    String? findCatalogName<T>(
      Iterable<T> models,
      bool Function(T model) matches,
      String Function(T model) name,
    ) {
      for (final model in models) {
        if (matches(model)) return name(model);
      }
      return null;
    }

    final categoryName = findCatalogName(
      itemState.allActiveCategoryList,
      (category) => category.id == itemModel.categoryId,
      (category) => category.name,
    );
    final groupName = findCatalogName(
      itemState.allActiveGroupList,
      (group) => group.id == itemModel.groupId,
      (group) => group.name,
    );
    final typeName = findCatalogName(
      itemState.allActiveTypeList,
      (type) => type.id == itemModel.typeId,
      (type) => type.name,
    );
    final hierarchyText = [
      if (categoryName != null && categoryName.isNotEmpty) categoryName,
      if (groupName != null && groupName.isNotEmpty) groupName,
      if (typeName != null && typeName.isNotEmpty) typeName,
    ].join('  |  ');

    String costPriceLabel() {
      if (stockUnits.isEmpty) {
        return '${itemModel.originalPrice.toInt()} MMK';
      }

      final costs = stockUnits.map((u) => u.originalPrice).toList();
      final minC = costs.reduce((a, b) => a < b ? a : b);
      final maxC = costs.reduce((a, b) => a > b ? a : b);
      if (minC == maxC) {
        return '${minC.toInt()} MMK';
      }
      return '${minC.toInt()}–${maxC.toInt()} MMK';
    }

    String sellPriceLabel() {
      if (stockUnits.isEmpty) {
        return '${CalculationFormula.getItemSellPrice(originalPrice: itemModel.originalPrice, profitPrice: itemModel.profitPrice, taxPercentage: itemModel.taxPercentage ?? 0).toInt()} MMK';
      }

      final prices = stockUnits
          .map(CheckoutHelpers.uniqueItemSellPrice)
          .toList();
      final minP = prices.reduce((a, b) => a < b ? a : b);
      final maxP = prices.reduce((a, b) => a > b ? a : b);
      if (minP == maxP) {
        return '${minP.toInt()} MMK';
      }
      return '${minP.toInt()}–${maxP.toInt()} MMK';
    }

    return BlocBuilder<PromotionCubit, PromotionState>(
      builder: (context, state) {
        PromotionModel? promotion = context
            .read<PromotionCubit>()
            .getSinglePromotionFromItemId(itemModel.id);
        ItemPromotionModel? itemPromotionModel = context
            .read<PromotionCubit>()
            .getSingleItemPromotionModelFromItemId(itemModel.id);

        return Card(
          elevation: 3,
          shadowColor: Colors.black12,
          shape: const RoundedRectangleBorder(
            borderRadius: UIConstants.mediumBorderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onLongPress: () => popupMenu.currentState?.showButtonMenu(),
            onTap: () {
              // Show menu on tap for better mobile UX instead of just long press
              popupMenu.currentState?.showButtonMenu();
            },
            child: Stack(
              children: [
                // Hidden PopupMenuButton
                Positioned.fill(
                  child: PopupMenuButton(
                    key: popupMenu,
                    tooltip: "Options",
                    child: const SizedBox.shrink(),
                    itemBuilder: (BuildContext context) {
                      return [
                        if (itemModel.needStock)
                          cusPopUpMenuItem(
                            func: () {
                              showSheet.showCusBottomSheet(
                                CreateUniqueStockInScreen(
                                  itemModel: itemModel,
                                  batchStockIn: true,
                                ),
                              );
                            },
                            txt: "Batch Stock-In",
                            context: context,
                            isImportant: false,
                          ),
                        // cusPopUpMenuItem(
                        //   func: (){
                        //     showSheet.showCusBottomSheet(CreateUniqueStockInScreen(itemModel: itemModel, batchStockIn: false));
                        //   },
                        //   txt: "Single Stock-In",
                        //   context : context,
                        //   isImportant: false,
                        // ),
                        if (userModel != null &&
                            userModel.userLevel == UserLevel.merchant &&
                            isStorage == true)
                          cusPopUpMenuItem(
                            func: () {
                              Navigator.of(context).pushNamed(
                                UniqueItemScreen.routeName,
                                arguments: {"item": itemModel.toJson()},
                              );
                            },
                            txt: "Reduce Stock",
                            isImportant: true,
                            context: context,
                          ),
                        if (userModel != null &&
                            userModel.userLevel == UserLevel.merchant &&
                            isStorage == true)
                          cusPopUpMenuItem(
                            func: () {
                              showSheet.showCusBottomSheet(
                                EditItemScreen(itemModel: itemModel),
                              );
                            },
                            txt: "Edit",
                            context: context,
                            isImportant: false,
                          ),
                        if (userModel != null &&
                            userModel.userLevel == UserLevel.merchant &&
                            isStorage == true)
                          cusPopUpMenuItem(
                            func: () {
                              showSheet.showCusDialogScreen(
                                ConfirmScreen(
                                  txt: "Are you sure want to delete this item?",
                                  title: "Delete",
                                  acceptBtnTxt: "Yes, delete",
                                  cancelBtnTxt: "Cancel",
                                  acceptFunc: () async {
                                    context.read<LoadingCubit>().setLoading(
                                      "Deleting ...",
                                    );
                                    final value = await context
                                        .read<ItemCubit>()
                                        .deleteItem(userModel, itemModel);
                                    if (!context.mounted) return;
                                    Navigator.of(context).pop();
                                    if (value) {
                                      context.read<LoadingCubit>().setSuccess(
                                        "Success !",
                                      );
                                    } else {
                                      context.read<LoadingCubit>().setFail(
                                        "Cannot delete",
                                      );
                                    }
                                  },
                                  cancelFunc: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              );
                            },
                            txt: "Delete",
                            context: context,
                            isImportant: true,
                          ),
                        if (userModel != null &&
                            userModel.userLevel == UserLevel.merchant &&
                            isStorage == true)
                          cusPopUpMenuItem(
                            func: () {
                              if (promotion == null) {
                                showSheet.showCusBottomSheet(
                                  AddPromotionToItemScreen(
                                    itemModel: itemModel,
                                  ),
                                );
                              } else {
                                showSheet.showCusDialogScreen(
                                  ConfirmScreen(
                                    txt:
                                        "Are you sure want to remove promotion from this item?",
                                    title: "Remove promotion",
                                    acceptBtnTxt: "Yes, remove",
                                    cancelBtnTxt: "Cancel",
                                    acceptFunc: () async {
                                      context.read<LoadingCubit>().setLoading(
                                        "Removing ...",
                                      );
                                      final value = await context
                                          .read<PromotionCubit>()
                                          .detachItemWithPromotion(
                                            userModel: userModel,
                                            itemPromotionList: [
                                              itemPromotionModel!,
                                            ],
                                          );
                                      if (!context.mounted) return;
                                      Navigator.of(context).pop();
                                      if (value) {
                                        context.read<LoadingCubit>().setSuccess(
                                          "Success !",
                                        );
                                      } else {
                                        context.read<LoadingCubit>().setFail(
                                          "Cannot Remove",
                                        );
                                      }
                                    },
                                    cancelFunc: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                );
                              }
                            },
                            txt: promotion == null
                                ? "Add promotion"
                                : "Remove Promotion",
                            context: context,
                            isImportant: true,
                          ),
                      ];
                    },
                  ),
                ),

                // Visual Card Content
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Area (Icon and Badges)
                    SizedBox(
                      height: 112,
                      child: Container(
                        color: Colors.grey.withValues(alpha: 0.05),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            ItemImageWidget(imageId: itemModel.imageId),
                            // Stock Count Badge
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: outOfStock
                                      ? UIConstants.redVioletClr
                                      : Colors.grey[700],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  !itemModel.needStock
                                      ? "Made to Order"
                                      : outOfStock
                                      ? "Out of Stock"
                                      : "$stockCount in Stock",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            // Promotion Badge
                            if (promotion != null)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "PROMO",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 8,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Details Area
                    Container(
                      padding: const EdgeInsets.all(8),
                      color: uiController.getpureDirectClr(themeModeType),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            itemModel.name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall!
                                .copyWith(
                                  fontWeight: FontWeight.bold,
                                  height: 1.2,
                                ),
                          ),
                          if (hierarchyText.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                hierarchyText,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          if (itemModel.description?.trim().isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                itemModel.description!.trim(),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                            ),
                          BusinessItemDetailChips(
                            businessType: businessType,
                            detail: businessDetail,
                            maxLines: 2,
                          ),

                          if (itemModel.code?.trim().isNotEmpty == true)
                            Padding(
                              padding: const EdgeInsets.only(top: 3),
                              child: Text(
                                'Barcode: ${itemModel.code!.trim()}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: Colors.green[700]),
                              ),
                            ),

                          // Prices based on user level
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (userModel?.userLevel == UserLevel.merchant &&
                                  isStorage) ...[
                                Text(
                                  "Cost: ${costPriceLabel()}",
                                  style: Theme.of(context).textTheme.bodySmall!
                                      .copyWith(color: Colors.grey[600]),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                sellPriceLabel(),
                                style: Theme.of(context).textTheme.titleSmall!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
