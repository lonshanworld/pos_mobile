import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:sqflite/sqflite.dart';

class ImageDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.imageTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          imageTxt TEXT NOT NULL
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.imageTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllImages(Database db)async{
    List<dynamic> data = await db.query(TxtConstants.imageTableName);
    cusDebugPrint(data);
    return data;
  }

}