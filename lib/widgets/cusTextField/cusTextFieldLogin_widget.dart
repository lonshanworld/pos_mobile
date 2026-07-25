import "package:flutter/material.dart";
import "package:pos_mobile/constants/uiConstants.dart";

class CusTextFieldLogin extends StatefulWidget {
  final TextEditingController txtController;
  final double verticalPadding;
  final double horizontalPadding;
  final String hintTxt;
  final TextStyle? txtStyle;
  final TextInputType txtInputType;
  final bool isPassword;
  final ValueChanged<String>? onChanged;
  final Widget? suffixIcon;

  const CusTextFieldLogin({
    super.key,
    required this.txtController,
    required this.verticalPadding,
    required this.horizontalPadding,
    required this.hintTxt,
    required this.txtInputType,
    this.txtStyle,
    this.isPassword = false,
    this.onChanged,
    this.suffixIcon,
  });

  @override
  State<CusTextFieldLogin> createState() => _CusTextFieldLoginState();
}

class _CusTextFieldLoginState extends State<CusTextFieldLogin> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword;
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      cursorColor: Colors.grey,
      controller: widget.txtController,
      onChanged: widget.onChanged,
      style: widget.txtStyle ?? Theme.of(context).textTheme.bodyLarge,
      keyboardType: widget.txtInputType,
      obscureText: _obscureText,
      decoration: InputDecoration(
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : widget.suffixIcon,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: UIConstants.mediumBorderRadius,
        ),
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.grey,
            width: 1,
          ),
          borderRadius: UIConstants.mediumBorderRadius,
        ),
        contentPadding: EdgeInsets.symmetric(
          vertical: widget.verticalPadding,
          horizontal: widget.horizontalPadding,
        ),
        hintText: widget.hintTxt,
      ),
    );
  }
}
