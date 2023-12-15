import 'package:flutter/material.dart';

import 'package:pos_mobile/widgets/tables_folder/cusTableRow.dart';


class StockOutItemTable extends StatelessWidget {

  final String name;
  final String count;
  final String originalPrice;
  final String finalSellPrice;
  final String profit;
  final String totalProfit;
  const StockOutItemTable({
    super.key,
    required this.name,
    required this.count,
    required this.originalPrice,
    required this.finalSellPrice,
    required this.profit,
    required this.totalProfit,
  });

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        Table(
          border: TableBorder.all(
            color: Colors.grey,
            width: 0.5,
          ),
          columnWidths: const {
            0 : FlexColumnWidth(8),
            1 : FlexColumnWidth(2),
            2 : FlexColumnWidth(5),
          },
          children: [
            CusTableRow.tableRowWithThreeStringsForStockOutHistory(name, count, originalPrice,context)
          ],
        ),
        Table(
          border: TableBorder.all(
              color: Colors.grey,
              width: 0.5
          ),
          columnWidths: const {
            0 : FlexColumnWidth(1.3),
            1 : FlexColumnWidth(1),
            2 : FlexColumnWidth(1.3),
          },
          children: [
            CusTableRow.tableRowWithThreeStringsForStockOutHistory(finalSellPrice, profit, totalProfit,context),
          ],
        ),
      ],
    );
  }
}
