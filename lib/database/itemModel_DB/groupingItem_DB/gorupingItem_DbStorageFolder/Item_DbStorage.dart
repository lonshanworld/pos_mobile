import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../constants/txtconstants.dart';

class ItemDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.itemTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          typeId INTEGER REFERENCES ${TxtConstants.typeTableName}(id) NOT NULL,
          createTime TEXT NOT NULL,
          lastUpdateTime TEXT,
          deleteTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          description TEXT,
          hasExpire INTEGER NOT NULL DEFAULT 0,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id), 
          colorCode TEXT,
          code TEXT,
          restrictionId INTEGER REFERENCES ${TxtConstants.restrictionTableName}(id),
          profitPrice REAL NOT NULL DEFAULT 0,
          originalPrice REAL NOT NULL DEFAULT 0,
          taxPercentage REAL NOT NULL DEFAULT 0,
          imageId INTEGER REFERENCES ${TxtConstants.imageTableName}(id)
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.itemTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllData(Database db)async{
    return await db.query(TxtConstants.itemTableName);
  }

  static Future<List<dynamic>>getAllActiveData(Database db)async{
    return await db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.itemTableName} WHERE activeStatus = ?
        """,
        [1]);
  }

  static Future<int>insertNewItem(
    Database db,
    {
      required UserModel userModel,
      required String name,
      required TypeModel typeModel,
      required DateTime dateTime,
      required bool hasExpire,
      required String? description,
      required double profitPrice,
      required double originalPrice,
      required double taxPercentage,
    }
  )async{
    return await db.rawInsert(
        """
          INSERT INTO ${TxtConstants.itemTableName}
          (
            typeId,
            name,
            createTime,
            createPersonId,
            hasExpire,
            description,
            profitPrice,
            originalPrice,
            taxPercentage
          )
          VALUES(?,?,?,?,?,?,?,?,?)
        """,
        [
          typeModel.id,
          name,
          dateTime.toString(),
          userModel.id,
          hasExpire ? 1 : 0,
          description,
          profitPrice,
          originalPrice,
          taxPercentage
        ]
    );
  }

  static Future<int>updateItemLastUpdateTime(Database db, DateTime dateTime, ItemModel itemModel)async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.itemTableName} SET lastUpdateTime = ? WHERE id = ?
        """,
        [dateTime.toString(), itemModel.id]
    );
  }

  static Future<List<dynamic>>getSingleItem(Database db, ItemModel itemModel)async{
    return await db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.itemTableName} WHERE id = ?
        """,
        [itemModel.id]
    );
  }

  static Future<int>updateItem(
    Database db,
    {
      required DateTime dateTime,
      required ItemModel itemModel,
      required String newName,
      required double originalPrice,
      required double profitPrice,
      required double taxPercentage,
    }
  )async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.itemTableName} 
          SET name = ?, 
          lastUpdateTime = ?, 
          originalPrice = ?, 
          profitPrice = ?, 
          taxPercentage = ? 
          WHERE id = ?
        """,
        [newName, dateTime.toString(), originalPrice, profitPrice, taxPercentage, itemModel.id]);
  }

  static Future<int>deactivateItem(
    Database db,
    {
      required UserModel userModel,
      required DateTime dateTime,
      required ItemModel itemModel,
    }
  )async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.itemTableName} SET deleteTime = ?, deletePersonId = ?, activeStatus = ? WHERE id = ?
        """,
        [dateTime.toString(), userModel.id, 0, itemModel.id]
    );
  }
}