import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/error_handlers/error_handler.dart";
import "package:pos_mobile/models/groupingItem_models_folders/category_model.dart";
import "package:pos_mobile/models/user_model_folder/user_model.dart";
import 'package:pos_mobile/screens/confirm_screens_folder/comfirm_screen.dart';
import "package:pos_mobile/screens/transaction/stockIn/category/edit_category_screen.dart";
import "package:pos_mobile/widgets/cusPopMenuItem_widget.dart";

import "../../features/cus_showmodelbottomsheet.dart";

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
                        final value = await context.read<ItemCubit>().deleteCategory(userModel!, categoryModel);
                        if (!context.mounted) return;
                        Navigator.of(ctx).pop();
                        if(value){
                          context.read<LoadingCubit>().setSuccess("Success !");
                        }else{
                          context.read<LoadingCubit>().setFail("Cannot delete");
                        }
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
        //   foregroundColor: Colors.grey.withValues(alpha: 0.3),
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
          if(userModel != null && userModel.userLevel == UserLevel.merchant && isStorage == true){
            popupMenu.currentState?.showButtonMenu();
          }
        },
        onTap: (){
          func();
        },
        borderRadius: UIConstants.mediumBorderRadius,
        child: Container(
          decoration: BoxDecoration(
            color: uiController.getpureDirectClr(themeModeType),
            borderRadius: UIConstants.mediumBorderRadius,
            border: Border.all(
              color: uiController.getpureOppositeClr(themeModeType).withValues(alpha: 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: UIConstants.mediumBorderRadius,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                // Colored header with category initial
                Expanded(
                  flex: 6,
                  child: Container(
                    color: _categoryColor(categoryModel.name).withValues(alpha: 0.12),
                    child: Center(
                      child: Text(
                        categoryModel.name.isNotEmpty ? categoryModel.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: _categoryColor(categoryModel.name),
                        ),
                      ),
                    ),
                  ),
                ),
                // Name + count footer
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoryModel.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "$groupCount ${groupCount == 1 ? 'group' : 'groups'}",
                          style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _categoryColor(String name) {
    const List<Color> palette = [
      Color(0xFF1565C0),
      Color(0xFF2E7D32),
      Color(0xFF6A1B9A),
      Color(0xFFE65100),
      Color(0xFF00695C),
      Color(0xFF283593),
      Color(0xFF880E4F),
      Color(0xFF00838F),
      Color(0xFF4E342E),
      Color(0xFF37474F),
    ];
    if (name.isEmpty) return palette[0];
    return palette[name.codeUnitAt(0) % palette.length];
  }
}
