import 'package:flutter/material.dart';

import '../../constants/uiConstants.dart';

class CusTextArea extends StatelessWidget {

  final TextEditingController txtController;
  final double verticalPadding;
  final double horizontalPadding;
  final String hintTxt;
  final TextStyle? txtStyle;
  const CusTextArea({
    super.key,
    this.txtStyle,
    required this.txtController,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.hintTxt,
  });

  @override
  Widget build(BuildContext context) {
      return TextField(
        cursorColor: Colors.grey,
        controller: txtController,
        style: txtStyle ?? Theme.of(context).textTheme.bodyLarge,
        keyboardType: TextInputType.multiline,
        minLines: 3,
        maxLines: null,
        decoration: InputDecoration(
            focusedBorder: const OutlineInputBorder(
              borderSide: const BorderSide(
                color: Colors.grey,
                width: 1,
              ),
              borderRadius: UIConstants.mediumBorderRadius,
            ),
            border: const OutlineInputBorder(
              borderSide: BorderSide(
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
