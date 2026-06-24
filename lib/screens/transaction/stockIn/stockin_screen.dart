import 'package:flutter/material.dart';
import 'package:pos_mobile/screens/transaction/stockIn/item/item_catalog_screen.dart';

class StockInScreen extends StatelessWidget {
  static const String routeName = "/stockinscreen";

  final bool isStorage;
  const StockInScreen({
    super.key,
    required this.isStorage,
  });

  @override
  Widget build(BuildContext context) {
    return ItemCatalogScreen(isStorage: isStorage);
  }
}
