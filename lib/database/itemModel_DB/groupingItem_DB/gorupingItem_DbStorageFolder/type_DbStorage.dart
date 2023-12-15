import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:sqflite/sqflite.dart';

class TypeDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.typeTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          groupId INTEGER REFERENCES ${TxtConstants.groupTableName}(id) NOT NULL,
          name TEXT NOT NULL,
          createTime TEXT NOT NULL,
          lastUpdateTime TEXT,
          deleteTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id), 
          colorCode TEXT,
          imageId INTEGER REFERENCES ${TxtConstants.imageTableName}(id),
          generalDescription TEXT,
          generalRestrictionId INTEGER REFERENCES ${TxtConstants.restrictionTableName}(id),
          hasExpire INTEGER NOT NULL DEFAULT 0
        )
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.typeTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllData(Database db)async{
    return await db.query(TxtConstants.typeTableName);
  }

  static Future<List<dynamic>>getAllActiveData(Database db)async{
    return await db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.typeTableName} WHERE activeStatus = ?
        """,
        [1]);
  }

  static Future<int>insertNewType(
    Database db,
    {
      required String name,
      required String? generalDescription,
      required GroupModel groupModel,
      required DateTime dateTime,
      required UserModel userModel,
      required bool hasExpire,
    }
  )async{
    return db.rawInsert(
        """
          INSERT INTO ${TxtConstants.typeTableName}
          (
            name,
            groupId,
            createTime,
            createPersonId,
            generalDescription,
            hasExpire
          )
          VALUES(?,?,?,?,?,?)
        """,
        [name, groupModel.id, dateTime.toString(), userModel.id, generalDescription, hasExpire ? 1 : 0]
    );
  }

  static Future<int>updateTypeLastUpdateTime(Database db, DateTime dateTime, TypeModel typeModel)async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.typeTableName} SET lastUpdateTime = ? WHERE id = ?
        """,
        [dateTime.toString(), typeModel.id]
    );
  }

  static Future<List<dynamic>>getSingleType(Database db, TypeModel typeModel)async{
    return await db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.typeTableName} WHERE id = ?
        """,
        [typeModel.id]);
  }

  static Future<int>updateTypeName(
    Database db,
    {
      required String newName,
      required DateTime dateTime,
      required TypeModel typeModel,
    }
  )async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.typeTableName} SET lastUpdateTime = ?, name = ? WHERE id = ? 
        """,
        [dateTime.toString(), newName, typeModel.id]
    );
  }

  static Future<int>deactivateType(
    Database db,
    {
      required DateTime dateTime,
      required UserModel userModel,
      required TypeModel typeModel,
    }
  )async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.typeTableName} SET deleteTime = ?, deletePersonId = ?, activeStatus = ? WHERE id = ?
        """,
        [dateTime.toString(), userModel.id, 0, typeModel.id]
    );
  }
}