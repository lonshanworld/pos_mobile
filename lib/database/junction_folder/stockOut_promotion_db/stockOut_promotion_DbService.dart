import 'package:pos_mobile/database/junction_folder/stockOut_promotion_db/stockOut_promotion_DbStorage.dart';
import 'package:pos_mobile/models/junction_models_folder/promotion_junctions/stockout_promotion_model.dart';
import 'package:sqflite/sqflite.dart';

class StockOutPromotionDbServive{
  static Future<void>initStockOutPromotionDb(Database db)async{
    await StockOutPromotionDbStorage.onCreate(db);
  }

  static Future<void>deleteStockOutPromotionDb(Database db)async{
    await StockOutPromotionDbStorage.onDelete(db);
  }

  static Future<List<StockOutPromotionModel>>getAllStockOutPromotionList(Database db)async{
    List<dynamic> rawDataList = await StockOutPromotionDbStorage.getAllData(db);
    return rawDataList.map((e) => StockOutPromotionModel.fromJson(e)).toList();
  }

  static Future<bool>addNewData({
    required Database db,
    required int stockOutId,
    required int promotionId,
  })async{
    int value = await StockOutPromotionDbStorage.insertData(db: db, stockOutId: stockOutId, promotionId: promotionId);
    if(value == -1){
      return false;
    }else{
      return true;
    }
  }
}