import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/utils/debug_print.dart';

class CrashReportApiService {
  static const String _baseUrl = String.fromEnvironment(
    'CRASH_REPORT_URL',
    defaultValue: 'http://localhost:8000',
  );

  static const String _apiToken = String.fromEnvironment(
    'CRASH_REPORT_TOKEN',
    defaultValue: '',
  );

  static Future<bool> syncCrashReports() async {
    try {
      if (_apiToken.isEmpty) {
        cusDebugPrint('Crash report token not configured');
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
              'Authorization': 'Bearer $_apiToken',
            },
            body: jsonEncode({
              'reports': unsyncedReports.map((r) => r.toJson()).toList(),
            }),
          )
          .timeout(const Duration(seconds: 30));

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
      } else if (response.statusCode == 429) {
        cusDebugPrint('Rate limit exceeded for crash reports');
        return false;
      } else {
        cusDebugPrint('Failed to sync crash reports: ${response.statusCode}');
        return false;
      }
    } on SocketException {
      cusDebugPrint('No internet connection for crash report sync');
      return false;
    } on http.ClientException {
      cusDebugPrint('Network error during crash report sync');
      return false;
    } catch (e) {
      cusDebugPrint('Error syncing crash reports: $e');
      return false;
    }

    return false;
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
}
