import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../../constants/txtconstants.dart';

class CategoryDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.categoryTableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          createTime TEXT NOT NULL,
          lastUpdateTime TEXT,
          deleteTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1,
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
        DROP TABLE IF EXISTS ${TxtConstants.categoryTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllData(Database db)async{
    return await db.query(TxtConstants.categoryTableName);
  }

  static Future<List<dynamic>>getAllActiveData (Database db)async{
    return await db.rawQuery(
        """
          SELECT * FROM ${TxtConstants.categoryTableName} WHERE activeStatus = ?
        """,
        [1]);
  }

  static Future<int>insertNewCategory(
      Database db,
      {
        required String categoryName,
        required UserModel userModel
      }
      )async{
    return await db.rawInsert(
        """
          INSERT INTO ${TxtConstants.categoryTableName}
          (
            name,
            createTime,
            createPersonId
          )
          VALUES(?,?,?)
        """,
        [categoryName, DateTime.now().toString(), userModel.id]);
  }


  static Future<int>updateCategoryLastUpdateTime(Database db, DateTime dateTime, CategoryModel categoryModel)async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.categoryTableName} SET lastUpdateTime = ? WHERE id = ?
        """,
        [dateTime.toString(), categoryModel.id]
    );
  }

  static Future<List<dynamic>>getSingleCategory(Database db, DateTime dateTime,CategoryModel categoryModel)async{
    return await db.rawQuery(
      """
        SELECT * FROM ${TxtConstants.categoryTableName} WHERE id = ?
      """,
      [categoryModel.id]
    );
  }

  static Future<int>updateCategoryName(Database db, DateTime dateTime, CategoryModel categoryModel, String newName)async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.categoryTableName} SET lastUpdateTime = ?, name = ? WHERE id = ?
        """,
        [dateTime.toString(), newName, categoryModel.id]
    );
  }

  static Future<int>deactivateCategory(
    Database db,
    {
      required DateTime dateTime,
      required CategoryModel categoryModel,
      required UserModel userModel,
    }
  )async{
    return await db.rawUpdate(
        """
          UPDATE ${TxtConstants.categoryTableName} SET deleteTime = ?, deletePersonId = ?, activeStatus = ? WHERE id = ?
        """,
        [dateTime.toString(), userModel.id, 0, categoryModel.id]
    );
  }
}