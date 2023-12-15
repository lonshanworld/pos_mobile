import 'package:pos_mobile/database/delivery_folder/delivery_model_DB/delivery_model_DbStorage.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_model.dart';
import 'package:sqflite/sqflite.dart';

class DeliveryModelDbService{
  static Future<void>initDeliveryModelDb(Database db)async{
    await DeliveryModelDbStorage.onCreate(db);
  }

  static Future<void>deleteDeliveryModelDb(Database db)async{
    await DeliveryModelDbStorage.onDelete(db);
  }

  static Future<List<DeliveryModel>>getAllDeliveryModel(Database db)async{
    List<dynamic> rawDataList = await DeliveryModelDbStorage.getAllData(db);
    return rawDataList.map((e) => DeliveryModel.fromJson(e)).toList();
  }

  static Future<int>createNewDeliveryModel(Database db, double deliveryCharges)async{
    return await DeliveryModelDbStorage.insertNewData(db, deliveryCharges);
  }
}