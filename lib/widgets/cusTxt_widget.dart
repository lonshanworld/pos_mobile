import "package:flutter/material.dart";

class CusTxtWidget extends StatelessWidget {

  final TextStyle txtStyle;
  final String txt;
  const CusTxtWidget({
    super.key,
    required this.txtStyle,
    required this.txt,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      txt,
      style: txtStyle.copyWith(
        height: 1,
      ),
      softWrap: true,
      overflow: TextOverflow.fade,
    );
  }
}
