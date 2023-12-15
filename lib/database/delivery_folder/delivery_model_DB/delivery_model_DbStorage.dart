import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class DeliveryModelDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.deliveryModelTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          startAddress TEXT,
          endAddress TEXT,
          deliveryCharges REAL,
          startDeliveryTime TEXT
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.deliveryModelTableName}
      """
    );
  }

  static Future<int>insertNewData(Database db, double deliveryCharges)async{
    return await db.rawInsert(
        """
          INSERT INTO ${TxtConstants.deliveryModelTableName}(deliveryCharges)  VALUES(?)
        """,
        [deliveryCharges]
    );
  }

  static Future<List<dynamic>> getAllData(Database db)async{
    return await db.query(TxtConstants.deliveryModelTableName);
  }
}