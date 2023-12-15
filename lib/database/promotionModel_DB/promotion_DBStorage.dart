import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/user_model_folder/user_model.dart';

class PromotionDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.promotionTableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          promotionName TEXT NOT NULL,
          promotionDescription TEXT NOT NULL,
          promotionPercentage REAL,
          promotionPrice REAL,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
          activeStatus INTEGER NOT NULL DEFAULT 1,
          promotionLimitPerson INTEGER,
          promotionLimitTime TEXT,
          promotionLimitPrice REAL,
          requirementForItemCount INTEGER,
          requirementForPrice REAL,
          promotionCode TEXT,
          createTime TEXT NOT NULL,
          deleteTime TEXT,
          lastUpdateTime TEXT
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.promotionTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllPromotion(Database db)async{
    List<dynamic> data = await db.query(TxtConstants.promotionTableName);
    cusDebugPrint(data);
    return data;
  }

  static Future<int> insertNewPromotion({
    required Database db,
    required String promotionName,
    required String promotionDescription,
    required double? promotionPercentage,
    required double? promotionPrice,
    required int createPersonId,
    required int? promotionLimitPerson,
    required DateTime? promotionLimitTime,
    required double? promotionLimitPrice,
    required int? requirementForItemCount,
    required int? requirementForPrice,
    required String? promotionCode,
  })async{
    return db.rawInsert(
      """INSERT INTO ${TxtConstants.promotionTableName}
        (
          promotionName, 
          promotionDescription, 
          promotionPercentage, 
          promotionPrice, 
          createPersonId, 
          promotionLimitPerson, 
          promotionLimitTime, 
          promotionLimitPrice, 
          requirementForItemCount, 
          requirementForPrice, 
          promotionCode, 
          createTime
        )  
        VALUES(?,?,?,?,?,?,?,?,?,?,?,?)
      """,
      [
        promotionName,
        promotionDescription,
        promotionPercentage,
        promotionPrice,
        createPersonId,
        promotionLimitPerson,
        promotionLimitTime,
        promotionLimitPrice,
        requirementForItemCount,
        requirementForPrice,
        promotionCode,
        DateTime.now().toString(),
      ],
    );
  }

  static Future<int>deactivatePromotion(
    Database db,
    {
      required UserModel userModel,
      required DateTime dateTime,
      required int promotionId,
    }
  )async{
    return await db.rawUpdate(
      """
        UPDATE ${TxtConstants.promotionTableName}
        SET deleteTime = ?, deletePersonId =?, activeStatus = ? WHERE id = ? 
      """,
      [dateTime.toString(), userModel.id, 0, promotionId]
    );
  }
}