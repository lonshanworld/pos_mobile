import 'package:pos_mobile/database/junction_folder/report_and_alerts/report_junctions/report_targetproduct_Db/report_targetproduct_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class ReportTargetProductDbService{
  static Future<void>initReportTargetProductDb(Database db)async{
    await ReportTargetProductDbStorage.onCreate(db);
  }

  static Future<void>deleteReportTargetProductDb(Database db)async{
    await ReportTargetProductDbStorage.onDelete(db);
  }
}