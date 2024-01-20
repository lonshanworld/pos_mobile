import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/loading_bloc/loading_cubit.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";
import "package:pos_mobile/controller/ui_controller.dart";
import "package:pos_mobile/error_handlers/error_handler.dart";

import "package:pos_mobile/utils/ui_responsive_calculation.dart";
import "package:pos_mobile/widgets/btns_folder/cusIconBtn_widget.dart";
import "package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart";

import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';


class CreateUserScreen extends StatefulWidget {

  final VoidCallback goBack;
  const CreateUserScreen({
    super.key,
    required this.goBack,
  });

  @override
  State<CreateUserScreen> createState() => _CreateUserScreenState();
}

class _CreateUserScreenState extends State<CreateUserScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  UserLevel? selectedUserLevel;


  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    final UIController uiController = UIController.instance;
    // final double deviceWidth = uiController.getDeviceWidth;
    final ErrorHandlers errorHandlers = ErrorHandlers();
    final UIutils uIutils = UIutils();


    List<UserLevel> cusUserLevel = [
      UserLevel.staff,
      UserLevel.admin,
    ];

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Create new user account",
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
        leading: CusIconBtn(
          size: UIConstants.bigIcon,
          func: (){
            widget.goBack();
          },
          clr: uiController.getpureOppositeClr(themeModeType),
          icon: Icons.arrow_back,
        ),
      ),
      body: Center(

        child: SingleChildScrollView(
          child: Container(
            width: uIutils.createUserAccountScreenWidthTextField(),
            padding: const EdgeInsets.symmetric(
              horizontal: UIConstants.bigSpace,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                uiController.sizedBox(
                    cusHeight: uiController.getDeviceHeight / 8, cusWidth: null),
                CusTextFieldLogin(
                  txtController: userNameController,
                  verticalPadding: UIConstants.mediumSpace,
                  horizontalPadding: UIConstants.bigSpace,
                  hintTxt: "Enter new username",
                  txtStyle: Theme.of(context).textTheme.bodyMedium,
                  txtInputType: TextInputType.text,
                ),
                uiController.sizedBox(cusHeight: UIConstants.bigSpace * 2, cusWidth: null),
                CusTextFieldLogin(
                  txtController: passwordController,
                  verticalPadding: UIConstants.mediumSpace,
                  horizontalPadding: UIConstants.bigSpace,
                  hintTxt: "Enter new password",
                  txtStyle: Theme.of(context).textTheme.bodyMedium,
                  txtInputType: TextInputType.text,
                ),
                uiController.sizedBox(cusHeight: UIConstants.bigSpace * 2, cusWidth: null),
                DropdownButton(
                  dropdownColor: uiController.getpureDirectClr(themeModeType),
                  borderRadius: UIConstants.mediumBorderRadius,
                  value: selectedUserLevel,
                  hint: Text(
                    "Choose user level",
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  items: cusUserLevel.map((e) => DropdownMenuItem<UserLevel>(
                    value: e,
                    child: Text(
                      e.name,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  )).toList(),
                  onChanged: (data){
                    setState(() {
                      selectedUserLevel = data;
                    });
                  },
                ),
                uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
                CusTxtElevatedBtn(
                  txt: "Create now",
                  verticalpadding: UIConstants.mediumSpace,
                  horizontalpadding: UIConstants.bigSpace,
                  bdrRadius: UIConstants.mediumRadius,
                  bgClr: Colors.teal,
                  func: ()async{
                    if(userNameController.text.trim().isEmpty || passwordController.text.trim().isEmpty || selectedUserLevel == null){
                      if(userNameController.text.trim().isEmpty && passwordController.text.trim().isEmpty){
                        errorHandlers.showErrorWithBtn(title: null, txt: "All forms must be filled");
                      }else if(userNameController.text.trim().isEmpty){
                        errorHandlers.showErrorWithBtn(title: null, txt: "Username cannot be empty");
                      }else if(passwordController.text.trim().isEmpty){
                        errorHandlers.showErrorWithBtn(title: null, txt: "Password cannot be empty");
                      }else if(selectedUserLevel == null){
                        errorHandlers.showErrorWithBtn(title: null, txt: "User Role need to be chosen");
                      }else{
                        errorHandlers.showErrorWithBtn(title: null, txt: "All forms must be filled");
                      }
                    }else{
                      context.read<LoadingCubit>().setLoading("Creating ...");
                      // Future.delayed(Duration(seconds: 5),(){
                      //   context.read<LoadingCubit>().setSuccess("Success !");
                      // });

                      await context.read<UserDataCubit>().createNewUser(
                          userName: userNameController.text.trim(),
                          password: passwordController.text.trim(),
                          userLevel: selectedUserLevel!
                      ).then((value){
                        if(value){
                          context.read<LoadingCubit>().setSuccess("Success !");
                          widget.goBack();
                        }else{
                          context.read<LoadingCubit>().setFail("Failed !");
                        }
                      });
                    }

                  },
                  txtStyle: Theme.of(context).textTheme.titleSmall!,
                  txtClr: Colors.white,
                ),
                uiController.sizedBox(cusHeight: UIConstants.bigSpace * 2, cusWidth: null),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
