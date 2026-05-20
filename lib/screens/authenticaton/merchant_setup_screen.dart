import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/screens/authenticaton/login_screen.dart';
import 'package:pos_mobile/utils/ui_responsive_calculation.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/widgets/cusTextField/cusTextFieldLogin_widget.dart';
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

class MerchantSetupScreen extends StatefulWidget {
  static const String routeName = "/merchantsetup";

  const MerchantSetupScreen({super.key});

  @override
  State<MerchantSetupScreen> createState() => _MerchantSetupScreenState();
}

class _MerchantSetupScreenState extends State<MerchantSetupScreen> {
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _userNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _createAccount() async {
    final userName = _userNameController.text.trim();
    final password = _passwordController.text.trim();

    if (userName.isEmpty && password.isEmpty) {
      _showMessage("All fields must be filled");
      return;
    } else if (userName.isEmpty) {
      _showMessage("Username cannot be empty");
      return;
    } else if (password.isEmpty) {
      _showMessage("Password cannot be empty");
      return;
    }

    setState(() => _isLoading = true);

    final success = await context.read<UserDataCubit>().createNewUser(
      userName: userName,
      password: password,
      userLevel: UserLevel.merchant,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      Navigator.of(context).pushReplacementNamed(
        LoginScreen.routeName,
        arguments: {"userLevel": UserLevel.merchant},
      );
    } else {
      _showMessage("Failed to create account. Username may already be taken.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final UIutils uIutils = UIutils();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              uiController.sizedBox(
                  cusHeight: uiController.getDeviceHeight / 11, cusWidth: null),
              const LogoImageWidget(widthandheight: 150),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              Text(
                "First-time Setup",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              uiController.sizedBox(
                  cusHeight: UIConstants.mediumSpace, cusWidth: null),
              Text(
                "Create your merchant account to get started",
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace * 2, cusWidth: null),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.bigSpace,
                ),
                width: uIutils.txtFieldLoginWidth(400),
                child: CusTextFieldLogin(
                  txtController: _userNameController,
                  verticalPadding: 10,
                  horizontalPadding: 20,
                  hintTxt: "Enter username",
                  txtInputType: TextInputType.text,
                ),
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: UIConstants.bigSpace,
                ),
                width: uIutils.txtFieldLoginWidth(400),
                child: CusTextFieldLogin(
                  txtController: _passwordController,
                  verticalPadding: 10,
                  horizontalPadding: 20,
                  hintTxt: "Enter password",
                  txtInputType: TextInputType.text,
                ),
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace * 1.5, cusWidth: null),
              _isLoading
                  ? const CircularProgressIndicator()
                  : CusTxtElevatedBtn(
                      txt: "Create Account",
                      verticalpadding: 10,
                      horizontalpadding: 40,
                      bdrRadius: 10,
                      bgClr: Colors.teal,
                      func: _createAccount,
                      txtStyle: Theme.of(context).textTheme.bodyLarge!,
                      txtClr: Colors.white,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
