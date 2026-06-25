import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/utils/debug_print.dart';

class CrashReportApiService {
  static const String _baseUrl = String.fromEnvironment(
    'CRASH_REPORT_URL',
    defaultValue: 'https://minipos-crash-backend.nanonux.com',
  );

  static const Duration _requestTimeout = Duration(seconds: 30);
  static const int _maxLogBodyLength = 500;

  static Future<bool> syncCrashReports() async {
    try {
      final deviceId = GetStorage().read('device_id');
      if (deviceId == null) {
        cusDebugPrint('Device ID not found, cannot sync crash reports');
        return false;
      }

      final unsyncedReports = await DBHelper.getUnsyncedCrashReports();

      if (unsyncedReports.isEmpty) {
        cusDebugPrint('No unsynced crash reports');
        return true;
      }

      cusDebugPrint('Syncing ${unsyncedReports.length} crash reports...');

      final response = await http
          .post(
            Uri.parse('$_baseUrl/api/crash-reports'),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $deviceId',
            },
            body: jsonEncode({
              'reports': unsyncedReports.map((r) => r.toJson()).toList(),
            }),
          )
          .timeout(_requestTimeout);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);

        if (responseData['status'] == 'Finish' ||
            responseData['message'] == 'Finish') {
          final reportIds = unsyncedReports.map((r) => r.id).toList();
          await DBHelper.markCrashReportsAsSynced(reportIds);
          await DBHelper.deleteSyncedCrashReports();

          cusDebugPrint('Successfully synced crash reports');
          return true;
        }

        cusDebugPrint(
          'Crash report sync returned unexpected response: '
          '${_safeResponseBody(response.body)}',
        );
        return false;
      } else if (response.statusCode == 429) {
        cusDebugPrint(
          'Rate limit exceeded for crash reports: '
          '${_safeResponseBody(response.body)}',
        );
        return false;
      } else {
        cusDebugPrint(
          'Failed to sync crash reports: ${response.statusCode} '
          '${_safeResponseBody(response.body)}',
        );
        return false;
      }
    } on SocketException {
      cusDebugPrint('No internet connection for crash report sync');
      return false;
    } on http.ClientException {
      cusDebugPrint('Network error during crash report sync');
      return false;
    } on TimeoutException {
      cusDebugPrint('Crash report sync timed out');
      return false;
    } on FormatException catch (e) {
      cusDebugPrint('Invalid crash report sync response: $e');
      return false;
    } catch (e) {
      cusDebugPrint('Error syncing crash reports: $e');
      return false;
    }
  }

  static Future<void> periodicSync() async {
    try {
      final count = await DBHelper.getUnsyncedCrashReportCount();
      if (count > 0) {
        cusDebugPrint('Found $count unsynced crash reports, attempting sync...');
        await syncCrashReports();
      }
    } catch (e) {
      cusDebugPrint('Error in periodic crash report sync: $e');
    }
  }

  static String _safeResponseBody(String body) {
    if (body.isEmpty) {
      return '<empty response>';
    }

    if (body.length <= _maxLogBodyLength) {
      return body;
    }

    return '${body.substring(0, _maxLogBodyLength)}...';
  }
}
