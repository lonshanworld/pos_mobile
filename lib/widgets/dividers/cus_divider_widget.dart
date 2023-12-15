import 'package:flutter/material.dart';

import '../../constants/uiConstants.dart';

class CusDividerWidget extends StatelessWidget {

  final Color clr;
  const CusDividerWidget({
    super.key,
    required this.clr
  });

  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: 1,
      height: UIConstants.bigSpace,
      color: clr,
      indent: UIConstants.bigSpace * 1.5 ,
      endIndent:  UIConstants.bigSpace * 1.5 ,
    );
  }
}
