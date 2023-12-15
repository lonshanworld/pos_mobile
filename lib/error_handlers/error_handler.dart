
import 'package:flutter/material.dart';
import 'package:pos_mobile/error_handlers/error_UI/errorboxwithBtn.dart';
import 'package:pos_mobile/error_handlers/item_folder/cannot_delete_itemBox_error_widget.dart';
import 'package:pos_mobile/globalkeys.dart';


class ErrorHandlers{
  final MainGlobalKeys mainGlobalKeys = MainGlobalKeys.instance;

  showErrorWithBtn({
    required String? title,
    required String txt,
  }){
    showDialog(
      context: mainGlobalKeys.cusGlobalNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (ctx){
        return ErrorBoxWithBtn(title: title, txt: txt);
      },
    );
  }

  cannotDeleteItem({
    required String title,
    required String txt,
  }){
    showDialog(
      context: mainGlobalKeys.cusGlobalNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (ctx){
        return CannotDeleteItemBoxError(title: title, txt: txt);
      },
    );
  }
}
