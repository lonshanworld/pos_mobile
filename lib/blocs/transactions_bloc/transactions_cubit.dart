import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import "package:collection/collection.dart";
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stockout_history_model.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';

import '../../constants/enums.dart';
import '../../feature/historyFilter.dart';
import '../../models/customer_model.dart';
import '../../models/deliver_model_folder/delivery_model.dart';
import '../../models/deliver_model_folder/delivery_person_model.dart';
import '../../models/groupingItem_models_folders/category_model.dart';
import '../../models/groupingItem_models_folders/group_model.dart';
import '../../models/groupingItem_models_folders/type_model.dart';
import '../../models/itemModel_with_UniqueItemcount.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/item_model_folder/uniqueItem_model.dart';
import '../../models/promotion_model_folder/promotion_model.dart';
import '../../models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import '../../models/user_model_folder/user_model.dart';

part 'transactions_state.dart';

class TransactionsCubit extends Cubit<TransactionsState> {
  TransactionsCubit()
      : super(const TransactionsData(
          activeStockInList: [],
          activeStockOutList: [],
          stockOutItemList: [],
          customerList: [],
          deliveryModelList: [],
          activeDeliveryPersonList: [],
          inActiveDeliveryPersonList: [],
          inActiveStockInList: [],
          inActiveStockOutList: [],
        )) {
    _initTransactionsList();
  }

  Future<void> _initTransactionsList() async {
    // emit(
    //     TransactionsData(
    //       stockInList: await DBHelper.getAllStockIn(),
    //       stockOutList: await DBHelper.getAllStockOut(),
    //       stockOutItemList: await DBHelper.getAllStockOutItem(),
    //       customerList: await DBHelper.getAllCustomer(),
    //       deliveryModelList: await DBHelper.getAllDeliveryModel(),
    //       deliveryPersonList: await DBHelper.getAllDeliveryPerson(),
    //     ));
    List<StockInModel> activeStockInList = [];
    List<StockInModel> inActiveStockInList = [];
    List<StockOutModel> activeStockOutList = [];
    List<StockOutModel> inActiveStockOutList = [];
    List<DeliveryPersonModel> activeDeliveryPersonList = [];
    List<DeliveryPersonModel> inActiveDeliveryPersonList = [];

    List<StockInModel> allStockInList = await DBHelper.getAllStockIn();
    for (int a = 0; a < allStockInList.length; a++) {
      if (allStockInList[a].activeStatus) {
        activeStockInList.add(allStockInList[a]);
      } else {
        inActiveStockInList.add(allStockInList[a]);
      }
    }

    List<StockOutModel> allStockOutList = await DBHelper.getAllStockOut();
    for (int b = 0; b < allStockOutList.length; b++) {
      if (allStockOutList[b].activeStatus) {
        activeStockOutList.add(allStockOutList[b]);
      } else {
        inActiveStockOutList.add(allStockOutList[b]);
      }
    }

    List<DeliveryPersonModel> allDeliveryPersonList =
        await DBHelper.getAllDeliveryPerson();
    for (int c = 0; c < allDeliveryPersonList.length; c++) {
      if (allDeliveryPersonList[c].activeStatus) {
        activeDeliveryPersonList.add(allDeliveryPersonList[c]);
      } else {
        inActiveDeliveryPersonList.add(allDeliveryPersonList[c]);
      }
    }

    emit(TransactionsData(
        activeStockInList: activeStockInList,
        activeStockOutList: activeStockOutList,
        stockOutItemList: await DBHelper.getAllStockOutItem(),
        customerList: await DBHelper.getAllCustomer(),
        deliveryModelList: await DBHelper.getAllDeliveryModel(),
        activeDeliveryPersonList: activeDeliveryPersonList,
        inActiveDeliveryPersonList: inActiveDeliveryPersonList,
        inActiveStockInList: inActiveStockInList,
        inActiveStockOutList: inActiveStockOutList));
  }

  Future<void> reloadList() async {
    await _initTransactionsList();
  }

  //stockin
  Future<bool> createNewUniqueItemList({
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
  }) async {
    bool value = await DBHelper.createStockIn(
        userModel: userModel,
        categoryModel: categoryModel,
        groupModel: groupModel,
        typeModel: typeModel,
        itemModel: itemModel,
        code: code,
        itemManufactureDate: itemManufactureDate,
        itemExpireDate: itemExpireDate,
        getItemFromWhere: getItemFromWhere,
        itemLength: itemLength);
    await _initTransactionsList();
    return value;
  }
  //stockin

  // stockOut
  Future<bool> createStockOutModel({
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
  }) async {
    bool value = await DBHelper.createStockOutList(
        uniqueItemList: uniqueItemList,
        userModel: userModel,
        deliveryCharges: deliveryCharges,
        taxPercentage: taxPercentage,
        additionalPromotionAmount: additionalPromotionAmount,
        description: description,
        customerName: customerName,
        deliveryName: deliveryName,
        shoppingType: shoppingType,
        paymentMethod: paymentMethod,
        barcode: barcode,
        dataList: dataList,
        finalTotalPrice: finalTotalPrice,
        promotionModel: promotionModel);
    await _initTransactionsList();
    return value;
  }
// Stock out

  List<StockOutItemModel> getSelectedStockOutItemList(int stockOutId) {
    List<StockOutItemModel> dataList = [];
    for (int i = 0; i < state.stockOutItemList.length; i++) {
      if (state.stockOutItemList[i].stockOutId == stockOutId) {
        dataList.add(state.stockOutItemList[i]);
      }
    }
    return dataList;
  }

  DeliveryModel? getDeliveryModel(int id) {
    return state.deliveryModelList
        .firstWhereOrNull((element) => element.id == id);
  }

  DeliveryPersonModel? getDeliveryPerson(int id) {
    return state.activeDeliveryPersonList
        .firstWhereOrNull((element) => element.id == id);
  }

  CustomerModel? getCustomerModel(int id) {
    return state.customerList.firstWhereOrNull((element) => element.id == id);
  }

  List<StockOutModel> getTodayStockOut() {
    String curDate = TextFormatters.getDate(DateTime.now());
    List<StockOutHistoryModel> historyList =
        HistoryFilter.filterStockOutHistory(state.activeStockOutList);
    List<StockOutModel> dataList = [];

    for (int i = 0; i < historyList.length; i++) {
      if (historyList[i].dateTimeTxt == curDate) {
        dataList.addAll(historyList[i].stockOutList);
      }
    }

    return dataList;
  }

  StockInHistoryModel? getTodayStockInHistory() {
    String curDate = TextFormatters.getDate(DateTime.now());
    List<StockInHistoryModel> historyList =
        HistoryFilter.filterStockInHistory(state.activeStockInList);
    return historyList
        .firstWhereOrNull((element) => element.dateTxt == curDate);
  }

  Future<bool>stockOutOrderCancel({
    required int stockOutId,
    required UserModel userModel,
    required List<ItemModel> itemModelList,
  })async{
    bool value = await  DBHelper.stockOutOrderCancel(stockOutId: stockOutId, userModel: userModel, itemModelList: itemModelList);
    if(value) await reloadList();
    return value;
  }

  Future<bool>stockOutDelete({
    required int stockOutId,
    required UserModel userModel,
  })async{
    bool value = await DBHelper.deleteStockOut(stockOutId: stockOutId, userModel: userModel);
    if(value) await reloadList();
    return value;
  }
}
