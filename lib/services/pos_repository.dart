import 'dart:convert';
import 'dart:io';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../constants/enums.dart';

import '../controller/DB_helper.dart';
import '../models/itemModel_with_UniqueItemcount.dart';
import '../models/item_model_folder/item_model.dart';
import '../models/item_model_folder/uniqueItem_model.dart';
import '../models/item_model_folder/item_business_detail_model.dart';
import '../models/groupingItem_models_folders/category_model.dart';
import '../models/groupingItem_models_folders/group_model.dart';
import '../models/groupingItem_models_folders/type_model.dart';
import '../models/customer_model.dart';
import '../models/deliver_model_folder/delivery_model.dart';
import '../models/deliver_model_folder/delivery_person_model.dart';
import '../models/promotion_model_folder/promotion_model.dart';
import '../models/update_history_model.dart';
import '../models/junction_models_folder/promotion_junctions/item_promotion_model.dart';
import '../models/stock_in_unit_spec.dart';
import '../models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import '../models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import '../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import '../models/junction_models_folder/promotion_junctions/stockout_promotion_model.dart';
import 'network_environment.dart';
import 'pos_api_client.dart';

export '../controller/DB_helper.dart';

/// Boundary used by Blocs for business data. Offline remains the compatibility path.
/// The single repository boundary used by the application. Local SQLite
/// operations are deliberately not inherited here; callers must explicitly
/// choose LocalPosRepository for offline-only infrastructure.
class PosRepository {
  static final PosRepository instance = PosRepository();
  final PosApiClient api;
  bool _lastRemoteWriteWasQueued = false;
  PosRepository({PosApiClient? api}) : api = api ?? PosApiClient();

  ApplicationNetworkEnvironment get mode => NetworkConfiguration.environment;
  bool get isOffline => mode == ApplicationNetworkEnvironment.offline;
  bool get isOnline => mode == ApplicationNetworkEnvironment.online;
  bool get isHybrid => mode == ApplicationNetworkEnvironment.hybrid;

  Future<void> initialize() => api.loadPersistedToken();

  Future<int> pendingSyncCount() async {
    if (kIsWeb) return 0;
    return (await DBHelper.getPendingOperations()).length;
  }

  /// Central read policy: offline uses SQLite, online requires the backend,
  /// and hybrid falls back to the local cache only after a failed request.
  Future<T> readWithMode<T>({
    required Future<T> Function() local,
    required Future<T> Function() remote,
  }) async {
    if (isOffline) return local();
    try {
      return await remote();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) return local();
      rethrow;
    }
  }

  /// Central write policy. Offline writes use SQLite. Online writes require
  /// the backend. Hybrid writes prefer the backend, but when the remote
  /// method queues an unavailable operation, the same mutation is applied to
  /// SQLite so the app remains usable until synchronization succeeds.
  Future<T> writeWithMode<T>({
    required Future<T> Function() local,
    required Future<T> Function() remote,
  }) async {
    if (isOffline) return local();
    if (isOnline) return remote();

    _lastRemoteWriteWasQueued = false;
    final result = await remote();
    if (_lastRemoteWriteWasQueued) await local();
    return result;
  }

  Future<Map<String, dynamic>> authenticate({
    required String username,
    required String password,
    String? shopId,
  }) => api.login(
    username: username,
    password: password,
    shopId: shopId ?? NetworkConfiguration.shopId,
  );

  Future<void> logout() => api.clearToken();

  Future<bool> createUser({
    required String username,
    required String password,
    required String role,
  }) async {
    final payload = {
      'username': username,
      'password': password,
      'role': role,
      'shop_id': NetworkConfiguration.shopId,
    };
    // First-time setup has no owner token yet. Bootstrap is deliberately
    // guarded by the backend so it cannot create a second owner later.
    if (role == 'owner' && api.token == null) {
      await api.bootstrap(
        username: username,
        password: password,
        shopId: NetworkConfiguration.shopId,
      );
      return true;
    }
    return _remoteOrQueue(
      operationType: 'user_create',
      payload: payload,
      remote: () => api.request('POST', '/api/v1/users', body: payload),
    );
  }

  Future<bool> updateUserPassword({
    required int userId,
    required String password,
  }) async {
    final payload = {'id': userId, 'password': password};
    return _remoteOrQueue(
      operationType: 'user_password_update',
      entityId: userId.toString(),
      payload: payload,
      remote: () => api.request(
        'PATCH',
        '/api/v1/users/$userId',
        body: {'password': password},
      ),
    );
  }

  Future<bool> deleteUser(int userId) async => _remoteOrQueue(
    operationType: 'user_delete',
    entityId: userId.toString(),
    payload: {'id': userId},
    remote: () => api.request('DELETE', '/api/v1/users/$userId'),
  );

  Future<List<Map<String, dynamic>>> fetchUsers() async {
    return readWithMode(
      local: () async => (await LocalPosRepository.getAllUsersFromDB())
          .map((user) => user.toJson())
          .toList(),
      remote: () async {
        return _fetchAllPaged('/api/v1/users', pageSize: 200);
      },
    );
  }

  Future<bool> merchantExists() async {
    final response = await api.request(
      'GET',
      '/api/v1/auth/setup-status?shop_id=${Uri.encodeQueryComponent(NetworkConfiguration.shopId)}',
    );
    return (response as Map)['merchant_exists'] == true;
  }

  Future<List<Map<String, dynamic>>> refreshChanges({String? since}) async {
    final path = since == null
        ? '/api/v1/sync/refresh'
        : '/api/v1/sync/refresh?since=${Uri.encodeQueryComponent(since)}';
    final response = await api.request('GET', path);
    final changes = ((response as Map)['changes'] as List? ?? const [])
        .map((item) => Map<String, dynamic>.from(item as Map))
        .toList();
    if (kIsWeb) return changes;
    for (final change in changes) {
      final payload = change['payload'];
      if (payload == null) continue;
      await DBHelper.cacheServerRecord(
        entityType: change['entity'] as String,
        entityId: change['entity_id'] as String,
        payload: jsonEncode(payload),
        updatedAt: change['changed_at'] as String,
      );
      await DBHelper.applyServerChange(
        entity: change['entity'] as String,
        operation: change['operation'] as String? ?? 'update',
        payload: payload,
      );
    }
    return changes;
  }

  Future<dynamic> getItems() async {
    return readWithMode(
      local: () => DBHelper.getAllItemData(),
      remote: () => api.request('GET', '/api/v1/items'),
    );
  }

  Future<Map<String, List>> fetchLegacyItemData() async {
    try {
      final catalogs = <String, List<Map<String, dynamic>>>{};
      for (final kind in ['category', 'group', 'type']) {
        final response = await api.request(
          'GET',
          '/api/v1/catalogs?kind=$kind&include_deleted=true',
        );
        catalogs[kind] = ((response as List?) ?? const [])
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      }
      final rawItems = await _fetchAllPaged(
        '/api/v1/items?include_deleted=true',
        pageSize: 200,
      );
      final rawUnique = await _fetchAllPaged(
        '/api/v1/unique-items?include_deleted=true',
        pageSize: 2000,
      );
      final images = await fetchImages();
      final imageByItemId = <int, int>{};
      for (final image in images) {
        final itemId = image['item_id'];
        final imageId = image['id'];
        if (itemId is int &&
            imageId is int &&
            !imageByItemId.containsKey(itemId)) {
          // /images is newest-first; keep the newest image for each item.
          imageByItemId[itemId] = imageId;
        }
      }
      return {
        'category': catalogs['category']!
            .map((x) => CategoryModel.fromJson(_catalogJson(x)))
            .toList(),
        'group': catalogs['group']!
            .map((x) => GroupModel.fromJson(_catalogJson(x)))
            .toList(),
        'type': catalogs['type']!
            .map((x) => TypeModel.fromJson(_catalogJson(x)))
            .toList(),
        'item': rawItems
            .map(
              (x) => ItemModel.fromJson(
                _itemJson(
                  x,
                  imageId:
                      x['image_id'] as int? ?? imageByItemId[x['id'] as int],
                  imageUrl: x['image_url'] as String?,
                ),
              ),
            )
            .toList(),
        'uniqueItem': rawUnique
            .map((x) => UniqueItemModel.fromJson(_uniqueJson(x)))
            .toList(),
      };
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllItemData();
      }
      rethrow;
    }
  }

  Future<List<CategoryModel>> fetchCategories({
    int limit = 50,
    int offset = 0,
  }) async {
    final data = await fetchLegacyItemData();
    return (data['category'] as List<CategoryModel>)
        .skip(offset)
        .take(limit)
        .toList();
  }

  Future<List<GroupModel>> fetchGroups({int limit = 50, int offset = 0}) async {
    final data = await fetchLegacyItemData();
    return (data['group'] as List<GroupModel>)
        .skip(offset)
        .take(limit)
        .toList();
  }

  Map<String, dynamic> _catalogJson(Map<String, dynamic> x) => {
    'id': x['id'],
    'name': x['name'],
    'description': x['description'],
    'categoryId': x['parent_id'],
    'groupId': x['parent_id'],
    'colorCode': null,
    'imageId': null,
    'generalDescription': x['description'],
    'generalRestrictionId': null,
    'hasExpire': x['has_expire'] == true || x['has_expire'] == 1 ? 1 : 0,
    'createPersonId': x['created_by'] ?? 0,
    'deletePersonId': x['updated_by'],
    'createTime': x['created_at'] ?? DateTime.now().toIso8601String(),
    'lastUpdateTime': x['updated_at'],
    'deleteTime': x['deleted_at'],
    'activeStatus': x['deleted_at'] == null ? 1 : 0,
  };

  Map<String, dynamic> _itemJson(
    Map<String, dynamic> x, {
    int? imageId,
    String? imageUrl,
  }) => {
    ..._catalogJson(x),
    'categoryId': x['category_id'],
    'groupId': x['group_id'],
    'typeId': x['type_id'],
    'name': x['name'],
    'description': x['description'],
    'code': x['code'],
    'originalPrice': _number(x['original_price']),
    'profitPrice': _number(x['profit_price']),
    'taxPercentage': _number(x['tax_percentage']),
    'need_stock': x['need_stock'] == true ? 1 : 0,
    'imageId': imageId,
    'imageUrl': imageUrl,
  };

  Map<String, dynamic> _uniqueJson(Map<String, dynamic> x) => {
    ..._catalogJson(x),
    'itemId': x['item_id'],
    'stockInId': x['stock_in_id'],
    'stockOutId': x['stock_out_id'],
    'code': x['barcode'],
    'originalPrice': _number(x['original_price']),
    'profitPrice': _number(x['profit_price']),
    'taxPercentage': _number(x['tax_percentage']),
    'moduleCount': null,
    'instanceLength': null,
    'instanceWidth': null,
    'instanceBatchNumber': x['batch_number'],
    'instanceImei': x['imei'],
    'itemManufactureDate': x['manufacture_date'],
    'itemExpireDate': x['expire_date'],
    'getItemFromWhere': null,
  };

  double _number(Object? value) => value is num ? value.toDouble() : 0;

  /// Reads every page from a backend Page response so the remote view has the
  /// same complete dataset as the local SQLite view. The backend caps normal
  /// resources at 200 rows and unique items at 2000 rows per request.
  Future<List<Map<String, dynamic>>> _fetchAllPaged(
    String path, {
    required int pageSize,
  }) async {
    final rows = <Map<String, dynamic>>[];
    var page = 1;
    while (true) {
      final separator = path.contains('?') ? '&' : '?';
      final response = await api.request(
        'GET',
        '$path${separator}page=$page&page_size=$pageSize',
      );
      if (response is! Map) break;
      final pageRows = ((response['items'] as List?) ?? const [])
          .map((item) => Map<String, dynamic>.from(item as Map))
          .toList();
      rows.addAll(pageRows);
      final total = response['total'] is num
          ? (response['total'] as num).toInt()
          : null;
      if (pageRows.isEmpty ||
          pageRows.length < pageSize ||
          (total != null && rows.length >= total)) {
        break;
      }
      page++;
    }
    return rows;
  }

  Future<List<PromotionModel>> fetchPromotions() async {
    try {
      final response = await api.request('GET', '/api/v1/promotions');
      return ((response as List?) ?? const []).map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        return PromotionModel.fromJson({
          'id': x['id'],
          'promotionName': x['name'],
          'promotionDescription': x['description'],
          'promotionPercentage': _numberOrNull(x['percentage']),
          'promotionPrice': _numberOrNull(x['fixed_price']),
          'createPersonId': x['created_by'] ?? 0,
          'deletePersonId': x['updated_by'],
          'activeStatus': x['deleted_at'] == null ? 1 : 0,
          'promotionLimitPerson': x['limit_person'],
          'promotionLimitPrice': _numberOrNull(x['limit_price']),
          'promotionLimitTime': x['limit_time'],
          'requirementForItemCount': x['requirement_count'],
          'requirementForPrice': _numberOrNull(x['requirement_price']),
          'promotionCode': x['code'],
          'createTime': x['created_at'] ?? DateTime.now().toIso8601String(),
          'lastUpdateTime': x['updated_at'],
          'deleteTime': x['deleted_at'],
        });
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllPromotion();
      }
      rethrow;
    }
  }

  Future<bool> createPromotion({
    required String name,
    String? description,
    double? percentage,
    double? fixedPrice,
    required String code,
  }) async {
    return _remoteOrQueue(
      operationType: 'promotion_create',
      payload: {
        'name': name,
        'description': description,
        'percentage': percentage,
        'fixed_price': fixedPrice,
        'code': code,
      },
      remote: () => api.request(
        'POST',
        '/api/v1/promotions',
        body: {
          'name': name,
          'description': description,
          'percentage': percentage,
          'fixed_price': fixedPrice,
          'code': code,
        },
      ),
    );
  }

  Future<bool> deletePromotion(int id) async {
    return _remoteOrQueue(
      operationType: 'promotion_delete',
      entityId: id.toString(),
      payload: {'promotion_id': id},
      remote: () => api.request('DELETE', '/api/v1/promotions/$id'),
    );
  }

  Future<bool> updatePromotion({
    required int id,
    required String name,
    String? description,
    double? percentage,
    double? fixedPrice,
    required String code,
  }) async {
    final payload = {
      'id': id,
      'name': name,
      'description': description,
      'percentage': percentage,
      'fixed_price': fixedPrice,
      'code': code,
    };
    return _remoteOrQueue(
      operationType: 'promotion_update',
      entityId: id.toString(),
      payload: payload,
      remote: () =>
          api.request('PATCH', '/api/v1/promotions/$id', body: payload),
    );
  }

  Future<bool> attachPromotion({
    required int promotionId,
    required int itemId,
  }) async {
    return _remoteOrQueue(
      operationType: 'promotion_attach',
      payload: {
        'promotion_id': promotionId,
        'target_type': 'item',
        'target_id': itemId,
      },
      remote: () => api.request(
        'POST',
        '/api/v1/promotions/$promotionId/targets',
        body: {'target_type': 'item', 'target_id': itemId},
      ),
    );
  }

  Future<bool> detachPromotionTarget({
    required int promotionId,
    required int targetId,
  }) async {
    return _remoteOrQueue(
      operationType: 'promotion_detach',
      entityId: targetId.toString(),
      payload: {'promotion_id': promotionId, 'target_id': targetId},
      remote: () => api.request(
        'DELETE',
        '/api/v1/promotions/$promotionId/targets/$targetId',
      ),
    );
  }

  Future<List<ItemPromotionModel>> fetchItemPromotions() async {
    try {
      final promotions = await fetchPromotions();
      final result = <ItemPromotionModel>[];
      for (final promotion in promotions) {
        final response = await api.request(
          'GET',
          '/api/v1/promotions/${promotion.id}/targets',
        );
        for (final raw in (response as List? ?? const [])) {
          final x = Map<String, dynamic>.from(raw as Map);
          if (x['target_type'] != 'item') continue;
          result.add(
            ItemPromotionModel.fromJson({
              'id': x['id'],
              'itemId': x['target_id'],
              'promotionId': promotion.id,
              'createTime': x['created_at'] ?? DateTime.now().toIso8601String(),
              'deleteTime': null,
              'createPersonId': 0,
              'deletePersonId': null,
              'activeStatus': 1,
            }),
          );
        }
      }
      return result;
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllItemPromotion();
      }
      rethrow;
    }
  }

  Future<List<StockOutPromotionModel>> fetchStockOutPromotions() async {
    try {
      final promotions = await fetchPromotions();
      final result = <StockOutPromotionModel>[];
      for (final promotion in promotions) {
        final response = await api.request(
          'GET',
          '/api/v1/promotions/${promotion.id}/targets',
        );
        for (final raw in (response as List? ?? const [])) {
          final x = Map<String, dynamic>.from(raw as Map);
          if (x['target_type'] == 'stock_out') {
            result.add(
              StockOutPromotionModel(
                stockOutId: x['target_id'] as int,
                promotionId: promotion.id,
              ),
            );
          }
        }
      }
      return result;
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllStockOutPromotion();
      }
      rethrow;
    }
  }

  Future<bool> createCatalog({
    required String kind,
    required String name,
    int? parentId,
    String? description,
    bool hasExpire = false,
  }) async {
    return _remoteOrQueue(
      operationType: 'catalog_create',
      payload: {
        'kind': kind,
        'name': name,
        'parent_id': parentId,
        'description': description,
        'has_expire': hasExpire,
      },
      remote: () => api.request(
        'POST',
        '/api/v1/catalogs',
        body: {
          'kind': kind,
          'name': name,
          'parent_id': parentId,
          'description': description,
          'has_expire': hasExpire,
        },
      ),
    );
  }

  Future<int> createItem({
    required String name,
    required int typeId,
    int? categoryId,
    int? groupId,
    String? code,
    required double originalPrice,
    required double profitPrice,
    required double taxPercentage,
    required bool hasExpire,
    required bool needStock,
    String? description,
  }) async {
    final payload = {
      'name': name,
      'type_id': typeId,
      'category_id': categoryId,
      'group_id': groupId,
      'code': code,
      'original_price': originalPrice,
      'profit_price': profitPrice,
      'tax_percentage': taxPercentage,
      'has_expire': hasExpire,
      'need_stock': needStock,
      'description': description,
    };
    try {
      final result = await api.request('POST', '/api/v1/items', body: payload);
      return (result as Map)['id'] as int;
    } on PosApiException catch (error) {
      if (!isHybrid || error.statusCode != null) rethrow;
      await submitOperation(operationType: 'item_create', payload: payload);
      // Negative values distinguish an accepted offline enqueue from a
      // server-created item; dependent uploads wait for the next refresh.
      return -1;
    }
  }

  Future<bool> saveBusinessDetailRemote(ItemBusinessDetailModel detail) async {
    return _remoteOrQueue(
      operationType: 'business_detail_update',
      entityId: detail.itemId.toString(),
      payload: {'item_id': detail.itemId, 'details': detail.toJson()},
      remote: () => api.request(
        'PUT',
        '/api/v1/items/${detail.itemId}/business-detail',
        body: {'item_id': detail.itemId, 'details': detail.toJson()},
      ),
    );
  }

  Future<List<ItemBusinessDetailModel>> fetchBusinessDetails() async {
    try {
      final response = await api.request(
        'GET',
        '/api/v1/item-business-details',
      );
      return ((response as List?) ?? const []).map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        final details = Map<String, dynamic>.from(
          x['details'] as Map? ?? const {},
        );
        return ItemBusinessDetailModel.fromJson({
          ...details,
          'id': x['id'],
          'itemId': x['item_id'],
        });
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllItemBusinessDetails();
      }
      rethrow;
    }
  }

  Future<ItemBusinessDetailModel?> fetchBusinessDetail(int itemId) async {
    try {
      final raw = Map<String, dynamic>.from(
        await api.request('GET', '/api/v1/items/$itemId/business-detail')
            as Map,
      );
      final details = Map<String, dynamic>.from(
        raw['details'] as Map? ?? const {},
      );
      return ItemBusinessDetailModel.fromJson({
        ...details,
        'id': raw['id'],
        'itemId': raw['item_id'],
      });
    } on PosApiException catch (error) {
      if (error.statusCode == 404) return null;
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getItemBusinessDetail(itemId);
      }
      rethrow;
    }
  }

  Future<CategoryModel?> fetchCategoryById(int id) async {
    try {
      final raw = Map<String, dynamic>.from(
        await api.request('GET', '/api/v1/catalogs/$id') as Map,
      );
      return CategoryModel.fromJson(_catalogJson(raw));
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getCategoryById(id);
      }
      rethrow;
    }
  }

  Future<GroupModel?> fetchGroupById(int id) async {
    try {
      final raw = Map<String, dynamic>.from(
        await api.request('GET', '/api/v1/catalogs/$id') as Map,
      );
      return GroupModel.fromJson(_catalogJson(raw));
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getGroupById(id);
      }
      rethrow;
    }
  }

  Future<TypeModel?> fetchTypeById(int id) async {
    try {
      final raw = Map<String, dynamic>.from(
        await api.request('GET', '/api/v1/catalogs/$id') as Map,
      );
      return TypeModel.fromJson(_catalogJson(raw));
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getTypeById(id);
      }
      rethrow;
    }
  }

  Future<bool> updateCatalog(
    int id, {
    required String kind,
    required String name,
    int? parentId,
    String? description,
  }) async {
    return _remoteOrQueue(
      operationType: 'catalog_update',
      entityId: id.toString(),
      payload: {
        'id': id,
        'kind': kind,
        'name': name,
        'parent_id': parentId,
        'description': description,
      },
      remote: () => api.request(
        'PATCH',
        '/api/v1/catalogs/$id',
        body: {
          'kind': kind,
          'name': name,
          'parent_id': parentId,
          'description': description,
        },
      ),
    );
  }

  Future<bool> updateItem(
    int id, {
    required String name,
    required int typeId,
    int? categoryId,
    int? groupId,
    String? code,
    required double originalPrice,
    required double profitPrice,
    required double taxPercentage,
    required bool needStock,
  }) async {
    final payload = {
      'id': id,
      'name': name,
      'type_id': typeId,
      'category_id': categoryId,
      'group_id': groupId,
      'code': code,
      'original_price': originalPrice,
      'profit_price': profitPrice,
      'tax_percentage': taxPercentage,
      'need_stock': needStock,
    };
    return _remoteOrQueue(
      operationType: 'item_update',
      entityId: id.toString(),
      payload: payload,
      remote: () => api.request('PATCH', '/api/v1/items/$id', body: payload),
    );
  }

  Future<bool> deleteResource(String path) async {
    final parts = path.split('/');
    final entityId = parts.isNotEmpty ? parts.last : null;
    return _remoteOrQueue(
      operationType: 'resource_delete',
      entityId: entityId,
      payload: {'path': path},
      remote: () => api.request('DELETE', path),
    );
  }

  Future<bool> isBarcodeAvailable(String barcode) async {
    try {
      final response =
          await api.request(
                'GET',
                '/api/v1/barcodes/available?barcode=${Uri.encodeQueryComponent(barcode)}',
              )
              as Map;
      return response['available'] == true;
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.isBarcodeAvailable(barcode);
      }
      rethrow;
    }
  }

  Future<bool> updateItemBarcode({
    required int itemId,
    required String barcode,
  }) async {
    if (isOffline) {
      return LocalPosRepository.updateItemBarcode(
        itemId: itemId,
        barcode: barcode,
      );
    }
    if (isOnline) {
      return _remoteOrQueue(
        operationType: 'item_barcode_update',
        entityId: itemId.toString(),
        payload: {'id': itemId, 'barcode': barcode},
        remote: () => api.request(
          'PATCH',
          '/api/v1/items/$itemId/barcode',
          body: {'barcode': barcode},
        ),
      );
    }
    _lastRemoteWriteWasQueued = false;
    final result = await _remoteOrQueue(
      operationType: 'item_barcode_update',
      entityId: itemId.toString(),
      payload: {'id': itemId, 'barcode': barcode},
      remote: () => api.request(
        'PATCH',
        '/api/v1/items/$itemId/barcode',
        body: {'barcode': barcode},
      ),
    );
    if (_lastRemoteWriteWasQueued) {
      await LocalPosRepository.updateItemBarcode(
        itemId: itemId,
        barcode: barcode,
      );
    }
    return result;
  }

  Future<bool> updateUniqueItemBarcode({
    required int uniqueItemId,
    required String barcode,
  }) async {
    if (isOffline) {
      return LocalPosRepository.updateUniqueItemBarcode(
        uniqueItemId: uniqueItemId,
        barcode: barcode,
      );
    }
    if (isOnline) {
      return _remoteOrQueue(
        operationType: 'unique_item_barcode_update',
        entityId: uniqueItemId.toString(),
        payload: {'id': uniqueItemId, 'barcode': barcode},
        remote: () => api.request(
          'PATCH',
          '/api/v1/unique-items/$uniqueItemId/barcode',
          body: {'barcode': barcode},
        ),
      );
    }
    _lastRemoteWriteWasQueued = false;
    final result = await _remoteOrQueue(
      operationType: 'unique_item_barcode_update',
      entityId: uniqueItemId.toString(),
      payload: {'id': uniqueItemId, 'barcode': barcode},
      remote: () => api.request(
        'PATCH',
        '/api/v1/unique-items/$uniqueItemId/barcode',
        body: {'barcode': barcode},
      ),
    );
    if (_lastRemoteWriteWasQueued) {
      await LocalPosRepository.updateUniqueItemBarcode(
        uniqueItemId: uniqueItemId,
        barcode: barcode,
      );
    }
    return result;
  }

  Future<bool> createCustomer({
    String? name,
    String? address,
    String? phone,
    String? request,
  }) async {
    final payload = {
      'name': name,
      'address': address,
      'phone': phone,
      'request': request,
    };
    return _remoteOrQueue(
      operationType: 'customer_create',
      payload: payload,
      remote: () => api.request('POST', '/api/v1/customers', body: payload),
    );
  }

  Future<bool> updateCustomer({
    required int id,
    String? name,
    String? address,
    String? phone,
    String? request,
  }) async {
    final payload = {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'request': request,
    };
    return _remoteOrQueue(
      operationType: 'customer_update',
      entityId: id.toString(),
      payload: payload,
      remote: () =>
          api.request('PATCH', '/api/v1/customers/$id', body: payload),
    );
  }

  Future<bool> deleteCustomer(int id) async => _remoteOrQueue(
    operationType: 'customer_delete',
    entityId: id.toString(),
    payload: {'id': id},
    remote: () => api.request('DELETE', '/api/v1/customers/$id'),
  );

  Future<List<CustomerModel>> fetchCustomers() async {
    try {
      final response = await api.request('GET', '/api/v1/customers');
      return ((response as List?) ?? const []).map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        return CustomerModel.fromJson({...x, 'phoneNo': x['phone']});
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllCustomer();
      }
      rethrow;
    }
  }

  Future<int?> createCustomerForSale(String name) async {
    final response = await api.request(
      'POST',
      '/api/v1/customers',
      body: {'name': name},
    );
    return (response as Map)['id'] as int?;
  }

  Future<int?> createDeliveryPersonForSale(String name) async {
    final response = await api.request(
      'POST',
      '/api/v1/delivery-people',
      body: {'name': name},
    );
    return (response as Map)['id'] as int?;
  }

  Future<bool> createDeliveryPerson({
    String? name,
    String? address,
    String? phone,
    String? request,
    bool active = true,
  }) async {
    final payload = {
      'name': name,
      'address': address,
      'phone': phone,
      'request': request,
      'active': active,
    };
    return _remoteOrQueue(
      operationType: 'delivery_person_create',
      payload: payload,
      remote: () =>
          api.request('POST', '/api/v1/delivery-people', body: payload),
    );
  }

  Future<bool> updateDeliveryPerson({
    required int id,
    String? name,
    String? address,
    String? phone,
    String? request,
    bool active = true,
  }) async {
    final payload = {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'request': request,
      'active': active,
    };
    return _remoteOrQueue(
      operationType: 'delivery_person_update',
      entityId: id.toString(),
      payload: payload,
      remote: () =>
          api.request('PATCH', '/api/v1/delivery-people/$id', body: payload),
    );
  }

  Future<bool> deleteDeliveryPerson(int id) async => _remoteOrQueue(
    operationType: 'delivery_person_delete',
    entityId: id.toString(),
    payload: {'id': id},
    remote: () => api.request('DELETE', '/api/v1/delivery-people/$id'),
  );

  Future<List<DeliveryPersonModel>> fetchDeliveryPeople() async {
    try {
      final response = await api.request('GET', '/api/v1/delivery-people');
      return ((response as List?) ?? const []).map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        return DeliveryPersonModel.fromJson({
          ...x,
          'phoneNo': x['phone'],
          'activeStatus': x['active'] == true ? 1 : 0,
        });
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllDeliveryPerson();
      }
      rethrow;
    }
  }

  Future<List<DeliveryModel>> fetchDeliveries() async {
    try {
      final response = await api.request('GET', '/api/v1/deliveries');
      return ((response as List?) ?? const []).map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        return DeliveryModel.fromJson({
          ...x,
          'deliveryCharges': x['charges'],
          'startDeliveryTime': x['start_time'],
        });
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllDeliveryModel();
      }
      rethrow;
    }
  }

  Future<bool> createDelivery({
    int? stockOutId,
    int? deliveryPersonId,
    String? startAddress,
    String? endAddress,
    double? charges,
    String? startTime,
  }) async {
    final payload = {
      'stock_out_id': stockOutId,
      'delivery_person_id': deliveryPersonId,
      'start_address': startAddress,
      'end_address': endAddress,
      'charges': charges,
      'start_time': startTime,
    };
    return _remoteOrQueue(
      operationType: 'delivery_create',
      payload: payload,
      remote: () => api.request('POST', '/api/v1/deliveries', body: payload),
    );
  }

  Future<bool> updateDelivery({
    required int id,
    int? stockOutId,
    int? deliveryPersonId,
    String? startAddress,
    String? endAddress,
    double? charges,
    String? startTime,
  }) async {
    final payload = {
      'id': id,
      'stock_out_id': stockOutId,
      'delivery_person_id': deliveryPersonId,
      'start_address': startAddress,
      'end_address': endAddress,
      'charges': charges,
      'start_time': startTime,
    };
    return _remoteOrQueue(
      operationType: 'delivery_update',
      entityId: id.toString(),
      payload: payload,
      remote: () =>
          api.request('PATCH', '/api/v1/deliveries/$id', body: payload),
    );
  }

  Future<bool> deleteDelivery(int id) async => _remoteOrQueue(
    operationType: 'delivery_delete',
    entityId: id.toString(),
    payload: {'id': id},
    remote: () => api.request('DELETE', '/api/v1/deliveries/$id'),
  );

  Future<bool> createAlert({
    required String title,
    required String description,
    String targetAudienceType = 'all',
    String importanceLevel = 'normal',
    String? colorCode,
  }) async {
    final payload = {
      'title': title,
      'description': description,
      'target_audience_type': targetAudienceType,
      'importance_level': importanceLevel,
      'color_code': colorCode,
    };
    return _remoteOrQueue(
      operationType: 'alert_create',
      payload: payload,
      remote: () => api.request('POST', '/api/v1/alerts', body: payload),
    );
  }

  Future<bool> updateAlert({
    required int id,
    String? title,
    String? description,
    String? targetAudienceType,
    String? importanceLevel,
    String? colorCode,
    bool? complete,
  }) async {
    final payload = {
      'id': id,
      'title': title,
      'description': description,
      'target_audience_type': targetAudienceType,
      'importance_level': importanceLevel,
      'color_code': colorCode,
      'complete': complete,
    };
    return _remoteOrQueue(
      operationType: 'alert_update',
      entityId: id.toString(),
      payload: payload,
      remote: () => api.request('PATCH', '/api/v1/alerts/$id', body: payload),
    );
  }

  Future<bool> deleteAlert(int id) async => _remoteOrQueue(
    operationType: 'alert_delete',
    entityId: id.toString(),
    payload: {'id': id},
    remote: () => api.request('DELETE', '/api/v1/alerts/$id'),
  );

  Future<bool> deleteImage(int id) async => _remoteOrQueue(
    operationType: 'image_delete',
    entityId: id.toString(),
    payload: {'id': id},
    remote: () => api.request('DELETE', '/api/v1/images/$id'),
  );

  Future<bool> deleteSetting(String key) async => _remoteOrQueue(
    operationType: 'setting_delete',
    entityId: key,
    payload: {'key': key},
    remote: () =>
        api.request('DELETE', '/api/v1/settings/${Uri.encodeComponent(key)}'),
  );

  Future<bool> createRestriction({
    required String name,
    String? description,
    int? maxQuantity,
    bool active = true,
  }) async {
    final payload = {
      'name': name,
      'description': description,
      'max_quantity': maxQuantity,
      'active': active,
    };
    return _remoteOrQueue(
      operationType: 'restriction_create',
      payload: payload,
      remote: () => api.request('POST', '/api/v1/restrictions', body: payload),
    );
  }

  Future<bool> updateRestriction({
    required int id,
    required String name,
    String? description,
    int? maxQuantity,
    bool active = true,
  }) async {
    final payload = {
      'id': id,
      'name': name,
      'description': description,
      'max_quantity': maxQuantity,
      'active': active,
    };
    return _remoteOrQueue(
      operationType: 'restriction_update',
      entityId: id.toString(),
      payload: payload,
      remote: () =>
          api.request('PATCH', '/api/v1/restrictions/$id', body: payload),
    );
  }

  Future<bool> deleteRestriction(int id) async => _remoteOrQueue(
    operationType: 'restriction_delete',
    entityId: id.toString(),
    payload: {'id': id},
    remote: () => api.request('DELETE', '/api/v1/restrictions/$id'),
  );

  Future<bool> createComponentItem({
    required int parentItemId,
    required int componentItemId,
    required double quantity,
  }) async {
    final payload = {
      'parent_item_id': parentItemId,
      'component_item_id': componentItemId,
      'quantity': quantity,
    };
    return _remoteOrQueue(
      operationType: 'component_create',
      payload: payload,
      remote: () =>
          api.request('POST', '/api/v1/component-items', body: payload),
    );
  }

  Future<bool> deleteComponentItem(int id) async => _remoteOrQueue(
    operationType: 'component_delete',
    entityId: id.toString(),
    payload: {'id': id},
    remote: () => api.request('DELETE', '/api/v1/component-items/$id'),
  );

  Future<List<StockInModel>> fetchStockIns({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await api.request('GET', '/api/v1/transactions');
      final all = ((response as Map)['stock_in'] as List? ?? const []);
      return all.skip(offset).take(limit).map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        return StockInModel.fromJson({
          'id': x['id'],
          'code': x['code'],
          'createTime': x['created_at'] ?? DateTime.now().toIso8601String(),
          'lastUpdateTime': x['updated_at'],
          'deleteTime': x['deleted_at'],
          'createPersonId': x['created_by'] ?? 0,
          'deletePersonId': x['updated_by'],
          'activeStatus': x['deleted_at'] == null ? 1 : 0,
        });
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return (await LocalPosRepository.getAllStockIn(
          limit: limit,
          offset: offset,
        ));
      }
      rethrow;
    }
  }

  Future<List<StockOutModel>> fetchStockOuts({
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await api.request('GET', '/api/v1/transactions');
      final all = ((response as Map)['stock_out'] as List? ?? const []);
      return all.skip(offset).take(limit).map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        return StockOutModel.fromJson({
          'id': x['id'],
          'code': x['code'],
          'description': x['description'],
          'shoppingType': x['shopping_type'] ?? 'shop',
          'paymentMethod': x['payment_method'] ?? 'cash',
          'additionalPromotionAmount': x['discount'],
          'taxPercentage': x['tax'],
          'activeStatus': x['deleted_at'] == null ? 1 : 0,
          'createTime': x['created_at'] ?? DateTime.now().toIso8601String(),
          'lastUpdateTime': x['updated_at'],
          'deleteTime': x['deleted_at'],
          'createPersonId': x['created_by'] ?? 0,
          'deletePersonId': x['updated_by'],
          'customerId': x['customer_id'],
          'deliveryPersonId': null,
          'deliveryModelId': null,
          'finalTotalPrice': _number(x['total']),
          'customerCash': _numberOrNull(x['customer_cash']),
          'refunds': _numberOrNull(x['refunds']),
        });
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllStockOut(limit: limit, offset: offset);
      }
      rethrow;
    }
  }

  Future<List<StockOutItemModel>> fetchStockOutItems({
    int limit = 2000,
    int offset = 0,
  }) async {
    try {
      final response = await api.request('GET', '/api/v1/transactions');
      final all = ((response as Map)['stock_out_items'] as List? ?? const []);
      return all.skip(offset).take(limit).map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        return StockOutItemModel.fromJson({
          'id': x['id'],
          'itemId': x['item_id'],
          'stockOutId': x['stock_out_id'],
          'count': x['count'],
          'originalPrice': _number(x['original_price']),
          'sellPrice': _number(x['sell_price']),
          'finalSellPrice': _number(x['final_sell_price']),
        });
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getAllStockOutItem();
      }
      rethrow;
    }
  }

  double? _numberOrNull(Object? value) =>
      value is num ? value.toDouble() : null;

  Future<List<Map<String, dynamic>>> fetchSettings() async {
    final response = await api.request('GET', '/api/v1/settings');
    return ((response as List?) ?? const [])
        .map((x) => Map<String, dynamic>.from(x as Map))
        .toList();
  }

  Future<Map<String, dynamic>> saveSetting(String key, String? value) async {
    try {
      return Map<String, dynamic>.from(
        await api.request(
              'PUT',
              '/api/v1/settings/$key',
              body: {'key': key, 'value': value},
            )
            as Map,
      );
    } on PosApiException catch (error) {
      if (!isHybrid || error.statusCode != null) rethrow;
      _lastRemoteWriteWasQueued = true;
      await DBHelper.enqueuePendingOperation(
        jsonEncode({
          'operation_id': const Uuid().v4(),
          'operation_type': 'setting',
          'entity_type': 'setting',
          'entity_id': key,
          'payload': {'key': key, 'value': value},
          'created_at': DateTime.now().toUtc().toIso8601String(),
          'retry_count': 0,
          'sync_status': 'pending',
        }),
      );
      return {'key': key, 'value': value, 'sync_status': 'pending'};
    }
  }

  Future<bool> resetItemTaxes() async => _remoteOrQueue(
    operationType: 'tax_reset',
    payload: {'scope': 'item'},
    remote: () =>
        api.request('POST', '/api/v1/taxes/reset', body: {'scope': 'item'}),
  );

  Future<bool> resetAllTaxes() async => _remoteOrQueue(
    operationType: 'tax_reset',
    payload: {'scope': 'all'},
    remote: () =>
        api.request('POST', '/api/v1/taxes/reset', body: {'scope': 'all'}),
  );

  Future<List<Map<String, dynamic>>> fetchAlerts() async {
    return _fetchAllPaged('/api/v1/alerts', pageSize: 200);
  }

  Future<List<Map<String, dynamic>>> fetchImages() async {
    final response = await api.request('GET', '/api/v1/images');
    return ((response as List?) ?? const [])
        .map((x) => Map<String, dynamic>.from(x as Map))
        .toList();
  }

  /// Uploads an image to the backend and returns its server identifier.
  /// The local image database remains the offline implementation; online mode
  /// must not report a local-only image as server-confirmed.
  Future<int> uploadImage({
    required String imagePath,
    int? itemId,
    String purpose = 'item',
    String? sourceMimeType,
  }) async {
    final Uint8List bytes;
    if (kIsWeb && imagePath.startsWith('data:')) {
      final separator = imagePath.indexOf(',');
      if (separator < 0) {
        throw const PosApiException('Invalid web image data');
      }
      bytes = Uint8List.fromList(
        base64Decode(imagePath.substring(separator + 1)),
      );
    } else {
      bytes = await File(imagePath).readAsBytes();
    }
    final mimeType = _mimeType(imagePath);
    final payload = <String, dynamic>{
      'path': imagePath,
      'item_id': itemId,
      'purpose': purpose,
      'mime_type': mimeType,
      'source_mime_type': sourceMimeType ?? mimeType,
      'data_base64': base64Encode(bytes),
      'checksum': null,
    };
    try {
      final response = await api.uploadImage(
        bytes: bytes,
        fileName: imagePath.startsWith('data:')
            ? 'image.jpg'
            : imagePath.split(RegExp(r'[/\\]')).last,
        mimeType: mimeType,
        sourceMimeType: sourceMimeType ?? mimeType,
        itemId: itemId,
        purpose: purpose,
      );
      return response['id'] as int;
    } on PosApiException catch (error) {
      if (!isHybrid || error.statusCode != null) rethrow;
      await submitOperation(operationType: 'image_create', payload: payload);
      return -1;
    }
  }

  String publicImageUrl(int imageId) => api.publicImageUrl(imageId);

  String _mimeType(String path) {
    if (path.startsWith('data:')) {
      final end = path.indexOf(';');
      if (end > 5) return path.substring(5, end);
    }
    final extension = path.toLowerCase().split('.').last;
    return switch (extension) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      'bmp' => 'image/bmp',
      'tif' || 'tiff' => 'image/tiff',
      'heic' => 'image/heic',
      'heif' => 'image/heif',
      'avif' => 'image/avif',
      'svg' => 'image/svg+xml',
      _ => 'image/unknown',
    };
  }

  Future<List<UpdateHistoryModel>> fetchHistory() async {
    try {
      final items = await _fetchAllPaged('/api/v1/history', pageSize: 200);
      return items.map((raw) {
        final x = Map<String, dynamic>.from(raw);
        final model = ModelType.values.firstWhere(
          (value) => value.name == x['entity_type'],
          orElse: () => ModelType.report,
        );
        final update = UpdateType.values.firstWhere(
          (value) => value.name == x['change_type'],
          orElse: () => UpdateType.update,
        );
        return UpdateHistoryModel.fromJson({
          'id': x['id'],
          'oldData': x['old_data'] == null ? '' : jsonEncode(x['old_data']),
          'newData': x['new_data'] == null ? '' : jsonEncode(x['new_data']),
          'createTime': x['created_at'],
          'modelType': model.name,
          'updateType': update.name,
          'createPersonId': x['created_by'] ?? 0,
          'deletePersonId': x['updated_by'],
          'activeStatus': x['deleted_at'] == null ? 1 : 0,
        });
      }).toList();
    } on PosApiException catch (error) {
      if (isHybrid && error.statusCode == null) {
        return LocalPosRepository.getHistoryList();
      }
      rethrow;
    }
  }

  Future<bool> createStockInFromLegacy({
    required ItemModel item,
    required int itemLength,
    required String? code,
    DateTime? manufactureDate,
    DateTime? expireDate,
    List<StockInUnitSpec>? unitSpecs,
  }) async {
    String? normalizedBarcode(String? value) {
      final trimmed = value?.trim();
      return trimmed == null || trimmed.isEmpty ? null : trimmed;
    }

    final normalizedCode = normalizedBarcode(code);
    final units = List.generate(itemLength, (index) {
      final spec = unitSpecs != null && index < unitSpecs.length
          ? unitSpecs[index]
          : null;
      return {
        'item_id': item.id,
        'barcode': normalizedBarcode(spec?.code) ?? normalizedCode,
        'original_price': spec?.originalPrice ?? item.originalPrice,
        'profit_price': spec?.profitPrice ?? item.profitPrice,
        'manufacture_date': manufactureDate?.toUtc().toIso8601String(),
        'expire_date': expireDate?.toUtc().toIso8601String(),
        'batch_number': spec?.instanceBatchNumber,
        'imei': spec?.instanceImei,
      };
    });
    final result = await submitOperation(
      operationType: 'stock_in',
      payload: {
        'operation_id': const Uuid().v4(),
        'code': normalizedCode,
        'units': units,
      },
    );
    return _isAcceptedOperationResult(result);
  }

  Future<bool> createStockOutFromLegacy({
    required List<ItemModelWithUniqueItemCountWithPromotion> lines,
    required String code,
    required String? description,
    required double tax,
    required double discount,
    required ShoppingType shoppingType,
    required PaymentMethod paymentMethod,
    String? customerName,
    String? deliveryName,
    double? deliveryCharges,
  }) async {
    int? customerId;
    int? deliveryPersonId;
    final canCreateRemoteRelations = !isHybrid || await _backendReachable();
    if (canCreateRemoteRelations &&
        customerName != null &&
        customerName.trim().isNotEmpty) {
      customerId = await createCustomerForSale(customerName.trim());
    }
    if (canCreateRemoteRelations &&
        deliveryName != null &&
        deliveryName.trim().isNotEmpty) {
      deliveryPersonId = await createDeliveryPersonForSale(deliveryName.trim());
    }
    final result = await submitOperation(
      operationType: 'sale',
      payload: {
        'operation_id': const Uuid().v4(),
        'code': code,
        'description': description,
        'customer_id': customerId,
        'customer_name': customerName,
        'delivery_person_id': deliveryPersonId,
        'delivery_name': deliveryName,
        'delivery_charges': deliveryCharges,
        'tax': tax,
        'discount': discount,
        'shopping_type': shoppingType.name,
        'payment_method': paymentMethod.name,
        'lines': lines
            .map(
              (line) => {
                'item_id': line.itemModel.id,
                'count': line.count,
                'original_price': line.avgOriginalPrice,
                'sell_price': line.avgSellPrice,
                'final_sell_price': line.avgFinalSellPrice,
              },
            )
            .toList(),
      },
    );
    return _isAcceptedOperationResult(result);
  }

  bool _isAcceptedOperationResult(dynamic response) {
    if (response is! Map) return false;

    // Direct endpoint responses contain `status`; /sync/upload wraps the
    // operation response in `results[0]`.
    final status =
        response['status'] ??
        ((response['results'] is List &&
                (response['results'] as List).isNotEmpty &&
                (response['results'].first is Map))
            ? response['results'].first['status']
            : null);
    return status == 'accepted' ||
        status == 'duplicate' ||
        status == 'pending' ||
        response['sync_status'] == 'pending';
  }

  Future<dynamic> submitOperation({
    required String operationType,
    required Map<String, dynamic> payload,
    String? entityType,
    String? entityId,
    String? deviceId,
    String? companyId,
    String? shopId,
  }) async {
    final operation = {
      'operation_id': payload['operation_id'] ?? const Uuid().v4(),
      'operation_type': operationType,
      'entity_type': entityType ?? operationType,
      'entity_id': entityId,
      'payload': payload,
      'created_at': DateTime.now().toUtc().toIso8601String(),
      'device_id': deviceId,
      'company_id': companyId,
      'shop_id': shopId,
      'retry_count': 0,
      'sync_status': 'pending',
      'last_error': null,
    };
    if (!NetworkConfiguration.usesBackend ||
        (NetworkConfiguration.environment ==
                ApplicationNetworkEnvironment.hybrid &&
            await _queueWhenUnavailable(operation))) {
      if (isHybrid) _lastRemoteWriteWasQueued = true;
      return operation;
    }
    try {
      return await api.request(
        'POST',
        '/api/v1/sync/upload',
        body: {
          'operations': [operation],
        },
      );
    } on PosApiException catch (error) {
      if (!isHybrid || error.statusCode != null) rethrow;
      await DBHelper.enqueuePendingOperation(jsonEncode(operation));
      _lastRemoteWriteWasQueued = true;
      return operation;
    }
  }

  Future<bool> _queueWhenUnavailable(Map<String, dynamic> operation) async {
    try {
      await api.request('GET', '/health');
      return false;
    } on PosApiException catch (error) {
      if (error.statusCode != null) rethrow;
      await DBHelper.enqueuePendingOperation(jsonEncode(operation));
      return true;
    }
  }

  Future<bool> _backendReachable() async {
    try {
      await api.request('GET', '/health');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _remoteOrQueue({
    required String operationType,
    required Map<String, dynamic> payload,
    required Future<dynamic> Function() remote,
    String? entityId,
  }) async {
    try {
      await remote();
      return true;
    } on PosApiException catch (error) {
      if (!isHybrid || error.statusCode != null) rethrow;
      _lastRemoteWriteWasQueued = true;
      final operation = {
        'operation_id': const Uuid().v4(),
        'operation_type': operationType,
        'entity_type': operationType,
        'entity_id': entityId,
        'payload': payload,
        'created_at': DateTime.now().toUtc().toIso8601String(),
        'device_id': null,
        'company_id': null,
        'shop_id': NetworkConfiguration.shopId,
        'retry_count': 0,
        'sync_status': 'pending',
        'last_error': null,
      };
      await DBHelper.enqueuePendingOperation(jsonEncode(operation));
      return true;
    }
  }
}
