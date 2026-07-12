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

  BuildContext? _loadingDialogContext;
  int _loadingOperationId = 0;

  BuildContext? get _navigatorContext =>
      mainGlobalKeys.cusGlobalNavigatorKey.currentContext;

  void showLoadingStatus() {
    if (_dialogVisible) {
      return;
    }

    final context = _navigatorContext;
    if (context == null ||
        state.txt == null ||
        state.widget == null ||
        state.clr == null) {
      return;
    }

    _dialogVisible = true;
    final int operationId = _loadingOperationId;
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: context,
      useRootNavigator: true,
      builder: (buildCtx) {
        // Keep the dialog's own context.  Popping from the global navigator
        // context is unsafe when the dialog has not been built yet: it can
        // pop the bottom sheet (or the screen below it) instead.
        if (operationId == _loadingOperationId) {
          _loadingDialogContext = buildCtx;
        }
        return LoadingScreen(
          txt: state.txt!,
          widget: state.widget!,
          clr: state.clr!,
        );
      },
    ).whenComplete(() {
      if (operationId == _loadingOperationId) {
        _dialogVisible = false;
        _loadingDialogContext = null;
      }
    });
    hasLoading = true;
  }

  void changeLoadingValue(bool value) {
    hasLoading = value;
  }

  void cancelLoadingLoading() {
    if (hasLoading || _dialogVisible) {
      final dialogContext = _loadingDialogContext;
      if (dialogContext != null && dialogContext.mounted) {
        try {
          final navigator = Navigator.of(dialogContext, rootNavigator: true);
          if (ModalRoute.of(dialogContext)?.isCurrent ?? false) {
            navigator.pop();
          }
        } catch (e) {
          // Handle any potential navigation state issues gracefully
        }
      }
      _loadingOperationId++;
      _loadingDialogContext = null;
      hasLoading = false;
      _dialogVisible = false;
    }
  }

  void setLoading(String txt) {
    cancelLoadingLoading();
    emit(LoadingLoading(newTxt: txt));
    hasLoading = true;
    showLoadingStatus();
  }

  void setSuccess(String txt, {bool showDialog = true}) {
    cancelLoadingLoading();
    emit(LoadingSuccess(newTxt: txt));
    if (showDialog) {
      showLoadingStatus();
    }
    final int operationId = _loadingOperationId;
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (operationId == _loadingOperationId) {
        cancelLoadingLoading();
      }
    });
  }

  void setFail(String txt) {
    cancelLoadingLoading();
    emit(LoadingFail(newTxt: txt));
    showLoadingStatus();

    // Automatically report any failure shown to the user
    CrashReporter.reportError(
      "User operation failed: $txt",
      errorType: "UserOperationFailure",
    );

    final int operationId = _loadingOperationId;
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (operationId == _loadingOperationId) {
        cancelLoadingLoading();
      }
    });
  }
}
