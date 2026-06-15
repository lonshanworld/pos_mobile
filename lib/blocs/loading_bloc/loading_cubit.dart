
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/globalkeys.dart';
import 'package:pos_mobile/utils/crash_reporter.dart';


import '../../screens/loading_screen.dart';

part 'loading_state.dart';

class LoadingCubit extends Cubit<LoadingState> {
  final MainGlobalKeys mainGlobalKeys = MainGlobalKeys.instance;
  bool hasLoading = false;
  bool _dialogVisible = false;

  LoadingCubit() : super(const LoadingInitial());

  BuildContext? get _navigatorContext =>
      mainGlobalKeys.cusGlobalNavigatorKey.currentContext;

  void showLoadingStatus(){
    if (_dialogVisible) {
      return;
    }

    final context = _navigatorContext;
    if (context == null || state.txt == null || state.widget == null || state.clr == null) {
      return;
    }

    _dialogVisible = true;
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: context,
      useRootNavigator: true,
      builder: (buildCtx){
        return LoadingScreen(txt: state.txt!, widget: state.widget!, clr: state.clr!,);
      },
    ).whenComplete(() {
      _dialogVisible = false;
    });
    hasLoading = true;
  }

  void changeLoadingValue(bool value){
    hasLoading = value;
  }

  void cancelLoadingLoading(){
    if(hasLoading || _dialogVisible){
      final context = _navigatorContext;
      if(context != null){
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (e) {
          // Handle any potential navigation state issues gracefully
        }
      }
      hasLoading = false;
      _dialogVisible = false;
    }
  }

  void setLoading(String txt){
    cancelLoadingLoading();
    emit(LoadingLoading(newTxt: txt));
    hasLoading = true;
    showLoadingStatus();
  }

  void setSuccess(String txt){
    cancelLoadingLoading();
    emit(LoadingSuccess(newTxt: txt));
    showLoadingStatus();
    Future.delayed(const Duration(milliseconds: 1200),(){
      cancelLoadingLoading();
    });
  }

  void setFail(String txt){
    cancelLoadingLoading();
    emit(LoadingFail(newTxt: txt));
    showLoadingStatus();
    
    // Automatically report any failure shown to the user
    CrashReporter.reportError("User operation failed: $txt", errorType: "UserOperationFailure");

    Future.delayed(const Duration(milliseconds: 1200),(){
      cancelLoadingLoading();
    });
  }
}
