import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class ReportDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.reportTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          alertStartTime TEXT NOT NULL,
          alertEndTime TEXT NOT NULL,
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
          color TEXT
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
       DROP TABLE IF EXISTS ${TxtConstants.reportTableName}
      """
    );
  }
}