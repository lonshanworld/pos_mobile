import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../../blocs/item_bloc/item_cubit.dart";
import "../../../../blocs/loading_bloc/loading_cubit.dart";
import "../../../../blocs/userData_bloc/user_data_cubit.dart";
import "../../../../constants/uiConstants.dart";
import "../../../../error_handlers/error_handler.dart";
import "../../../../models/groupingItem_models_folders/group_model.dart";
import "../../../../models/user_model_folder/user_model.dart";
import "../../../../widgets/btns_folder/cusTextOnlyBtn_widget.dart";
import "../../../../widgets/btns_folder/leadingBackIconBtn.dart";
import "../../../../widgets/cusTextField/cusTextFieldLogin_widget.dart";

class EditGroupScreen extends StatefulWidget {

  final GroupModel groupModel;
  const EditGroupScreen({
    super.key,
    required this.groupModel,
  });

  @override
  State<EditGroupScreen> createState() => _EditGroupScreenState();
}

class _EditGroupScreenState extends State<EditGroupScreen> {
  final TextEditingController groupNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        groupNameController.text = widget.groupModel.name;
      });
    }
  }

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final UserModel userModel = context.watch<UserDataCubit>().state.userModel!;


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leading: const CusLeadingBackIconBtn(),
        title: const Text(
          "Update Group",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: UIConstants.bigSpace,
          vertical: UIConstants.bigSpace,
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              CusTextFieldLogin(
                txtController: groupNameController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter new Group name",
                txtInputType: TextInputType.text,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Update",
                  func: ()async{
                    if(groupNameController.text.trim().isEmpty){
                      errorHandlers.showErrorWithBtn(title: null, txt: "Group Name should not be empty");
                    }else{
                      context.read<LoadingCubit>().setLoading("Updating ...");
                      await context.read<ItemCubit>().editGroupName(
                        userModel: userModel,
                        newName: groupNameController.text.trim(),
                        groupModel: widget.groupModel,
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
