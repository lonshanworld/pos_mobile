import 'package:pos_mobile/database/junction_folder/report_and_alerts/alert_junctions/alert_targetproduct_Db/alert_targetproduct_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class AlertTargetProductDbService{
  static Future<void>initAlertTargetProductDb(Database db)async{
    await AlertTargetProductDbStorage.onCreate(db);
  }

  static Future<void>deleteAlertTargetProductDb(Database db)async{
    await AlertTargetProductDbStorage.onDelete(db);
  }
}