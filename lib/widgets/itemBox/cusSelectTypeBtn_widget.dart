import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/screens/transaction/stockIn/type/edit_type_screen.dart";

import '../../blocs/loading_bloc/loading_cubit.dart';
import '../../blocs/userData_bloc/user_data_cubit.dart';
import '../../constants/enums.dart';
import '../../error_handlers/error_handler.dart';
import '../../features/cus_showmodelbottomsheet.dart';
import '../../models/groupingItem_models_folders/type_model.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/user_model_folder/user_model.dart';
import '../../screens/confirm_screens_folder/comfirm_screen.dart';
import '../../controller/ui_controller.dart';
import '../../constants/business_hierarchy_config.dart';

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
    final UIController uiController = UIController.instance;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final CusShowSheet showSheet = CusShowSheet();
    final List<ItemModel> itemList = context
        .read<ItemCubit>()
        .getSelectedItemList(typeModel.id);

    final typeLabel = BusinessHierarchyConfig.getLabel(
      uiController.businessType,
      HierarchyLevel.type,
    );
    final itemLabel = BusinessHierarchyConfig.getLabel(
      uiController.businessType,
      HierarchyLevel.item,
    );

    final canManage = isStorage && userModel?.userLevel == UserLevel.merchant;

    return ListTile(
      selected: isSelected,
      leading: const Icon(Icons.label_outline_rounded),
      title: Text(typeModel.name),
      subtitle: Text(
        "${itemList.length} ${itemList.length == 1 ? itemLabel.toLowerCase() : '${itemLabel.toLowerCase()}s'}",
      ),
      trailing: canManage
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showSheet.showCusBottomSheet(
                    EditTypeScreen(typeModel: typeModel),
                  ),
                ),
                IconButton(
                  tooltip: 'Delete',
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    if (itemList.isNotEmpty) {
                      errorHandlers.cannotDeleteItem(
                        title: "Delete denied !!!",
                        txt:
                            "There are ${itemList.length} ${itemLabel}s in this $typeLabel. You can delete only if there is no $itemLabel left.",
                      );
                      return;
                    }
                    showSheet.showCusDialogScreen(
                      ConfirmScreen(
                        txt: "Are you sure want to delete this $typeLabel?",
                        title: "Delete",
                        acceptBtnTxt: "Yes, delete",
                        cancelBtnTxt: "Cancel",
                        acceptFunc: () async {
                          final loading = context.read<LoadingCubit>();
                          loading.setLoading("Deleting ...");
                          final value = await context
                              .read<ItemCubit>()
                              .deleteType(userModel!, typeModel);
                          if (!context.mounted) return;
                          if (value) {
                            afterDeleteFunc();
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
}
