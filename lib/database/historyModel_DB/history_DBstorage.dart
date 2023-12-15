import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:sqflite/sqflite.dart';

class HistoryDbStorage{
  static Future<void>onCreate(Database db)async{
    await db.execute(
      """
        CREATE TABLE IF NOT EXISTS ${TxtConstants.historyTableName}(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          oldData TEXT NOT NULL,
          newData TEXT NOT NULL,
          createTime TEXT NOT NULL,
          modelType TEXT NOT NULL,
          updateType TEXT NOT NULL,
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
        DROP TABLE IF EXISTS ${TxtConstants.historyTableName}
      """
    );
  }

  static Future<void>onUpgrade(Database db)async{
    await onDelete(db);
    await onCreate(db);
  }

  static Future<List<dynamic>>getAllHistoryList(Database db)async{
    List<dynamic> data = await db.query(TxtConstants.historyTableName);
    cusDebugPrint(data);
    return data;
  }


  // NOTE : return -1 if not successful
  static Future<int>addHistory({
    required String oldData,
    required String newData,
    required ModelType modelType,
    required UpdateType updateType,
    required int createPersonId,
    required Database db,
    required DateTime dateTime,
  })async{
    /*
    TODO : All the object instances are already stored as an instance in history oldData
    Example =>
      This is single history list
        oldData = "{name : Mg Mg, age : 21}"
        newData = "{name : Kyaw Kyaw, age : 21}"
        This is what I plan originally. In this condition, I will know both old and new data.
        But data duplication happen when i add another history

        oldData = "{name : Kyaw Kyaw, age : 21}"
        newData = "{name : Mya Mya, age : 21}"
        Now previous history data already has kyaw kyaw (data duplication).

    How to prevent data duplication??
    if newData is only added, we will never know what is the original data.
    But what about using oldData???
      It solves the problem.

      This is original userData = {name : Mg Mg, age : 21}
      Now if i want to update this, all I need to do is adding data to oldData
      Imagine if we update the name to Kyaw Kyaw.
      oldData = "{name : Mg Mg, age : 21}"
      newData = null
      why?
      original data can be paired with original createDate of userData.
      current newData can be paired with newly createDate of historyData List

      Then, when we update again, pervious newData can be paired with previous createDate of historyDataList
      current newData can be paired with newly create Date of historyDataLIst

      *** NOTE : the first data always has to be paired with createDate of userData ***
      *** Exception :
        For UserData, you need to store only newData because the history shoud be stored only when the user is logout
     */
    return await db.rawInsert(
      "INSERT INTO ${TxtConstants.historyTableName}(oldData, newData, createTime, modelType, updateType, createPersonId) VALUES(?,?,?,?,?,?)",
      [oldData, "", dateTime.toString(), modelType.name, updateType.name, createPersonId]
    );
  }
}