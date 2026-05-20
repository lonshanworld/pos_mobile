import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pos_mobile/services/crash_report_api_service.dart';
import 'package:pos_mobile/utils/debug_print.dart';

/// Manages automatic syncing of crash reports based on connectivity status
class CrashReportSyncManager {
  static CrashReportSyncManager? _instance;
  static CrashReportSyncManager get instance {
    _instance ??= CrashReportSyncManager._();
    return _instance!;
  }

  CrashReportSyncManager._();

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicSyncTimer;
  bool _isOnline = false;
  bool _isInitialized = false;
  bool _isSyncing = false;

  /// Initialize the sync manager and start monitoring connectivity
  Future<void> initialize() async {
    if (_isInitialized) {
      cusDebugPrint('CrashReportSyncManager already initialized');
      return;
    }

    cusDebugPrint('Initializing CrashReportSyncManager...');

    // Check initial connectivity
    final connectivityResult = await Connectivity().checkConnectivity();
    _isOnline = _hasConnectivity(connectivityResult);
    cusDebugPrint('Initial connectivity: ${_isOnline ? "Online" : "Offline"}');

    // If online at startup, attempt initial sync
    if (_isOnline) {
      _attemptSync(reason: 'Initial startup');
    }

    // Listen for connectivity changes
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      _onConnectivityChanged,
      onError: (error) {
        cusDebugPrint('Connectivity listener error: $error');
      },
    );

    // Set up periodic sync while online (every 5 minutes)
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _attemptSync(reason: 'Periodic check'),
    );

    _isInitialized = true;
    cusDebugPrint('CrashReportSyncManager initialized successfully');
  }

  /// Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    final wasOnline = _isOnline;
    _isOnline = _hasConnectivity(results);

    if (_isOnline && !wasOnline) {
      // Device just came online
      cusDebugPrint('Device came online - attempting crash report sync');
      _attemptSync(reason: 'Device came online');
    } else if (!_isOnline && wasOnline) {
      // Device went offline
      cusDebugPrint('Device went offline');
    }
  }

  /// Check if any of the connectivity results indicate online status
  bool _hasConnectivity(List<ConnectivityResult> results) {
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);
  }

  /// Attempt to sync crash reports (only if online and not already syncing)
  Future<void> _attemptSync({required String reason}) async {
    if (!_isOnline) {
      cusDebugPrint('Skipping sync: Device is offline');
      return;
    }

    if (_isSyncing) {
      cusDebugPrint('Skipping sync: Already syncing');
      return;
    }

    _isSyncing = true;
    try {
      cusDebugPrint('Attempting crash report sync ($reason)...');
      // periodicSync already checks if there are reports before sending
      await CrashReportApiService.periodicSync();
    } catch (e) {
      cusDebugPrint('Error during crash report sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// Manually trigger a sync (useful for manual refresh buttons)
  Future<void> manualSync() async {
    cusDebugPrint('Manual sync triggered');
    await _attemptSync(reason: 'Manual trigger');
  }

  /// Get current connectivity status
  bool get isOnline => _isOnline;

  /// Clean up resources
  void dispose() {
    cusDebugPrint('Disposing CrashReportSyncManager...');
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    _isInitialized = false;
    _instance = null;
  }
}
