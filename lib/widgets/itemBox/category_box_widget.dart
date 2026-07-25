import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/error_handlers/error_handler.dart";
import "package:pos_mobile/models/groupingItem_models_folders/category_model.dart";
import "package:pos_mobile/models/user_model_folder/user_model.dart";
import 'package:pos_mobile/screens/confirm_screens_folder/comfirm_screen.dart';
import "package:pos_mobile/screens/transaction/stockIn/category/edit_category_screen.dart";
import "package:pos_mobile/constants/business_hierarchy_config.dart";
import "../../features/cus_showmodelbottomsheet.dart";

class CategoryBoxWidget extends StatelessWidget {
  final CategoryModel categoryModel;
  final int itemCount;
  final VoidCallback func;
  // final DateTime lastUpdateTime;
  final bool isStorage;
  const CategoryBoxWidget({
    super.key,
    required this.categoryModel,
    required this.itemCount,
    required this.func,
    // required this.lastUpdateTime,
    required this.isStorage,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final CusShowSheet showSheet = CusShowSheet();
    final categoryLabel = BusinessHierarchyConfig.getLabel(
      uiController.businessType,
      HierarchyLevel.category,
    );
    final itemLabel = BusinessHierarchyConfig.getLabel(
      uiController.businessType,
      HierarchyLevel.item,
    );

    final canManage = isStorage && userModel?.userLevel == UserLevel.merchant;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: _categoryColor(
          categoryModel.name,
        ).withValues(alpha: 0.12),
        foregroundColor: _categoryColor(categoryModel.name),
        child: Text(
          categoryModel.name.isNotEmpty
              ? categoryModel.name[0].toUpperCase()
              : '?',
        ),
      ),
      title: Text(categoryModel.name),
      subtitle: Text(
        "$itemCount ${itemCount == 1 ? itemLabel.toLowerCase() : '${itemLabel.toLowerCase()}s'}",
      ),
      trailing: canManage
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showSheet.showCusBottomSheet(
                    EditCategoryScreen(categoryModel: categoryModel),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    if (itemCount > 0) {
                      errorHandlers.cannotDeleteItem(
                        title: "Delete denied !!!",
                        txt:
                            "There are $itemCount ${itemLabel}s using this $categoryLabel. You can delete it only when nothing references it.",
                      );
                      return;
                    }
                    showSheet.showCusDialogScreen(
                      ConfirmScreen(
                        txt: "Are you sure want to delete this $categoryLabel?",
                        title: "Delete",
                        acceptBtnTxt: "Yes, delete",
                        cancelBtnTxt: "Cancel",
                        acceptFunc: () async {
                          final loading = context.read<LoadingCubit>();
                          loading.setLoading("Deleting ...");
                          final value = await context
                              .read<ItemCubit>()
                              .deleteCategory(userModel!, categoryModel);
                          if (!context.mounted) return;
                          if (value) {
                            loading.setSuccess("Success !");
                          } else {
                            loading.setFail("Cannot delete");
                          }
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
                        cancelFunc: () => Navigator.of(context).pop(),
                      ),
                    );
                  },
                ),
              ],
            )
          : null,
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
