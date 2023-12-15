import 'package:sqflite/sqflite.dart';

import '../../../../constants/txtconstants.dart';
import '../../../../models/groupingItem_models_folders/category_model.dart';
import '../../../../models/groupingItem_models_folders/group_model.dart';
import '../../../../models/user_model_folder/user_model.dart';

class GroupDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.groupTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          categoryId INTEGER REFERENCES ${TxtConstants.categoryTableName}(id) NOT NULL,
          createTime TEXT NOT NULL,
          lastUpdateTime TEXT,
          deleteTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          description TEXT,
          createPersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id) NOT NULL,
          deletePersonId INTEGER REFERENCES ${TxtConstants.userTableName}(id), 
          colorCode TEXT
        )  
      """
    );
  }

  static Future<void>onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.groupTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllData(Database db)async{
    return await db.query(TxtConstants.groupTableName);
  }

  static Future<List<dynamic>>getAllActiveData(Database db)async{
    return await db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.groupTableName} WHERE activeStatus = ?
        """,
        [1]);
  }

  static Future<int>insertNewGroup(
    Database db,
    {
      required UserModel userModel,
      required CategoryModel categoryModel,
      required String groupName,
      required String? description,
      required DateTime dateTime,
    }
  )async{
    return await db.rawInsert(
        """
          INSERT INTO ${TxtConstants.groupTableName}
          (
            name,
            categoryId,
            createTime,
            description,
            createPersonId
          )
          VALUES(?,?,?,?,?)
        """,
        [groupName, categoryModel.id, dateTime.toString(), description, userModel.id]
    );
  }

  static Future<int>updateGroupLastUpdateTime(Database db, DateTime dateTime, GroupModel groupModel)async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.groupTableName} SET lastUpdateTime = ? WHERE id = ?
        """,
        [dateTime.toString(), groupModel.id]
    );
  }

  static Future<List<dynamic>>getSingleGroup(Database db, GroupModel groupModel)async{
    return await db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.groupTableName} WHERE id = ?
        """,
        [groupModel.id]
    );
  }

  static Future<int>updateGroupName(
      Database db,
      {
        required String newName,
        required DateTime dateTime,
        required GroupModel groupModel,
      }
      )async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.groupTableName} SET lastUpdateTime = ?, name = ? WHERE id = ? 
        """,
        [dateTime.toString(), newName, groupModel.id]
    );
  }

  static Future<int>deactivateGroup(
      Database db,
      {
        required DateTime dateTime,
        required GroupModel groupModel,
        required UserModel userModel,
      }
      )async{
    return await db.rawUpdate(
        """
        UPDATE ${TxtConstants.groupTableName} SET deleteTime = ?, deletePersonId = ?, activeStatus = ? WHERE id = ?
      """,
        [dateTime.toString(), userModel.id, 0, groupModel.id]
    );
  }
}