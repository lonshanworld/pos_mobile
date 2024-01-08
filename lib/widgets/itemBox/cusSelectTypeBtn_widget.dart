import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/screens/transaction/stockIn/type/edit_type_screen.dart";
import "package:pos_mobile/widgets/cusPopMenuItem_widget.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";

import '../../blocs/loading_bloc/loading_cubit.dart';
import '../../blocs/userData_bloc/user_data_cubit.dart';
import '../../constants/enums.dart';
import '../../error_handlers/error_handler.dart';
import '../../feature/cus_showmodelbottomsheet.dart';
import '../../models/groupingItem_models_folders/type_model.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/user_model_folder/user_model.dart';
import '../../screens/confirm_screens_folder/comfirm_screen.dart';

class CusSelectTypeBtnWidget extends StatelessWidget {

  final bool isSelected;
  final TypeModel typeModel;
  final VoidCallback func;
  final bool isStorage;
  final VoidCallback afterDeleteFunc;
  const CusSelectTypeBtnWidget({
    super.key,
    required this.isSelected,
    required this.typeModel,
    required this.func,
    required this.isStorage,
    required this.afterDeleteFunc,
  });

  @override
  Widget build(BuildContext context) {
    // final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    // final UIController uiController = UIController.instance;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final GlobalKey<PopupMenuButtonState> popupMenu = GlobalKey<PopupMenuButtonState>();
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final CusShowSheet showSheet = CusShowSheet();
    final List<ItemModel> itemList = context.read<ItemCubit>().getSelectedItemList(typeModel.id);

    return PopupMenuButton(
      key: popupMenu,
      itemBuilder: (btnCtx){
        return [
          cusPopUpMenuItem(
            func: (){
              showSheet.showCusBottomSheet(EditTypeScreen(typeModel: typeModel));
            },
            txt: "Edit",
            context: btnCtx,
            isImportant : false,
          ),
          cusPopUpMenuItem(
            func: (){
              if(itemList.isNotEmpty){
                errorHandlers.cannotDeleteItem(
                  title: "Delete denied !!!",
                  txt: "There are ${itemList.length} items in this type. You can delete only if there is no item left.",
                );
              }else{
                // showDialog(
                //   context: btnCtx,
                //   barrierDismissible: false,
                //   builder: (ctx){
                //     return ConfirmScreen(
                //       txt: "Are you sure want to delete this type?",
                //       title: "Delete",
                //       acceptBtnTxt: "Yes, delete",
                //       cancelBtnTxt: "Cancel",
                //       acceptFunc: ()async{
                //         context.read<LoadingCubit>().setLoading("Deleting ...");
                //         await context.read<ItemCubit>().deleteType(userModel!, typeModel).then((value){
                //           Navigator.of(ctx).pop();
                //           if(value){
                //             afterDeleteFunc();
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
                  txt: "Are you sure want to delete this type?",
                  title: "Delete",
                  acceptBtnTxt: "Yes, delete",
                  cancelBtnTxt: "Cancel",
                  acceptFunc: ()async{
                    context.read<LoadingCubit>().setLoading("Deleting ...");
                    await context.read<ItemCubit>().deleteType(userModel!, typeModel).then((value){
                      Navigator.of(context).pop();
                      if(value){
                        afterDeleteFunc();
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
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 0),
          foregroundColor: Colors.transparent,
          backgroundColor: isSelected ? Colors.lightGreenAccent.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
          surfaceTintColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            vertical: UIConstants.smallSpace,
            horizontal: UIConstants.bigSpace,
          ),
          side: BorderSide(
            color: isSelected ? Colors.green :Colors.transparent,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100),
          )
        ),
        onLongPress: (){
          if(userModel != null && userModel.userLevel == UserLevel.admin && isStorage == true){
            popupMenu.currentState?.showButtonMenu();
          }
        },
        onPressed: func,
        child: CusTxtWidget(
          txt: typeModel.name,
          txtStyle: Theme.of(context).textTheme.bodyLarge!,
        ),
      ),
    );
  }
}
