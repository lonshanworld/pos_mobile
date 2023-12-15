import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/database/historyModel_DB/history_DBservice.dart';
import 'package:pos_mobile/database/itemModel_DB/uniqueItem_DB/uniqueItem_DbStorage.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/item_model_folder/item_model.dart';
import '../../../models/item_model_folder/uniqueItem_model.dart';
import '../../../models/user_model_folder/user_model.dart';


class UniqueItemDbService{
  static Future<void>initUniqueItemDb(Database db)async{
    await UniqueItemDbStorage.onCreate(db);
  }

  static Future<void>deleteUniqueItemDb(Database db)async{
    await UniqueItemDbStorage.onDelete(db);
  }

  // static Future<bool>addUniqueItemList({
  //   required Database db,
  //   required List<UniqueItemModel> uniqueItemModelList,
  // })async{
  //   List<int> values = await UniqueItemDbStorage.insertNewDataList(db: db, uniqueItemModelList: uniqueItemModelList);
  // }
  static Future<List<UniqueItemModel>> getAllData(Database db)async{
    List<dynamic> itemList = await UniqueItemDbStorage.getAllUniqueItemList(db);
    return itemList.map((e) => UniqueItemModel.fromJson(e)).toList();
  }



  static Future<List<int>> updateUniqueItemList(
    Database db,
    {
      required UserModel userModel,
      required List<UniqueItemModel> uniqueItemList,
      required DateTime dateTime,
      required double profitPrice,
      required double originalPrice,
      required double taxPercentage,
    }
  )async{
    return await UniqueItemDbStorage.updateUniqueItemList(db, userModel: userModel, uniqueItemList: uniqueItemList, dateTime: dateTime, profitPrice: profitPrice, originalPrice: originalPrice, taxPercentage: taxPercentage) ;
  }

  static Future<bool> reActivateUniqueItemList(
    Database db,
    {
      required UserModel userModel,
      required int stockOutId,
      required DateTime dateTime,
      required List<ItemModel> itemModelList,
    }
  )async{
    try{
      List<dynamic> oldDataList = await UniqueItemDbStorage.getSelectedUniqueItemListFromStockOutId(db, stockOutId: stockOutId);
      List<UniqueItemModel> formattedOldDataList = oldDataList.map((e) => UniqueItemModel.fromJson(e)).toList();
      List<int> updateValueList = [];
      for(int x =0; x < formattedOldDataList.length; x++){
        ItemModel item = itemModelList.firstWhere((element) => element.id == formattedOldDataList[x].itemId);
        int updateValue = await UniqueItemDbStorage.reInStockUniqueItemList(db, stockOutId: stockOutId, originalPrice: item.originalPrice, profitPrice: item.profitPrice, taxPercentage: item.taxPercentage ?? 0, dateTime: dateTime);
        updateValueList.add(updateValue);
      }
      if(updateValueList.contains(-1)) return false;


      List<UniqueItemModel> formattedNewDataList = [];
      for(int a = 0 ; a < formattedOldDataList.length; a++){
        List<dynamic> rawNewDataList = await UniqueItemDbStorage.getSingleUniqueItemList(db, uniqueItemId: formattedOldDataList[a].id);
        UniqueItemModel newData = UniqueItemModel.fromJson(rawNewDataList.first);
        formattedNewDataList.add(newData);
      }
      if(formattedNewDataList.length != formattedOldDataList.length) return false;


      List<bool> historyUpdateValueList = [];
      for(int b = 0; b < formattedNewDataList.length; b++){
        UniqueItemModel oldData = formattedOldDataList.firstWhere((element) => formattedNewDataList[b].id == element.id);
        bool historyUpdateValue = await HistoryDBService.addHistoryData(oldData: oldData, newData: formattedNewDataList[b], updateType: UpdateType.orderCancel, createPersonId: userModel.id, db: db, dateTime: dateTime);
        historyUpdateValueList.add(historyUpdateValue);
      }
      return !historyUpdateValueList.contains(false);
    }catch(err){
      cusDebugPrint(err);
      return false;
    }

  }

  static Future<bool>deActivateUniqueItem(
    Database db,
    {
      required UniqueItemModel uniqueItemModel,
      required UserModel userModel,
    }
  )async{
    DateTime dateTime = DateTime.now();
    int value = await UniqueItemDbStorage.deActivateSingleUniqueItem(
        db,
        uniqueItemId: uniqueItemModel.id,
        userModel: userModel,
        dateTime: dateTime,
    );
    return value != -1;
  }
}