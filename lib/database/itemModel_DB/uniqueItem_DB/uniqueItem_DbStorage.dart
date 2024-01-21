import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../constants/txtconstants.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';


class UniqueItemDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
        """
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
          moduleCount INTEGER
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.uniqueItemTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>> getAllUniqueItemList(Database db)async{
    return await db.query(TxtConstants.uniqueItemTableName);
  }

  // static Future<List<dynamic>>getAllActiveUniqueItems(Database db)async{
  //   return await db.rawQuery(
  //       """
  //         SELECT * FROM ${TxtConstants.uniqueItemTableName}
  //       """,);
  // }
  static Future<List<dynamic>> getSingleUniqueItemList(
    Database db,
    {
      required int uniqueItemId,
    }
  )async{
    return db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.uniqueItemTableName} WHERE id = ?
        """,
        [uniqueItemId]
    );
  }

  static Future<List<int>>insertNewDataList({
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
  })async{
    final Batch batch =db.batch();
    for(int i = 0 ; i < itemLength; i++ ){
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
            getItemFromWhere
          )
          VALUES(?,?,?,?,?,?,?,?,?,?,?)
        """,
        [
          itemModel.id,
          stockInId,
          dateTime.toString(),
          userModel.id,
          itemManufactureDate?.toString(),
          itemExpireDate?.toString(),
          itemModel.originalPrice,
          itemModel.profitPrice,
          itemModel.taxPercentage,
          code,
          getItemFromWhere
        ],
      );
    }
    final List<int>results = (await batch.commit()).map((e) => e is int ? e : null).cast<int>().toList();
    return results;
  }

  static Future<List<int>> stockOutUniqueItemList(
    Database db,
    {
      required List<UniqueItemModel> uniqueItemList,
      required UserModel userModel,
      required DateTime dateTime,
      required int stockOutId,
    }
  )async{
    final Batch batch =db.batch();
    for(int a = 0; a < uniqueItemList.length; a++){
      batch.rawUpdate(
          """
            UPDATE ${TxtConstants.uniqueItemTableName}
            SET 
            stockOutId = ?,
            deleteTime = ?,
            deletePersonId = ?,
            activeStatus = ?
            WHERE id = ?
          """,
          [
            stockOutId,
            dateTime.toString(),
            userModel.id,
            0,
            uniqueItemList[a].id
          ]
      );
    }
    final List<int>results = (await batch.commit()).map((e) => e is int ? e : null).cast<int>().toList();
    return results;
  }

  static Future<List<int>>deactivateUniqueItemList(
    Database db,
    {
      required UserModel userModel,
      required List<UniqueItemModel> uniqueItemList,
      required DateTime dateTime,
    }
  )async{
    final Batch batch = db.batch();
    for(int i = 0; i < uniqueItemList.length; i++){
      batch.rawUpdate(
          """
            UPDATE ${TxtConstants.uniqueItemTableName}
            SET
            deleteTime = ?,
            deletePersonId = ?,
            activeStatus = ?
            WHERE id = ?
          """,
          [
            dateTime.toString(),
            userModel.id,
            0,
            uniqueItemList[i].id
          ]
      );
    }
    final List<int>results = (await batch.commit()).map((e) => e is int ? e : null).cast<int>().toList();
    return results;
  }

  static Future<List<int>>updateUniqueItemList(
      Database db,
      {
        required UserModel userModel,
        required List<UniqueItemModel> uniqueItemList,
        required DateTime dateTime,
        required double profitPrice,
        required double originalPrice,
        required double taxPercentage,
      }
      )async{
    final Batch batch = db.batch();
    for(int i = 0; i < uniqueItemList.length; i++){
      batch.rawUpdate(
          """
            UPDATE ${TxtConstants.uniqueItemTableName}
            SET
            lastUpdateTime = ?,
            originalPrice = ?,
            profitPrice = ?,
            taxPercentage = ?
            WHERE id = ? AND activeStatus = ?
          """,
          [
            dateTime.toString(),
            originalPrice,
            profitPrice,
            taxPercentage,
            uniqueItemList[i].id,
            1,
          ]
      );
    }
    final List<int>results = (await batch.commit()).map((e) => e is int ? e : null).cast<int>().toList();
    return results;
  }

  static Future<List<dynamic>> getSelectedUniqueItemListFromStockOutId(
    Database db,
    {
      required int stockOutId,
    }
  )async{
    return db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.uniqueItemTableName} WHERE stockOutId = ?
        """,
        [stockOutId]
    );
  }

  static Future<int>reInStockUniqueItemList(
    Database db,
    {
      required int stockOutId,
      required double originalPrice,
      required double profitPrice,
      required double taxPercentage,
      required DateTime dateTime,

    }
  )async{
    return db.rawUpdate(
        """
          UPDATE ${TxtConstants.uniqueItemTableName}
          SET 
          originalPrice = ?,
          profitPrice = ?,
          taxPercentage = ?,
          lastUpdateTime = ?,
          activeStatus = ?,
          deleteTime = ?,
          deletePersonId = ?
          WHERE stockOutId = ? AND activeStatus = ?
        """,
        [originalPrice, profitPrice, taxPercentage, dateTime.toString(), 1, null, null,stockOutId, 0]);
  }

  static Future<int>deActivateSingleUniqueItem(
    Database db,
    {
      required int uniqueItemId,
      required UserModel userModel,
      required DateTime dateTime,
    }
  )async{
    return db.rawUpdate(
        """
          UPDATE ${TxtConstants.uniqueItemTableName}
          SET
          deleteTime = ?,
          deletePersonId = ?,
          activeStatus = ?
          WHERE id = ?
        """,
        [dateTime.toString(), userModel.id, 0, uniqueItemId]
    );
  }
}