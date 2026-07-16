import 'package:path/path.dart';
import 'package:pos_mobile/database/alerts_DB/alert_DbService.dart';
import 'package:pos_mobile/database/crash_report_DB/crash_report_DBService.dart';
import 'package:pos_mobile/database/customer_DB/customer_Db_service.dart';
import 'package:pos_mobile/database/delivery_folder/delivery_model_DB/delivery_model_DbService.dart';
import 'package:pos_mobile/database/delivery_folder/delivery_person_DB/delivery_person_DbService.dart';
import 'package:pos_mobile/database/historyModel_DB/history_DBservice.dart';
import 'package:pos_mobile/database/imageModel_DB/image_DBsevice.dart';
import 'package:pos_mobile/database/itemModel_DB/item_business_detail_DB/item_business_detail_db_service.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/groupingItem_DbService.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/category_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/groupingItem_DB/gorupingItem_DbStorageFolder/Item_DbStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/module_component_item_DB/module_component_item_DbService.dart';
import 'package:pos_mobile/database/itemModel_DB/uniqueItem_DB/uniqueItem_DbService.dart';
import 'package:pos_mobile/database/junction_folder/item_promotion_db/item_promotion_DbService.dart';
import 'package:pos_mobile/database/junction_folder/report_and_alerts/alert_junctions/alert_knownperson_Db/alert_knownperson_DbService.dart';
import 'package:pos_mobile/database/junction_folder/report_and_alerts/alert_junctions/alert_targetperson_Db/alert_targetperson_DbService.dart';
import 'package:pos_mobile/database/junction_folder/report_and_alerts/alert_junctions/alert_targetproduct_Db/alert_targetproduct_DbService.dart';
import 'package:pos_mobile/database/junction_folder/report_and_alerts/report_junctions/report_image_Db/report_image_DbService.dart';
import 'package:pos_mobile/database/junction_folder/report_and_alerts/report_junctions/report_targetperson_Db/report_targetperson_DbService.dart';
import 'package:pos_mobile/database/junction_folder/report_and_alerts/report_junctions/report_targetproduct_Db/report_targetproduct_DbService.dart';
import 'package:pos_mobile/database/junction_folder/stockOut_promotion_db/stockOut_promotion_DbService.dart';
import 'package:pos_mobile/database/junction_folder/type_promotion_db/type_promotion_DbService.dart';
import 'package:pos_mobile/database/promotionModel_DB/promotion_DBservice.dart';
import 'package:pos_mobile/database/reports_DB/reports_DbService.dart';
import 'package:pos_mobile/database/restrictionModel_DB/restriction_DBservice.dart';
import 'package:pos_mobile/database/transactionModel_DB/transaction_DBservice.dart';
import 'package:pos_mobile/database/userModel_DB/user_DBService.dart';
import 'package:pos_mobile/database/db_schema_migrator.dart';
import 'package:pos_mobile/models/customer_model.dart';

import 'package:pos_mobile/models/crash_report_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/group_model.dart';
import 'package:pos_mobile/models/itemModel_with_UniqueItemcount.dart';
import 'package:pos_mobile/models/item_model_folder/uniqueItem_model.dart';
import 'package:pos_mobile/models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import 'package:pos_mobile/models/junction_models_folder/promotion_junctions/stockout_promotion_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/models/update_history_model.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';

import 'package:pos_mobile/utils/debug_print.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/enums.dart';
import '../constants/txtconstants.dart';
import '../models/deliver_model_folder/delivery_model.dart';
import '../models/deliver_model_folder/delivery_person_model.dart';
import '../models/groupingItem_models_folders/type_model.dart';
import '../models/item_model_folder/item_business_detail_model.dart';
import '../models/item_model_folder/item_model.dart';
import '../models/stock_in_unit_spec.dart';
import '../models/promotion_model_folder/promotion_model.dart';
import '../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/constants/uiConstants.dart';

class DBHelper {
  static Database? database;

  static Future<String> getDbpath(String tableName) async {
    return join(await getDatabasesPath(), "$tableName.db");
  }

  static Future<void> dbConfig(Database db) async {
    await db.execute("PRAGMA foreign_keys = ON");
  }

  @pragma('vm:entry-point')
  static Future<void> initiateAllDB() async {
    // TODO : initiate all DB;
    String path = await getDbpath(TxtConstants.databaseKey);
    database = await openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onConfigure: DBHelper.dbConfig,
      onUpgrade: _onUpgrade,
      onOpen: _onOpen,
    );
  }

  static Future<void> _onCreate(Database db, int value) async {
    await ImageDbService.initImageDb(db);
    await UserDBService.initUserDB(db);
    await CustomerDbService.initCustomerDb(db);
    await DeliveryModelDbService.initDeliveryModelDb(db);
    await DeliveryPersonDbService.initDeliveryPersonDb(db);
    await RestrictionDBService.initRestrictionDb(db);
    await PromotionDBService.initPromotionDb(db);
    await GroupingItemDbService.initAllGroupingItemDb(db);
    await TransactionDBService.initTransactionDb(db);
    await UniqueItemDbService.initUniqueItemDb(db);
    await ModuleComponentItemDbService.initModuleComponentItemDbService(db);
    await ItemBusinessDetailDbService.initItemBusinessDetailDb(db);
    await AlertDbService.initAlertDb(db);
    await ReportDbService.initReportDb(db);
    await CrashReportDbService.initCrashReportDb(db);

    await ItemPromotionDbService.initItemPromotionDB(db);
    await StockOutPromotionDbServive.initStockOutPromotionDb(db);
    await TypePromotionDbService.initTypePromotionDb(db);

    await AlertKnownPersonDbService.initAlertKnownPersonDb(db);
    await AlertTargetPersonDbService.initAlertTargetPersonDb(db);
    await AlertTargetProductDbService.initAlertTargetProductDb(db);

    await ReportImageDbService.initReportImageDb(db);
    await ReportTargetPersonDbService.initReportTargetPersonDb(db);
    await ReportTargetProductDbService.initReportTargetProductDb(db);

    await HistoryDBService.initHistoryDb(db);
  }

  static Future<void> _onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    await _prepareDatabase(db);
  }

  static Future<void> _onOpen(Database db) async {
    await _prepareDatabase(db);
  }

  static Future<void> _prepareDatabase(Database db) async {
    await DbSchemaMigrator.reconcile(db);
  }

  static Future<List<UniqueItemModel>> getAllUniqueItems({
    int limit = 5000,
    int offset = 0,
  }) async {
    return await UniqueItemDbService.getAllData(
      database!,
      limit: limit,
      offset: offset,
    );
  }

  static Future<List<UserModel>> getAllUsersFromDB() async {
    return await UserDBService.getAllUsers(database!);
  }

  static Future<bool> createNewUser({
    required String userName,
    required String password,
    required UserLevel userLevel,
  }) async {
    bool value = await UserDBService.createNewUser(
      userName: userName,
      password: password,
      userLevel: userLevel,
      db: database!,
    );
    cusDebugPrint(value);
    return value;
  }

  static Future<bool> loginAndLogOut({
    required UserModel userModel,
    required bool isLogin,
  }) async {
    return await UserDBService.loginLogoutUserUpdate(
      database!,
      userModel,
      isLogin,
    );
  }

  static Future<bool> changeUserPassword({
    required int userId,
    required String newPassword,
  }) async {
    return await UserDBService.updateUserPassword(
      db: database!,
      userId: userId,
      newPassword: newPassword,
    );
  }

  static Future<List<UpdateHistoryModel>> getHistoryList() async {
    List<dynamic> dataList = await HistoryDBService.getAllHistory(database!);
    return dataList.map((e) => UpdateHistoryModel.fromJson(e)).toList();
  }

  static Future<int> saveCrashReport(CrashReportModel report) async {
    return await CrashReportDbService.saveCrashReport(database!, report);
  }

  static Future<List<CrashReportModel>> getUnsyncedCrashReports() async {
    return await CrashReportDbService.getUnsyncedReports(database!);
  }

  static Future<int> getUnsyncedCrashReportCount() async {
    return await CrashReportDbService.getUnsyncedCount(database!);
  }

  static Future<bool> markCrashReportsAsSynced(List<int> ids) async {
    return await CrashReportDbService.markReportsAsSynced(database!, ids);
  }

  static Future<bool> deleteSyncedCrashReports() async {
    return await CrashReportDbService.deleteSyncedReports(database!);
  }

  static Future<List<CategoryModel>> getAllCategory({
    int limit = UIConstants.defaultPageLimit,
    int offset = 0,
  }) async {
    List<dynamic> data = await CategoryDbStorage.getAllData(
      database!,
      limit: limit,
      offset: offset,
    );
    return data.map((e) => CategoryModel.fromJson(e)).toList();
  }

  static Future<int> getTotalCategoryCount() async {
    return await GroupingItemDbService.getTotalCategoryCount(database!);
  }

  static Future<CategoryModel?> getCategoryById(int id) async {
    return await GroupingItemDbService.getCategoryById(database!, id);
  }

  static Future<bool> createNewCategory(
    UserModel userModel,
    String categoryName,
  ) async {
    return await GroupingItemDbService.createNewCategory(
      database!,
      categoryName: categoryName,
      userModel: userModel,
    );
  }

  static Future<bool> createNewGroup({
    required UserModel userModel,
    CategoryModel? categoryModel,
    required String groupName,
    required String? description,
  }) async {
    return await GroupingItemDbService.createNewGroup(
      database!,
      userModel: userModel,
      categoryModel: categoryModel,
      groupName: groupName,
      description: description,
    );
  }

  static Future<bool> createNewType({
    required UserModel userModel,
    CategoryModel? categoryModel,
    GroupModel? groupModel,
    required String typeName,
    required String? generalDescription,
    required bool hasExpire,
  }) async {
    return await GroupingItemDbService.createNewType(
      database!,
      userModel: userModel,
      categoryModel: categoryModel,
      groupModel: groupModel,
      typeName: typeName,
      generalDescription: generalDescription,
      hasExpire: hasExpire,
    );
  }

  static Future<int> createNewItem({
    required UserModel userModel,
    required int? categoryId,
    required int? groupId,
    required TypeModel typeModel,
    required String name,
    required String? description,
    required bool hasExpire,
    required double profitPrice,
    required double originalPrice,
    required double taxPercentage,
    required bool needStock,
    required String? code,
  }) async {
    final normalizedCode = code?.trim();
    if (normalizedCode != null && normalizedCode.isNotEmpty) {
      if (!await isBarcodeAvailable(normalizedCode)) return -1;
    }

    return await GroupingItemDbService.createNewItem(
      database!,
      userModel: userModel,
      categoryId: categoryId,
      groupId: groupId,
      typeModel: typeModel,
      name: name,
      description: description,
      hasExpire: hasExpire,
      profitPrice: profitPrice,
      originalPrice: originalPrice,
      taxPercentage: taxPercentage,
      needStock: needStock,
      code: code,
    );
  }

  static Future<int> saveItemImage({
    required int itemId,
    required String imagePath,
  }) async {
    final imageId = await ImageDbService.insertImage(database!, imagePath);
    final updated = await ItemDbStorage.updateImageId(
      database!,
      itemId: itemId,
      imageId: imageId,
    );
    return updated == 0 ? -1 : imageId;
  }

  static Future<String?> getImagePath(int imageId) async {
    return await ImageDbService.getImagePath(database!, imageId);
  }

  static Future<List<ItemBusinessDetailModel>>
  getAllItemBusinessDetails() async {
    return await ItemBusinessDetailDbService.getAll(database!);
  }

  static Future<ItemBusinessDetailModel?> getItemBusinessDetail(
    int itemId,
  ) async {
    return await ItemBusinessDetailDbService.getByItemId(database!, itemId);
  }

  static Future<bool> saveItemBusinessDetail(
    ItemBusinessDetailModel detail,
  ) async {
    return await ItemBusinessDetailDbService.upsert(database!, detail);
  }

  static Future<bool> createStockIn({
    required UserModel userModel,
    CategoryModel? categoryModel,
    GroupModel? groupModel,
    TypeModel? typeModel,
    required ItemModel itemModel,
    required String? code,
    required DateTime? itemManufactureDate,
    required DateTime? itemExpireDate,
    required String? getItemFromWhere,
    required int itemLength,
    List<StockInUnitSpec>? unitSpecs,
  }) async {
    return await TransactionDBService.createStockIn(
      database!,
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
  }

  static Future<bool> createStockOutList({
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
    required DateTime checkoutTime,
  }) async {
    return await TransactionDBService.insertStockOut(
      database!,
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
      promotionModel: promotionModel,
      checkoutTime: checkoutTime,
    );
  }

  static Future<bool> editCategoryName({
    required String name,
    required UserModel userModel,
    required CategoryModel categoryModel,
  }) async {
    return await GroupingItemDbService.updateCategoryName(
      database!,
      name: name,
      userModel: userModel,
      categoryModel: categoryModel,
    );
  }

  static Future<bool> deleteCategory({
    required UserModel userModel,
    required CategoryModel categoryModel,
  }) async {
    return await GroupingItemDbService.deactivateCategory(
      database!,
      userModel: userModel,
      categoryModel: categoryModel,
    );
  }

  static Future<bool> editGroupName({
    required String newName,
    required UserModel userModel,
    required GroupModel groupModel,
  }) async {
    return await GroupingItemDbService.updateGroupName(
      database!,
      name: newName,
      userModel: userModel,
      groupModel: groupModel,
    );
  }

  static Future<bool> deleteGroup({
    required UserModel userModel,
    required GroupModel groupModel,
  }) async {
    return await GroupingItemDbService.deactivateGroup(
      database!,
      userModel: userModel,
      groupModel: groupModel,
    );
  }

  static Future<bool> editType({
    required String newName,
    required UserModel userModel,
    required TypeModel typeModel,
  }) async {
    return await GroupingItemDbService.updateTypeName(
      database!,
      newName: newName,
      userModel: userModel,
      typeModel: typeModel,
    );
  }

  static Future<bool> deleteType({
    required UserModel userModel,
    required TypeModel typeModel,
  }) async {
    return await GroupingItemDbService.deactivateType(
      database!,
      typeModel: typeModel,
      userModel: userModel,
    );
  }

  static Future<bool> editItem({
    required UserModel userModel,
    required ItemModel itemModel,
    required List<UniqueItemModel> uniqueItemList,
    required String newName,
    required int? categoryId,
    required int? groupId,
    required int typeId,
    required double newOriginalPrice,
    required double newProfitPrice,
    required double newTaxPercentage,
    required bool needStock,
    required String? newCode,
  }) async {
    return await GroupingItemDbService.updateItem(
      database!,
      userModel: userModel,
      itemModel: itemModel,
      uniqueItemList: uniqueItemList,
      newName: newName,
      categoryId: categoryId,
      groupId: groupId,
      typeId: typeId,
      newOriginalPrice: newOriginalPrice,
      newProfitPrice: newProfitPrice,
      newTaxPercentage: newTaxPercentage,
      needStock: needStock,
      newCode: newCode,
    );
  }

  static Future<bool> updateItemBarcode({
    required int itemId,
    required String barcode,
  }) async {
    if (!await isBarcodeAvailable(barcode)) return false;
    return GroupingItemDbService.updateItemBarcode(
      database!,
      itemId: itemId,
      barcode: barcode,
    );
  }

  static Future<bool> updateUniqueItemBarcode({
    required int uniqueItemId,
    required String barcode,
  }) async {
    if (!await isBarcodeAvailable(barcode)) return false;
    return UniqueItemDbService.updateUniqueItemBarcode(
      database!,
      uniqueItemId: uniqueItemId,
      barcode: barcode,
    );
  }

  static Future<bool> isBarcodeAvailable(String barcode) async {
    final normalized = barcode.trim();
    if (normalized.isEmpty) return false;

    final itemMatches = await database!.query(
      TxtConstants.itemTableName,
      columns: const ['id'],
      where: 'LOWER(TRIM(code)) = LOWER(?)',
      whereArgs: [normalized],
      limit: 1,
    );
    if (itemMatches.isNotEmpty) return false;

    final uniqueItemMatches = await database!.query(
      TxtConstants.uniqueItemTableName,
      columns: const ['id'],
      where: 'LOWER(TRIM(code)) = LOWER(?)',
      whereArgs: [normalized],
      limit: 1,
    );
    return uniqueItemMatches.isEmpty;
  }

  static Future<bool> deleteItem({
    required UserModel userModel,
    required ItemModel itemModel,
    required List<UniqueItemModel> uniqueItemList,
  }) async {
    return await GroupingItemDbService.deactivateItem(
      database!,
      userModel: userModel,
      itemModel: itemModel,
      uniqueItemList: uniqueItemList,
    );
  }

  static Future<List<StockInModel>> getAllStockIn({
    int limit = UIConstants.defaultPageLimit,
    int offset = 0,
  }) async {
    return await TransactionDBService.getAllStockInData(
      database!,
      limit: limit,
      offset: offset,
    );
  }

  static Future<List<StockOutModel>> getAllStockOut({
    int limit = UIConstants.defaultPageLimit,
    int offset = 0,
  }) async {
    return await TransactionDBService.getAllStockOutData(
      database!,
      limit: limit,
      offset: offset,
    );
  }

  static Future<List<StockOutItemModel>> getAllStockOutItem({
    int limit = UIConstants.defaultPageLimit,
    int offset = 0,
  }) async {
    return await TransactionDBService.getAllStockOutItemData(
      database!,
      limit: limit,
      offset: offset,
    );
  }

  static Future<List<CustomerModel>> getAllCustomer() async {
    return await CustomerDbService.getAllCustomer(database!);
  }

  static Future<List<DeliveryModel>> getAllDeliveryModel() async {
    return await DeliveryModelDbService.getAllDeliveryModel(database!);
  }

  static Future<List<DeliveryPersonModel>> getAllDeliveryPerson() async {
    return await DeliveryPersonDbService.getAllDeliveryPerson(database!);
  }

  static Future<List<PromotionModel>> getAllPromotion() async {
    return await PromotionDBService.getAllPromotions(database!);
  }

  static Future<List<ItemPromotionModel>> getAllItemPromotion() async {
    return await ItemPromotionDbService.getAllItemPromotion(database!);
  }

  static Future<List<StockOutPromotionModel>> getAllStockOutPromotion() async {
    return await StockOutPromotionDbServive.getAllStockOutPromotionList(
      database!,
    );
  }

  static Future<bool> addNewPromotion({
    required String promotionName,
    required String promotionDescription,
    required double? promotionPercentage,
    required double? promotionPrice,
    required String promotionCode,
    required UserModel userModel,
  }) async {
    return await PromotionDBService.insertNewPromotion(
      db: database!,
      promotionName: promotionName,
      promotionDescription: promotionDescription,
      promotionPercentage: promotionPercentage,
      promotionPrice: promotionPrice,
      createPersonId: userModel.id,
      promotionLimitPerson: null,
      promotionLimitTime: null,
      promotionLimitPrice: null,
      requirementForItemCount: null,
      requirementForPrice: null,
      promotionCode: promotionCode,
    );
  }

  static Future<bool> deletePromotion({
    required UserModel userModel,
    required int promotionId,
    required List<ItemPromotionModel> itemPromotionList,
  }) async {
    return await PromotionDBService.deletePromotion(
      database!,
      userModel: userModel,
      promotionId: promotionId,
      itemPromotionList: itemPromotionList,
    );
  }

  static Future<bool> attachItemWithPromotion({
    required UserModel userModel,
    required int promotionId,
    required int itemId,
  }) async {
    return await ItemPromotionDbService.addNewData(
      db: database!,
      itemId: itemId,
      promotionId: promotionId,
      createPersonId: userModel.id,
    );
  }

  static Future<bool> detachItemWithPromotion({
    required List<ItemPromotionModel> itemPromotionList,
    required UserModel userModel,
  }) async {
    DateTime dateTime = DateTime.now();
    return await ItemPromotionDbService.deleteItemPromotion(
      database!,
      itemPromotionList: itemPromotionList,
      userModel: userModel,
      dateTime: dateTime,
    );
  }

  static Future<bool> stockOutOrderCancel({
    required int stockOutId,
    required UserModel userModel,
    required List<ItemModel> itemModelList,
  }) async {
    return await TransactionDBService.stockOutOrderCancel(
      database!,
      userModel: userModel,
      stockOutId: stockOutId,
      itemModelList: itemModelList,
    );
  }

  static Future<bool> deleteStockOut({
    required int stockOutId,
    required UserModel userModel,
  }) async {
    return await TransactionDBService.deleteStockOut(
      database!,
      userModel: userModel,
      stockOutId: stockOutId,
    );
  }

  static Future<bool> deleteUniqueItem(
    UniqueItemModel uniqueItemModel,
    UserModel userModel,
  ) async {
    return await UniqueItemDbService.deActivateUniqueItem(
      database!,
      uniqueItemModel: uniqueItemModel,
      userModel: userModel,
    );
  }

  static Future<List<CategoryModel>> getAllCategories({
    int limit = UIConstants.defaultPageLimit,
    int offset = 0,
  }) async {
    final data = await GroupingItemDbService.getAllCategories(
      database!,
      limit: limit,
      offset: offset,
    );
    return data;
  }

  static Future<List<CategoryModel>> getAllActiveCategories() async {
    return await GroupingItemDbService.getAllActiveCategories(database!);
  }

  static Future<List<GroupModel>> getAllGroups({
    int limit = UIConstants.defaultPageLimit,
    int offset = 0,
  }) async {
    return await GroupingItemDbService.getAllGroups(
      database!,
      limit: limit,
      offset: offset,
    );
  }

  static Future<List<GroupModel>> getAllActiveGroups() async {
    return await GroupingItemDbService.getAllActiveGroups(database!);
  }

  static Future<GroupModel?> getGroupById(int id) async {
    return await GroupingItemDbService.getGroupById(database!, id);
  }

  static Future<TypeModel?> getTypeById(int id) async {
    return await GroupingItemDbService.getTypeById(database!, id);
  }

  static Future<List<TypeModel>> getAllActiveTypes() async {
    return await GroupingItemDbService.getAllActiveTypes(database!);
  }

  static Future<Map<String, List>> getAllItemData({
    int limit = UIConstants.defaultPageLimit,
    int offset = 0,
  }) async {
    return await GroupingItemDbService.getAllData(
      database!,
      limit: limit,
      offset: offset,
    );
  }

  static Future<Map<int, int>> getGroupCountByCategory() async {
    return await GroupingItemDbService.getGroupCountByCategory(database!);
  }

  static Future<Map<int, int>> getTypeCountByGroup() async {
    return await GroupingItemDbService.getTypeCountByGroup(database!);
  }
}
