import 'package:pos_mobile/database/crash_report_DB/crash_report_DBStorage.dart';
import 'package:pos_mobile/models/crash_report_model.dart';
import 'package:sqflite/sqflite.dart';

class CrashReportDbService {
  static Future<void> initCrashReportDb(Database db) async {
    await CrashReportDbStorage.onCreate(db);
  }

  static Future<void> deleteCrashReportDb(Database db) async {
    await CrashReportDbStorage.onDelete(db);
  }

  static Future<int> saveCrashReport(Database db, CrashReportModel report) async {
    final data = report.toMap();
    data.remove('id');
    return await CrashReportDbStorage.insertCrashReport(db, data);
  }

  static Future<List<CrashReportModel>> getUnsyncedReports(Database db) async {
    final maps = await CrashReportDbStorage.getAllUnsyncedReports(db);
    return maps.map((map) => CrashReportModel.fromMap(map)).toList();
  }

  static Future<List<CrashReportModel>> getAllReports(Database db) async {
    final maps = await CrashReportDbStorage.getAllReports(db);
    return maps.map((map) => CrashReportModel.fromMap(map)).toList();
  }

  static Future<bool> markReportsAsSynced(Database db, List<int> ids) async {
    final count = await CrashReportDbStorage.markAsSynced(db, ids);
    return count > 0;
  }

  static Future<bool> deleteSyncedReports(Database db) async {
    final count = await CrashReportDbStorage.deleteAllSynced(db);
    return count > 0;
  }

  static Future<int> getUnsyncedCount(Database db) async {
    return await CrashReportDbStorage.getUnsyncedCount(db);
  }
}
