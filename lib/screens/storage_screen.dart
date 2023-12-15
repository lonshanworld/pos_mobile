import "package:flutter/material.dart";
import "package:pos_mobile/screens/transaction/stockIn/stockin_screen.dart";

class StorageScreen extends StatelessWidget {
  static const String routeName = "/storagescreen";

  const StorageScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return const StockInScreen(isStorage: true);
  }
}
