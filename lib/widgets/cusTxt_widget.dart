import "package:flutter/material.dart";

class CusTxtWidget extends StatelessWidget {

  final TextStyle txtStyle;
  final String txt;
  final TextAlign? textAlign;
  const CusTxtWidget({
    super.key,
    required this.txtStyle,
    required this.txt,
    this.textAlign,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      textAlign: textAlign ?? TextAlign.start,
      style: txtStyle.copyWith(
        height: 1,
      ),
      softWrap: true,
      overflow: TextOverflow.fade,
    );
  }
}
