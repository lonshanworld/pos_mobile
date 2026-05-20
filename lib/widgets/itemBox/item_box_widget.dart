import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
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
import '../../screens/confirm_screens_folder/comfirm_screen.dart';
import "../../utils/formula.dart";
import "../cusPopMenuItem_widget.dart";

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
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final GlobalKey<PopupMenuButtonState> popupMenu = GlobalKey<PopupMenuButtonState>();
    final CusShowSheet showSheet = CusShowSheet();
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final int stockCount = context.read<ItemCubit>().getSelectedUniqueItemList(itemModel.id).length;
    final bool outOfStock = stockCount <= 0;

    return BlocBuilder<PromotionCubit, PromotionState>(
      builder: (context, state) {
        PromotionModel? promotion = context.read<PromotionCubit>().getSinglePromotionFromItemId(itemModel.id);
        ItemPromotionModel? itemPromotionModel = context.read<PromotionCubit>().getSingleItemPromotionModelFromItemId(itemModel.id);

        return Card(
          elevation: 3,
          shadowColor: Colors.black12,
          shape: RoundedRectangleBorder(borderRadius: UIConstants.mediumBorderRadius),
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
                        cusPopUpMenuItem(
                          func: (){
                            showSheet.showCusBottomSheet(CreateUniqueStockInScreen(itemModel: itemModel, batchStockIn: true));
                          },
                          txt: "Batch Stock-In",
                          context : context,
                          isImportant: false,
                        ),
                        cusPopUpMenuItem(
                          func: (){
                            showSheet.showCusBottomSheet(CreateUniqueStockInScreen(itemModel: itemModel, batchStockIn: false));
                          },
                          txt: "Single Stock-In",
                          context : context,
                          isImportant: false,
                        ),
                        if(userModel != null && userModel.userLevel == UserLevel.merchant && isStorage == true)cusPopUpMenuItem(
                          func: (){
                            Navigator.of(context).pushNamed(
                              UniqueItemScreen.routeName,
                              arguments: {
                                "item" : itemModel.toJson()
                              }
                            );
                          },
                          txt: "Reduce Stock",
                          isImportant: true,
                          context: context,
                        ),
                        if(userModel != null && userModel.userLevel == UserLevel.merchant && isStorage == true)cusPopUpMenuItem(
                          func: (){
                            showSheet.showCusBottomSheet(EditItemScreen(itemModel: itemModel));
                          },
                          txt: "Edit",
                          context: context,
                          isImportant: false,
                        ),
                        if(userModel != null && userModel.userLevel == UserLevel.merchant && isStorage == true)cusPopUpMenuItem(
                          func: (){
                            showSheet.showCusDialogScreen(ConfirmScreen(
                              txt: "Are you sure want to delete this item?",
                              title: "Delete",
                              acceptBtnTxt: "Yes, delete",
                              cancelBtnTxt: "Cancel",
                              acceptFunc: ()async{
                                context.read<LoadingCubit>().setLoading("Deleting ...");
                                final value = await context.read<ItemCubit>().deleteItem(userModel, itemModel);
                                if (!context.mounted) return;
                                Navigator.of(context).pop();
                                if(value){
                                  context.read<LoadingCubit>().setSuccess("Success !");
                                }else{
                                  context.read<LoadingCubit>().setFail("Cannot delete");
                                }
                              },
                              cancelFunc: (){
                                Navigator.of(context).pop();
                              },
                            ));
                          },
                          txt: "Delete",
                          context: context,
                          isImportant: true,
                        ),
                        if(userModel != null && userModel.userLevel == UserLevel.merchant && isStorage == true)cusPopUpMenuItem(
                          func: (){
                            if(promotion == null){
                              showSheet.showCusBottomSheet(AddPromotionToItemScreen(itemModel: itemModel));
                            }else{
                              showSheet.showCusDialogScreen(ConfirmScreen(
                                txt: "Are you sure want to remove promotion from this item?",
                                title: "Remove promotion",
                                acceptBtnTxt: "Yes, remove",
                                cancelBtnTxt: "Cancel",
                                acceptFunc: ()async{
                                  context.read<LoadingCubit>().setLoading("Removing ...");
                                  final value = await context.read<PromotionCubit>().detachItemWithPromotion(
                                    userModel: userModel,
                                    itemPromotionList: [itemPromotionModel!],
                                  );
                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                  if(value){
                                    context.read<LoadingCubit>().setSuccess("Success !");
                                  }else{
                                    context.read<LoadingCubit>().setFail("Cannot Remove");
                                  }
                                },
                                cancelFunc: (){
                                  Navigator.of(context).pop();
                                },
                              ));
                            }
                          },
                          txt: promotion == null ? "Add promotion" : "Remove Promotion",
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
                    Expanded(
                      flex: 4,
                      child: Container(
                        color: Colors.grey.withValues(alpha: 0.05),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            Center(
                              child: Icon(
                                Icons.inventory_2_rounded,
                                size: 40,
                                color: Colors.grey.withValues(alpha: 0.25),
                              ),
                            ),
                            // Stock Count Badge
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: outOfStock ? UIConstants.redVioletClr : Colors.grey[700],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  outOfStock ? "Out of Stock" : "$stockCount in Stock",
                                  style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            // Promotion Badge
                            if (promotion != null)
                              Positioned(
                                top: 8,
                                left: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    "PROMO",
                                    style: TextStyle(color: Colors.black, fontSize: 8, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    
                    // Details Area
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        color: uiController.getpureDirectClr(themeModeType),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Title
                            Text(
                              itemModel.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                fontWeight: FontWeight.bold,
                                height: 1.2,
                              ),
                            ),
                            
                            // Prices based on user level
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (userModel?.userLevel == UserLevel.merchant && isStorage) ...[
                                  Text(
                                    "Cost: ${itemModel.originalPrice} MMK",
                                    style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 2),
                                ],
                                Text(
                                  "${CalculationFormula.getItemSellPrice(originalPrice: itemModel.originalPrice, profitPrice: itemModel.profitPrice, taxPercentage: itemModel.taxPercentage ?? 0).toInt()} MMK",
                                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
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