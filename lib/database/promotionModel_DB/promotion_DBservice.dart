import 'package:pos_mobile/database/junction_folder/item_promotion_db/item_promotion_DbService.dart';
import 'package:pos_mobile/database/promotionModel_DB/promotion_DBStorage.dart';
import 'package:pos_mobile/models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/user_model_folder/user_model.dart';

class PromotionDBService{
  static Future<void>initPromotionDb(Database db)async{
    await PromotionDbStorage.onCreate(db);
  }

  static Future<void>deletePromotionDb(Database db)async{
    await PromotionDbStorage.onDelete(db);
  }

  static Future<List<PromotionModel>>getAllPromotions(Database db)async{
    List<dynamic> dataList = await PromotionDbStorage.getAllPromotion(db);
    return dataList.map((e) => PromotionModel.fromJson(e)).toList();
  }

  static Future<bool>insertNewPromotion({
    required Database db,
    required String promotionName,
    required String promotionDescription,
    required double? promotionPercentage,
    required double? promotionPrice,
    required int createPersonId,
    required int? promotionLimitPerson,
    required DateTime? promotionLimitTime,
    required double? promotionLimitPrice,
    required int? requirementForItemCount,
    required int? requirementForPrice,
    required String? promotionCode,
  })async{
    int value = await PromotionDbStorage.insertNewPromotion(db: db, promotionName: promotionName, promotionDescription: promotionDescription, promotionPercentage: promotionPercentage, promotionPrice: promotionPrice, createPersonId: createPersonId, promotionLimitPerson: promotionLimitPerson, promotionLimitTime: promotionLimitTime, promotionLimitPrice: promotionLimitPrice, requirementForItemCount: requirementForItemCount, requirementForPrice: requirementForPrice, promotionCode: promotionCode);
    if(value == -1){
      return false;
    }else{
      return true;
    }
  }

  static Future<bool>deletePromotion(
    Database db,
    {
      required UserModel userModel,
      required int promotionId,
      required List<ItemPromotionModel> itemPromotionList,
    }
  )async{
    DateTime dateTime = DateTime.now();
    bool updateItemSuccess = await ItemPromotionDbService.deleteItemPromotion(db, itemPromotionList: itemPromotionList, userModel: userModel, dateTime: dateTime);
    if(!updateItemSuccess) return false;
    int value = await PromotionDbStorage.deactivatePromotion(db, userModel: userModel, dateTime: dateTime, promotionId: promotionId);
    return value != -1;
  }
}