import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/services/pos_repository.dart';
import 'package:pos_mobile/widgets/btns_folder/leadingBackIconBtn.dart';
import 'package:pos_mobile/screens/screen_data_loader.dart';

class TaxSettingsScreen extends StatefulWidget {
  static const String routeName = '/tax_settings';

  const TaxSettingsScreen({super.key});

  @override
  State<TaxSettingsScreen> createState() => _TaxSettingsScreenState();
}

class _TaxSettingsScreenState extends State<TaxSettingsScreen> {
  late final TextEditingController _checkoutTaxController;

  @override
  void initState() {
    super.initState();
    unawaited(loadData());
    _checkoutTaxController = TextEditingController(
      text: context
          .read<ShopInfoCubit>()
          .state
          .checkoutTaxPercentage
          .toString(),
    );
  }

  Future<void> loadData() async {
    await Future.wait([
      ScreenDataLoader.shopInfo(context),
      ScreenDataLoader.items(context),
      ScreenDataLoader.transactions(context),
    ]);
  }

  @override
  void dispose() {
    _checkoutTaxController.dispose();
    super.dispose();
  }

  Future<void> _toggleTax(bool value) async {
    final shopCubit = context.read<ShopInfoCubit>();
    await shopCubit.updateTaxEnabled(value);
    if (!value) {
      await PosRepository.instance.writeWithMode(
        local: LocalPosRepository.clearAllTaxValues,
        remote: PosRepository.instance.resetAllTaxes,
      );
      if (mounted) await context.read<ItemCubit>().reloadItemData();
      if (mounted) await context.read<TransactionsCubit>().reloadList();
    }
  }

  Future<void> _saveCheckoutPercentage(String value) async {
    final percentage = double.tryParse(value.trim());
    if (percentage == null || percentage < 0) return;
    await context.read<ShopInfoCubit>().updateCheckoutTaxPercentage(percentage);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ShopInfoCubit>().state;
    return Scaffold(
      appBar: AppBar(
        leading: const CusLeadingBackIconBtn(),
        title: const Text('Tax Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(UIConstants.bigSpace),
        children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: const Text('Enable Tax'),
            subtitle: const Text('Main control for all tax features'),
            value: state.taxEnabled,
            onChanged: _toggleTax,
          ),
          if (state.taxEnabled) ...[
            const Divider(),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Item-level tax'),
              subtitle: const Text('Allow tax values on individual items'),
              value: state.itemTaxEnabled,
              onChanged: (value) async {
                await context.read<ShopInfoCubit>().updateItemTaxEnabled(value);
                if (!value) {
                  await PosRepository.instance.writeWithMode(
                    local: LocalPosRepository.clearItemTaxValues,
                    remote: PosRepository.instance.resetItemTaxes,
                  );
                  if (mounted) await context.read<ItemCubit>().reloadItemData();
                }
              },
            ),
            SwitchListTile.adaptive(
              contentPadding: EdgeInsets.zero,
              title: const Text('Checkout/order-level tax'),
              subtitle: const Text('Apply tax to the whole checkout order'),
              value: state.checkoutTaxEnabled,
              onChanged: (value) =>
                  context.read<ShopInfoCubit>().updateCheckoutTaxEnabled(value),
            ),
            if (state.checkoutTaxEnabled)
              TextField(
                controller: _checkoutTaxController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Checkout tax percentage',
                  suffixText: '%',
                ),
                onSubmitted: _saveCheckoutPercentage,
                onEditingComplete: () =>
                    _saveCheckoutPercentage(_checkoutTaxController.text),
              ),
          ],
        ],
      ),
    );
  }
}
