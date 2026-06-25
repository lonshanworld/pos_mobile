import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/database/delivery_folder/delivery_person_DB/delivery_person_DbStorage.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_person_model.dart';
import 'package:sqflite/sqflite.dart';

class DeliveryPersonDbService{
  static Future<void>initDeliveryPersonDb(Database db)async{
    await DeliveryPersonDbStorage.onCreate(db);
  }

  static Future<void>deletePerson(Database db)async{
    await DeliveryPersonDbStorage.onDelete(db);
  }

  static Future<List<DeliveryPersonModel>> getAllDeliveryPerson(Database db, {int limit = UIConstants.defaultPageLimit, int offset = 0})async{
    List<dynamic> rawDataList = await DeliveryPersonDbStorage.getAllData(db, limit: limit, offset: offset);
    return rawDataList.map((e) => DeliveryPersonModel.fromJson(e)).toList();
  }

  static Future<int>addNewDeliveryPerson(Database db, String name)async{
    return await DeliveryPersonDbStorage.insertNewData(db, name);
  }
}