part of 'history_cubit.dart';

@immutable
abstract class HistoryState {
  final List<UpdateHistoryModel> historyList;
  const HistoryState({
    required this.historyList,
  });
}

class HistoryData extends HistoryState {
  const HistoryData({required super.historyList});
}
