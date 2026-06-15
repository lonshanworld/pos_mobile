import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:pos_mobile/widgets/btns_folder/cus_switch_btn_widget.dart';

import '../../../../blocs/item_bloc/item_cubit.dart';
import '../../../../blocs/loading_bloc/loading_cubit.dart';
import '../../../../blocs/userData_bloc/user_data_cubit.dart';
import '../../../../constants/uiConstants.dart';
import '../../../../controller/DB_helper.dart';
import '../../../../controller/ui_controller.dart';
import '../../../../models/groupingItem_models_folders/group_model.dart';
import '../../../../models/user_model_folder/user_model.dart';
import '../../../../widgets/btns_folder/cusTextOnlyBtn_widget.dart';
import '../../../../widgets/btns_folder/leadingBackIconBtn.dart';
import '../../../../widgets/cusTextField/cusTextArea_widget.dart';
import '../../../../widgets/cusTextField/cusTextFieldLogin_widget.dart';
import '../../../../widgets/cusTxt_widget.dart';

class CreateTypeScreen extends StatefulWidget {

  final GroupModel selectedGroupModel;
  const CreateTypeScreen({
    super.key,
    required this.selectedGroupModel,
  });


  @override
  State<CreateTypeScreen> createState() => _CreateTypeScreenState();
}

class _CreateTypeScreenState extends State<CreateTypeScreen> {
  final TextEditingController typeNameController = TextEditingController();
  final TextEditingController textAreaController = TextEditingController();
  bool hasExpire = false;
  late final Future<CategoryModel?> _categoryFuture;

  @override
  void initState() {
    super.initState();
    _categoryFuture = DBHelper.getCategoryById(widget.selectedGroupModel.categoryId);
  }

  @override
  void dispose() {
    typeNameController.dispose();
    textAreaController.dispose();
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

    return FutureBuilder<CategoryModel?>(
      future: _categoryFuture,
      builder: (context, snapshot) {
        final CategoryModel? categoryModel = snapshot.data;
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            leading: const CusLeadingBackIconBtn(),
            title: const Text(
              "Create Type",
            ),
          ),
          body: snapshot.connectionState != ConnectionState.done
              ? const Center(child: CircularProgressIndicator())
              : categoryModel == null
                  ? const Center(child: Text("This category has some error"))
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: UIConstants.mediumSpace,
                          horizontal: UIConstants.bigSpace,
                        ),
                        child: Column(
                          children: [
                            CusTextFieldLogin(
                              txtController: typeNameController,
                              verticalPadding: UIConstants.mediumSpace,
                              horizontalPadding: UIConstants.bigSpace + UIConstants.mediumSpace,
                              hintTxt: "Enter new Type name",
                              txtInputType: TextInputType.text,
                            ),
                            uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CusTxtWidget(
                                  txtStyle: Theme.of(context).textTheme.bodyMedium!,
                                  txt: "This Type has expire date ?",
                                ),
                                CusSwitchBtnWidget(
                                  boolValue: hasExpire,
                                  func: (bool value){
                                    setState(() {
                                      hasExpire = value;
                                    });
                                    cusDebugPrint(value);
                                  },
                                  clr: Colors.blue,
                                ),
                              ],
                            ),
                            uiController.sizedBox(cusHeight: UIConstants.mediumSpace, cusWidth: null),
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
                              hintTxt: "Enter general description",
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
                                  if(typeNameController.text.trim().isEmpty){
                                    showValidationMessage("Type name should not be empty");
                                  }else{
                                    final loadingCubit = context.read<LoadingCubit>();
                                    final itemCubit = context.read<ItemCubit>();
                                    final navigator = Navigator.of(context);
                                    loadingCubit.setLoading("Creating ...");
                                    final value = await itemCubit.createNewType(
                                      userModel: userModel,
                                      categoryModel: categoryModel,
                                      groupModel: widget.selectedGroupModel,
                                      typeName: typeNameController.text.trim(),
                                      generalDescription: (textAreaController.text.trim() == "" || textAreaController.text.trim().isEmpty)
                                          ?
                                      null
                                          :
                                      textAreaController.text.trim(),
                                      hasExpire: hasExpire,
                                    );

                                    if (!mounted) return;
                                    if(value){
                                      loadingCubit.setSuccess("Success !");
                                      navigator.pop();
                                    }else{
                                      loadingCubit.setFail("Fail !");
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
      },
    );
  }
}
