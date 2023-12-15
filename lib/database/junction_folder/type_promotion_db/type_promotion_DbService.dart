
import 'package:pos_mobile/database/junction_folder/type_promotion_db/type_promotion_DbStorage.dart';
import 'package:sqflite/sqflite.dart';

class TypePromotionDbService{
  static Future<void>initTypePromotionDb(Database db)async{
    await TypePromotionDbStorage.onCreate(db);
  }

  static Future<void>deleteTypePromotionDb(Database db)async{
    await TypePromotionDbStorage.onDelete(db);
  }
}