import 'package:pos_mobile/database/junction_folder/item_promotion_db/item_promotion_DbStorage.dart';
import 'package:pos_mobile/models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/user_model_folder/user_model.dart';

class ItemPromotionDbService{
  static Future<void>initItemPromotionDB(Database db)async{
    await ItemPromotionDbStorage.onCreate(db);
  }

  static Future<void>deleteItemPromotionDb(Database db)async{
    await ItemPromotionDbStorage.onDelete(db);
  }

  static Future<List<ItemPromotionModel>> getAllItemPromotion(Database db)async{
    List<dynamic> rawdataList = await ItemPromotionDbStorage.getAllData(db);
    return rawdataList.map((e) => ItemPromotionModel.fromJson(e)).toList();
  }

  static Future<bool>addNewData({
    required Database db,
    required int itemId,
    required int promotionId,
    required int createPersonId,
  })async{
    int value = await ItemPromotionDbStorage.insertData(db: db, itemId: itemId, promotionId: promotionId, createPersonId: createPersonId);
    if(value == -1){
      return  false;
    }else{
      return true;
    }
  }

  static Future<bool>deleteItemPromotion(
    Database db,
    {
      required List<ItemPromotionModel> itemPromotionList,
      required UserModel userModel,
      required DateTime dateTime,
    }
  )
  async{
    List<int> value = await ItemPromotionDbStorage.deactivateItemPromotion(db, itemPromotionList: itemPromotionList, userModel: userModel, dateTime: dateTime);
    if(value.contains(-1)){
      return false;
    }else{
      return true;
    }
  }
}