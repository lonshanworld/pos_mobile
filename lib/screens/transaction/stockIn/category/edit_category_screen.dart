import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';

import '../../../../blocs/item_bloc/item_cubit.dart';
import '../../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../../constants/uiConstants.dart';
import '../../../../controller/ui_controller.dart';
import '../../../../models/user_model_folder/user_model.dart';
import '../../../../widgets/btns_folder/cusTextOnlyBtn_widget.dart';
import '../../../../widgets/btns_folder/leadingBackIconBtn.dart';
import '../../../../widgets/cusTextField/cusTextFieldLogin_widget.dart';

class EditCategoryScreen extends StatefulWidget {

  final CategoryModel categoryModel;
  const EditCategoryScreen({
    super.key,
    required this.categoryModel,
  });

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final TextEditingController categoryNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        categoryNameController.text = widget.categoryModel.name;
      });
    }
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
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CusLeadingBackIconBtn(),
        title: const Text(
            "Update Category"
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              CusTextFieldLogin(
                txtController: categoryNameController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter new Category name",
                txtInputType: TextInputType.text,
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Update",
                  func: ()async{
                    if(categoryNameController.text.trim().isEmpty){
                      showValidationMessage("Category name cannot be empty");
                    }else{
                      context.read<LoadingCubit>().setLoading("Updating ...");
                      final value = await context.read<ItemCubit>().editCategoryName(
                        name: categoryNameController.text.trim(),
                        userModel: userModel,
                        categoryModel: widget.categoryModel,
                      );

                      if (!mounted) return;
                      if(value){
                        Navigator.of(context).pop();
                        context.read<LoadingCubit>().setSuccess("Success !");

                      }else{
                        context.read<LoadingCubit>().setFail("Fail !");
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
