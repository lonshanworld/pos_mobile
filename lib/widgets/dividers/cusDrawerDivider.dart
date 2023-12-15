import "package:flutter/material.dart";
import "package:pos_mobile/constants/uiConstants.dart";

class CusDrawerDivider extends StatelessWidget {
  const CusDrawerDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const Divider(
      thickness: 1,
      height: 1,
      color: Colors.grey,
      indent: UIConstants.bigSpace,
      endIndent:  UIConstants.bigSpace,
    );
  }
}
