import 'package:flutter/material.dart';

class CusTxtOnlyBtn extends StatelessWidget {

  final TextStyle textStyle;
  final String txt;
  final Color clr;
  final VoidCallback func;
  const CusTxtOnlyBtn({
    super.key,
    required this.textStyle,
    required this.txt,
    required this.func,
    required this.clr,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: Colors.grey,
      ),
      onPressed: func,
      child: Text(
        txt,
        style: textStyle.copyWith(
          color: clr,
        ),
      ),
    );
  }
}
