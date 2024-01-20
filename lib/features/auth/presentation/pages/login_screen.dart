
import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/history_bloc/history_cubit.dart";


import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";

import "package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart";


import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/constants/uiConstants.dart";

import 'package:pos_mobile/controller/ui_controller.dart';


import "package:pos_mobile/screens/home_screen.dart";

import "package:pos_mobile/utils/ui_responsive_calculation.dart";

import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import "package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart";
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

import '../../../../error_handlers/error_handler.dart';



class LoginScreen extends StatefulWidget {
  static const String routeName = "/loginscreen";

  final UserLevel userLevel;
  const LoginScreen({
    super.key,
    required this.userLevel,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController userNameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  void dispose() {
    userNameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    // final DBHelper dbController = DBHelper.instance;
    final ErrorHandlers errorHandler = ErrorHandlers();
    final UIutils uIutils = UIutils();
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              uiController.sizedBox(
                  cusHeight: uiController.getDeviceHeight / 11, cusWidth: null),
              if(widget.userLevel != UserLevel.superAdmin)const Center(
                child: LogoImageWidget(
                  widthandheight: 200,
                ),
              ),
              if(widget.userLevel != UserLevel.superAdmin)uiController.sizedBox(
                  cusHeight: UIConstants.bigSpace * 3, cusWidth: null),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.bigSpace,
                ),
                width: uIutils.txtFieldLoginWidth(400),
                child: CusTextFieldLogin(
                  txtController: userNameController,
                  verticalPadding: 10,
                  horizontalPadding: 20,
                  hintTxt: "Enter your username",
                  txtInputType: TextInputType.text,
                ),
              ),
              uiController.sizedBox(
                  cusHeight: UIConstants.bigSpace, cusWidth: null),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.bigSpace,
                ),
                width: uIutils.txtFieldLoginWidth(400),
                child: CusTextFieldLogin(
                  txtController: passwordController,
                  verticalPadding: 10,
                  horizontalPadding: 20,
                  hintTxt: "Enter your password",
                  txtInputType: TextInputType.text,
                ),
              ),
              uiController.sizedBox(
                  cusHeight: UIConstants.bigSpace * 1.5, cusWidth: null),
              CusTxtElevatedBtn(
                txt: "Login",
                verticalpadding: 10,
                horizontalpadding: 40,
                bdrRadius: 10,
                bgClr: uiController.getpureOppositeClr(themeModeType),
                func: () {
                  if(userNameController.text.trim().isEmpty || passwordController.text.trim().isEmpty ){
                    if(userNameController.text.trim().isEmpty && passwordController.text.trim().isEmpty){
                      errorHandler.showErrorWithBtn(title: null, txt: "All forms must be filled");
                    }else if(userNameController.text.trim().isEmpty){
                      errorHandler.showErrorWithBtn(title: null, txt: "Username cannot be empty");
                    }else if(passwordController.text.trim().isEmpty){
                      errorHandler.showErrorWithBtn(title: null, txt: "Password cannot be empty");
                    }else{
                      errorHandler.showErrorWithBtn(title: null, txt: "All forms must be filled");
                    }
                  }else{
                    context.read<UserDataCubit>().login(
                      userName: userNameController.text.trim(),
                      password: passwordController.text.trim(),
                      userLevel: widget.userLevel,
                      buildContext: context,
                    ).then((value)async {
                      // Navigator.of(context).pop();

                      if(value){
                        await context.read<HistoryCubit>().reloadHistoryList().then((_){
                          Navigator.of(context).pushNamedAndRemoveUntil(HomeScreen.routeName, (route) => false);
                        });
                      }
                    });
                  }

                },
                txtStyle: Theme.of(context).textTheme.bodyLarge!,
                txtClr: uiController.getpureDirectClr(themeModeType),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
