import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/models/crash_report_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class CrashReporter {
  CrashReporter._();

  static PackageInfo? _packageInfo;

  static Future<void> _saveToLocalDatabase({
    required dynamic error,
    required StackTrace? stackTrace,
    required String errorType,
  }) async {
    try {
      _packageInfo ??= await PackageInfo.fromPlatform();

      final report = CrashReportModel(
        id: 0,
        errorMessage: error.toString(),
        stackTrace: stackTrace?.toString() ?? 'No stack trace',
        deviceInfo: Platform.operatingSystem,
        userInfo: null,
        appVersion: _packageInfo!.version,
        platform: Platform.operatingSystem,
        timestamp: DateTime.now(),
        errorType: errorType,
        isSynced: false,
      );

      await DBHelper.saveCrashReport(report);
      cusDebugPrint('Crash report saved to local database');
    } catch (e) {
      cusDebugPrint('Failed to save crash report to database: $e');
    }
  }

  static Future<void> initialize({
    required FutureOr<void> Function() appRunner,
  }) async {
    const sentryDsn = String.fromEnvironment('SENTRY_DSN');

    FlutterError.onError = (FlutterErrorDetails details) async {
      FlutterError.presentError(details);

      await _saveToLocalDatabase(
        error: details.exception,
        stackTrace: details.stack,
        errorType: 'FlutterError',
      );

      if (sentryDsn.isNotEmpty) {
        await Sentry.captureException(
          details.exception,
          stackTrace: details.stack,
        );
      } else {
        cusDebugPrint('FlutterError: ${details.exceptionAsString()}');
      }
    };

    PlatformDispatcher.instance.onError = (error, stack) {
      _saveToLocalDatabase(
        error: error,
        stackTrace: stack,
        errorType: 'PlatformError',
      );

      if (sentryDsn.isNotEmpty) {
        Sentry.captureException(error, stackTrace: stack);
      } else {
        cusDebugPrint('PlatformError: $error');
      }
      return true;
    };

    if (sentryDsn.isEmpty) {
      await appRunner();
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.tracesSampleRate = kReleaseMode ? 0.2 : 1.0;
        options.environment = kReleaseMode ? 'production' : 'development';
      },
      appRunner: () async {
        await appRunner();
      },
    );
  }
}
