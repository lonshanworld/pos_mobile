
import 'package:pos_mobile/database/customer_DB/customer_Db_service.dart';
import 'package:pos_mobile/database/delivery_folder/delivery_model_DB/delivery_model_DbService.dart';
import 'package:pos_mobile/database/delivery_folder/delivery_person_DB/delivery_person_DbService.dart';
import 'package:pos_mobile/database/itemModel_DB/uniqueItem_DB/uniqueItem_DbService.dart';
import 'package:pos_mobile/database/junction_folder/stockOut_promotion_db/stockOut_promotion_DbService.dart';
import 'package:pos_mobile/database/transactionModel_DB/transaction_DbStorages/transaction_stockIn_DbStorage.dart';
import 'package:pos_mobile/database/transactionModel_DB/transaction_DbStorages/transaction_stockOutItem_DbStorage.dart';
import 'package:pos_mobile/database/transactionModel_DB/transaction_DbStorages/transaction_stockOut_DbStorage.dart';
import 'package:pos_mobile/models/itemModel_with_UniqueItemcount.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';

import 'package:sqflite/sqflite.dart';

import '../../constants/enums.dart';
import '../../models/groupingItem_models_folders/category_model.dart';
import '../../models/groupingItem_models_folders/group_model.dart';
import '../../models/groupingItem_models_folders/type_model.dart';
import '../../models/item_model_folder/uniqueItem_model.dart';
import '../../models/promotion_model_folder/promotion_model.dart';
import '../../models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import '../itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/Item_DbStorage.dart';
import '../itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/category_DbStorage.dart';
import '../itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/group_DbStorage.dart';
import '../itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/type_DbStorage.dart';
import '../itemModel_DB/uniqueItem_DB/uniqueItem_DbStorage.dart';


class TransactionDBService{
  static Future<void>initTransactionDb(Database db)async{
    await TransactionStockInDbStorage.onCreate(db);
    await TransactionStockOutDbStorage.onCreate(db);
    await TransactionStockOutItemDbStorage.onCreate(db);
  }

  static Future<void>deleteTransactionDb(Database db)async{
    await TransactionStockOutItemDbStorage.onDelete(db);
    await TransactionStockOutDbStorage.onDelete(db);
    await TransactionStockInDbStorage.onDelete(db);
  }


  static Future<int>insertStockIn(Database db, UserModel userModel, DateTime dateTime)async{
    return await TransactionStockInDbStorage.insertStockIn(db: db, createPersonId: userModel.id, dateTime: dateTime);
  }



  static Future<bool>insertStockOut(
    Database db,
    {
      required List<UniqueItemModel> uniqueItemList,
      required List<ItemModelWithUniqueItemCountWithPromotion> dataList,
      required UserModel userModel,
      required double? deliveryCharges,
      required double taxPercentage,
      required double? additionalPromotionAmount,
      required String? description,
      required String? customerName,
      required String? deliveryName,
      required ShoppingType shoppingType,
      required PaymentMethod paymentMethod,
      required String barcode,
      required double finalTotalPrice,
      required PromotionModel? promotionModel,
    }
  )async{
    try{
      DateTime dateTime = DateTime.now();
      int? customerId;
      int? deliveryModelId;
      int? deliveryPersonId;
      if(customerName != null && customerName != ""){
        customerId = await CustomerDbService.addNewCustomer(db, customerName);
      }
      if(deliveryCharges != null && deliveryCharges != 0){
        deliveryModelId = await DeliveryModelDbService.createNewDeliveryModel(db, deliveryCharges);
      }
      if(deliveryName != null && deliveryName != ""){
        deliveryPersonId = await DeliveryPersonDbService.addNewDeliveryPerson(db, deliveryName);
      }

      if(customerId == -1 || deliveryModelId == -1 || deliveryPersonId == -1){
        return false;
      }else{
        int stockOutId = await TransactionStockOutDbStorage.insertNewData(db, userModel: userModel, dateTime: dateTime, taxPercentage: taxPercentage, additionalPromotionAmount: additionalPromotionAmount, description: description, shoppingType: shoppingType, paymentMethod: paymentMethod, barcode: barcode, customerId: customerId, deliveryPersonId: deliveryPersonId, deliveryModelId: deliveryModelId, finalTotalPrice: finalTotalPrice);
        // if(stockOutId == -1){
        //   return false;
        // }else{
        //   await TransactionStockOutItemDbStorage.insertNewDataList(db: db, dataList: dataList, stockOutId: stockOutId);
        //   return await stockOutUniqueItemList(db, uniqueItemList: uniqueItemList, userModel: userModel, dateTime: dateTime, stockOutId: stockOutId);
        // }
        if(stockOutId == -1) return false;
        List<int> valueList = await TransactionStockOutItemDbStorage.insertNewDataList(db: db, dataList: dataList, stockOutId: stockOutId);
        if(valueList.contains(-1)) return false;

        if(promotionModel != null){
          bool insertStockOutPromotion = await StockOutPromotionDbServive.addNewData(db: db, stockOutId: stockOutId, promotionId: promotionModel.id);
          if(!insertStockOutPromotion) return false;
        }

        return await stockOutUniqueItemList(db, uniqueItemList: uniqueItemList, userModel: userModel, dateTime: dateTime, stockOutId: stockOutId);
      }
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }
  
  static Future<List<StockOutModel>> getAllStockOutData(Database db)async{
    List<dynamic> dataList = await TransactionStockOutDbStorage.getAllData(db);
    return dataList.map((e) => StockOutModel.fromJson(e)).toList();
  }

  static Future<List<StockInModel>> getAllStockInData(Database db)async{
    List<dynamic> dataList = await TransactionStockInDbStorage.getAllStockInList(db);
    return dataList.map((e) => StockInModel.fromJson(e)).toList();
  }

  static Future<List<StockOutItemModel>> getAllStockOutItemData(Database db)async{
    List<dynamic> dataList = await TransactionStockOutItemDbStorage.getAllData(db);
    return dataList.map((e) => StockOutItemModel.fromJson(e)).toList();
  }

  static Future<bool>createStockIn(
      Database db,
      {
        required UserModel userModel,
        required CategoryModel categoryModel,
        required GroupModel groupModel,
        required TypeModel typeModel,
        required ItemModel itemModel,
        required String? code,
        required DateTime? itemManufactureDate,
        required DateTime? itemExpireDate,
        required String? getItemFromWhere,
        required int itemLength,
      }
      )async{
    DateTime dateTime = DateTime.now();
    int stockInId = await insertStockIn(db, userModel, dateTime);
    if(stockInId == -1){
      return false;
    }else{
      int categoryValue = await CategoryDbStorage.updateCategoryLastUpdateTime(db, dateTime, categoryModel);
      if(categoryValue == -1){
        return false;
      }else{
        int groupValue = await GroupDbStorage.updateGroupLastUpdateTime(db, dateTime, groupModel);
        if(groupValue == -1){
          return false;
        }else{
          int typeValue = await TypeDbStorage.updateTypeLastUpdateTime(db, dateTime, typeModel);
          if(typeValue == -1){
            return false;
          }else{
            int itemValue = await ItemDbStorage.updateItemLastUpdateTime(db, dateTime, itemModel);
            if(itemValue == -1){
              return false;
            }else{
              List<int> uniqueIdList = await UniqueItemDbStorage.insertNewDataList(db: db, itemLength: itemLength, userModel: userModel, stockInId: stockInId, dateTime: dateTime, itemModel: itemModel, itemManufactureDate: itemManufactureDate, itemExpireDate: itemExpireDate, getItemFromWhere: getItemFromWhere, code: code);
              if(uniqueIdList.contains(-1)){
                return false;
              }else{
                return true;
              }
            }
          }
        }
      }
    }
  }

  static Future<bool>stockOutUniqueItemList(
      Database db,
      {
        required List<UniqueItemModel> uniqueItemList,
        required UserModel userModel,
        required DateTime dateTime,
        required int stockOutId,
      }
      )async{
    List<int> idList = await UniqueItemDbStorage.stockOutUniqueItemList(db, uniqueItemList: uniqueItemList, userModel: userModel, dateTime: dateTime, stockOutId: stockOutId);
    if(idList.contains(-1)){
      return false;
    }else{
      return true;
    }
  }

  static Future<bool>stockOutOrderCancel(
    Database db,
    {
      required UserModel userModel,
      required int stockOutId,
      required List<ItemModel> itemModelList,
    }
  )async{
    DateTime dateTime = DateTime.now();
    try{
      int value = await TransactionStockOutDbStorage.deActivateStockOut(db, userModel: userModel, dateTime: dateTime, stockOutId: stockOutId);
      if(value == -1) return false;
      bool updateValue = await UniqueItemDbService.reActivateUniqueItemList(db, userModel: userModel, stockOutId: stockOutId, dateTime: dateTime, itemModelList: itemModelList);
      return updateValue;
    }catch(err){
      cusDebugPrint(err);
      return false;

    }
  }

  static Future<bool>deleteStockOut(
    Database db,
    {
      required UserModel userModel,
      required int stockOutId,
    }
  )async{
    DateTime dateTime = DateTime.now();
    try{
      int value = await TransactionStockOutDbStorage.deActivateStockOut(db, userModel: userModel, dateTime: dateTime, stockOutId: stockOutId);
      return value != -1;
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }
}