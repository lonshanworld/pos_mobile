import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextArea_widget.dart';
import 'package:pos_mobile/widgets/cusTxt_widget.dart';

import '../../../../blocs/item_bloc/item_cubit.dart';
import '../../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../../controller/ui_controller.dart';
import '../../../../error_handlers/error_handler.dart';
import '../../../../models/user_model_folder/user_model.dart';
import '../../../../widgets/btns_folder/cusTextOnlyBtn_widget.dart';
import '../../../../widgets/btns_folder/leadingBackIconBtn.dart';
import '../../../../widgets/cusTextField/cusTextFieldLogin_widget.dart';

class CreateGroupScreen extends StatefulWidget {

  final CategoryModel selectedCategoryModel;
  const CreateGroupScreen({
    super.key,
    required this.selectedCategoryModel,
  });

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();
  final TextEditingController textAreaController = TextEditingController();


  @override
  void dispose() {
    groupNameController.dispose();
    textAreaController.dispose();
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
          "Create Group",
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
                txtController: groupNameController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter new Group name",
                txtInputType: TextInputType.text,
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace + UIConstants.mediumSpace, cusWidth: null),
              Align(
                alignment: Alignment.centerLeft,
                child: CusTxtWidget(
                  txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
                    color: Colors.grey
                  ),
                  txt: "Optional",
                ),
              ),
              uiController.sizedBox(cusHeight: UIConstants.smallSpace, cusWidth: null),
              CusTextArea(
                txtController: textAreaController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter description",
                txtStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Colors.grey,
                ),
              ),

              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Create",
                  func: ()async{
                    if(groupNameController.text.trim().isEmpty){
                      errorHandlers.showErrorWithBtn(title: null, txt: "Group Name should not be empty");
                    }else{
                      context.read<LoadingCubit>().setLoading("Creating ...");
                      await context.read<ItemCubit>().createNewGroup(
                          userModel: userModel,
                          categoryModel: widget.selectedCategoryModel,
                          groupName: groupNameController.text.trim(),
                          description:
                          (textAreaController.text.trim() == "" || textAreaController.text.trim().isEmpty)
                              ?
                            null
                              :
                            textAreaController.text.trim(),
                      ).then((value){
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

