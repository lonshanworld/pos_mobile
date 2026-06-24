import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import "package:collection/collection.dart";
import 'package:pos_mobile/features/historyFilter.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stockout_history_model.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';

import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import '../../models/customer_model.dart';
import '../../models/deliver_model_folder/delivery_model.dart';
import '../../models/deliver_model_folder/delivery_person_model.dart';
import '../../models/groupingItem_models_folders/category_model.dart';
import '../../models/groupingItem_models_folders/group_model.dart';
import '../../models/groupingItem_models_folders/type_model.dart';
import '../../models/itemModel_with_UniqueItemcount.dart';
import '../../models/item_model_folder/item_model.dart';
import '../../models/item_model_folder/uniqueItem_model.dart';
import '../../models/stock_in_unit_spec.dart';
import '../../models/promotion_model_folder/promotion_model.dart';
import '../../models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import '../../models/user_model_folder/user_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';

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
    try{
      List<StockInModel> activeStockInList = [];
      List<StockInModel> inActiveStockInList = [];
      List<StockOutModel> activeStockOutList = [];
      List<StockOutModel> inActiveStockOutList = [];
      List<DeliveryPersonModel> activeDeliveryPersonList = [];
      List<DeliveryPersonModel> inActiveDeliveryPersonList = [];

      // Fetch first page (defaultPageLimit items)
      List<StockInModel> allStockInList = await DBHelper.getAllStockIn(limit: UIConstants.defaultPageLimit, offset: 0);
      for (int a = 0; a < allStockInList.length; a++) {
        if (allStockInList[a].activeStatus) {
          activeStockInList.add(allStockInList[a]);
        } else {
          inActiveStockInList.add(allStockInList[a]);
        }
      }

      List<StockOutModel> allStockOutList = await DBHelper.getAllStockOut(limit: UIConstants.defaultPageLimit, offset: 0);
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
          inActiveStockOutList: inActiveStockOutList,
          stockInOffset: 0,
          stockOutOffset: 0,
        hasMoreStockIn: allStockInList.length == UIConstants.defaultPageLimit,
        hasMoreStockOut: allStockOutList.length == UIConstants.defaultPageLimit,
          isLoadingMoreStockIn: false,
          isLoadingMoreStockOut: false));
    }catch(e){
      cusDebugPrint('Failed to load transaction data: $e');
      emit(const TransactionsData(
        activeStockInList: [],
        activeStockOutList: [],
        stockOutItemList: [],
        customerList: [],
        deliveryModelList: [],
        activeDeliveryPersonList: [],
        inActiveDeliveryPersonList: [],
        inActiveStockInList: [],
        inActiveStockOutList: [],
      ));
    }
  }

  Future<void> loadMoreStockIn() async {
    if (state.isLoadingMoreStockIn || !state.hasMoreStockIn) return;

    emit(TransactionsData(
      activeStockInList: state.activeStockInList,
      activeStockOutList: state.activeStockOutList,
      stockOutItemList: state.stockOutItemList,
      customerList: state.customerList,
      deliveryModelList: state.deliveryModelList,
      activeDeliveryPersonList: state.activeDeliveryPersonList,
      inActiveDeliveryPersonList: state.inActiveDeliveryPersonList,
      inActiveStockInList: state.inActiveStockInList,
      inActiveStockOutList: state.inActiveStockOutList,
      stockInOffset: state.stockInOffset,
      stockOutOffset: state.stockOutOffset,
      hasMoreStockIn: state.hasMoreStockIn,
      hasMoreStockOut: state.hasMoreStockOut,
      isLoadingMoreStockIn: true,
      isLoadingMoreStockOut: state.isLoadingMoreStockOut,
    ));

    try{
      final int newOffset = state.stockInOffset + UIConstants.defaultPageLimit;
      List<StockInModel> moreStockInList = await DBHelper.getAllStockIn(limit: UIConstants.defaultPageLimit, offset: newOffset);

      List<StockInModel> newActiveStockInList = List.from(state.activeStockInList);
      List<StockInModel> newInActiveStockInList = List.from(state.inActiveStockInList);

      for (var item in moreStockInList) {
        if (item.activeStatus) {
          newActiveStockInList.add(item);
        } else {
          newInActiveStockInList.add(item);
        }
      }

      emit(TransactionsData(
        activeStockInList: newActiveStockInList,
        activeStockOutList: state.activeStockOutList,
        stockOutItemList: state.stockOutItemList,
        customerList: state.customerList,
        deliveryModelList: state.deliveryModelList,
        activeDeliveryPersonList: state.activeDeliveryPersonList,
        inActiveDeliveryPersonList: state.inActiveDeliveryPersonList,
        inActiveStockInList: newInActiveStockInList,
        inActiveStockOutList: state.inActiveStockOutList,
        stockInOffset: newOffset,
        stockOutOffset: state.stockOutOffset,
        hasMoreStockIn: moreStockInList.length == UIConstants.defaultPageLimit,
        hasMoreStockOut: state.hasMoreStockOut,
        isLoadingMoreStockIn: false,
        isLoadingMoreStockOut: state.isLoadingMoreStockOut,
      ));
    }catch(e){
      cusDebugPrint('Failed to load more stock in data: $e');
      emit(TransactionsData(
        activeStockInList: state.activeStockInList,
        activeStockOutList: state.activeStockOutList,
        stockOutItemList: state.stockOutItemList,
        customerList: state.customerList,
        deliveryModelList: state.deliveryModelList,
        activeDeliveryPersonList: state.activeDeliveryPersonList,
        inActiveDeliveryPersonList: state.inActiveDeliveryPersonList,
        inActiveStockInList: state.inActiveStockInList,
        inActiveStockOutList: state.inActiveStockOutList,
        stockInOffset: state.stockInOffset,
        stockOutOffset: state.stockOutOffset,
        hasMoreStockIn: false,
        hasMoreStockOut: state.hasMoreStockOut,
        isLoadingMoreStockIn: false,
        isLoadingMoreStockOut: state.isLoadingMoreStockOut,
      ));
    }
  }

  Future<void> loadMoreStockOut() async {
    if (state.isLoadingMoreStockOut || !state.hasMoreStockOut) return;

    emit(TransactionsData(
      activeStockInList: state.activeStockInList,
      activeStockOutList: state.activeStockOutList,
      stockOutItemList: state.stockOutItemList,
      customerList: state.customerList,
      deliveryModelList: state.deliveryModelList,
      activeDeliveryPersonList: state.activeDeliveryPersonList,
      inActiveDeliveryPersonList: state.inActiveDeliveryPersonList,
      inActiveStockInList: state.inActiveStockInList,
      inActiveStockOutList: state.inActiveStockOutList,
      stockInOffset: state.stockInOffset,
      stockOutOffset: state.stockOutOffset,
      hasMoreStockIn: state.hasMoreStockIn,
      hasMoreStockOut: state.hasMoreStockOut,
      isLoadingMoreStockIn: state.isLoadingMoreStockIn,
      isLoadingMoreStockOut: true,
    ));

    try{
      final int newOffset = state.stockOutOffset + UIConstants.defaultPageLimit;
      List<StockOutModel> moreStockOutList = await DBHelper.getAllStockOut(limit: UIConstants.defaultPageLimit, offset: newOffset);

      List<StockOutModel> newActiveStockOutList = List.from(state.activeStockOutList);
      List<StockOutModel> newInActiveStockOutList = List.from(state.inActiveStockOutList);

      for (var item in moreStockOutList) {
        if (item.activeStatus) {
          newActiveStockOutList.add(item);
        } else {
          newInActiveStockOutList.add(item);
        }
      }

      emit(TransactionsData(
        activeStockInList: state.activeStockInList,
        activeStockOutList: newActiveStockOutList,
        stockOutItemList: state.stockOutItemList,
        customerList: state.customerList,
        deliveryModelList: state.deliveryModelList,
        activeDeliveryPersonList: state.activeDeliveryPersonList,
        inActiveDeliveryPersonList: state.inActiveDeliveryPersonList,
        inActiveStockInList: state.inActiveStockInList,
        inActiveStockOutList: newInActiveStockOutList,
        stockInOffset: state.stockInOffset,
        stockOutOffset: newOffset,
        hasMoreStockIn: state.hasMoreStockIn,
        hasMoreStockOut: moreStockOutList.length == UIConstants.defaultPageLimit,
        isLoadingMoreStockIn: state.isLoadingMoreStockIn,
        isLoadingMoreStockOut: false,
      ));
    }catch(e){
      cusDebugPrint('Failed to load more stock out data: $e');
      emit(TransactionsData(
        activeStockInList: state.activeStockInList,
        activeStockOutList: state.activeStockOutList,
        stockOutItemList: state.stockOutItemList,
        customerList: state.customerList,
        deliveryModelList: state.deliveryModelList,
        activeDeliveryPersonList: state.activeDeliveryPersonList,
        inActiveDeliveryPersonList: state.inActiveDeliveryPersonList,
        inActiveStockInList: state.inActiveStockInList,
        inActiveStockOutList: state.inActiveStockOutList,
        stockInOffset: state.stockInOffset,
        stockOutOffset: state.stockOutOffset,
        hasMoreStockIn: state.hasMoreStockIn,
        hasMoreStockOut: false,
        isLoadingMoreStockIn: state.isLoadingMoreStockIn,
        isLoadingMoreStockOut: false,
      ));
    }
  }

  Future<void> reloadList() async {
    await _initTransactionsList();
  }

  //stockin
  Future<bool> createNewUniqueItemList({
    required UserModel userModel,
    CategoryModel? categoryModel,
    GroupModel? groupModel,
    required TypeModel typeModel,
    required ItemModel itemModel,
    required String? code,
    required DateTime? itemManufactureDate,
    required DateTime? itemExpireDate,
    required String? getItemFromWhere,
    required int itemLength,
    List<StockInUnitSpec>? unitSpecs,
  }) async {
    try{
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
          itemLength: itemLength,
          unitSpecs: unitSpecs,
      );
      await _initTransactionsList();
      return value;
    }catch(e){
      cusDebugPrint('Failed to create stock in data: $e');
      return false;
    }
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
    try{
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
    }catch(e){
      cusDebugPrint('Failed to create stock out data: $e');
      return false;
    }
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
    try{
      bool value = await  DBHelper.stockOutOrderCancel(stockOutId: stockOutId, userModel: userModel, itemModelList: itemModelList);
      if(value) await reloadList();
      return value;
    }catch(e){
      cusDebugPrint('Failed to cancel stock out order: $e');
      return false;
    }
  }

  Future<bool>stockOutDelete({
    required int stockOutId,
    required UserModel userModel,
  })async{
    try{
      bool value = await DBHelper.deleteStockOut(stockOutId: stockOutId, userModel: userModel);
      if(value) await reloadList();
      return value;
    }catch(e){
      cusDebugPrint('Failed to delete stock out: $e');
      return false;
    }
  }
}
