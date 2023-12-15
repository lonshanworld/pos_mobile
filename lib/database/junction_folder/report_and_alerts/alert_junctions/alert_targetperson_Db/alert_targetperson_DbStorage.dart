import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class AlertTargetPersonDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.alertTargetPersonTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          alertId INTEGER REFERENCES ${TxtConstants.alertTableName}(id) NOT NULL,
          targetPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.alertTargetPersonTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onCreate(db);
    await onDelete(db);
  }
}