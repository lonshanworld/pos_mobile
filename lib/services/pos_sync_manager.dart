import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

import 'network_environment.dart';
import 'pending_operation_sync.dart';
import 'pos_repository.dart';

class PosSyncState {
  final bool online;
  final bool syncing;
  final int succeeded;
  final int failed;
  final int conflicts;
  final List<String> conflictMessages;
  final String? error;
  const PosSyncState({
    this.online = false,
    this.syncing = false,
    this.succeeded = 0,
    this.failed = 0,
    this.conflicts = 0,
    this.conflictMessages = const [],
    this.error,
  });
}

class PosSyncManager {
  static final PosSyncManager instance = PosSyncManager();
  final PosRepository repository;
  final PendingOperationSync pendingSync;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  PosSyncState state = const PosSyncState();
  bool _running = false;
  Future<void> Function()? onChangesApplied;

  PosSyncManager({PosRepository? repository})
    : repository = repository ?? PosRepository.instance,
      pendingSync = PendingOperationSync(
        api: (repository ?? PosRepository.instance).api,
      );

  Future<void> initialize() async {
    if (!NetworkConfiguration.usesBackend) return;
    final initial = await Connectivity().checkConnectivity();
    _setOnline(_hasNetwork(initial));
    _subscription = Connectivity().onConnectivityChanged.listen((results) {
      final online = _hasNetwork(results);
      _setOnline(online);
      if (online) unawaited(synchronize());
    });
    // A connectivity check is safe before login, but refreshing the shop's
    // data is not. A fresh login will explicitly retry synchronization.
    if (state.online && repository.api.token != null) await synchronize();
  }

  Future<bool> synchronize() async {
    if (kIsWeb ||
        !state.online ||
        _running ||
        !NetworkConfiguration.usesBackend ||
        repository.api.token == null) {
      return false;
    }
    _running = true;
    state = const PosSyncState(online: true, syncing: true);
    try {
      await repository.api.request('GET', '/health');
      final summary = kIsWeb
          ? const SyncSummary()
          : await pendingSync.synchronize();
      final changes = await repository.refreshChanges();
      if (changes.isNotEmpty) {
        await onChangesApplied?.call();
      }
      state = PosSyncState(
        online: true,
        succeeded: summary.succeeded,
        failed: summary.failed,
        conflicts: summary.conflicts,
        conflictMessages: summary.conflictMessages,
      );
      return changes.isNotEmpty;
    } catch (error) {
      state = PosSyncState(online: true, failed: 1, error: error.toString());
      return false;
    } finally {
      _running = false;
    }
  }

  void _setOnline(bool online) => state = PosSyncState(online: online);

  bool _hasNetwork(List<ConnectivityResult> results) => results.any(
    (result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn,
  );

  void dispose() => _subscription?.cancel();
}
