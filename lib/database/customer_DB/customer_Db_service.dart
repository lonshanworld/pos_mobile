import 'package:pos_mobile/database/customer_DB/customer_Db_Storage.dart';
import 'package:pos_mobile/models/customer_model.dart';
import 'package:sqflite/sqflite.dart';

class CustomerDbService{
  static Future<void>initCustomerDb(Database db)async{
    await CustomerDbStorage.onCreate(db);
  }

  static Future<void>deleteCustomerDb(Database db)async{
    await CustomerDbStorage.onDelete(db);
  }

  static Future<List<CustomerModel>>getAllCustomer(Database db)async{
    List<dynamic> rawDataList = await CustomerDbStorage.getAllData(db);
    return rawDataList.map((e) => CustomerModel.fromJson(e)).toList();
  }

  static Future<int>addNewCustomer(Database db, String customerName)async{
    return await CustomerDbStorage.insertNewData(db,customerName);
  }
}