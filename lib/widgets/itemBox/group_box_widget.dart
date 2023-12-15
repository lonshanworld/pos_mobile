import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/screens/transaction/stockIn/group/edit_group_screen.dart';
import 'package:pos_mobile/widgets/cusPopMenuItem_widget.dart';

import '../../blocs/item_bloc/item_cubit.dart';
import '../../blocs/loading_bloc/loading_cubit.dart';
import '../../blocs/theme_bloc/theme_cubit.dart';
import '../../constants/enums.dart';
import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';
import '../../error_handlers/error_handler.dart';
import '../../features/cus_showmodelbottomsheet.dart';
import '../../models/groupingItem_models_folders/group_model.dart';
import '../../screens/confirm_screens_folder/comfirm_screen.dart';
import '../../utils/txt_formatters.dart';
import '../cusTxt_widget.dart';

class GroupBoxWidget extends StatelessWidget {
  final GroupModel groupModel;
  final int typeCount;
  final VoidCallback func;

  final bool isStorage;
  const GroupBoxWidget({
    super.key,
    required this.groupModel,
    required this.typeCount,
    required this.func,
    required this.isStorage,
  });

  @override
  Widget build(BuildContext context) {
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UIController uiController = UIController.instance;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final GlobalKey<PopupMenuButtonState> popupMenu = GlobalKey<PopupMenuButtonState>();
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final CusShowSheet showSheet = CusShowSheet();

    return PopupMenuButton(
      key: popupMenu,
      itemBuilder: (btnCtx){
        return [
          cusPopUpMenuItem(
            func: (){
              showSheet.showCusBottomSheet(EditGroupScreen(groupModel: groupModel));
            },
            txt: "Edit",
            context: btnCtx,
            isImportant: false,
          ),
          cusPopUpMenuItem(
            func: (){
              if(typeCount > 0){
                errorHandlers.cannotDeleteItem(
                  title: "Delete denied !!!",
                  txt: "There are $typeCount types in this group. You can delete only if there is no type left.",
                );
              }else{
                // showDialog(
                //   context: btnCtx,
                //   barrierDismissible: false,
                //   builder: (ctx){
                //     return ConfirmScreen(
                //       txt: "Are you sure want to delete this group?",
                //       title: "Delete",
                //       acceptBtnTxt: "Yes, delete",
                //       cancelBtnTxt: "Cancel",
                //       acceptFunc: ()async{
                //         context.read<LoadingCubit>().setLoading("Deleting ...");
                //         await context.read<ItemCubit>().deleteGroup(userModel!, groupModel).then((value){
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
                showSheet.showCusDialogScreen( ConfirmScreen(
                  txt: "Are you sure want to delete this group?",
                  title: "Delete",
                  acceptBtnTxt: "Yes, delete",
                  cancelBtnTxt: "Cancel",
                  acceptFunc: ()async{
                    context.read<LoadingCubit>().setLoading("Deleting ...");
                    await context.read<ItemCubit>().deleteGroup(userModel!, groupModel).then((value){
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
              }
            },
            txt: "Delete",
            context: btnCtx,
            isImportant: true,
          ),
        ];
      },
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: 8,
          foregroundColor: Colors.grey.withOpacity(0.3),
          backgroundColor: uiController.getpureDirectClr(themeModeType),
          surfaceTintColor: uiController.getpureDirectClr(themeModeType),
          // side: BorderSide(
          //   color: Colors.deepPurple.shade100,
          // ),
          minimumSize: const Size(0, 0),
          padding: EdgeInsets.zero,
          shape: const RoundedRectangleBorder(
            borderRadius: UIConstants.mediumBorderRadius,
          ),
        ),
        onLongPress: (){
          if(userModel != null && userModel.userLevel == UserLevel.admin && isStorage == true){
            popupMenu.currentState?.showButtonMenu();
          }
        },
        onPressed: (){
          func();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!,
              txt: groupModel.name,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.bodyMedium!,
                  txt: "Types : ",
                ),
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: uiController.getpureOppositeClr(themeModeType),
                    borderRadius: UIConstants.mediumBorderRadius,
                  ),
                  alignment: Alignment.center,
                  child: CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleMedium!.copyWith(
                      color:  uiController.getpureDirectClr(themeModeType),
                    ),
                    txt: typeCount.toString(),
                  ),
                ),

              ],
            ),
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                color: Colors.grey
              ),
              txt: TextFormatters.getDateTime(groupModel.lastUpdateTime ?? groupModel.createTime),
            ),
          ],
        ),
      ),
    );
  }
}
