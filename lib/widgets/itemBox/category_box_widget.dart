import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/error_handlers/error_handler.dart";
import "package:pos_mobile/models/groupingItem_models_folders/category_model.dart";
import "package:pos_mobile/models/user_model_folder/user_model.dart";
import 'package:pos_mobile/screens/confirm_screens_folder/comfirm_screen.dart';
import "package:pos_mobile/screens/transaction/stockIn/category/edit_category_screen.dart";
import "package:pos_mobile/widgets/cusPopMenuItem_widget.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";

import "../../feature/cus_showmodelbottomsheet.dart";


class CategoryBoxWidget extends StatelessWidget {

  final CategoryModel categoryModel;
  final int groupCount;
  final VoidCallback func;
  // final DateTime lastUpdateTime;
  final bool isStorage;
  const CategoryBoxWidget({
    super.key,
    required this.categoryModel,
    required this.groupCount,
    required this.func,
    // required this.lastUpdateTime,
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
      itemBuilder: (ctx){
        return [
          cusPopUpMenuItem(
            func: (){
              showSheet.showCusBottomSheet(EditCategoryScreen(categoryModel: categoryModel));
            },
            txt: "Edit",
            isImportant: false,
            context: ctx,
          ),
          cusPopUpMenuItem(
            func: (){
              if(groupCount > 0){
                errorHandlers.cannotDeleteItem(
                  title: "Delete denied !!!",
                  txt: "There are $groupCount groups in this category. You can delete only if there is no group left.",
                );
              }else{

                showSheet.showCusDialogScreen(
                    ConfirmScreen(
                      txt: "Are you sure want to delete this category?",
                      title: "Delete",
                      acceptBtnTxt: "Yes, delete",
                      cancelBtnTxt: "Cancel",
                      acceptFunc: ()async{
                        context.read<LoadingCubit>().setLoading("Deleting ...");
                        await context.read<ItemCubit>().deleteCategory(userModel!, categoryModel).then((value){
                          Navigator.of(ctx).pop();
                          if(value){
                            context.read<LoadingCubit>().setSuccess("Success !");
                          }else{
                            context.read<LoadingCubit>().setFail("Cannot delete");
                          }
                        });
                      },
                      cancelFunc: (){
                        Navigator.of(ctx).pop();
                      },
                    )
                );
              }
            },
            txt: "Delete",
            context: ctx,
            isImportant: true,
          ),
        ];
      },
      child: InkWell(
        // style: ElevatedButton.styleFrom(
        //   elevation: 8,
        //   foregroundColor: Colors.grey.withOpacity(0.3),
        //   backgroundColor: uiController.getpureDirectClr(themeModeType),
        //   surfaceTintColor: uiController.getpureDirectClr(themeModeType),
        //   // side: BorderSide(
        //   //   color: Colors.deepPurple.shade100,
        //   // ),
        //   minimumSize: const Size(0, 0),
        //   padding: EdgeInsets.zero,
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.all(
        //       Radius.circular(UIConstants.mediumRadius),
        //     ),
        //   ),
        // ),
        onLongPress: (){
          if(userModel != null && userModel.userLevel == UserLevel.admin && isStorage == true){
            popupMenu.currentState?.showButtonMenu();
          }
        },
        onTap: (){
          func();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            CusTxtWidget(
              txtStyle: Theme.of(context).textTheme.titleSmall!,
              txt: categoryModel.name,
            ),
            CircleAvatar(
              radius: 30,
              backgroundColor: uiController.getpureOppositeClr(themeModeType),
              child: CusTxtWidget(
                txtStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color:  uiController.getpureDirectClr(themeModeType),
                ),
                txt: groupCount.toString(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
