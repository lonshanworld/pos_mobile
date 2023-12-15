import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class ReportTargetProductDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
        """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.reportTargetProductTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          reportId INTEGER REFERENCES ${TxtConstants.reportTableName}(id) NOT NULL,
          targetProductType TEXT NOT NULL,
          targetProductId INTEGER NOT NULL
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.reportTargetProductTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }
}