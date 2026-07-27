import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/history_bloc/history_cubit.dart';
import '../blocs/item_bloc/item_cubit.dart';
import '../blocs/promotion_bloc/promotion_cubit.dart';
import '../blocs/shop_info_bloc/shop_info_cubit.dart';
import '../blocs/transactions_bloc/transactions_cubit.dart';
import '../blocs/userData_bloc/user_data_cubit.dart';

/// Starts the API/local-data read required by a screen.
///
/// The PageView builds more than one page at startup. Keeping an in-flight
/// request per Cubit prevents those screens from making the same request
/// repeatedly while still allowing a later visit to refresh the data.
class ScreenDataLoader {
  ScreenDataLoader._();

  static Future<void>? _itemsRequest;
  static Future<void>? _transactionsRequest;
  static Future<void>? _promotionsRequest;
  static Future<void>? _historyRequest;
  static Future<void>? _usersRequest;
  static Future<void>? _shopInfoRequest;
  static Future<void>? _allRequest;

  static Future<void> items(BuildContext context) {
    final activeRequest = _itemsRequest;
    if (activeRequest != null) return activeRequest;

    final request = _safeLoad(
      'items',
      context.read<ItemCubit>().reloadItemData,
    );
    _itemsRequest = request;
    request.whenComplete(() {
      if (identical(_itemsRequest, request)) _itemsRequest = null;
    });
    return request;
  }

  static Future<void> transactions(BuildContext context) {
    final activeRequest = _transactionsRequest;
    if (activeRequest != null) return activeRequest;

    final request = _safeLoad(
      'transactions',
      context.read<TransactionsCubit>().reloadList,
    );
    _transactionsRequest = request;
    request.whenComplete(() {
      if (identical(_transactionsRequest, request)) {
        _transactionsRequest = null;
      }
    });
    return request;
  }

  static Future<void> promotions(BuildContext context) {
    final activeRequest = _promotionsRequest;
    if (activeRequest != null) return activeRequest;

    final request = _safeLoad(
      'promotions',
      context.read<PromotionCubit>().reloadAllPromotion,
    );
    _promotionsRequest = request;
    request.whenComplete(() {
      if (identical(_promotionsRequest, request)) _promotionsRequest = null;
    });
    return request;
  }

  static Future<void> history(BuildContext context) {
    final activeRequest = _historyRequest;
    if (activeRequest != null) return activeRequest;

    final request = _safeLoad(
      'history',
      context.read<HistoryCubit>().reloadHistoryList,
    );
    _historyRequest = request;
    request.whenComplete(() {
      if (identical(_historyRequest, request)) _historyRequest = null;
    });
    return request;
  }

  static Future<void> users(BuildContext context) {
    final activeRequest = _usersRequest;
    if (activeRequest != null) return activeRequest;

    final request = _safeLoad('users', context.read<UserDataCubit>().initData);
    _usersRequest = request;
    request.whenComplete(() {
      if (identical(_usersRequest, request)) _usersRequest = null;
    });
    return request;
  }

  static Future<void> shopInfo(BuildContext context) {
    final activeRequest = _shopInfoRequest;
    if (activeRequest != null) return activeRequest;

    final request = _safeLoad(
      'shop settings',
      context.read<ShopInfoCubit>().reloadRemoteSettings,
    );
    _shopInfoRequest = request;
    request.whenComplete(() {
      if (identical(_shopInfoRequest, request)) _shopInfoRequest = null;
    });
    return request;
  }

  static Future<void> all(BuildContext context) {
    final activeRequest = _allRequest;
    if (activeRequest != null) return activeRequest;

    final request = Future.wait<void>([
      items(context),
      transactions(context),
      promotions(context),
      history(context),
      shopInfo(context),
      users(context),
    ]);
    _allRequest = request;
    request.whenComplete(() {
      if (identical(_allRequest, request)) _allRequest = null;
    });
    return request;
  }

  static Future<void> _safeLoad(
    String name,
    Future<void> Function() load,
  ) async {
    try {
      await load();
    } catch (error, stackTrace) {
      debugPrint('Failed to load $name data: $error\n$stackTrace');
    }
  }
}
