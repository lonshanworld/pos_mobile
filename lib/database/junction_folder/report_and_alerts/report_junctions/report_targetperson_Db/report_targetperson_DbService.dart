import 'package:pos_mobile/database/junction_folder/report_and_alerts/report_junctions/report_targetperson_Db/report_targetperson_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class ReportTargetPersonDbService{
  static Future<void>initReportTargetPersonDb(Database db)async{
    await ReportTargetPersonDbStorage.onCreate(db);
  }

  static Future<void>deleteReportTargetPersonDb(Database db)async{
    await ReportTargetPersonDbStorage.onDelete(db);
  }
}