
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/globalkeys.dart';


import '../../screens/loading_screen.dart';

part 'loading_state.dart';

class LoadingCubit extends Cubit<LoadingState> {
  final MainGlobalKeys mainGlobalKeys = MainGlobalKeys.instance;
  bool hasLoading = false;

  LoadingCubit() : super(const LoadingInitial());

  void showLoadingStatus(){
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: mainGlobalKeys.cusGlobalNavigatorKey.currentContext!,
      builder: (buildCtx){
        return LoadingScreen(txt: state.txt!, widget: state.widget!, clr: state.clr!,);
      },
    );
  }

  void changeLoadingValue(bool value){
    hasLoading = value;
  }

  void cancelLoadingLoading(){
    if(hasLoading){
      Navigator.of(mainGlobalKeys.cusGlobalNavigatorKey.currentContext!).pop();
      hasLoading = false;
    }
  }

  void setLoading(String txt){
    emit(LoadingLoading(newTxt: txt));
    hasLoading = true;
    showLoadingStatus();
  }

  void setSuccess(String txt){
    emit(LoadingSuccess(newTxt: txt));
    cancelLoadingLoading();
    showLoadingStatus();
    Future.delayed(const Duration(milliseconds: 1200),(){
      Navigator.of(mainGlobalKeys.cusGlobalNavigatorKey.currentContext!).pop();
    });
  }

  void setFail(String txt){
    emit(LoadingFail(newTxt: txt));
    cancelLoadingLoading();
    showLoadingStatus();
    Future.delayed(const Duration(milliseconds: 1200),(){
      Navigator.of(mainGlobalKeys.cusGlobalNavigatorKey.currentContext!).pop();
    });
  }
}
