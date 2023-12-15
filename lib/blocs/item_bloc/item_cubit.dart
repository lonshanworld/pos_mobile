
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import "package:collection/collection.dart";

import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/itemModel_with_UniqueItemcount.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';

import '../../models/groupingItem_models_folders/group_model.dart';
import '../../models/groupingItem_models_folders/type_model.dart';
import '../../models/item_model_folder/uniqueItem_model.dart';
import '../../models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import '../../models/promotion_model_folder/promotion_model.dart';
import '../../models/user_model_folder/user_model.dart';

part 'item_state.dart';

class ItemCubit extends Cubit<ItemState> {

  ItemCubit() : super(const ItemData(
    activeCategoryList: [],
    activeGroupList: [],
    activeTypeList: [],
    activeItemList: [],
    activeUniqueItemList: [],
    inActiveCategoryList: [],
    inActiveGroupList: [],
    inActiveTypeList: [],
    inActiveItemList: [],
    inActiveUniqueItemList: []
  )){
    _initAllItemData();
  }

  Future<void>_initAllItemData()async{
    Map<String, List> data = await DBHelper.getAllItemData();
    // emit(ItemData(
    //   activeCategoryList: data["category"] as List<CategoryModel>,
    //   activeGroupList: data["group"] as List<GroupModel>,
    //   activeTypeList: data["type"] as List<TypeModel>,
    //   activeItemList: data["item"] as List<ItemModel>,
    //   activeUniqueItemList: data["uniqueItem"] as List<UniqueItemModel>,
    // ));
    List<CategoryModel> activeCategoryList = [];
    List<CategoryModel> inActiveCategoryList = [];

    List<GroupModel> activeGroupList = [];
    List<GroupModel> inActiveGroupList = [];

    List<TypeModel> activeTypeList = [];
    List<TypeModel> inActiveTypeList = [];

    List<ItemModel> activeItemList = [];
    List<ItemModel> inActiveItemList = [];

    List<UniqueItemModel> activeUniqueItemList =[];
    List<UniqueItemModel> inActiveUniqueItemList = [];

    List<CategoryModel> rawCategoryList = data["category"] as List<CategoryModel>;
    List<GroupModel> rawGroupList = data["group"] as List<GroupModel>;
    List<TypeModel> rawTypeList = data["type"] as List<TypeModel>;
    List<ItemModel> rawItemList = data["item"] as List<ItemModel>;
    List<UniqueItemModel> rawUniqueItemList = data["uniqueItem"] as List<UniqueItemModel>;

    for(int a = 0; a< rawCategoryList.length; a++){
      if(rawCategoryList[a].activeStatus){
        activeCategoryList.add(rawCategoryList[a]);
      }else{
        inActiveCategoryList.add(rawCategoryList[a]);
      }
    }

    for(int b = 0; b < rawGroupList.length; b++){
      if(rawGroupList[b].activeStatus){
        activeGroupList.add(rawGroupList[b]);
      }else{
        inActiveGroupList.add(rawGroupList[b]);
      }
    }

    for(int c = 0; c< rawTypeList.length; c++){
      if(rawTypeList[c].activeStatus){
        activeTypeList.add(rawTypeList[c]);
      }else{
        inActiveTypeList.add(rawTypeList[c]);
      }
    }

    for(int d = 0; d < rawItemList.length; d++){
      if(rawItemList[d].activeStatus){
        activeItemList.add(rawItemList[d]);
      }else{
        inActiveItemList.add(rawItemList[d]);
      }
    }

    for(int e = 0; e < rawUniqueItemList.length; e++){
      if(rawUniqueItemList[e].activeStatus){
        activeUniqueItemList.add(rawUniqueItemList[e]);
      }else{
        inActiveUniqueItemList.add(rawUniqueItemList[e]);
      }
    }

    emit(ItemData(activeCategoryList: activeCategoryList, activeGroupList: activeGroupList, activeTypeList: activeTypeList, activeItemList: activeItemList, activeUniqueItemList: activeUniqueItemList, inActiveCategoryList: inActiveCategoryList, inActiveGroupList: inActiveGroupList, inActiveTypeList: inActiveTypeList, inActiveItemList: inActiveItemList, inActiveUniqueItemList: inActiveUniqueItemList));
  }

  Future<void>reloadAllItem()async{
    await _initAllItemData();
  }




  //filter
  List<ItemModelWithUniqueItemCountWithPromotion> getItemListWithCountFromUniqueItemListWithPromotion({
    required List<UniqueItemModel> uniqueItemList,
    required List<ItemModel> itemModelList, 
    required List<PromotionModel> activePromotionList,
    required List<ItemPromotionModel> itemPromotionList
  }){
    List<ItemModelWithUniqueItemCountWithPromotion> dataList = [];
    for(int i = 0; i < itemModelList.length; i++){
      PromotionModel? promotion;
      int count = 0;
      ItemPromotionModel? datajoint = itemPromotionList.firstWhereOrNull((element) => element.itemId == itemModelList[i].id);
      if(datajoint != null){
        promotion = activePromotionList.firstWhereOrNull((element) => element.id == datajoint.promotionId);
      }

      for(int j = 0; j < uniqueItemList.length; j++){
        if(itemModelList[i].id == uniqueItemList[j].itemId){
          count ++;
        }
      }
      ItemModelWithUniqueItemCountWithPromotion dataModel = ItemModelWithUniqueItemCountWithPromotion(itemModel: itemModelList[i], count: count, promotion: promotion);
      dataList.add(dataModel);
    }
    return dataList;
  }
  //filter




  // stockIn
  Future<bool>createNewCategory(UserModel userModel, String categoryName)async{
    bool value = await DBHelper.createNewCategory(userModel, categoryName);
    await _initAllItemData();
    return value;
  }

  Future<bool>createNewGroup({
    required UserModel userModel,
    required CategoryModel categoryModel,
    required String groupName,
    required String? description,
  })async{
    bool value = await DBHelper.createNewGroup(userModel: userModel, categoryModel: categoryModel, groupName: groupName, description: description);
    await _initAllItemData();
    return value;
  }

  Future<bool>createNewType({
    required UserModel userModel,
    required CategoryModel categoryModel,
    required GroupModel groupModel,
    required String typeName,
    required String? generalDescription,
    required bool hasExpire,
  })async{
    bool value = await DBHelper.createNewType(
      userModel: userModel,
      categoryModel: categoryModel,
      groupModel: groupModel,
      typeName: typeName,
      generalDescription: (generalDescription == null || generalDescription == "") ? null : generalDescription,
      hasExpire: hasExpire,
    );
    await _initAllItemData();
    return value;
  }

  Future<bool>createNewItem({
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
  })async{
    bool value = await DBHelper.createNewItem(
        userModel: userModel,
        categoryModel: categoryModel,
        groupModel: groupModel,
        typeModel: typeModel,
        name: name,
        description: description,
        hasExpire: hasExpire,
        profitPrice: profitPrice,
        originalPrice: originalPrice,
        taxPercentage: taxPercentage
    );
    await _initAllItemData();
    return value;
  }

  

  List<GroupModel> getSelectedGroupList(int? id){
    List<GroupModel> newList = [];
    for(int a = 0 ; a < state.activeGroupList.length; a++){
      if(id == state.activeGroupList[a].categoryId){
        newList.add(state.activeGroupList[a]);
      }
    }
    return newList;
  }

  List<TypeModel> getSelectedTypeList(int? id){
    List<TypeModel> newList = [];
    for(int a = 0 ; a < state.activeTypeList.length; a++){
      if(id == state.activeTypeList[a].groupId){
        newList.add(state.activeTypeList[a]);
      }
    }
    return newList;
  }

  List<ItemModel>getSelectedItemList(int? id){
    List<ItemModel> newList = [];
    for(int a = 0; a < state.activeItemList.length; a++){
      if(id == state.activeItemList[a].typeId){
        newList.add(state.activeItemList[a]);
      }
    }
    return newList;
  }

  List<UniqueItemModel>getSelectedUniqueItemList(int itemId){
    List<UniqueItemModel> newList = [];
    for(int a = 0; a < state.activeUniqueItemList.length; a++){
      if(itemId == state.activeUniqueItemList[a].itemId){
        newList.add(state.activeUniqueItemList[a]);
      }
    }
    return newList;
  }

  // List<UniqueItemModel>testinguniqueItemList(int itemId){
  //   List<UniqueItemModel> originalList = [...state.activeUniqueItemList, ...state.inActiveUniqueItemList];
  //   List<UniqueItemModel> newList = [];
  //   for(int a = 0; a < originalList.length; a++){
  //     if(itemId == originalList[a].itemId){
  //       newList.add(originalList[a]);
  //     }
  //   }
  //   return newList;
  // }

  List<UniqueItemModel> getSelectedUniqueItemFromStockOutId(int stockOutId){

    List<UniqueItemModel> dataList = [];
    for(int i = 0; i < state.inActiveUniqueItemList.length; i++){
      if(state.inActiveUniqueItemList[i].stockOutId != null && state.inActiveUniqueItemList[i].stockOutId == stockOutId){
        dataList.add(state.inActiveUniqueItemList[i]);
      }
    }

    return dataList;
  }

  CategoryModel getCategory(int id){
    return state.activeCategoryList.firstWhereOrNull((element) => element.id == id)!;
  }
  
  GroupModel getGroup(int id){
    return state.activeGroupList.firstWhereOrNull((element) => element.id == id)!;
  }

  TypeModel? getType(int id){
    return state.activeTypeList.firstWhereOrNull((element) => element.id == id);
  }

  ItemModel? getItem(int id){
    return state.activeItemList.firstWhereOrNull((element) => element.id == id);
  }
// stockIn




  




  // Edit
  Future<bool>editCategoryName({
    required String name,
    required UserModel userModel,
    required CategoryModel categoryModel,
  })async{
    bool value = await DBHelper.editCategoryName(name: name, userModel: userModel, categoryModel: categoryModel);
    await _initAllItemData();
    return value;
  }

  Future<bool>editGroupName({
    required String newName,
    required UserModel userModel,
    required GroupModel groupModel,
  })async{
    bool value = await DBHelper.editGroupName(newName: newName, userModel: userModel, groupModel: groupModel);
    await _initAllItemData();
    return value;
  }

  Future<bool>editTypeName({
    required String newName,
    required UserModel userModel,
    required TypeModel typeModel,
  })async{
    bool value = await DBHelper.editType(newName: newName, userModel: userModel, typeModel: typeModel);
    await _initAllItemData();
    return value;
  }

  Future<bool>editItem({
    required UserModel userModel,
    required ItemModel itemModel,
    required String newName,
    required double newOriginalPrice,
    required double newProfitPrice,
    required double newTaxPercentage,
  })async{
    List<UniqueItemModel> uniqueItemList = getSelectedUniqueItemList(itemModel.id);
    bool value = await DBHelper.editItem(userModel: userModel, itemModel: itemModel, uniqueItemList: uniqueItemList, newName: newName, newOriginalPrice: newOriginalPrice, newProfitPrice: newProfitPrice, newTaxPercentage: newTaxPercentage);
    await _initAllItemData();
    return value;
  }
  // edit




  // delete
  Future<bool>deleteCategory(UserModel userModel, CategoryModel categoryModel)async{
    bool value = await DBHelper.deleteCategory(userModel: userModel, categoryModel: categoryModel);
    await _initAllItemData();
    return value;
  }

  Future<bool>deleteGroup(UserModel userModel, GroupModel groupModel)async{
    bool value = await DBHelper.deleteGroup(userModel: userModel, groupModel: groupModel);
    await _initAllItemData();
    return value;
  }

  Future<bool>deleteType(UserModel userModel, TypeModel typeModel)async{
    bool value = await DBHelper.deleteType(userModel: userModel, typeModel: typeModel);
    await _initAllItemData();
    return value;
  }

  Future<bool>deleteItem(UserModel userModel, ItemModel itemModel)async{
    List<UniqueItemModel> uniqueItemList = getSelectedUniqueItemList(itemModel.id);
    bool value = await DBHelper.deleteItem(userModel: userModel, itemModel: itemModel, uniqueItemList:  uniqueItemList);
    await _initAllItemData();
    return value;
  }

  List<UniqueItemModel> filterInActiveUniqueItemList (){
    List<UniqueItemModel> newList = [];
    for(int i = 0; i < state.inActiveUniqueItemList.length; i++){
      if(state.inActiveUniqueItemList[i].activeStatus == false && state.inActiveUniqueItemList[i].stockOutId != null){
        newList.add(state.inActiveUniqueItemList[i]);
      }
    }
    return newList;
  }


  List<ItemModel> getItemListFromSelectedUniqueItemList(List<UniqueItemModel> uniqueItemList){
    List<int> idList = [];
    for(int a = 0; a < uniqueItemList.length; a++){
      if(!idList.contains(uniqueItemList[a].itemId)){
        idList.add(uniqueItemList[a].itemId);
      }
    }
    List <ItemModel> allItemList = [...state.activeItemList, ...state.inActiveItemList];
    List<ItemModel> dataList = [];
    for(int b = 0; b < idList.length; b++){
      ItemModel? itemModel = allItemList.firstWhereOrNull((element) => element.id == idList[b]);
      if(itemModel != null){
        dataList.add(itemModel);
      }
    }

    return dataList;
  }

  Future<bool>deleteUniqueItem(UniqueItemModel uniqueItemModel, UserModel userModel)async{
    bool value = await DBHelper.deleteUniqueItem(uniqueItemModel, userModel);
    if(value) reloadAllItem();
    return value;
  }

}
