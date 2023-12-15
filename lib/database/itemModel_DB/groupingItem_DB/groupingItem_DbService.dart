import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/database/historyModel_DB/history_DBservice.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/Item_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/category_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/group_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/type_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/uniqueItem_DB/uniqueItem_DbService.dart';
import 'package:pos_mobile/database/itemModel_DB/uniqueItem_DB/uniqueItem_DbStorage.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/type_model.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:sqflite/sqflite.dart';

import '../../../models/item_model_folder/item_model.dart';
import '../../../models/user_model_folder/user_model.dart';
import '../../../utils/debug_print.dart';

class GroupingItemDbService{
  static Future<void>initAllGroupingItemDb(Database db)async{
    await CategoryDbStorage.onCreate(db);
    await GroupDbStorage.onCreate(db);
    await TypeDbStorage.onCreate(db);
    await ItemDbStorage.onCreate(db);
  }

  static Future<void>deleteAllGroupingItemDb(Database db)async{
    await ItemDbStorage.onDelete(db);
    await TypeDbStorage.onDelete(db);
    await GroupDbStorage.onDelete(db);
    await CategoryDbStorage.onDelete(db);
  }

  static Future<Map<String, List>>getAllData(Database db)async{
    List<dynamic> categoryList = await CategoryDbStorage.getAllData(db);
    List<dynamic> groupList = await GroupDbStorage.getAllData(db);
    List<dynamic> typeList = await TypeDbStorage.getAllData(db);
    List<dynamic> itemList = await ItemDbStorage.getAllData(db);
    return {
      "category" : categoryList.map((e) => CategoryModel.fromJson(e)).toList(),
      "group" : groupList.map((e) => GroupModel.fromJson(e)).toList(),
      "type" : typeList.map((e) => TypeModel.fromJson(e)).toList(),
      "item" : itemList.map((e) => ItemModel.fromJson(e)).toList(),
    };
  }

  static Future<bool>createNewCategory(
      Database db,
      {
        required String categoryName,
        required UserModel userModel
      }
    )async{
    int value = await CategoryDbStorage.insertNewCategory(db, categoryName: categoryName, userModel: userModel);
    if(value == -1){
      return false;
    }else{
      return true;
    }
  }
  
  static Future<bool>createNewGroup(
    Database db,
    {
      required UserModel userModel,
      required CategoryModel categoryModel,
      required String groupName,
      required String? description,
    }  
  )async{
    DateTime dateTime = DateTime.now();
    int value = await CategoryDbStorage.updateCategoryLastUpdateTime(db, dateTime, categoryModel);
    if(value == -1){
      return false;
    }else{
      int groupId = await GroupDbStorage.insertNewGroup(db, userModel: userModel, categoryModel: categoryModel, groupName: groupName, description: description, dateTime: dateTime);
      if(groupId == -1){
        return false;
      }else{
        return true;
      }
    }
  }

  static Future<bool>createNewType(
    Database db,
    {
      required UserModel userModel,
      required CategoryModel categoryModel,
      required GroupModel groupModel,
      required String typeName,
      required String? generalDescription,
      required bool hasExpire
    }
  )async{
    DateTime dateTime = DateTime.now();
    int value = await CategoryDbStorage.updateCategoryLastUpdateTime(db, dateTime, categoryModel);
    if(value == -1){
      return false;
    }else{
      int groupValue = await GroupDbStorage.updateGroupLastUpdateTime(db, dateTime, groupModel);
      if(groupValue == -1){
        return false;
      }else{
        int typeId = await TypeDbStorage.insertNewType(
          db,
          name: typeName,
          generalDescription: generalDescription,
          groupModel: groupModel,
          dateTime: dateTime,
          userModel: userModel,
          hasExpire: hasExpire,
        );
        if(typeId == -1){
          return false;
        }else{
          return true;
        }
      }
    }
  }

  static Future<bool>createNewItem(
    Database db,
    {
      required UserModel userModel,
      required CategoryModel categoryModel,
      required GroupModel groupModel,
      required TypeModel typeModel,
      required String name,
      required String? description,
      required bool hasExpire,
      required double profitPrice,
      required double originalPrice,
      required double taxPercentage,
    }
  )async{
    try{
      DateTime dateTime = DateTime.now();
      int value = await CategoryDbStorage.updateCategoryLastUpdateTime(db, dateTime, categoryModel);
      int groupValue = await GroupDbStorage.updateGroupLastUpdateTime(db, dateTime, groupModel);
      int typeValue = await TypeDbStorage.updateTypeLastUpdateTime(db, dateTime, typeModel);
      int itemId = await ItemDbStorage.insertNewItem(
          db,
          userModel: userModel,
          name: name,
          typeModel: typeModel,
          dateTime: dateTime,
          hasExpire: hasExpire,
          description: description,
          profitPrice: profitPrice,
          originalPrice: originalPrice,
          taxPercentage: taxPercentage
      );
      return value != -1 && groupValue != -1 && typeValue != -1 && itemId != -1;
    }catch(e){
      cusDebugPrint(e);
      return false;
    }
  }


  // category
  static Future<bool>updateCategoryName(
    Database db,  {
    required String name,
    required UserModel userModel,
    required CategoryModel categoryModel,
  })async{
    try{
      DateTime dateTime = DateTime.now();
      List<dynamic> oldRawList = await CategoryDbStorage.getSingleCategory(db, dateTime, categoryModel);
      if(oldRawList.isEmpty) return false;

      int value = await CategoryDbStorage.updateCategoryName(db, dateTime, categoryModel,name);
      if(value == -1)return false;

      List<dynamic> newRawList = await CategoryDbStorage.getSingleCategory(db, dateTime, categoryModel);
      if(newRawList.isEmpty) return false;

      return await HistoryDBService.addHistoryData(
          oldData: CategoryModel.fromJson(oldRawList.first),
          newData:CategoryModel.fromJson(newRawList.first),
          updateType: UpdateType.update,
          createPersonId: userModel.id,
          db: db,
          dateTime: dateTime,
      );
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }

  static Future<bool>deactivateCategory(
    Database db,
    {
      required UserModel userModel,
      required CategoryModel categoryModel,
    }
  )async{
    DateTime dateTime = DateTime.now();
    try{
      int value = await CategoryDbStorage.deactivateCategory(db, dateTime: dateTime, categoryModel: categoryModel, userModel: userModel);
      return value != -1;
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }
  // category




  //group
  static Future<bool>updateGroupName(
    Database db,
    {
      required String name,
      required UserModel userModel,
      required GroupModel groupModel,
    }
  )async{
    try{
      DateTime dateTime = DateTime.now();
      List<dynamic> oldRawList = await GroupDbStorage.getSingleGroup(db, groupModel);
      if(oldRawList.isEmpty) return false;

      int value = await GroupDbStorage.updateGroupName(db, newName: name, dateTime: dateTime, groupModel: groupModel);
      if(value == -1) return false;

      List<dynamic> newRawList = await GroupDbStorage.getSingleGroup(db, groupModel);
      if(newRawList.isEmpty) return false;

      return await HistoryDBService.addHistoryData(
        oldData: GroupModel.fromJson(oldRawList.first),
        newData: GroupModel.fromJson(newRawList.first),
        updateType: UpdateType.update,
        createPersonId: userModel.id,
        db: db,
        dateTime: dateTime,
      );
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }

  static Future<bool>deactivateGroup(
    Database db,
    {
      required UserModel userModel,
      required GroupModel groupModel,
    }
  )async{
    DateTime dateTime = DateTime.now();
    try{
      int value = await GroupDbStorage.deactivateGroup(db, dateTime: dateTime, groupModel: groupModel, userModel: userModel);
      return value != -1;
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }
  //group




  // type
  static Future<bool>updateTypeName(
    Database db,
    {
      required String newName,
      required UserModel userModel,
      required TypeModel typeModel,
    }
  )async{
    DateTime dateTime = DateTime.now();
    try{
      List<dynamic>oldRawList = await TypeDbStorage.getSingleType(db, typeModel);
      if(oldRawList.isEmpty) return false;

      int value = await TypeDbStorage.updateTypeName(db, newName: newName, dateTime: dateTime, typeModel: typeModel);
      if(value == -1) return false;

      List<dynamic> newRawList = await TypeDbStorage.getSingleType(db, typeModel);
      if(newRawList.isEmpty) return false;

      return await HistoryDBService.addHistoryData(
        oldData: TypeModel.fromJson(oldRawList.first),
        newData: TypeModel.fromJson(newRawList.first),
        updateType: UpdateType.update,
        createPersonId: userModel.id,
        db: db,
        dateTime: dateTime,
      );
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }

  static Future<bool>deactivateType(
    Database db,
    {
      required TypeModel typeModel,
      required UserModel userModel,
    }
  )async{
    DateTime dateTime = DateTime.now();
    try{
      int value = await TypeDbStorage.deactivateType(db, dateTime: dateTime, userModel: userModel, typeModel: typeModel);
      return value != -1;
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }
  // type




  // item
  static Future<bool>updateItem(
    Database db,
    {
      required UserModel userModel,
      required ItemModel itemModel,
      required List<UniqueItemModel> uniqueItemList,
      required String newName,
      required double newOriginalPrice,
      required double newProfitPrice,
      required double newTaxPercentage,
    }
  )async{
    try{
      DateTime dateTime = DateTime.now();
      List<dynamic> oldRawList = await ItemDbStorage.getSingleItem(db, itemModel);
      if(oldRawList.isEmpty) return false;

      int value = await ItemDbStorage.updateItem(
        db,
        dateTime: dateTime,
        itemModel: itemModel,
        newName: newName,
        originalPrice: newOriginalPrice,
        profitPrice: newProfitPrice,
        taxPercentage: newTaxPercentage,
      );
      if(value == -1) return false;

      List<int> valueList = await UniqueItemDbService.updateUniqueItemList(
        db,
        userModel: userModel,
        uniqueItemList: uniqueItemList,
        dateTime: dateTime,
        profitPrice: newProfitPrice,
        originalPrice: newOriginalPrice,
        taxPercentage: newTaxPercentage,
      );

      if(valueList.contains(-1))return false;

      List<dynamic> newRawList = await ItemDbStorage.getSingleItem(db, itemModel);
      if(newRawList.isEmpty) return false;

      return await HistoryDBService.addHistoryData(
          oldData: ItemModel.fromJson(oldRawList.first),
          newData: ItemModel.fromJson(newRawList.first),
          updateType: UpdateType.update,
          createPersonId: userModel.id,
          db: db,
          dateTime: dateTime
      );
    }catch(err){
      cusDebugPrint(err);
      return false;
    }
  }

  static Future<bool>deactivateItem(
    Database db,
    {
      required UserModel userModel,
      required ItemModel itemModel,
      required List<UniqueItemModel> uniqueItemList,
    }
  )async{
    DateTime dateTime = DateTime.now();
    List<int> idList = await UniqueItemDbStorage.deactivateUniqueItemList(db, userModel: userModel, uniqueItemList: uniqueItemList, dateTime: dateTime);
    if(idList.contains(-1)) return false;
    int value = await ItemDbStorage.deactivateItem(db, userModel: userModel, dateTime: dateTime, itemModel: itemModel);
    return value != -1;
  }
  // item

}