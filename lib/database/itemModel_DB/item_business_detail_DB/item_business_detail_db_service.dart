import 'package:pos_mobile/database/itemModel_DB/item_business_detail_DB/item_business_detail_db_storage.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';
import 'package:sqflite/sqflite.dart';

class ItemBusinessDetailDbService {
  static Future<void> initItemBusinessDetailDb(Database db) async {
    await ItemBusinessDetailDbStorage.onCreate(db);
  }

  static Future<List<ItemBusinessDetailModel>> getAll(Database db) async {
    final rows = await ItemBusinessDetailDbStorage.getAll(db);
    return rows.map((e) => ItemBusinessDetailModel.fromJson(e)).toList();
  }

  static Future<ItemBusinessDetailModel?> getByItemId(Database db, int itemId) async {
    final row = await ItemBusinessDetailDbStorage.getByItemId(db, itemId);
    if (row == null) return null;
    return ItemBusinessDetailModel.fromJson(row);
  }

  static Future<bool> upsert(Database db, ItemBusinessDetailModel detail) async {
    if (detail.isEmpty) {
      await ItemBusinessDetailDbStorage.deleteByItemId(db, detail.itemId);
      return true;
    }
    final result = await ItemBusinessDetailDbStorage.upsert(db, detail);
    return result != -1;
  }

  static Future<bool> deleteByItemId(Database db, int itemId) async {
    final result = await ItemBusinessDetailDbStorage.deleteByItemId(db, itemId);
    return result != -1;
  }
}
