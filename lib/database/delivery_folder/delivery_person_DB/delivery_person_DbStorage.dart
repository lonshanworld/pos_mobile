import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class DeliveryPersonDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.deliveryPersonTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          address TEXT,
          request TEXT,
          phoneNo TEXT,
          activeStatus INTEGER DEFAULT 1
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.deliveryPersonTableName}
      """
    );
  }

  static Future<List<dynamic>> getAllData(Database db)async{
    return await db.query(TxtConstants.deliveryPersonTableName);
  }

  static Future<int>insertNewData(Database db, String name)async{
    return await db.rawInsert(
        """
          INSERT INTO ${TxtConstants.deliveryPersonTableName}(name) VALUES(?)
        """,
        [name]
    );
  }
}