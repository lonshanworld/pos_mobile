import 'package:pos_mobile/database/itemModel_DB/module_component_item_DB/module_component_item_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class ModuleComponentItemDbService{
  static Future<void>initModuleComponentItemDbService(Database db)async{
    await ModuleComponentItemDbStorage.onCreate(db);
  }

}