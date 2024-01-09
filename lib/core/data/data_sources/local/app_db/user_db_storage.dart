import 'package:pos_mobile/core/data/data_sources/local/storage_abstract.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:sqflite/sqflite.dart';

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
          userCreateTime TEXT NOT NULL,
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
  Future<List> getAllData() async{
    return await _db.query(TxtConstants.userTableName);
  }

  @override
  Future<List> getSingleData<String>(String id) async{
    return await _db.rawQuery(
      """
        SELECT * FROM ${TxtConstants.userTableName} WHERE id = ?
      """,
      [id]
    );
  }


  @override
  Future<int> deactivateSingleData<String>(String id) {
    // TODO: implement deactivateSingleData
    throw UnimplementedError();
  }

  @override
  Future<int> deleteSingleData<String>(String id) {
    // TODO: implement deleteSingleData
    throw UnimplementedError();
  }



  @override
  Future<int> insertSingleData<String>(String data) {
    // TODO: implement insertSingleData
    throw UnimplementedError();
  }



  @override
  Future<int> updateSingleLastUpdateTime<String>(String data) {
    // TODO: implement updateSingleLastUpdateTime
    throw UnimplementedError();
  }

}