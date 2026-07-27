import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/models/user_model_folder/user_model.dart";
import "package:pos_mobile/screens/screen_data_loader.dart";

import "package:pos_mobile/widgets/btns_folder/cusTxtIconBtn_widget.dart";
import "package:pos_mobile/widgets/cusTxt_widget.dart";
import "package:pos_mobile/widgets/tables_folder/user_table_folder/userModelTable.dart";

class CheckAllAccountScreen extends StatefulWidget {
  final VoidCallback goToCreateScreen;
  const CheckAllAccountScreen({super.key, required this.goToCreateScreen});

  @override
  State<CheckAllAccountScreen> createState() => _CheckAllAccountScreenState();
}

class _CheckAllAccountScreenState extends State<CheckAllAccountScreen> {
  @override
  void initState() {
    super.initState();
    unawaited(loadData());
  }

  Future<void> loadData() => ScreenDataLoader.users(context);

  @override
  Widget build(BuildContext context) {
    final List<UserModel> userList = context.select(
      (UserDataCubit cubit) => cubit.state.allUserModelList,
    );
    final UserModel? owner = context.select(
      (UserDataCubit cubit) => cubit.state.userModel,
    );
    final bool isOwner =
        owner?.userLevel == UserLevel.merchant ||
        owner?.userLevel == UserLevel.superAdmin;
    final UIController uiController = UIController.instance;

    Future<void> showResetPasswordDialog() async {
      final eligibleUsers = userList
          .where((e) => e.userLevel != UserLevel.superAdmin)
          .toList();

      if (eligibleUsers.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("No eligible account available for password reset."),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      final passController = TextEditingController();
      final confirmController = TextEditingController();
      UserModel selectedUser = eligibleUsers.first;
      bool obscurePassword = true;
      bool obscureConfirmation = true;

      await showDialog(
        context: context,
        builder: (ctx) {
          return StatefulBuilder(
            builder: (ctx, setLocalState) {
              return AlertDialog(
                title: const Text("Reset User Password"),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButtonFormField<UserModel>(
                      initialValue: selectedUser,
                      isExpanded: true,
                      items: eligibleUsers
                          .map(
                            (e) => DropdownMenuItem<UserModel>(
                              value: e,
                              child: Text(
                                "${e.userName} (${e.userLevel.name})",
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setLocalState(() {
                            selectedUser = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: UIConstants.mediumSpace),
                    TextField(
                      controller: passController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: "New password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setLocalState(
                            () => obscurePassword = !obscurePassword,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: UIConstants.mediumSpace),
                    TextField(
                      controller: confirmController,
                      obscureText: obscureConfirmation,
                      decoration: InputDecoration(
                        labelText: "Confirm password",
                        suffixIcon: IconButton(
                          icon: Icon(
                            obscureConfirmation
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () => setLocalState(
                            () => obscureConfirmation = !obscureConfirmation,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text("Cancel"),
                  ),
                  FilledButton(
                    onPressed: () async {
                      final msg = await context
                          .read<UserDataCubit>()
                          .resetUserPasswordByOwner(
                            targetUserId: selectedUser.id,
                            newPassword: passController.text.trim(),
                            confirmPassword: confirmController.text.trim(),
                          );
                      if (!context.mounted) return;
                      Navigator.of(ctx).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(msg ?? "Password reset successfully."),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const Text("Reset"),
                  ),
                ],
              );
            },
          );
        },
      );

      passController.dispose();
      confirmController.dispose();
    }

    // DataColumn dataColumn(String txt){
    //   return DataColumn(
    //     label: CusTxtWidget(
    //       txt: txt,
    //       txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
    //         fontWeight: FontWeight.bold,
    //       ),
    //     ),
    //   );
    // }
    //
    // DataCell dataCell(String txt){
    //   return DataCell(
    //     CusTxtWidget(
    //       txtStyle:Theme.of(context).textTheme.bodyMedium!,
    //       txt: txt == "null" ? "- -" : txt,
    //     ),
    //     placeholder: true,
    //   );
    // }
    //
    // DataRow dataRow({
    //   required int id,
    //   required String name,
    //   required String level,
    //   required String loginTime,
    //   required String logoutTime,
    // }){
    //   return DataRow(
    //     cells: [
    //       dataCell(id.toString()),
    //       dataCell(name),
    //       dataCell(level),
    //       dataCell(loginTime),
    //       dataCell(logoutTime),
    //     ],
    //   );
    // }

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            left: 0,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: UIConstants.bigSpace,
                  ),
                  child: Row(
                    children: [
                      CusTxtWidget(
                        txtStyle: Theme.of(context).textTheme.titleSmall!,
                        txt: "Total Accounts ( ${userList.length} )",
                      ),
                      const Spacer(),
                      if (isOwner)
                        CusTxtIconElevatedBtn(
                          txt: "Reset Password",
                          verticalpadding: UIConstants.smallSpace,
                          horizontalpadding: UIConstants.mediumSpace,
                          bdrRadius: UIConstants.smallRadius,
                          bgClr: Colors.orange,
                          func: showResetPasswordDialog,
                          txtStyle: Theme.of(context).textTheme.bodySmall!,
                          txtClr: Colors.white,
                          icon: Icons.lock_reset,
                          iconSize: UIConstants.normalNormalIconSize,
                        ),
                    ],
                  ),
                ),
                uiController.sizedBox(
                  cusHeight: UIConstants.mediumSpace,
                  cusWidth: null,
                ),
                Expanded(
                  child: Column(
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.vertical,
                        child: UserTable(
                          userList: userList,
                          showPassword: true,
                        ),
                      ),
                      uiController.sizedBox(
                        cusHeight: UIConstants.bigSpace * 6,
                        cusWidth: null,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 30,
            right: 30,
            child: CusTxtIconElevatedBtn(
              txt: "Create new account",
              verticalpadding: UIConstants.mediumSpace,
              horizontalpadding: UIConstants.bigSpace,
              bdrRadius: UIConstants.mediumRadius,
              bgClr: Colors.teal,
              func: () async {
                widget.goToCreateScreen();
              },
              txtStyle: Theme.of(context).textTheme.titleSmall!,
              txtClr: Colors.white,
              icon: Icons.add,
              iconSize: UIConstants.normalNormalIconSize,
            ),
          ),
        ],
      ),
    );
  }
}
