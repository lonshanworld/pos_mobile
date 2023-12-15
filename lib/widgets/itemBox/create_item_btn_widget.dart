import 'package:flutter/material.dart';
import 'package:pos_mobile/features/cus_showmodelbottomsheet.dart';

import '../../constants/uiConstants.dart';
import '../btns_folder/cusTxtIconBtn_widget.dart';

class CreateItemBtnWidget extends StatelessWidget {

  final String txt;
  final Widget widget;
  const CreateItemBtnWidget({
    super.key,
    required this.txt,
    required this.widget,
  });

  @override
  Widget build(BuildContext context) {
    final CusShowSheet showSheet = CusShowSheet();

    return Positioned(
      bottom: 30,
      right: 30,
      child: CusTxtIconElevatedBtn(
        txt: txt,
        verticalpadding: UIConstants.smallSpace,
        horizontalpadding: UIConstants.mediumSpace,
        bdrRadius: UIConstants.mediumRadius,
        bgClr: Colors.blueAccent,
        func: (){
          showSheet.showCusBottomSheet(widget);
        },
        txtStyle: Theme.of(context).textTheme.titleSmall!,
        txtClr: Colors.white,
        icon: Icons.add,
        iconSize: 26,
      ),
    );
  }
}
