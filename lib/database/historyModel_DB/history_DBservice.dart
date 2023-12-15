import 'dart:convert';

import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/database/historyModel_DB/history_DBstorage.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';
import 'package:pos_mobile/models/report_and_alert_models_folder/alert_model.dart';
import 'package:pos_mobile/models/report_and_alert_models_folder/report_model.dart';
import 'package:pos_mobile/models/restriction_model_folder/restriction_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../models/groupingItem_models_folders/category_model.dart';
import '../../models/groupingItem_models_folders/group_model.dart';

class HistoryDBService{
  // final Database? database;
  //
  // HistoryDBService({
  //   required this.database,
  // });

  static Future<void>initHistoryDb(Database db)async{
    await HistoryDbStorage.onCreate(db);
  }

  // static Future<void>updateHistoryDb(Database db)async{
  //   await HistoryDbStorage.onUpgrade(db);
  // }
  static Future<void>deleteHistoryDb(Database db)async{
    await HistoryDbStorage.onDelete(db);
  }

  static Future<List<dynamic>>getAllHistory(Database db)async{
    return await HistoryDbStorage.getAllHistoryList(db);
  }

  static Future<bool>addHistoryData({
    required Object oldData,
    required Object newData,
    required UpdateType updateType,
    required int createPersonId,
    required Database db,
    required DateTime dateTime,
  })async{
    String? oldInfo;
    String? newInfo;
    ModelType? modelType;

    switch(newData.runtimeType){
      case CategoryModel :
        modelType = ModelType.category;
        oldData as CategoryModel;
        newData as CategoryModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case GroupModel :
        modelType = ModelType.group;
        oldData as GroupModel;
        newData as GroupModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case TypeModel :
        modelType = ModelType.type;
        oldData as TypeModel;
        newData as TypeModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(oldData.toJson());
        break;

      case ItemModel :
        modelType = ModelType.item;
        oldData as ItemModel;
        newData as ItemModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case UniqueItemModel :
        modelType = ModelType.uniqueItem;
        oldData as UniqueItemModel;
        newData as UniqueItemModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case PromotionModel :
        modelType = ModelType.promotion;
        oldData as PromotionModel;
        newData as PromotionModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case RestrictionModel :
        modelType = ModelType.restriction;
        oldData as RestrictionModel;
        newData as RestrictionModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case StockInModel :
        modelType = ModelType.stockIn;
        oldData as StockInModel;
        newData as StockInModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case StockOutModel :
        modelType = ModelType.stockOut;
        oldData as StockOutModel;
        newData as StockInModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case UserModel :
        modelType = ModelType.userModel;
        oldData as UserModel;
        newData as UserModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case AlertModel :
        modelType = ModelType.alert;
        oldData as AlertModel;
        newData as AlertModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      case ReportModel :
        modelType = ModelType.report;
        oldData as ReportModel;
        newData as ReportModel;
        oldInfo = jsonEncode(oldData.toJson());
        newInfo = jsonEncode(newData.toJson());
        break;

      default :
        null;
        break;
    }

    if(oldInfo != null && newInfo != null && modelType != null){
      int value = await HistoryDbStorage.addHistory(
        oldData: oldInfo,
        newData: newInfo,
        modelType: modelType,
        updateType: updateType,
        createPersonId: createPersonId,
        db: db,
        dateTime: dateTime,
      );
      if(value == -1){
        return false;
      }else{
        return true;
      }
    }else{
      return false;
    }


  }


}