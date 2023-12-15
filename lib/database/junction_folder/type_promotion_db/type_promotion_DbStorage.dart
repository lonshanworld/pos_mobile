import 'package:sqflite/sqflite.dart';

import '../../../constants/txtconstants.dart';

class TypePromotionDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
        """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.typePromotionTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          typeId INTEGER REFERENCES ${TxtConstants.typeTableName}(id) NOT NULL,
          promotionId INTEGER REFERENCES ${TxtConstants.promotionTableName}(id) NOT NULL,
          createTime TEXT NOT NULL,
          deleteTime TEXT,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id),
          activeStatus INTEGER NOT NULL DEFAULT 1
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.typePromotionTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

}