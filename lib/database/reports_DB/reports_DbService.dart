import 'package:pos_mobile/database/reports_DB/reports_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class ReportDbService{
  static Future<void>initReportDb(Database db)async{
    await ReportDbStorage.onCreate(db);
  }

  static Future<void>deleteReportDb(Database db)async{
    await ReportDbStorage.onDelete(db);
  }

  static Future<List<dynamic>>getAllReports(Database db, {int limit = 100, int offset = 0})async{
    return await ReportDbStorage.getAllData(db, limit: limit, offset: offset);
  }
}