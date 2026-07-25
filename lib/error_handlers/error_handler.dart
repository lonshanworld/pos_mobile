
import 'package:flutter/material.dart';
import 'package:pos_mobile/error_handlers/error_UI/errorboxwithBtn.dart';
import 'package:pos_mobile/error_handlers/item_folder/cannot_delete_itemBox_error_widget.dart';
import 'package:pos_mobile/globalkeys.dart';
import 'package:pos_mobile/utils/crash_reporter.dart';


class ErrorHandlers{
  final MainGlobalKeys mainGlobalKeys = MainGlobalKeys.instance;

  void showErrorWithBtn({
    required String? title,
    required String txt,
  }){
    // Automatically report any error dialog shown to the user
    CrashReporter.reportError("Error Dialog Shown: [$title] $txt", errorType: "UserErrorDialog");

    showDialog(
      context: mainGlobalKeys.cusGlobalNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (ctx){
        return ErrorBoxWithBtn(title: title, txt: txt);
      },
    );
  }

  void cannotDeleteItem({
    required String title,
    required String txt,
  }){
    // Automatically report any item deletion error shown to the user
    CrashReporter.reportError("Cannot Delete Item: [$title] $txt", errorType: "UserErrorDialog");

    showDialog(
      context: mainGlobalKeys.cusGlobalNavigatorKey.currentContext!,
      barrierDismissible: false,
      builder: (ctx){
        return CannotDeleteItemBoxError(title: title, txt: txt);
      },
    );
  }
}
