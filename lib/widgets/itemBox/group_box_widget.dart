import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/screens/transaction/stockIn/group/edit_group_screen.dart';

import '../../blocs/item_bloc/item_cubit.dart';
import '../../blocs/loading_bloc/loading_cubit.dart';
import '../../constants/enums.dart';
import '../../controller/ui_controller.dart';
import '../../error_handlers/error_handler.dart';
import '../../features/cus_showmodelbottomsheet.dart';
import '../../models/groupingItem_models_folders/group_model.dart';
import '../../screens/confirm_screens_folder/comfirm_screen.dart';
import '../../constants/business_hierarchy_config.dart';
import '../../utils/txt_formatters.dart';

class GroupBoxWidget extends StatelessWidget {
  final GroupModel groupModel;
  final int itemCount;
  final VoidCallback func;

  final bool isStorage;
  const GroupBoxWidget({
    super.key,
    required this.groupModel,
    required this.itemCount,
    required this.func,
    required this.isStorage,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final UserModel? userModel = context.watch<UserDataCubit>().state.userModel;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final CusShowSheet showSheet = CusShowSheet();
    final groupLabel = BusinessHierarchyConfig.getLabel(
      uiController.businessType,
      HierarchyLevel.group,
    );
    final itemLabel = BusinessHierarchyConfig.getLabel(
      uiController.businessType,
      HierarchyLevel.item,
    );

    final canManage = isStorage && userModel?.userLevel == UserLevel.merchant;

    return ListTile(
      leading: const Icon(Icons.folder_open_rounded, color: Colors.blueAccent),
      title: Text(groupModel.name),
      subtitle: Text(
        "$itemCount ${itemCount == 1 ? itemLabel.toLowerCase() : '${itemLabel.toLowerCase()}s'}  •  ${TextFormatters.getDateTime(groupModel.lastUpdateTime ?? groupModel.createTime)}",
      ),
      trailing: canManage
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  tooltip: 'Edit',
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => showSheet.showCusBottomSheet(
                    EditGroupScreen(groupModel: groupModel),
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
                            "There are $itemCount ${itemLabel}s using this $groupLabel. You can delete it only when nothing references it.",
                      );
                      return;
                    }
                    showSheet.showCusDialogScreen(
                      ConfirmScreen(
                        txt: "Are you sure want to delete this $groupLabel?",
                        title: "Delete",
                        acceptBtnTxt: "Yes, delete",
                        cancelBtnTxt: "Cancel",
                        acceptFunc: () async {
                          final loading = context.read<LoadingCubit>();
                          loading.setLoading("Deleting ...");
                          final value = await context
                              .read<ItemCubit>()
                              .deleteGroup(userModel!, groupModel);
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
}
