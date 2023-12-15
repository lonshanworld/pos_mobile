import "package:flutter/material.dart";
import 'package:pos_mobile/constants/uiConstants.dart';

class CusTextFieldLogin extends StatelessWidget {

  final TextEditingController txtController;
  final double verticalPadding;
  final double horizontalPadding;
  final String hintTxt;
  final TextStyle? txtStyle;
  final TextInputType txtInputType;
  const CusTextFieldLogin({
    super.key,
    required this.txtController,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.hintTxt,
    required this.txtInputType,
    this.txtStyle
  } );

  @override
  Widget build(BuildContext context) {
    // final UIController uiController = UIController.instance;
    // final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return TextField(
      cursorColor: Colors.grey,
      controller: txtController,
      style: txtStyle ?? Theme.of(context).textTheme.bodyLarge,
      keyboardType:txtInputType,
      decoration: InputDecoration(
        focusedBorder: OutlineInputBorder(
          borderSide:const BorderSide(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: UIConstants.mediumBorderRadius,
        ),
        border: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.grey,
            width: 1
          ),
          borderRadius: UIConstants.mediumBorderRadius,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: verticalPadding,
          horizontal: horizontalPadding,
        ),
        labelText: hintTxt,
        labelStyle: txtStyle ?? Theme.of(context).textTheme.bodyLarge!.copyWith(
          color: Colors.grey,
        )
      ),
    );
  }
}
