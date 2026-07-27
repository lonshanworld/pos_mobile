import 'package:flutter_bloc/flutter_bloc.dart';

import '../../services/pos_repository.dart';

class AlertsState {
  final List<Map<String, dynamic>> alerts;
  final bool loading;
  final String? error;

  const AlertsState({this.alerts = const [], this.loading = false, this.error});

  AlertsState copyWith({
    List<Map<String, dynamic>>? alerts,
    bool? loading,
    String? error,
    bool clearError = false,
  }) => AlertsState(
    alerts: alerts ?? this.alerts,
    loading: loading ?? this.loading,
    error: clearError ? null : (error ?? this.error),
  );
}

class AlertsCubit extends Cubit<AlertsState> {
  AlertsCubit() : super(const AlertsState());

  Future<void> load() async {
    emit(state.copyWith(loading: true, clearError: true));
    try {
      final alerts = await PosRepository.instance.readWithMode(
        local: () => LocalPosRepository.getAllAlerts(),
        remote: () => PosRepository.instance.fetchAlerts(),
      );
      emit(AlertsState(alerts: alerts));
    } catch (error) {
      emit(state.copyWith(loading: false, error: error.toString()));
    }
  }
}
