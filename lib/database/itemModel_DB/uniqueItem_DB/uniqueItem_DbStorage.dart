import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../constants/txtconstants.dart';
import '../../../models/stock_in_unit_spec.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';

class UniqueItemDbStorage {
  static Future<void> onCreate(Database db) async {
    await db.execute("""
        CREATE TABLE IF NOT EXISTS ${TxtConstants.uniqueItemTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          itemId INTEGER REFERENCES ${TxtConstants.itemTableName}(id) NOT NULL,
          stockInId INTEGER REFERENCES ${TxtConstants.stockInTableName}(id) NOT NULL,
          stockOutId INTEGER REFERENCES ${TxtConstants.stockOutTableName}(id),
          createTime TEXT NOT NULL,
          lastUpdateTime TEXT,
          deleteTime TEXT,
          itemManufactureDate TEXT,
          itemExpireDate TEXT,
          code TEXT,
          originalPrice REAL NOT NULL DEFAULT 0,
          profitPrice REAL NOT NULL DEFAULT 0,
          taxPercentage REAL NOT NULL DEFAULT 0,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
          activeStatus INTEGER NOT NULL DEFAULT 1,
          getItemFromWhere TEXT,
          moduleCount INTEGER,
          instanceImei TEXT
        )
      """);
    // OPTIMIZATION: Add indexes for itemId, stockOutId, and activeStatus
    await db.execute(
      "CREATE INDEX IF NOT EXISTS idx_uniqueItem_itemId ON ${TxtConstants.uniqueItemTableName}(itemId);",
    );
    await db.execute(
      "CREATE INDEX IF NOT EXISTS idx_uniqueItem_stockOutId ON ${TxtConstants.uniqueItemTableName}(stockOutId);",
    );
    await db.execute(
      "CREATE INDEX IF NOT EXISTS idx_uniqueItem_activeStatus ON ${TxtConstants.uniqueItemTableName}(activeStatus);",
    );
  }

  static Future<void> onDelete(Database db) async {
    await db.execute("""
        DROP TABLE IF EXISTS ${TxtConstants.uniqueItemTableName}
      """);
  }

  static Future<void> onUpgrade(Database db) async {
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>> getAllUniqueItemList(
    Database db, {
    int limit = 100,
    int offset = 0,
  }) async {
    return await db.query(
      TxtConstants.uniqueItemTableName,
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
  }

  static Future<int> updateUniqueItemBarcode(
    Database db, {
    required int uniqueItemId,
    required String barcode,
    required DateTime dateTime,
  }) async {
    return db.rawUpdate(
      """
        UPDATE ${TxtConstants.uniqueItemTableName}
        SET code = ?, lastUpdateTime = ?
        WHERE id = ? AND activeStatus = 1 AND stockOutId IS NULL
      """,
      [barcode, dateTime.toString(), uniqueItemId],
    );
  }

  // static Future<List<dynamic>>getAllActiveUniqueItems(Database db)async{
  //   return await db.rawQuery(
  //       """
  //         SELECT * FROM ${TxtConstants.uniqueItemTableName}
  //       """,);
  // }
  static Future<List<dynamic>> getSingleUniqueItemList(
    Database db, {
    required int uniqueItemId,
  }) async {
    return db.rawQuery(
      """
          SELECT * FROM ${TxtConstants.uniqueItemTableName} WHERE id = ?
        """,
      [uniqueItemId],
    );
  }

  static Future<List<int>> insertNewDataList({
    required Database db,
    required int itemLength,
    required UserModel userModel,
    required int stockInId,
    required DateTime dateTime,
    required ItemModel itemModel,
    required DateTime? itemManufactureDate,
    required DateTime? itemExpireDate,
    required String? getItemFromWhere,
    required String? code,
    List<StockInUnitSpec>? unitSpecs,
  }) async {
    final int count = unitSpecs?.isNotEmpty == true
        ? unitSpecs!.length
        : itemLength;
    final Batch batch = db.batch();
    for (int i = 0; i < count; i++) {
      final StockInUnitSpec? spec = unitSpecs != null && i < unitSpecs.length
          ? unitSpecs[i]
          : null;
      final double originalPrice =
          spec?.originalPrice ?? itemModel.originalPrice;
      final double profitPrice = spec?.profitPrice ?? itemModel.profitPrice;
      final String? unitCode = spec?.code ?? code;

      batch.rawInsert(
        """
          INSERT INTO ${TxtConstants.uniqueItemTableName}
          (
            itemId,
            stockInId,
            createTime,
            createPersonId,
            itemManufactureDate,
            itemExpireDate,
            originalPrice,
            profitPrice,
            taxPercentage,
            code,
            getItemFromWhere,
            instanceLength,
            instanceWidth,
            instanceBatchNumber,
            instanceImei
          )
          VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        """,
        [
          itemModel.id,
          stockInId,
          dateTime.toString(),
          userModel.id,
          itemManufactureDate?.toString(),
          itemExpireDate?.toString(),
          originalPrice,
          profitPrice,
          itemModel.taxPercentage,
          unitCode,
          getItemFromWhere,
          spec?.instanceLength,
          spec?.instanceWidth,
          spec?.instanceBatchNumber,
          spec?.instanceImei,
        ],
      );
    }
    final List<int> results = (await batch.commit())
        .map((e) => e is int ? e : null)
        .cast<int>()
        .toList();
    return results;
  }

  static Future<List<int>> stockOutUniqueItemList(
    Database db, {
    required List<UniqueItemModel> uniqueItemList,
    required UserModel userModel,
    required DateTime dateTime,
    required int stockOutId,
  }) async {
    final List<int> results = [];
    for (int a = 0; a < uniqueItemList.length; a++) {
      final UniqueItemModel cartUnit = uniqueItemList[a];

      if (cartUnit.id < 0) {
        results.add(0);
        continue;
      }

      final List<Map<String, dynamic>> dbRows = await db.query(
        TxtConstants.uniqueItemTableName,
        where: 'id = ?',
        whereArgs: [cartUnit.id],
      );
      if (dbRows.isEmpty) {
        results.add(-1);
        continue;
      }
      final Map<String, dynamic> dbRow = dbRows.first;
      final double? dbLength = (dbRow['instanceLength'] as num?)?.toDouble();
      final double? cartLength = cartUnit.instanceLength;

      if (dbLength != null && cartLength != null && cartLength < dbLength) {
        // Clothing measurement split:
        final double remainingLength = dbLength - cartLength;
        final double originalDbOriginalPrice = (dbRow['originalPrice'] as num)
            .toDouble();
        final double originalDbProfitPrice = (dbRow['profitPrice'] as num)
            .toDouble();
        final double soldOriginalPrice = cartUnit.originalPrice;
        final double soldProfitPrice = cartUnit.profitPrice;
        final double remainingOriginalPrice =
            (originalDbOriginalPrice - soldOriginalPrice)
                .clamp(0, double.infinity)
                .toDouble();
        final double remainingProfitPrice =
            (originalDbProfitPrice - soldProfitPrice).toDouble();

        // Update the original piece in place with the remaining length and scaled prices
        final int updateCount = await db.rawUpdate(
          """
            UPDATE ${TxtConstants.uniqueItemTableName}
            SET
            instanceLength = ?,
            originalPrice = ?,
            profitPrice = ?,
            lastUpdateTime = ?
            WHERE id = ? AND activeStatus = 1
          """,
          [
            remainingLength,
            remainingOriginalPrice,
            remainingProfitPrice,
            dateTime.toString(),
            cartUnit.id,
          ],
        );

        // Insert a new inactive unique item record representing the sold portion
        final int insertId = await db.rawInsert(
          """
            INSERT INTO ${TxtConstants.uniqueItemTableName}
            (
              itemId,
              stockInId,
              stockOutId,
              createTime,
              lastUpdateTime,
              deleteTime,
              itemManufactureDate,
              itemExpireDate,
              code,
              originalPrice,
              profitPrice,
              taxPercentage,
              createPersonId,
              deletePersonId,
              activeStatus,
              getItemFromWhere,
              moduleCount,
              instanceLength,
              instanceWidth,
              instanceBatchNumber
            )
            VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
          """,
          [
            dbRow['itemId'],
            dbRow['stockInId'],
            stockOutId,
            dbRow['createTime'],
            dateTime.toString(),
            dateTime.toString(),
            dbRow['itemManufactureDate'],
            dbRow['itemExpireDate'],
            dbRow['code'],
            soldOriginalPrice,
            soldProfitPrice,
            dbRow['taxPercentage'],
            dbRow['createPersonId'],
            userModel.id,
            0,
            dbRow['getItemFromWhere'],
            dbRow['moduleCount'],
            cartLength,
            dbRow['instanceWidth'],
            dbRow['instanceBatchNumber'],
          ],
        );

        results.add(updateCount > 0 && insertId != -1 ? insertId : -1);
      } else {
        // Normal checkout: mark as sold
        final int count = await db.rawUpdate(
          """
            UPDATE ${TxtConstants.uniqueItemTableName}
            SET 
            stockOutId = ?,
            deleteTime = ?,
            deletePersonId = ?,
            activeStatus = ?
            WHERE id = ?
          """,
          [stockOutId, dateTime.toString(), userModel.id, 0, cartUnit.id],
        );
        results.add(count > 0 ? cartUnit.id : -1);
      }
    }
    return results;
  }

  static Future<List<int>> deactivateUniqueItemList(
    Database db, {
    required UserModel userModel,
    required List<UniqueItemModel> uniqueItemList,
    required DateTime dateTime,
  }) async {
    final Batch batch = db.batch();
    for (int i = 0; i < uniqueItemList.length; i++) {
      batch.rawUpdate(
        """
            UPDATE ${TxtConstants.uniqueItemTableName}
            SET
            deleteTime = ?,
            deletePersonId = ?,
            activeStatus = ?
            WHERE id = ?
          """,
        [dateTime.toString(), userModel.id, 0, uniqueItemList[i].id],
      );
    }
    final List<int> results = (await batch.commit())
        .map((e) => e is int ? e : null)
        .cast<int>()
        .toList();
    return results;
  }

  static Future<List<int>> updateUniqueItemList(
    Database db, {
    required UserModel userModel,
    required List<UniqueItemModel> uniqueItemList,
    required DateTime dateTime,
    required double profitPrice,
    required double originalPrice,
    required double taxPercentage,
  }) async {
    final Batch batch = db.batch();
    for (int i = 0; i < uniqueItemList.length; i++) {
      batch.rawUpdate(
        """
            UPDATE ${TxtConstants.uniqueItemTableName}
            SET
            lastUpdateTime = ?,
            originalPrice = ?,
            profitPrice = ?,
            taxPercentage = ?
            WHERE id = ? AND activeStatus = ? AND stockOutId IS NULL
          """,
        [
          dateTime.toString(),
          originalPrice,
          profitPrice,
          taxPercentage,
          uniqueItemList[i].id,
          1,
        ],
      );
    }
    final List<int> results = (await batch.commit())
        .map((e) => e is int ? e : null)
        .cast<int>()
        .toList();
    return results;
  }

  static Future<List<dynamic>> getSelectedUniqueItemListFromStockOutId(
    Database db, {
    required int stockOutId,
  }) async {
    return db.rawQuery(
      """
          SELECT * FROM ${TxtConstants.uniqueItemTableName} WHERE stockOutId = ? ORDER BY id DESC
        """,
      [stockOutId],
    );
  }

  static Future<int> reInStockUniqueItem(
    Database db, {
    required int uniqueItemId,
    required DateTime dateTime,
  }) async {
    return db.rawUpdate(
      """
          UPDATE ${TxtConstants.uniqueItemTableName}
          SET 
          lastUpdateTime = ?,
          activeStatus = ?,
          deleteTime = ?,
          deletePersonId = ?,
          stockOutId = ?
          WHERE id = ? AND activeStatus = ?
        """,
      [dateTime.toString(), 1, null, null, null, uniqueItemId, 0],
    );
  }

  static Future<int> deActivateSingleUniqueItem(
    Database db, {
    required int uniqueItemId,
    required UserModel userModel,
    required DateTime dateTime,
  }) async {
    return db.rawUpdate(
      """
          UPDATE ${TxtConstants.uniqueItemTableName}
          SET
          deleteTime = ?,
          deletePersonId = ?,
          activeStatus = ?
          WHERE id = ?
        """,
      [dateTime.toString(), userModel.id, 0, uniqueItemId],
    );
  }
}
