import 'package:flutter/material.dart';

import '../constants/uiConstants.dart';
import '../globalkeys.dart';

class CusShowSheet{
  final MainGlobalKeys mainGlobalKeys = MainGlobalKeys.instance;

  showCusBottomSheet(Widget screen){
    showModalBottomSheet(
      context: mainGlobalKeys.cusGlobalNavigatorKey.currentContext!,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx){
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(UIConstants.bigRadius),
            topLeft: Radius.circular(UIConstants.bigRadius),
          ),
          child: screen,
        );
      },
    );
  }
  
  showCusDialogScreen(Widget screen){
    showDialog(
      context: mainGlobalKeys.cusGlobalNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (ctx){
        return screen;
      },
    );
  }
}