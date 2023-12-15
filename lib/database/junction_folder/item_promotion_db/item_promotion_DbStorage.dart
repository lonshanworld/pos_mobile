import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/user_model_folder/user_model.dart';

class ItemPromotionDbStorage{
  static Future<void> onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.itemPromotionTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          itemId INTEGER REFERENCES ${TxtConstants.itemTableName}(id) NOT NULL,
          promotionId INTEGER REFERENCES ${TxtConstants.promotionTableName}(id) NOT NULL,
          createTime TEXT NOT NULL,
          deleteTime TEXT,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
          activeStatus INTEGER NOT NULL DEFAULT 1
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.itemPromotionTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllData(Database db)async{
    return await db.query(TxtConstants.itemPromotionTableName);
  }

  static Future<int>insertData({
    required Database db,
    required int itemId,
    required int promotionId,
    required int createPersonId,
  })async{
    return await db.rawInsert(
      """
        INSERT INTO ${TxtConstants.itemPromotionTableName}
        (
          itemId,
          promotionId,
          createTime,
          createPersonId
        )
        VALUES(?,?,?,?)
      """,
      [itemId, promotionId, DateTime.now().toString(), createPersonId],
    );
  }

  static Future<List<int>>deactivateItemPromotion(
    Database db,
    {
      required List<ItemPromotionModel> itemPromotionList,
      required UserModel userModel,
      required DateTime dateTime,
    }
  )async{
    final Batch batch = db.batch();
    for(int i =0; i < itemPromotionList.length; i++){
      batch.rawUpdate(
          """
            UPDATE ${TxtConstants.itemPromotionTableName}
            SET deleteTime = ?, deletePersonId =?, activeStatus = ? WHERE id = ? 
          """,
          [dateTime.toString(), userModel.id, 0, itemPromotionList[i].id]
      );
    }
    final List<int>results = (await batch.commit()).map((e) => e is int ? e : null).cast<int>().toList();
    return results;
  }
}