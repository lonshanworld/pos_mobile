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
                showSheet.showCusDialogScreen( ConfirmScreen(
                  txt: "Are you sure want to delete this group?",
                  title: "Delete",
                  acceptBtnTxt: "Yes, delete",
                  cancelBtnTxt: "Cancel",
                  acceptFunc: ()async{
                    context.read<LoadingCubit>().setLoading("Deleting ...");
                    final value = await context.read<ItemCubit>().deleteGroup(userModel!, groupModel);
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
          elevation: 2,
          foregroundColor: Colors.grey.withValues(alpha: 0.2),
          backgroundColor: uiController.getpureDirectClr(themeModeType),
          surfaceTintColor: uiController.getpureDirectClr(themeModeType),
          minimumSize: const Size(0, 0),
          padding: const EdgeInsets.all(UIConstants.mediumSpace),
          shape: const RoundedRectangleBorder(
            borderRadius: UIConstants.mediumBorderRadius,
          ),
        ),
        onLongPress: (){
          if(userModel != null && userModel.userLevel == UserLevel.merchant && isStorage == true){
            popupMenu.currentState?.showButtonMenu();
          }
        },
        onPressed: (){
          func();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.folder_open_rounded, size: 18, color: Colors.blueAccent.withValues(alpha: 0.8)),
                const SizedBox(width: 6),
                Expanded(
                  child: CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    txt: groupModel.name,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withValues(alpha: 0.12),
                    borderRadius: UIConstants.smallBorderRadius,
                  ),
                  child: CusTxtWidget(
                    txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                      color: Colors.blueAccent,
                      fontWeight: FontWeight.w600,
                    ),
                    txt: "$typeCount ${typeCount == 1 ? 'type' : 'types'}",
                  ),
                ),
                CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.bodySmall!.copyWith(
                    color: Colors.grey,
                  ),
                  txt: TextFormatters.getDateTime(groupModel.lastUpdateTime ?? groupModel.createTime),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}