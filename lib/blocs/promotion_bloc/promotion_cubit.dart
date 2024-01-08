
import 'package:flutter_bloc/flutter_bloc.dart';
import "package:flutter/material.dart";
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';

import '../../feature/code_generator_feature.dart';
import '../../models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import '../../models/junction_models_folder/promotion_junctions/stockout_promotion_model.dart';
import '../../models/promotion_model_folder/promotion_model.dart';
import "package:collection/collection.dart";
part 'promotion_state.dart';

class PromotionCubit extends Cubit<PromotionState> {
  PromotionCubit() : super(const PromotionData(
      activePromotionList: [],
      inActivePromotionList: [],
      activeItemPromotionList: [], 
      inActiveItemPromotionList: [], 
      stockOutPromotionList: []
  )){
    _loadAllData();
  }

  Future<void> _loadAllData()async{
    await _getAllPromotion();
    await _getAllItemPromotion();
    await _getAllStockOutPromotion();
  }

  Future<void> reloadStockOutPromotionDataList()async{
    await _getAllStockOutPromotion();
  }

  Future<void>_getAllPromotion()async{
    List<PromotionModel> promotionList = await DBHelper.getAllPromotion();

    List<PromotionModel> activePromotionList = [];
    List<PromotionModel> inActivePromotionList = [];
    for(int a = 0; a < promotionList.length; a++){
      cusDebugPrint(promotionList[a].activeStatus);
      if(promotionList[a].activeStatus){
        activePromotionList.add(promotionList[a]);
      }else{
        inActivePromotionList.add(promotionList[a]);
      }
    }
    emit(
        PromotionData(
            activePromotionList: activePromotionList,
            inActivePromotionList: inActivePromotionList,
            activeItemPromotionList: state.activeItemPromotionList,
            inActiveItemPromotionList: state.inActiveItemPromotionList, 
            stockOutPromotionList: state.stockOutPromotionList,
        )
    );
  }
  
  Future<void>_getAllStockOutPromotion()async{
    emit(
        PromotionData(
          activePromotionList: state.activePromotionList,
          inActivePromotionList: state.inActivePromotionList,
          activeItemPromotionList: state.activeItemPromotionList,
          inActiveItemPromotionList: state.inActiveItemPromotionList,
          stockOutPromotionList: await DBHelper.getAllStockOutPromotion(),
        )
    );
  }
  
  Future<void>_getAllItemPromotion()async{
    List<ItemPromotionModel> allItemPromotionList = await DBHelper.getAllItemPromotion();
    List<ItemPromotionModel> activeItemPromotionList = [];
    List<ItemPromotionModel> inActiveItemPromotionList = [];
    for(int a = 0; a< allItemPromotionList.length; a++){
      cusDebugPrint(allItemPromotionList[a].id);
      if(allItemPromotionList[a].activeStatus){
        activeItemPromotionList.add(allItemPromotionList[a]);
      }else{
        inActiveItemPromotionList.add(allItemPromotionList[a]);
      }
    }
    
    emit(PromotionData(
      activePromotionList: state.activePromotionList,
      inActivePromotionList: state.inActivePromotionList,
      activeItemPromotionList: activeItemPromotionList,
      inActiveItemPromotionList: inActiveItemPromotionList,
      stockOutPromotionList: state.stockOutPromotionList,
    ));
  }

  Future<bool>addNewPromotion({
    required String promotionName,
    required String? promotionDescription,
    required double? promotionPercentage,
    required double? promotionPrice,
    required UserModel userModel,
  })async{
    bool value = await DBHelper.addNewPromotion(
      promotionName: promotionName,
      promotionDescription: promotionDescription ?? " -- ",
      promotionPercentage: promotionPercentage, 
      promotionPrice: promotionPrice,
      promotionCode: CodeGenerator.getUniqueCodeForPromotion(promotionName),
      userModel: userModel,
    );
    await _getAllPromotion();
    return value;
  }

  Future<bool>deletePromotion({
    required UserModel userModel,
    required int promotionId,
  })async{
    List<ItemPromotionModel> selectedItemPromotionList = [];
    for(int i = 0; i< state.activeItemPromotionList.length; i++){
      if(state.activeItemPromotionList[i].promotionId == promotionId){
        selectedItemPromotionList.add(state.activeItemPromotionList[i]);
      }
    }
    bool value = await DBHelper.deletePromotion(userModel: userModel, promotionId: promotionId, itemPromotionList: selectedItemPromotionList);
    await _getAllPromotion();
    await _getAllItemPromotion();
    return value;
  }

  Future<bool>detachItemWithPromotion({
    required UserModel userModel,
    required List<ItemPromotionModel> itemPromotionList,
  })async{
    bool value = await DBHelper.detachItemWithPromotion(itemPromotionList: itemPromotionList, userModel: userModel);
    await _getAllItemPromotion();
    return value;
  }

  Future<bool>attachItemWithPromotion({
    required UserModel userModel,
    required int promotionId,
    required int itemId,
  })async{
    bool value = await DBHelper.attachItemWithPromotion(userModel: userModel, promotionId: promotionId, itemId: itemId);
    await _getAllItemPromotion();
    return value;
  }

  Future<void>reloadAllPromotion()async{
    await _getAllItemPromotion();
  }


  // NOTE : each item can have only one promotion (currently)
  PromotionModel? getSinglePromotionFromItemId(int itemId){
    ItemPromotionModel? itemPromotionModel =  state.activeItemPromotionList.firstWhereOrNull((element) => element.itemId == itemId);
    if(itemPromotionModel == null) return null;
    return state.activePromotionList.firstWhereOrNull((element) => element.id == itemPromotionModel.promotionId);
  }

  ItemPromotionModel? getSingleItemPromotionModelFromItemId(int itemId){
    return state.activeItemPromotionList.firstWhereOrNull((element) => element.itemId == itemId);
  }

  List<ItemPromotionModel> getAllItemPromotionListFromPromotionId(int promotionId){
    List<ItemPromotionModel> list = [];
    for(int i =0 ; i < state.activeItemPromotionList.length; i++){
      if(state.activeItemPromotionList[i].promotionId == promotionId ){
        list.add(state.activeItemPromotionList[i]);
      }
    }
    return list;
  }
}
