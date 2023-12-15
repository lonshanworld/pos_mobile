import 'package:pos_mobile/database/junction_folder/report_and_alerts/alert_junctions/alert_knownperson_Db/alert_knownperson_DbStorage.dart';
import 'package:pos_mobile/models/junction_models_folder/alert_junctions/alert_knownperson_model.dart';
import 'package:sqflite/sqflite.dart';

class AlertKnownPersonDbService{
  static Future<void>initAlertKnownPersonDb(Database db)async{
    await AlertKnownPersonDbStorage.onCreate(db);
  }

  static Future<void>deleteAlertKnowPersonDb(Database db)async{
    await AlertKnownPersonDbStorage.onDelete(db);
  }

  static Future<List<AlertKnownPersonModel>> getAllAlertPersonList(Database db)async{
    List<dynamic> data = await AlertKnownPersonDbStorage.getAllData(db);
    return data.map((e) => AlertKnownPersonModel.fromJson(e)).toList();
  }
}