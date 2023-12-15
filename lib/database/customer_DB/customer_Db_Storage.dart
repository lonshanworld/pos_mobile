import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class CustomerDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.customerTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          address TEXT,
          phoneNo TEXT,
          request TEXT
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.customerTableName}
      """
    );
  }

  static Future<List<dynamic>> getAllData(Database db)async{
    return db.query(TxtConstants.customerTableName);
  }

  static Future<int>insertNewData(Database db, String name)async{
    return await db.rawInsert(
        """
          INSERT INTO ${TxtConstants.customerTableName}(name) VALUES(?)
        """,
        [name]
    );
  }
}