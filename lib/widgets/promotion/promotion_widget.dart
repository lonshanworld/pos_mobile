import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import 'package:pos_mobile/features/cus_showmodelbottomsheet.dart';
import 'package:pos_mobile/models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import "package:pos_mobile/utils/txt_formatters.dart";
import "package:pos_mobile/utils/ui_responsive_calculation.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/index_box_widget.dart";

import '../../blocs/loading_bloc/loading_cubit.dart';
import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';
import '../../models/promotion_model_folder/promotion_model.dart';
import '../../models/user_model_folder/user_model.dart';
import '../../screens/confirm_screens_folder/comfirm_screen.dart';
import '../cusPopMenuItem_widget.dart';

class PromotionWidget extends StatelessWidget {

  final PromotionModel promotionModel;
  final int index;
  const PromotionWidget({
    super.key,
    required this.promotionModel,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UIController uiController = UIController.instance;
    final UIutils uIutils = UIutils();
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final CusShowSheet showSheet = CusShowSheet();

    return PopupMenuButton(
      enabled: userModel?.userLevel == UserLevel.admin,
      tooltip: "Create by : ${context.read<UserDataCubit>().getSingleUser(promotionModel.createPersonId) == null ? "User not found" : context.read<UserDataCubit>().getSingleUser(promotionModel.createPersonId)!.userName}",
      itemBuilder: (BuildContext context) {
        final List<ItemPromotionModel> itemPromotionModelList = context.read<PromotionCubit>().getAllItemPromotionListFromPromotionId(promotionModel.id);
        return [

          cusPopUpMenuItem(
            func: (){
              // showDialog(
              //   context: context,
              //   barrierDismissible: false,
              //   builder: (ctx){
              //     return ConfirmScreen(
              //       txt: "Are you sure want to delete this promotion ? ${itemPromotionModelList.isEmpty ? "" : "There are still ${itemPromotionModelList.length} items that use this promotion."}",
              //       title: "Delete",
              //       acceptBtnTxt: "Yes, delete",
              //       cancelBtnTxt: "Cancel",
              //       acceptFunc: ()async{
              //         context.read<LoadingCubit>().setLoading("Deleting ...");
              //         await context.read<PromotionCubit>().deletePromotion(
              //           userModel: userModel!,
              //           promotionId: promotionModel.id
              //         ).then((value){
              //           Navigator.of(ctx).pop();
              //           if(value){
              //             context.read<LoadingCubit>().setSuccess("Success !");
              //           }else{
              //             context.read<LoadingCubit>().setFail("Cannot delete");
              //           }
              //         });
              //       },
              //       cancelFunc: (){
              //         Navigator.of(ctx).pop();
              //       },
              //     );
              //   },
              // );
              showSheet.showCusDialogScreen(ConfirmScreen(
                txt: "Are you sure want to delete this promotion ? ${itemPromotionModelList.isEmpty ? "" : "There are still ${itemPromotionModelList.length} items that use this promotion."}",
                title: "Delete",
                acceptBtnTxt: "Yes, delete",
                cancelBtnTxt: "Cancel",
                acceptFunc: ()async{
                  context.read<LoadingCubit>().setLoading("Deleting ...");
                  await context.read<PromotionCubit>().deletePromotion(
                      userModel: userModel!,
                      promotionId: promotionModel.id
                  ).then((value){
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
        ];
      },
      child: Container(
        width: uIutils.promotionWidgetWidth(),
        height: uIutils.promotionWidgetWidth()/2.7,
        padding: const EdgeInsets.all(UIConstants.mediumSpace),
        decoration: BoxDecoration(
          color: uiController.getpureDirectClr(themeModeType),
          border: Border.all(
            color: Colors.pinkAccent.withOpacity(0.5),
            width: 0.5,
          ),
          borderRadius:UIConstants.mediumBorderRadius,

        ),
        child: Column(
          children: [
            Row(
              children: [
                IndexBoxWidget(index: index.toString()),
                uiController.sizedBox(cusHeight: null, cusWidth: UIConstants.bigSpace),
                Expanded(
                  child: CusTxtWidget(
                    txt: promotionModel.promotionName,
                    txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Colors.pinkAccent
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Text(
                "Description :  ${promotionModel.promotionDescription}",
                style: Theme.of(context).textTheme.bodyMedium!,
              ),
            ),
            if(promotionModel.promotionPercentage != null && promotionModel.promotionPercentage != 0)Row(
              children: [
                CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.bodyMedium!,
                  txt: "Promotion Percentage  ",
                ),
                IndexBoxWidget(index: promotionModel.promotionPercentage.toString()),
                CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.bodyMedium!,
                  txt: " %",
                ),
              ],
            ),
            if(promotionModel.promotionPrice != null && promotionModel.promotionPrice != 0)Row(
              children: [
                CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.bodyMedium!,
                  txt: "Promotion Price  ",
                ),
                IndexBoxWidget(index: promotionModel.promotionPrice.toString()),
                CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.bodyMedium!,
                  txt: " MMK",
                ),
              ],
            ),
            if(promotionModel.lastUpdateTime == null)Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Created At : ${TextFormatters.getDateTime(promotionModel.createTime)}",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),
            if(promotionModel.lastUpdateTime != null)Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Last-updated At : ${TextFormatters.getDateTime(promotionModel.lastUpdateTime)}",
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Colors.grey,
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
