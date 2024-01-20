import 'package:pos_mobile/core/data/data_sources/local/storage_abstract.dart';
import 'package:sqflite/sqflite.dart';
import '../../../../auth/domain/entities/user_form_entity/user_form_entity.dart';
import '../../../../../constants/txtconstants.dart';

class UserDbStorage implements Storage{
  final Database _db;
  UserDbStorage(this._db);

  @override
  Future<void> onCreate() async{
    await _db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.userTableName} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          userName TEXT NOT NULL,
          password TEXT NOT NULL,
          userLevel TEXT NOT NULL,
          userCreatedTime TEXT NOT NULL,
          userLoginTime TEXT,
          userLogoutTime TEXT,
          activeStatus INTEGER NOT NULL DEFAULT 1,
          imageId INTEGER REFERENCES ${TxtConstants.imageTableName}(id)
        )
      """
    );
  }

  @override
  Future<void> onDelete() async{
    await _db.execute(
      """
        DROP TABLE IF EXISTS ${TxtConstants.userTableName}
      """
    );
  }

  @override
  Future<void> onUpgrade() async{
    throw UnimplementedError();
  }

  @override
  Future<List<dynamic>> getAllData() async{
    return await _db.query(TxtConstants.userTableName);
  }

  @override
  Future<List<dynamic>> getSingleData(int id) async{
    return await _db.rawQuery(
      """
        SELECT * FROM ${TxtConstants.userTableName} WHERE id = ?
      """,
      [id]
    );
  }


  @override
  Future<int> insertSingleData<T>(T data)async{
    UserFormEntity insertData = data as UserFormEntity;
    return await _db.rawInsert(
      """
        INSERT INTO ${TxtConstants.userTableName}
        (
          userName,
          password,
          userLevel,
          userCreatedTime
        )
        VALUES(?,?,?,?)
      """,
      [
        insertData.userName,
        insertData.password,
        insertData.userLevel.name,
        DateTime.now().toString(),
      ]
    );
  }


  @override
  Future<int> deactivateSingleData(int id) async{
    return await _db.rawUpdate(
      """
        UPDATE ${TxtConstants.userTableName}
        SET activeStatus = ?
        WHERE id = ?
      """,
      [0, id]
    );
  }

  @override
  Future<int> deleteSingleData(int id)async {
    return await _db.rawDelete(
      """
        DELETE FROM ${TxtConstants.userTableName}
        WHERE id = ?
      """,
      [id]
    );
  }

  Future<int>updateLoginTime(int id, DateTime dateTime)async{
    return await _db.rawUpdate(
      """
        UPDATE ${TxtConstants.userTableName}
        SET userLoginTime = ? 
        WHERE id = ?
      """,
      [
        dateTime.toString(),
        id,
      ]
    );
  }

  Future<int>updateLogoutTime(int id, DateTime dateTime)async{
    return await _db.rawUpdate(
      """
        UPDATE ${TxtConstants.userTableName}
        SET userLogoutTime = ?
        WHERE id = ? 
      """
    );
  }


}