import 'package:pos_mobile/database/alerts_DB/alert_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class AlertDbService{
  static Future<void>initAlertDb(Database db)async{
    await AlertDbStorage.onCreate(db);
  }

  static Future<void>deleteAlertDb(Database db)async{
    await AlertDbStorage.onDelete(db);
  }

  static Future<List<dynamic>>getAllAlerts(Database db, {int limit = 100, int offset = 0})async{
    return await AlertDbStorage.getAllData(db, limit: limit, offset: offset);
  }
}