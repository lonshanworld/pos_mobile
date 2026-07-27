import 'dart:convert';
import 'package:path/path.dart';
import 'package:pos_mobile/database/alerts_DB/alert_DbService.dart';
import 'package:pos_mobile/database/crash_report_DB/crash_report_DBService.dart';
import 'package:pos_mobile/database/customer_DB/customer_Db_service.dart';
import 'package:pos_mobile/database/delivery_folder/delivery_model_DB/delivery_model_DbService.dart';
import 'package:pos_mobile/database/delivery_folder/delivery_person_DB/delivery_person_DbService.dart';
import 'package:pos_mobile/database/historyModel_DB/history_DBservice.dart';
import 'package:pos_mobile/database/imageModel_DB/image_DBsevice.dart';
import 'package:pos_mobile/database/imageModel_DB/image_DBStorage.dart';
import 'package:pos_mobile/database/itemModel_DB/item_business_detail_DB/item_business_detail_db_service.dart';
import 'package:pos_mobile/database/itemModel_DB/item_business_detail_DB/item_business_detail_db_storage.dart';
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
import 'package:pos_mobile/database/shopinfo_db/shop_info_storage.dart';
import 'package:pos_mobile/models/customer_model.dart';

import 'package:pos_mobile/models/crash_report_model.dart';
import 'package:pos_mobile/models/groupingItem_models_folders/category_model.dart';
import 'package:pos_mobile/constants/txtconstants.dart';
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
import '../models/deliver_model_folder/delivery_model.dart';
import '../models/deliver_model_folder/delivery_person_model.dart';
import '../models/groupingItem_models_folders/type_model.dart';
import '../models/item_model_folder/item_business_detail_model.dart';
import '../models/item_model_folder/item_model.dart';
import '../models/stock_in_unit_spec.dart';
import '../models/promotion_model_folder/promotion_model.dart';
import '../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/constants/uiConstants.dart';

/// The legacy SQLite implementation. Business Blocs should use PosRepository;
/// DBHelper remains as a compatibility alias for local infrastructure.
class LocalPosRepository {
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
      onConfigure: LocalPosRepository.dbConfig,
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
    await db.execute('''CREATE TABLE IF NOT EXISTS pending_operations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      operation_id TEXT NOT NULL UNIQUE,
      operation_type TEXT NOT NULL,
      entity_type TEXT NOT NULL,
      entity_id TEXT,
      payload TEXT NOT NULL,
      created_at TEXT NOT NULL,
      device_id TEXT,
      company_id TEXT,
      shop_id TEXT,
      retry_count INTEGER NOT NULL DEFAULT 0,
      sync_status TEXT NOT NULL DEFAULT 'pending',
      last_error TEXT
    )''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_pending_operations_status ON pending_operations(sync_status)',
    );
    await db.execute('''CREATE TABLE IF NOT EXISTS server_cache (
      entity_type TEXT NOT NULL,
      entity_id TEXT NOT NULL,
      payload TEXT NOT NULL,
      updated_at TEXT NOT NULL,
      PRIMARY KEY (entity_type, entity_id)
    )''');
  }

  static Future<int> enqueuePendingOperation(String operationJson) async {
    final operation = jsonDecode(operationJson) as Map<String, dynamic>;
    return database!.insert('pending_operations', {
      'operation_id': operation['operation_id'],
      'operation_type': operation['operation_type'],
      'entity_type': operation['entity_type'],
      'entity_id': operation['entity_id'],
      'payload': jsonEncode(operation['payload']),
      'created_at': operation['created_at'],
      'device_id': operation['device_id'],
      'company_id': operation['company_id'],
      'shop_id': operation['shop_id'],
      'retry_count': operation['retry_count'] ?? 0,
      'sync_status': operation['sync_status'] ?? 'pending',
      'last_error': operation['last_error'],
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  static Future<List<Map<String, dynamic>>> getPendingOperations() =>
      database!.query(
        'pending_operations',
        where: "sync_status != ?",
        whereArgs: ['synchronized'],
        orderBy: 'id',
      );

  static Future<void> cacheServerRecord({
    required String entityType,
    required String entityId,
    required String payload,
    required String updatedAt,
  }) async {
    await database!.insert(
      'server_cache',
      {
        'entity_type': entityType,
        'entity_id': entityId,
        'payload': payload,
        'updated_at': updatedAt,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Materialize backend change-log records into the legacy SQLite cache.
  /// `server_cache` remains the lossless envelope, while these projections
  /// keep existing offline Blocs immediately consistent after a refresh.
  static Future<void> applyServerChange({
    required String entity,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final db = database!;
    final deleted = operation == 'delete' || payload['deleted_at'] != null;
    final id = payload['id'];
    if (id is! int) return;
    final active = deleted ? 0 : 1;
    final createdAt = payload['created_at'] ?? DateTime.now().toIso8601String();
    final updatedAt = payload['updated_at'];
    final createdBy = payload['created_by'] ?? 1;
    if (entity == 'user') {
      // Backend users do not expose password hashes. Preserve an existing
      // local password when one exists; a newly cached backend user remains
      // available for account lists but cannot be used for offline login
      // until the user authenticates against the backend.
      final existing = await db.query(
        TxtConstants.userTableName,
        columns: const [
          'password',
          'userLoginTime',
          'userLogoutTime',
          'imageId',
        ],
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      final existingUser = existing.isEmpty ? const <String, dynamic>{} : existing.first;
      await db.insert(TxtConstants.userTableName, {
        'id': id,
        'userName': payload['username'] ?? '',
        'password': existingUser['password'] ?? '',
        'userLevel': payload['role'] == 'owner' ? 'merchant' : 'staff',
        'userCreateTime': payload['created_at'] ?? DateTime.now().toIso8601String(),
        'userLoginTime': existingUser['userLoginTime'],
        'userLogoutTime': existingUser['userLogoutTime'],
        'activeStatus': payload['active'] == false || deleted ? 0 : 1,
        'imageId': existingUser['imageId'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'catalog') {
      final kind = payload['kind'];
      final table = switch (kind) {
        'category' => TxtConstants.categoryTableName,
        'group' => TxtConstants.groupTableName,
        'type' => TxtConstants.typeTableName,
        _ => null,
      };
      if (table == null) return;
      await db.insert(table, {
        'id': id,
        'name': payload['name'] ?? '',
        'createTime': createdAt,
        'lastUpdateTime': updatedAt,
        'deleteTime': payload['deleted_at'],
        'activeStatus': active,
        'createPersonId': createdBy,
        'deletePersonId': payload['updated_by'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'item') {
      await db.insert(TxtConstants.itemTableName, {
        'id': id,
        'name': payload['name'] ?? '',
        'categoryId': payload['category_id'],
        'groupId': payload['group_id'],
        'typeId': payload['type_id'] ?? 0,
        'createTime': createdAt,
        'lastUpdateTime': updatedAt,
        'deleteTime': payload['deleted_at'],
        'activeStatus': active,
        'description': payload['description'],
        'hasExpire': payload['has_expire'] == true ? 1 : (payload['has_expire'] ?? 0),
        'createPersonId': createdBy,
        'deletePersonId': payload['updated_by'],
        'code': payload['code'],
        'profitPrice': payload['profit_price'] ?? 0,
        'originalPrice': payload['original_price'] ?? 0,
        'taxPercentage': payload['tax_percentage'] ?? 0,
        'need_stock': payload['need_stock'] == true ? 1 : (payload['need_stock'] ?? 1),
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'unique_item') {
      await db.insert(TxtConstants.uniqueItemTableName, {
        'id': id,
        'itemId': payload['item_id'],
        'stockInId': payload['stock_in_id'],
        'stockOutId': payload['stock_out_id'],
        'createTime': createdAt,
        'lastUpdateTime': updatedAt,
        'deleteTime': payload['deleted_at'],
        'itemManufactureDate': payload['manufacture_date'],
        'itemExpireDate': payload['expire_date'],
        'code': payload['barcode'],
        'originalPrice': payload['original_price'] ?? 0,
        'profitPrice': payload['profit_price'] ?? 0,
        'taxPercentage': payload['tax_percentage'] ?? 0,
        'createPersonId': createdBy,
        'deletePersonId': payload['updated_by'],
        'activeStatus': active,
        'getItemFromWhere': null,
        'moduleCount': null,
        'instanceLength': null,
        'instanceWidth': null,
        'instanceBatchNumber': payload['batch_number'],
        'instanceImei': payload['imei'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'stock_in') {
      await db.insert(TxtConstants.stockInTableName, {
        'id': id,
        'createPersonId': createdBy,
        'deletePersonId': payload['updated_by'],
        'createTime': createdAt,
        'code': payload['code'],
        'lastUpdateTime': updatedAt,
        'deleteTime': payload['deleted_at'],
        'activeStatus': active,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'stock_out') {
      await db.insert(TxtConstants.stockOutTableName, {
        'id': id,
        'createPersonId': createdBy,
        'deletePersonId': payload['updated_by'],
        'createTime': createdAt,
        'lastUpdateTime': updatedAt,
        'deleteTime': payload['deleted_at'],
        'description': payload['description'],
        'shoppingType': payload['shopping_type'] ?? 'shop',
        'paymentMethod': payload['payment_method'] ?? 'cash',
        'additionalPromotionAmount': payload['discount'],
        'taxPercentage': payload['tax'],
        'activeStatus': active,
        'code': payload['code'] ?? '',
        'customerId': payload['customer_id'],
        'deliveryPersonId': null,
        'deliveryModelId': null,
        'finalTotalPrice': payload['total'] ?? 0,
        'customerCash': payload['customer_cash'],
        'refunds': payload['refunds'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'stock_out_item') {
      await db.insert(TxtConstants.stockOutItemTableName, {
        'id': id,
        'stockOutId': payload['stock_out_id'],
        'itemId': payload['item_id'],
        'count': payload['count'] ?? 0,
        'originalPrice': payload['original_price'] ?? 0,
        'sellPrice': payload['sell_price'] ?? 0,
        'finalSellPrice': payload['final_sell_price'] ?? 0,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'promotion_target') {
      final targetType = payload['target_type'];
      final targetId = payload['target_id'];
      final promotionId = payload['promotion_id'];
      if (targetId is! int || promotionId is! int) return;
      if (targetType == 'item') {
        if (deleted) {
          await db.delete(
            TxtConstants.itemPromotionTableName,
            where: 'id = ?',
            whereArgs: [id],
          );
        } else {
          await db.insert(TxtConstants.itemPromotionTableName, {
            'id': id,
            'itemId': targetId,
            'promotionId': promotionId,
            'createTime': createdAt,
            'deleteTime': payload['deleted_at'],
            'createPersonId': createdBy,
            'deletePersonId': payload['updated_by'],
            'activeStatus': active,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      } else if (targetType == 'type') {
        if (deleted) {
          await db.delete(
            TxtConstants.typePromotionTableName,
            where: 'id = ?',
            whereArgs: [id],
          );
        } else {
          await db.insert(TxtConstants.typePromotionTableName, {
            'id': id,
            'typeId': targetId,
            'promotionId': promotionId,
            'createTime': createdAt,
            'deleteTime': payload['deleted_at'],
            'createPersonId': createdBy,
            'deletePersonId': payload['updated_by'],
            'activeStatus': active,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      } else if (targetType == 'stock_out') {
        if (deleted) {
          await db.delete(
            TxtConstants.stockOutPromotionTableName,
            where: 'stockOutId = ? AND promotionId = ?',
            whereArgs: [targetId, promotionId],
          );
        } else {
          await db.insert(TxtConstants.stockOutPromotionTableName, {
            'stockOutId': targetId,
            'promotionId': promotionId,
          }, conflictAlgorithm: ConflictAlgorithm.replace);
        }
      }
    } else if (entity == 'restriction') {
      await db.insert(TxtConstants.restrictionTableName, {
        'id': id,
        'title': payload['name'] ?? '',
        'reason': payload['description'] ?? '',
        'createTime': createdAt,
        'deleteTime': payload['deleted_at'],
        'lastUpdateTime': updatedAt,
        'activeStatus': payload['active'] == false || deleted ? 0 : 1,
        'createPersonId': createdBy,
        'deletePersonId': payload['updated_by'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'promotion') {
      await db.insert(TxtConstants.promotionTableName, {
        'id': id,
        'promotionName': payload['name'] ?? '',
        'promotionDescription': payload['description'] ?? '--',
        'promotionPercentage': payload['percentage'],
        'promotionPrice': payload['fixed_price'],
        'createPersonId': createdBy,
        'deletePersonId': payload['updated_by'],
        'activeStatus': active,
        'promotionCode': payload['code'],
        'createTime': createdAt,
        'deleteTime': payload['deleted_at'],
        'lastUpdateTime': updatedAt,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'item_business_detail') {
      final details = Map<String, dynamic>.from(payload['details'] as Map? ?? const {});
      details['id'] = id;
      details['itemId'] = payload['item_id'];
      await ItemBusinessDetailDbStorage.upsert(db, ItemBusinessDetailModel.fromJson(details));
    } else if (entity == 'customer') {
      if (deleted) {
        await db.delete(
          TxtConstants.customerTableName,
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        await db.insert(TxtConstants.customerTableName, {
          'id': id,
          'name': payload['name'],
          'address': payload['address'],
          'phoneNo': payload['phone'],
          'request': payload['request'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } else if (entity == 'delivery_person') {
      await db.insert(TxtConstants.deliveryPersonTableName, {
        'id': id,
        'name': payload['name'],
        'address': payload['address'],
        'phoneNo': payload['phone'],
        'request': payload['request'],
        'activeStatus': payload['active'] == false || deleted ? 0 : 1,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'delivery') {
      if (deleted) {
        await db.delete(
          TxtConstants.deliveryModelTableName,
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        await db.insert(TxtConstants.deliveryModelTableName, {
          'id': id,
          'startAddress': payload['start_address'],
          'endAddress': payload['end_address'],
          'deliveryCharges': payload['charges'],
          'startDeliveryTime': payload['start_time'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    } else if (entity == 'alert') {
      await db.insert(TxtConstants.alertTableName, {
        'id': id,
        'createTime': createdAt,
        'deleteTime': payload['deleted_at'],
        'lastUpdateTime': updatedAt,
        'createPersonId': createdBy,
        'deletePersonId': payload['updated_by'],
        'title': payload['title'] ?? '',
        'description': payload['description'] ?? '',
        'targetAudienceType': payload['target_audience_type'] ?? 'all',
        'importanceLevel': payload['importance_level'] ?? 'normal',
        'activeStatus': active,
        'colorCode': payload['color_code'],
        'completeStatus': payload['complete'] == true ? 1 : 0,
        'completePersonId': payload['updated_by'],
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    } else if (entity == 'image') {
      final itemId = payload['item_id'];
      if (deleted) {
        await db.delete(
          TxtConstants.imageTableName,
          where: 'id = ?',
          whereArgs: [id],
        );
      } else {
        await db.insert(TxtConstants.imageTableName, {
          'id': id,
          'imageTxt': payload['path'] ?? 'server-image:$id',
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
      if (itemId is int) {
        await db.update(
          TxtConstants.itemTableName,
          {'imageId': deleted ? null : id},
          where: 'id = ?',
          whereArgs: [itemId],
        );
      }
    } else if (entity == 'setting') {
      final key = payload['key']?.toString();
      final value = payload['value']?.toString();
      if (key != null) await _applyShopSetting(key, value);
    }
  }

  static Future<void> _applyShopSetting(String key, String? value) async {
    final storage = ShopInfoStorage.instance;
    switch (key) {
      case 'shopInfo_shopName': if (value != null) await storage.saveShopName(value);
      case 'shopInfo_shopAddress': if (value != null) await storage.saveShopAddress(value);
      case 'shopInfo_phNum': if (value != null) await storage.savePhNum(value);
      case 'shopInfo_noReturnNote': if (value != null) await storage.saveNoReturnNote(value);
      case 'shopInfo_taxEnabled': await storage.saveTaxEnabled(value == 'true');
      case 'shopInfo_itemTaxEnabled': await storage.saveItemTaxEnabled(value == 'true');
      case 'shopInfo_checkoutTaxEnabled': await storage.saveCheckoutTaxEnabled(value == 'true');
      case 'shopInfo_checkoutTaxPercentage':
        final parsed = double.tryParse(value ?? '');
        if (parsed != null) await storage.saveCheckoutTaxPercentage(parsed);
      case 'shopInfo_logoPath': await storage.saveLogoPath(value);
      case 'shopInfo_logoSizeRatio':
        final parsed = double.tryParse(value ?? '');
        if (parsed != null) await storage.saveLogoSizeRatio(parsed);
      case 'shopInfo_includeQrCode': await storage.saveIncludeQrCode(value == 'true');
      case 'shopInfo_includeLogo': await storage.saveIncludeLogo(value != 'false');
    }
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

  static Future<List<Map<String, dynamic>>> getAllAlerts({
    int limit = UIConstants.defaultPageLimit,
    int offset = 0,
  }) async {
    final rows = await AlertDbService.getAllAlerts(
      database!,
      limit: limit,
      offset: offset,
    );
    return rows.map((row) => Map<String, dynamic>.from(row as Map)).toList();
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

  static Future<List<dynamic>> getAllImages() async {
    return ImageDbStorage.getAllImages(database!);
  }

  static Future<int> updateImagePath({
    required int imageId,
    required String imagePath,
  }) async {
    return ImageDbService.updateImagePath(
      database!,
      imageId: imageId,
      imagePath: imagePath,
    );
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

  static Future<void> clearAllTaxValues() async {
    final db = database;
    if (db == null) return;
    await db.transaction((txn) async {
      await _clearItemTaxValues(txn);
      await txn.update(TxtConstants.stockOutTableName, {'taxPercentage': 0});
    });
  }

  static Future<void> clearItemTaxValues() async {
    final db = database;
    if (db == null) return;
    await db.transaction(_clearItemTaxValues);
  }

  static Future<void> _clearItemTaxValues(Transaction txn) async {
    await txn.update(TxtConstants.itemTableName, {'taxPercentage': 0});
    await txn.update(TxtConstants.uniqueItemTableName, {'taxPercentage': 0});
    await txn.update(TxtConstants.moduleComponentItemTableName, {
      'taxPercentage': 0,
    });
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

/// Backward-compatible name for native/database services that still use it.
typedef DBHelper = LocalPosRepository;
