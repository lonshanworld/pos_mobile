import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class StockOutPromotionDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.stockOutPromotionTableName}(
          stockOutId INTEGER REFERENCES ${TxtConstants.stockOutTableName}(id) NOT NULL,
          promotionId INTEGER REFERENCES ${TxtConstants.promotionTableName}(id) NOT NULL
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.stockOutPromotionTableName}
      """
    );
  }

  static Future<List<dynamic>>getAllData(Database db)async{
    return await db.query(TxtConstants.stockOutPromotionTableName);
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<int>insertData({
    required Database db,
    required int stockOutId,
    required int promotionId,
  })async{
    return await db.rawInsert(
      """
        INSERT INTO ${TxtConstants.stockOutPromotionTableName}
        (
          stockOutId,
          promotionId
        )
        VALUES(?,?)
      """,
      [
        stockOutId,
        promotionId,
      ],
    );
  }
}