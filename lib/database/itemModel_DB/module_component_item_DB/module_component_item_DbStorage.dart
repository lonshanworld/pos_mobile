import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class ModuleComponentItemDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.moduleComponentItemTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
          createTime TEXT NOT NULL,
          lastUpdateTime TEXT,
          deleteTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          parentId TEXT,
          uniqueId INTEGER REFERENCES ${TxtConstants.uniqueItemTableName}(id),
          componentCount INTEGER,
          originalPrice REAL NOT NULL DEFAULT 0,
          profitPrice REAL NOT NULL DEFAULT 0,
          taxPercentage REAL NOT NULL DEFAULT 0,
          disposePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
          stockInId INTEGER REFERENCES ${TxtConstants.stockInTableName}(id),
          stockOutId INTEGER REFERENCES ${TxtConstants.stockOutTableName}(id),
          code TEXT
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.moduleComponentItemTableName}
      """
    );
  }
}