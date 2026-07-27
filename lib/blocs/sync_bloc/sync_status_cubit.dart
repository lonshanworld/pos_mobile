import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/pos_sync_manager.dart';

class SyncStatusCubit extends Cubit<PosSyncState> {
  final PosSyncManager manager;
  StreamSubscription? _timer;

  SyncStatusCubit({
    PosSyncManager? manager,
    Future<void> Function()? onChangesApplied,
  }) : manager = manager ?? PosSyncManager.instance,
       super(const PosSyncState()) {
    this.manager.onChangesApplied = onChangesApplied;
  }

  Future<void> initialize() async {
    await manager.initialize();
    emit(manager.state);
    _timer ??= Stream.periodic(const Duration(seconds: 2)).listen((_) {
      if (!isClosed) emit(manager.state);
    });
  }

  Future<bool> retry() async {
    final changesApplied = await manager.synchronize();
    if (!isClosed) emit(manager.state);
    return changesApplied;
  }

  @override
  Future<void> close() async {
    await _timer?.cancel();
    return super.close();
  }
}
