
import 'package:pos_mobile/database/junction_folder/report_and_alerts/alert_junctions/alert_targetperson_Db/alert_targetperson_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class AlertTargetPersonDbService{
  static Future<void>initAlertTargetPersonDb(Database db)async{
    await AlertTargetPersonDbStorage.onCreate(db);
  }

  static Future<void>deleteAlertTargetPersonDb(Database db)async{
    await AlertTargetPersonDbStorage.onDelete(db);
  }
}