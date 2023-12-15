part of 'loading_cubit.dart';

@immutable
abstract class LoadingState {
  final String? txt;
  final LoadingStatus? loadingStatus;
  final Color? clr;
  final Widget? widget;
  const LoadingState({
    required this.txt,
    required this.loadingStatus,
    required this.clr,
    required this.widget,
  });
}

class LoadingInitial extends LoadingState {
  const LoadingInitial():super(
    txt: null,
    loadingStatus: null,
    clr: null,
    widget: null,
  );
}

class LoadingLoading extends LoadingState{
  const LoadingLoading({required String newTxt}):super(
    txt: newTxt,
    clr: Colors.black,
    loadingStatus: LoadingStatus.loading,
    widget: const SpinKitPouringHourGlassRefined(
      color: Colors.black,
      duration: Duration(seconds: 1),
      size: UIConstants.normalLoadingIconSize,
    ),
  );
}

class LoadingSuccess extends LoadingState{
  const LoadingSuccess({required String newTxt}):super(
    txt: newTxt,
    clr: Colors.green,
    loadingStatus: LoadingStatus.success,
    widget: const Icon(
      Icons.check,
      size: UIConstants.bigLoadingIconSize,
      color: Colors.green,
    ),
  );
}

class LoadingFail extends LoadingState{
  const LoadingFail({required String newTxt}):super(
    txt: newTxt,
    clr: Colors.red,
    loadingStatus: LoadingStatus.fail,
    widget: const Icon(
      Icons.close,
      size: UIConstants.bigLoadingIconSize,
      color: Colors.red,
    ),
  );
}