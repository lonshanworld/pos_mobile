import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/models/item_model_folder/item_business_detail_model.dart';
import 'package:sqflite/sqflite.dart';

class ItemBusinessDetailDbStorage {
  static Future<void> onCreate(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${TxtConstants.itemBusinessDetailTableName}(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itemId INTEGER NOT NULL UNIQUE REFERENCES ${TxtConstants.itemTableName}(id),
        clothingColor TEXT,
        measurementLength REAL,
        measurementWidth REAL,
        measurementUnit TEXT,
        pricePerMeasurementUnit REAL,
        brand TEXT,
        deviceCategory TEXT,
        deviceColor TEXT,
        ram TEXT,
        rom TEXT,
        modelNumber TEXT,
        weightValue REAL,
        weightUnit TEXT,
        packSize TEXT,
        barcode TEXT,
        isOrganic INTEGER NOT NULL DEFAULT 0,
        shelfLifeDays INTEGER,
        dosage TEXT,
        activeIngredient TEXT,
        manufacturer TEXT
      )
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_itemBusinessDetail_itemId ON ${TxtConstants.itemBusinessDetailTableName}(itemId);',
    );
  }

  static Future<void> onDelete(Database db) async {
    await db.execute(
      'DROP TABLE IF EXISTS ${TxtConstants.itemBusinessDetailTableName}',
    );
  }

  static Future<List<Map<String, Object?>>> getAll(Database db) async {
    return db.query(TxtConstants.itemBusinessDetailTableName);
  }

  static Future<Map<String, Object?>?> getByItemId(Database db, int itemId) async {
    final rows = await db.query(
      TxtConstants.itemBusinessDetailTableName,
      where: 'itemId = ?',
      whereArgs: [itemId],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return rows.first;
  }

  static Future<int> upsert(Database db, ItemBusinessDetailModel detail) async {
    final existing = await getByItemId(db, detail.itemId);
    if (existing == null) {
      return db.insert(
        TxtConstants.itemBusinessDetailTableName,
        detail.toJson()..remove('id'),
      );
    }
    return db.update(
      TxtConstants.itemBusinessDetailTableName,
      detail.toJson()..remove('id'),
      where: 'itemId = ?',
      whereArgs: [detail.itemId],
    );
  }

  static Future<int> deleteByItemId(Database db, int itemId) async {
    return db.delete(
      TxtConstants.itemBusinessDetailTableName,
      where: 'itemId = ?',
      whereArgs: [itemId],
    );
  }
}
