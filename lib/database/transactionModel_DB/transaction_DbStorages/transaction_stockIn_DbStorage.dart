import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class TransactionStockInDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.stockInTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id), 
          createTime TEXT NOT NULL,
          lastUpdateTime TEXT,
          deleteTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.stockInTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>> getAllStockInList(Database db)async{
    return await db.query(TxtConstants.stockInTableName);
  }

  static Future<int>insertStockIn({
    required Database db,
    required int createPersonId,
    required DateTime dateTime,
  })async{
    return await db.rawInsert(
      """
        INSERT INTO ${TxtConstants.stockInTableName}
        (
          createPersonId,
          createTime
        )
        VALUES(?,?)
      """,
      [ createPersonId, dateTime.toString()],
    );
  }
}