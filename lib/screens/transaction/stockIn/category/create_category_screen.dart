import "dart:async";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/business_hierarchy_config.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/models/user_model_folder/user_model.dart";
import "package:pos_mobile/screens/screen_data_loader.dart";
import "package:pos_mobile/widgets/btns_folder/cusTextOnlyBtn_widget.dart";
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';

import "../../../../widgets/btns_folder/leadingBackIconBtn.dart";

class CreateCategoryScreen extends StatefulWidget {
  const CreateCategoryScreen({super.key});

  @override
  State<CreateCategoryScreen> createState() => _CreateCategoryScreenState();
}

class _CreateCategoryScreenState extends State<CreateCategoryScreen> {
  final TextEditingController categoryNameController = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    unawaited(loadData());
  }

  Future<void> loadData() async {
    await Future.wait([
      ScreenDataLoader.items(context),
      ScreenDataLoader.users(context),
    ]);
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;

    void showValidationMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
    }

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CusLeadingBackIconBtn(),
        title: Text(
          "Create ${BusinessHierarchyConfig.getLabel(uiController.businessType, HierarchyLevel.category)}",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: UIConstants.bigSpace),
        child: SingleChildScrollView(
          child: Column(
            children: [
              uiController.sizedBox(
                cusHeight: UIConstants.bigSpace,
                cusWidth: null,
              ),
              CusTextFieldLogin(
                txtController: categoryNameController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding:
                    UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter new Category name",
                txtInputType: TextInputType.text,
              ),
              uiController.sizedBox(
                cusHeight: UIConstants.bigSpace,
                cusWidth: null,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Create",
                  func: () async {
                    if (_isSubmitting) return;
                    if (categoryNameController.text.trim().isEmpty) {
                      showValidationMessage("Category name cannot be empty");
                    } else {
                      setState(() => _isSubmitting = true);
                      final loadingCubit = context.read<LoadingCubit>();
                      final itemCubit = context.read<ItemCubit>();
                      final navigator = Navigator.of(context);
                      loadingCubit.setLoading("Creating ...");
                      final value = await itemCubit.createNewCategory(
                        userModel,
                        categoryNameController.text.trim(),
                      );

                      if (!context.mounted) return;
                      if (value) {
                        // The category editor is itself a modal sheet. Do not
                        // open a second success dialog above it, otherwise
                        // pop() can dismiss that dialog instead of the sheet.
                        loadingCubit.setSuccess("Success !", showDialog: false);
                        if (navigator.canPop()) {
                          await navigator.maybePop();
                        }
                      } else {
                        loadingCubit.setFail("Fail !");
                        setState(() => _isSubmitting = false);
                      }
                    }
                  },
                  clr: Colors.deepPurpleAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
