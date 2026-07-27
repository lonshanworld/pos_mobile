import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/history_bloc/history_cubit.dart';
import '../blocs/item_bloc/item_cubit.dart';
import '../blocs/promotion_bloc/promotion_cubit.dart';
import '../blocs/transactions_bloc/transactions_cubit.dart';
import '../blocs/shop_info_bloc/shop_info_cubit.dart';
import '../blocs/userData_bloc/user_data_cubit.dart';

/// Reloads the shared business-data Cubits after authentication or sync.
///
/// These Cubits are app-scoped, so they must not fetch remote data from their
/// constructors: constructors run before the user has logged in.
class PosDataReloadService {
  PosDataReloadService._();

  static Future<void> reloadAll(BuildContext context) async {
    await Future.wait([
      _safeReload('items', context.read<ItemCubit>().reloadItemData),
      _safeReload('transactions', context.read<TransactionsCubit>().reloadList),
      _safeReload(
        'promotions',
        context.read<PromotionCubit>().reloadAllPromotion,
      ),
      _safeReload('history', context.read<HistoryCubit>().reloadHistoryList),
      _safeReload(
        'settings',
        context.read<ShopInfoCubit>().reloadRemoteSettings,
      ),
      _safeReload('users', context.read<UserDataCubit>().initData),
    ]);
  }

  static Future<void> _safeReload(
    String name,
    Future<void> Function() reload,
  ) async {
    try {
      await reload();
    } catch (error) {
      // A failed secondary refresh must not undo a successful login or sync.
      debugPrint('Failed to reload $name data: $error');
    }
  }
}
