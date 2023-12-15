import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "../../../../blocs/item_bloc/item_cubit.dart";
import "../../../../blocs/loading_bloc/loading_cubit.dart";
import "../../../../blocs/userData_bloc/user_data_cubit.dart";
import "../../../../constants/uiConstants.dart";
import "../../../../error_handlers/error_handler.dart";
import "../../../../models/groupingItem_models_folders/type_model.dart";
import "../../../../models/user_model_folder/user_model.dart";
import "../../../../widgets/btns_folder/cusTextOnlyBtn_widget.dart";
import "../../../../widgets/btns_folder/leadingBackIconBtn.dart";
import "../../../../widgets/cusTextField/cusTextFieldLogin_widget.dart";

class EditTypeScreen extends StatefulWidget {

  final TypeModel typeModel;
  const EditTypeScreen({
    super.key,
    required this.typeModel,
  });

  @override
  State<EditTypeScreen> createState() => _EditTypeScreenState();
}

class _EditTypeScreenState extends State<EditTypeScreen> {
  final TextEditingController typeNameController = TextEditingController();


  @override
  void initState() {
    super.initState();
    if(mounted){
      setState(() {
        typeNameController.text = widget.typeModel.name;
      });
    }
  }

  @override
  void dispose() {
    typeNameController.dispose();
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
          "Update Type",
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
                txtController: typeNameController,
                verticalPadding: UIConstants.mediumSpace,
                horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                hintTxt: "Enter new Type name",
                txtInputType: TextInputType.text,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: CusTxtOnlyBtn(
                  textStyle: Theme.of(context).textTheme.titleSmall!,
                  txt: "Update",
                  func: ()async{
                    if(typeNameController.text.trim().isEmpty){
                      errorHandlers.showErrorWithBtn(title: null, txt: "Type Name should not be empty");
                    }else{
                      context.read<LoadingCubit>().setLoading("Updating ...");
                      await context.read<ItemCubit>().editTypeName(
                        userModel: userModel,
                        newName: typeNameController.text.trim(),
                        typeModel: widget.typeModel,
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
