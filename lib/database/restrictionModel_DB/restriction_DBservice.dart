import 'package:pos_mobile/database/restrictionModel_DB/restriction_DBStorage.dart';
import 'package:pos_mobile/models/restriction_model_folder/restriction_model.dart';
import 'package:sqflite/sqflite.dart';

class RestrictionDBService{
  static Future<void>initRestrictionDb(Database db)async{
    await RestrictionDbStorage.onCreate(db);
  }

  static Future<void>deleteRestrictionDb(Database db)async{
    await RestrictionDbStorage.onDelete(db);
  }

  static Future<List<RestrictionModel>>getAllRestrictons(Database db)async{
    List<dynamic> dataList = await RestrictionDbStorage.getAllRestrictions(db);
    return dataList.map((e) => RestrictionModel.fromJson(e)).toList();
  }

  static Future<bool>addNewRestriction({
    required Database db,
    required String title,
    required String reason,
    required int createPersonId,
  })async{
    int value = await RestrictionDbStorage.insertNewRestriction(db: db, title: title, reason: reason, createPersonId: createPersonId);
    if(value == -1){
      return false;
    }else{
      return true;
    }
  }
}