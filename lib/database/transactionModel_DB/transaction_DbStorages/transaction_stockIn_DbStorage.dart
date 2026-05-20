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
    // OPTIMIZATION: Add indexes for StockIn table
    await db.execute("CREATE INDEX IF NOT EXISTS idx_stockIn_createTime ON ${TxtConstants.stockInTableName}(createTime);");
    await db.execute("CREATE INDEX IF NOT EXISTS idx_stockIn_activeStatus ON ${TxtConstants.stockInTableName}(activeStatus);");
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

  static Future<List<dynamic>>getAllStockInList(Database db, {int limit = 2000, int offset = 0})async{
    return await db.query(
      TxtConstants.stockInTableName,
      orderBy: 'id DESC',
      limit: limit,
      offset: offset,
    );
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