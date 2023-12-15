import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class ReportImageDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.reportImageTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reportId INTEGER REFERENCES ${TxtConstants.reportTableName}(id) NOT NULL,
          imageId INTEGER REFERENCES ${TxtConstants.imageTableName}(id) NOT NULL
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.reportImageTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }
}