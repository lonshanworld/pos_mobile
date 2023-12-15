import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class AlertKnownPersonDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.alertKnownPersonTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          alertId INTEGER REFERENCES ${TxtConstants.alertTableName}(id) NOT NULL,
          knownPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          knownTime TEXT NOT NULL
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.alertKnownPersonTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllData(Database db)async{
    List<dynamic> rawData = await db.query(TxtConstants.alertKnownPersonTableName);
    return rawData;
  }
}