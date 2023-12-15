import 'package:pos_mobile/database/alerts_DB/alert_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class AlertDbService{
  static Future<void>initAlertDb(Database db)async{
    await AlertDbStorage.onCreate(db);
  }

  static Future<void>deleteAlertDb(Database db)async{
    await AlertDbStorage.onDelete(db);
  }
}