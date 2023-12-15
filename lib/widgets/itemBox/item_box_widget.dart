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
import "package:pos_mobile/utils/txt_formatters.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/index_box_widget.dart";

import "../../blocs/loading_bloc/loading_cubit.dart";
import "../../blocs/theme_bloc/theme_cubit.dart";
import "../../blocs/userData_bloc/user_data_cubit.dart";
import "../../constants/enums.dart";
import "../../controller/ui_controller.dart";
import "../../models/user_model_folder/user_model.dart";
import '../../screens/confirm_screens_folder/comfirm_screen.dart';
import "../../utils/formula.dart";
import "../cusPopMenuItem_widget.dart";
import "../promotion/promotion_with_item_widget.dart";

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

    Widget showPrice(String txt1, String txt2){
      return Row(
        children: [
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: Colors.grey,
            ),
            txt: txt1,
          ),
          CusTxtWidget(
            txtStyle: Theme.of(context).textTheme.titleSmall!,
            txt: txt2,
          ),
        ],
      );
    }

    return BlocBuilder<PromotionCubit, PromotionState>(
      builder: (context, state) {
        PromotionModel? promotion = context.read<PromotionCubit>().getSinglePromotionFromItemId(itemModel.id);
        ItemPromotionModel? itemPromotionModel = context.read<PromotionCubit>().getSingleItemPromotionModelFromItemId(itemModel.id);

        return SizedBox(
          width: UIConstants.itemBoxWidth,
          height: UIConstants.itemBoxHeight,
          child: PopupMenuButton(
            key: popupMenu,
            tooltip: itemModel.lastUpdateTime == null ? TextFormatters.getDateTime(itemModel.createTime) : TextFormatters.getDateTime(itemModel.lastUpdateTime),

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
                if(userModel != null && userModel.userLevel == UserLevel.admin && isStorage == true)cusPopUpMenuItem(
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
                if(userModel != null && userModel.userLevel == UserLevel.admin && isStorage == true)cusPopUpMenuItem(
                  func: (){
                    showSheet.showCusBottomSheet(EditItemScreen(itemModel: itemModel));
                  },
                  txt: "Edit",
                  context: context,
                  isImportant: false,
                ),
                if(userModel != null && userModel.userLevel == UserLevel.admin && isStorage == true)cusPopUpMenuItem(
                  func: (){
                    showSheet.showCusDialogScreen(ConfirmScreen(
                      txt: "Are you sure want to delete this item?",
                      title: "Delete",
                      acceptBtnTxt: "Yes, delete",
                      cancelBtnTxt: "Cancel",
                      acceptFunc: ()async{
                        context.read<LoadingCubit>().setLoading("Deleting ...");
                        await context.read<ItemCubit>().deleteItem(userModel, itemModel).then((value){
                          Navigator.of(context).pop();
                          if(value){
                            context.read<LoadingCubit>().setSuccess("Success !");
                          }else{
                            context.read<LoadingCubit>().setFail("Cannot delete");
                          }
                        });

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
                if(userModel != null && userModel.userLevel == UserLevel.admin && isStorage == true)cusPopUpMenuItem(
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
                          await context.read<PromotionCubit>().detachItemWithPromotion(userModel: userModel, itemPromotionList: [itemPromotionModel!]).then((value){
                            Navigator.of(context).pop();
                            if(value){
                              context.read<LoadingCubit>().setSuccess("Success !");
                            }else{
                              context.read<LoadingCubit>().setFail("Cannot Remove");
                            }
                          });
                        },
                        cancelFunc: (){
                          Navigator.of(context).pop();
                        },
                      ));
                    }
                  },
                  txt: context.read<PromotionCubit>().getSinglePromotionFromItemId(itemModel.id) == null ? "Add promotion" : "Remove Promotion",
                  context: context,
                  isImportant: true,
                ),
              ];
            },
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 5,
                foregroundColor: Colors.grey,
                backgroundColor: uiController.getpureDirectClr(themeModeType),
                surfaceTintColor: uiController.getpureDirectClr(themeModeType),
                minimumSize: const Size(0, 0),
                padding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(UIConstants.smallRadius)
                  ),
                ),
              ),
              onLongPress: (){
                popupMenu.currentState?.showButtonMenu();
              },
              onPressed: null,
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  SizedBox(
                    width: 70,
                    height: 80,
                    child: Stack(
                      children: [
                        const Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Material(
                            borderRadius: BorderRadius.all(
                              Radius.circular(UIConstants.smallRadius)
                            ),
                            color: Colors.transparent,
                            child: Image(
                              width: 70,
                              height: 70,
                              fit: BoxFit.contain,
                              image: AssetImage(
                                "assets/images/IMG_20230921_195426.png"
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: IndexBoxWidget(index: index.toString()),
                        ),
                      ],
                    ),
                  ),
                  if(userModel != null)Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        CusTxtWidget(
                          txtStyle: Theme.of(context).textTheme.titleSmall!,
                          txt: itemModel.name,
                        ),
                        // if(userModel!.userLevel != UserLevel.admin)Row(
                        //   children: [
                        //     CusTxtWidget(
                        //       txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        //         color: Colors.grey,
                        //       ),
                        //       txt: "Price - ",
                        //     ),
                        //     CusTxtWidget(
                        //       txtStyle: Theme.of(context).textTheme.titleSmall!,
                        //       txt: CalculationFormula.getItemSellPrice(originalPrice: itemModel.originalPrice, profitPrice: itemModel.profitPrice, taxPercentage: itemModel.taxPercentage ?? 0).toInt().toString(),
                        //     ),
                        //   ],
                        // ),
                        if( userModel.userLevel != UserLevel.admin && !isStorage)showPrice(
                          "Price - ",
                          CalculationFormula.getItemSellPrice(originalPrice: itemModel.originalPrice, profitPrice: itemModel.profitPrice, taxPercentage: itemModel.taxPercentage ?? 0).toInt().toString(),
                        ),
                        if(userModel.userLevel == UserLevel.admin && isStorage)showPrice(
                          "Org Price - ",
                          itemModel.originalPrice.toString(),
                        ),
                        if(userModel.userLevel == UserLevel.admin && isStorage)showPrice(
                          "Sell Price - ",
                          CalculationFormula.getItemSellPrice(originalPrice: itemModel.originalPrice, profitPrice: itemModel.profitPrice, taxPercentage: itemModel.taxPercentage ?? 0).toInt().toString(),
                        ),
                        if(itemModel.hasExpire)Row(
                          children: [
                            CusTxtWidget(
                              txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Colors.green.withOpacity(0.6),
                              ),
                              txt: "Has Expire - ",
                            ),
                            const Icon(
                              Icons.check,
                              color: Colors.green,
                              size: UIConstants.normalsmallIconSize,
                            ),
                          ],
                        ),
                        if(promotion != null)PromotionWithItemWidget(promotion: promotion)
                      ],
                    ),
                  ),
                  Container(
                    width: 35,
                    height: UIConstants.itemBoxHeight,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.only(
                        topRight:Radius.circular(UIConstants.smallRadius),
                        bottomRight: Radius.circular(UIConstants.smallRadius),
                      )
                    ),
                    child: Center(
                      child: RotatedBox(
                        quarterTurns: 3,
                        child: CusTxtWidget(
                          txt: context.read<ItemCubit>().getSelectedUniqueItemList(itemModel.id).length.toString(),
                          txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
