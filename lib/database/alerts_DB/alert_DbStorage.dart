import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class AlertDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.alertTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          createTime TEXT NOT NULL,
          deleteTime TEXT,
          lastUpdateTime TEXT,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          targetAudienceType TEXT NOT NULL,
          importanceLevel TEXT NOT NULL,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          colorCode TEXT,
          completeStatus INTEGER NOT NULL DEFAULT 0,
          completePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id)
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
       DROP TABLE IF EXISTS ${TxtConstants.alertTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onUpgrade(db);
  }
}