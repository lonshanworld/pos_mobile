import 'package:pos_mobile/database/imageModel_DB/image_DBStorage.dart';
import 'package:sqflite/sqflite.dart';

class ImageDbService{
  static Future<void>initImageDb(Database db)async{
    await ImageDbStorage.onCreate(db);
  }

  // static Future<void>updateImageDb(Database db)async{
  //   await ImageDbStorage.onUpgrade(db);
  // }
  static Future<void>deleteImageDb(Database db)async{
    await ImageDbStorage.onDelete(db);
  }

}