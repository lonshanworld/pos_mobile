import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:sqflite/sqflite.dart';

class UserDBStorage{

  // static Future<void> initUserTableDB()async{
  //   String path = await DBHelper.getDbpath(TxtConstants.userTableName);
  //   _database = await openDatabase(
  //     path,
  //     version: 1,
  //     onCreate: _oncreate,
  //     onConfigure: DBHelper.dbConfig,
  //     onUpgrade: _onUpgrade,
  //   );
  // }

  static Future<void> oncreate(Database db)async {
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.userTableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userName TEXT NOT NULL,
          password TEXT NOT NULL,
          userLevel TEXT NOT NULL,
          userCreateTime TEXT NOT NULL,
          userLoginTime TEXT,
          userLogoutTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          imageId INTEGER REFERENCES ${TxtConstants.imageTableName}(id)
        )
      """
    );
  }

  // TODO : use with care
  static Future<void> onDelete(Database db)async{
    await db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.userTableName}  
      """
    );
  }

  static Future<void> onUpgrade(Database db)async{
    await onDelete(db);
    await oncreate(db);
  }

  static Future<List<dynamic>> getAllData(Database db)async{
    return await db.query(TxtConstants.userTableName);
  }

  static Future<List<dynamic>>getSingleUser(Database db, int id)async{
    return await db.rawQuery(
      """
        SELECT * FROM ${TxtConstants.userTableName} WHERE id = ?
      """,
      [id]
    );
  }

  static Future<int>insertNewUser(Database db,{
    required String userName,
    required String password,
    required UserLevel userLevel,
  })async{
    // NOTE : if there is error ,the response will be -1
    return await db.rawInsert(
      "INSERT INTO ${TxtConstants.userTableName}(userName, password, userLevel,userCreateTime) VALUES(?,?,?,?)",
      [userName, password, userLevel.name, DateTime.now().toString()],
    );
  }

  static Future<int>updateLoginTime(Database db,int id, DateTime dateTime)async{

    return await db.rawUpdate(
      "UPDATE ${TxtConstants.userTableName} SET userLoginTime = ? WHERE id = ?",
      [dateTime.toString(), id]
    );
  }

  static Future<int>updateLogoutTime(Database db,int id, DateTime dateTime)async{
    return await db.rawUpdate(
        "UPDATE ${TxtConstants.userTableName} SET userLogoutTime = ? WHERE id = ?",
        [dateTime.toString(), id]
    );
  }

  static Future<int>updateUserName(Database db,String userName,int id)async{
    return await db.rawUpdate(
        "UPDATE ${TxtConstants.userTableName} SET userName = ? WHERE id = ?",
        [userName, id]
    );
  }

  static Future<int>updatePassword(Database db,String newPassword, int id)async{
    return await db.rawUpdate(
        "UPDATE ${TxtConstants.userTableName} SET password = ? WHERE id = ?",
        [newPassword ,id]
    );
  }

  static Future<int>updateimageId(Database db,String newimageId, int id)async{
    return await db.rawUpdate(
        "UPDATE ${TxtConstants.userTableName} SET imageId = ? WHERE id = ?",
        [newimageId, id]
    );
  }

  static Future<int>deleteUser(Database db,int id)async{
    /* NOTE : you must not delete the actual row data
              Instead, change only activeStatus to false */
    return await db.rawUpdate(
      "UPDATE ${TxtConstants.userTableName} SET activeStatus = ? WHERE id = ?",
      [0, id],
    );
  }
}