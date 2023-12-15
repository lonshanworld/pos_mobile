import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/item_bloc/item_cubit.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/error_handlers/error_handler.dart";
import "package:pos_mobile/models/user_model_folder/user_model.dart";
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


  @override
  void dispose() {
    categoryNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CusLeadingBackIconBtn(),
        title: const Text(
          "Create Category"
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
                  txt: "Create",
                  func: ()async{
                    if(categoryNameController.text.trim().isEmpty){
                      errorHandlers.showErrorWithBtn(title: null, txt: "Text cannot be empty");
                    }else{
                      context.read<LoadingCubit>().setLoading("Creating ...");
                      await context.read<ItemCubit>().createNewCategory(userModel, categoryNameController.text.trim()).then((value){
                        if(value){
                          Navigator.of(context).pop();
                          context.read<LoadingCubit>().setSuccess("Success !");

                        }else{
                          context.read<LoadingCubit>().setFail("Fail !");
                        }
                      });
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
