import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import "package:collection/collection.dart";
import 'package:pos_mobile/utils/debug_print.dart';

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
    allActiveCategoryList: [],
    allActiveGroupList: [],
    allActiveTypeList: [],
    activeItemList: [],
    activeUniqueItemList: [],
    inActiveCategoryList: [],
    inActiveGroupList: [],
    inActiveTypeList: [],
    inActiveItemList: [],
    inActiveUniqueItemList: [],
    categoryGroupCountMap: {},
    groupTypeCountMap: {},
    totalCategoryCount: 0,
    categoryOffset: 0,
    hasMoreCategory: true,
    isLoadingMoreCategory: false,
    groupOffset: 0,
    hasMoreGroup: true,
    isLoadingMoreGroup: false,
  )) {
    _initAllItemData();
  }

  Future<void>_initAllItemData()async{
    try{
      final Map<String, List> data = await DBHelper.getAllItemData(
        limit: UIConstants.defaultPageLimit,
        offset: 0,
      );
      final int totalCategoryCount = await DBHelper.getTotalCategoryCount();
      final Map<int, int> categoryGroupCountMap = await DBHelper.getGroupCountByCategory();
      final Map<int, int> groupTypeCountMap = await DBHelper.getTypeCountByGroup();
      final List<CategoryModel> allActiveCategoryList =
          _filterActiveCategoryList(await DBHelper.getAllActiveCategories());
      final List<GroupModel> allActiveGroupList =
          _filterActiveGroupList(await DBHelper.getAllActiveGroups());
      final List<TypeModel> allActiveTypeList =
          _filterActiveTypeList(await DBHelper.getAllActiveTypes());

      final List<CategoryModel> rawCategoryList =
          (data["category"] as List<CategoryModel>?) ?? <CategoryModel>[];
      final List<GroupModel> rawGroupList =
          (data["group"] as List<GroupModel>?) ?? <GroupModel>[];
      final List<TypeModel> rawTypeList =
          (data["type"] as List<TypeModel>?) ?? <TypeModel>[];
      final List<ItemModel> rawItemList =
          (data["item"] as List<ItemModel>?) ?? <ItemModel>[];
      final List<UniqueItemModel> rawUniqueItemList =
          (data["uniqueItem"] as List<UniqueItemModel>?) ??
          <UniqueItemModel>[];

      List<CategoryModel> activeCategoryList = [];
      List<CategoryModel> inActiveCategoryList = [];
      List<GroupModel> activeGroupList = [];
      List<GroupModel> inActiveGroupList = [];
      List<TypeModel> activeTypeList = [];
      List<TypeModel> inActiveTypeList = [];
      List<ItemModel> activeItemList = [];
      List<ItemModel> inActiveItemList = [];
      List<UniqueItemModel> activeUniqueItemList = [];
      List<UniqueItemModel> inActiveUniqueItemList = [];

      for (final category in rawCategoryList) {
        if (category.activeStatus) {
          activeCategoryList.add(category);
        } else {
          inActiveCategoryList.add(category);
        }
      }

      for (final group in rawGroupList) {
        if (group.activeStatus) {
          activeGroupList.add(group);
        } else {
          inActiveGroupList.add(group);
        }
      }

      for (final type in rawTypeList) {
        if (type.activeStatus) {
          activeTypeList.add(type);
        } else {
          inActiveTypeList.add(type);
        }
      }

      for (final item in rawItemList) {
        if (item.activeStatus) {
          activeItemList.add(item);
        } else {
          inActiveItemList.add(item);
        }
      }

      for (final uniqueItem in rawUniqueItemList) {
        if (uniqueItem.activeStatus) {
          activeUniqueItemList.add(uniqueItem);
        } else {
          inActiveUniqueItemList.add(uniqueItem);
        }
      }

      emit(ItemData(
        activeCategoryList: activeCategoryList,
        activeGroupList: activeGroupList,
        activeTypeList: activeTypeList,
        allActiveCategoryList: allActiveCategoryList,
        allActiveGroupList: allActiveGroupList,
        allActiveTypeList: allActiveTypeList,
        activeItemList: activeItemList,
        activeUniqueItemList: activeUniqueItemList,
        inActiveCategoryList: inActiveCategoryList,
        inActiveGroupList: inActiveGroupList,
        inActiveTypeList: inActiveTypeList,
        inActiveItemList: inActiveItemList,
        inActiveUniqueItemList: inActiveUniqueItemList,
        categoryGroupCountMap: categoryGroupCountMap,
        groupTypeCountMap: groupTypeCountMap,
        totalCategoryCount: totalCategoryCount,
        categoryOffset: 0,
        hasMoreCategory:
            rawCategoryList.length == UIConstants.defaultPageLimit,
        isLoadingMoreCategory: false,
        groupOffset: 0,
        hasMoreGroup: rawGroupList.length == UIConstants.defaultPageLimit,
        isLoadingMoreGroup: false,
      ));
    }catch(err){
      cusDebugPrint('Failed to initialize item data: $err');
      emit(const ItemData(
        activeCategoryList: [],
        activeGroupList: [],
        activeTypeList: [],
        allActiveCategoryList: [],
        allActiveGroupList: [],
        allActiveTypeList: [],
        activeItemList: [],
        activeUniqueItemList: [],
        inActiveCategoryList: [],
        inActiveGroupList: [],
        inActiveTypeList: [],
        inActiveItemList: [],
        inActiveUniqueItemList: [],
        categoryGroupCountMap: {},
        groupTypeCountMap: {},
        totalCategoryCount: 0,
        categoryOffset: 0,
        hasMoreCategory: false,
        isLoadingMoreCategory: false,
        groupOffset: 0,
        hasMoreGroup: false,
        isLoadingMoreGroup: false,
      ));
    }
  }

  Future<void>reloadAllItem()async{
    await _initAllItemData();
  }

  List<CategoryModel> _filterActiveCategoryList(List<CategoryModel> source) {
    return source.where((category) => category.activeStatus).toList();
  }

  List<GroupModel> _filterActiveGroupList(List<GroupModel> source) {
    return source.where((group) => group.activeStatus).toList();
  }

  List<TypeModel> _filterActiveTypeList(List<TypeModel> source) {
    return source.where((type) => type.activeStatus).toList();
  }

  Future<void> loadMoreCategories() async {
    if (state.isLoadingMoreCategory || !state.hasMoreCategory) return;

    emit((state as ItemData).copyWith(isLoadingMoreCategory: true));

    try{
      final int newOffset = state.categoryOffset + UIConstants.defaultPageLimit;
      List<CategoryModel> moreCategories = await DBHelper.getAllCategories(
        limit: UIConstants.defaultPageLimit,
        offset: newOffset,
      );

      List<CategoryModel> newActiveCategoryList = List.from(state.activeCategoryList);
      List<CategoryModel> newInActiveCategoryList = List.from(state.inActiveCategoryList);

      for (var category in moreCategories) {
        if (category.activeStatus) {
          newActiveCategoryList.add(category);
        } else {
          newInActiveCategoryList.add(category);
        }
      }

      emit((state as ItemData).copyWith(
        activeCategoryList: newActiveCategoryList,
        inActiveCategoryList: newInActiveCategoryList,
        categoryOffset: newOffset,
        hasMoreCategory: moreCategories.length == UIConstants.defaultPageLimit,
        isLoadingMoreCategory: false,
      ));
    }catch(e){
      cusDebugPrint('Failed to load more categories: $e');
      emit((state as ItemData).copyWith(isLoadingMoreCategory: false));
    }
  }

  Future<void> loadMoreGroups() async {
    if (state.isLoadingMoreGroup || !state.hasMoreGroup) return;

    emit((state as ItemData).copyWith(isLoadingMoreGroup: true));

    try{
      final int newOffset = state.groupOffset + UIConstants.defaultPageLimit;
      List<GroupModel> moreGroups = await DBHelper.getAllGroups(
        limit: UIConstants.defaultPageLimit,
        offset: newOffset,
      );

      List<GroupModel> newActiveGroupList = List.from(state.activeGroupList);
      List<GroupModel> newInActiveGroupList = List.from(state.inActiveGroupList);

      for (var group in moreGroups) {
        if (group.activeStatus) {
          newActiveGroupList.add(group);
        } else {
          newInActiveGroupList.add(group);
        }
      }

      emit((state as ItemData).copyWith(
        activeGroupList: newActiveGroupList,
        inActiveGroupList: newInActiveGroupList,
        groupOffset: newOffset,
        hasMoreGroup: moreGroups.length == UIConstants.defaultPageLimit,
        isLoadingMoreGroup: false,
      ));
    }catch(e){
      cusDebugPrint('Failed to load more groups: $e');
      emit((state as ItemData).copyWith(isLoadingMoreGroup: false));
    }
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
    try{
      bool value = await DBHelper.createNewCategory(userModel, categoryName);
      await _initAllItemData();
      return value;
    }catch(e){
      cusDebugPrint('Failed to create category: $e');
      return false;
    }
  }

  Future<bool>createNewGroup({
    required UserModel userModel,
    required CategoryModel categoryModel,
    required String groupName,
    required String? description,
  })async{
    try{
      bool value = await DBHelper.createNewGroup(userModel: userModel, categoryModel: categoryModel, groupName: groupName, description: description);
      await _initAllItemData();
      return value;
    }catch(e){
      cusDebugPrint('Failed to create group: $e');
      return false;
    }
  }

  Future<bool>createNewType({
    required UserModel userModel,
    required CategoryModel categoryModel,
    required GroupModel groupModel,
    required String typeName,
    required String? generalDescription,
    required bool hasExpire,
  })async{
    try{
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
    }catch(e){
      cusDebugPrint('Failed to create type: $e');
      return false;
    }
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
    try{
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
    }catch(e){
      cusDebugPrint('Failed to create item: $e');
      return false;
    }
  }

  

  List<GroupModel> getSelectedGroupList(int? id){
    List<GroupModel> newList = [];
    for(int a = 0 ; a < state.allActiveGroupList.length; a++){
      if(id == state.allActiveGroupList[a].categoryId){
        newList.add(state.allActiveGroupList[a]);
      }
    }
    return newList;
  }

  int getGroupCountForCategory(int categoryId) {
    return state.categoryGroupCountMap[categoryId] ?? 0;
  }

  int getTotalCategoryCount() {
    return state.totalCategoryCount;
  }

  List<TypeModel> getSelectedTypeList(int? id){
    List<TypeModel> newList = [];
    for(int a = 0 ; a < state.allActiveTypeList.length; a++){
      if(id == state.allActiveTypeList[a].groupId){
        newList.add(state.allActiveTypeList[a]);
      }
    }
    return newList;
  }

  int getTypeCountForGroup(int groupId) {
    return state.groupTypeCountMap[groupId] ?? 0;
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
