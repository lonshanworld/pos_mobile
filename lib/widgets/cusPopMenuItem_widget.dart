import "package:flutter/material.dart";

import "cusTxt_widget.dart";

PopupMenuItem cusPopUpMenuItem(
    {required VoidCallback func,required String txt, required bool isImportant,required BuildContext context}
    ){
  return PopupMenuItem(
    onTap:func,
    child: CusTxtWidget(
      txtStyle: Theme.of(context).textTheme.titleSmall!.copyWith(
        color: isImportant ? Colors.red : Colors.black,
      ),
      txt: txt,
    ),
  );
}