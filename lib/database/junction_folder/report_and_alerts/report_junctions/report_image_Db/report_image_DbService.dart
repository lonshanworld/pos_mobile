import 'package:pos_mobile/database/junction_folder/report_and_alerts/report_junctions/report_image_Db/report_image_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class ReportImageDbService{
  static Future<void>initReportImageDb(Database db)async{
    await ReportImageDbStorage.onCreate(db);
  }

  static Future<void>deleteReportImageDb(Database db)async{
    await ReportImageDbStorage.onDelete(db);
  }
}