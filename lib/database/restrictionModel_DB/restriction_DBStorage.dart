import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:sqflite/sqflite.dart';

class RestrictionDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.restrictionTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          reason TEXT NOT NULL,
          createTime TEXT NOT NULL,
          deleteTime TEXT,
          lastUpdateTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id)
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.restrictionTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllRestrictions(Database db)async{
    List<dynamic> data = await db.query(TxtConstants.restrictionTableName);
    cusDebugPrint(data);
    return data;
  }

  static Future<int>insertNewRestriction({
    required Database db,
    required String title,
    required String reason,
    required int createPersonId,
  })async{
    return await db.rawInsert(
      """
        INSERT INTO ${TxtConstants.restrictionTableName}
        (
          title,
          reason,
          createTime,
          createPersonId,
        )
        VALUES(?,?,?,?)
      """,
      [title, reason, DateTime.now().toString(), createPersonId],
    );
  }
}