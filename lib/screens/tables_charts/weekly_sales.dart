import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/features/historyFilter.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/widgets/tables_folder/tables_charts_widget.dart';

class WeeklySales extends StatefulWidget {
  const WeeklySales({super.key});

  @override
  State<WeeklySales> createState() => _WeeklySalesState();
}

class _WeeklySalesState extends State<WeeklySales> {
  int _currentPage = 0;
  static const int _pageSize = 15;

  @override
  Widget build(BuildContext context) {
    final tablesAndCharts = TablesAndCharts(context: context);
    final stockOutList = context.watch<TransactionsCubit>().state.activeStockOutList;
    final LinkedHashMap<String, List<StockOutModel>> weeklyMap =
        HistoryFilter.filterWeeklyStockOut(stockOutList);
    final List<String> allKeys = weeklyMap.keys.toList().reversed.toList();
    final int totalCount = allKeys.length;

    if (totalCount == 0) return _emptyState(context);

    final int totalPages = ((totalCount - 1) ~/ _pageSize) + 1;
    final int safePage = _currentPage.clamp(0, totalPages - 1);
    final int start = safePage * _pageSize;
    final int end = (start + _pageSize).clamp(0, totalCount);
    final List<String> pageKeys = allKeys.sublist(start, end);

    return Column(
      children: [
        _recordsHeader(context, totalCount, safePage, totalPages, start, end),
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: DataTable(
                headingRowColor: WidgetStateProperty.resolveWith(
                    (_) => UIConstants.redVioletClr.withValues(alpha: 0.4)),
                dataRowMinHeight: 48,
                dataRowMaxHeight: 56,
                columns: [
                  tablesAndCharts.tableTitle("No."),
                  tablesAndCharts.tableTitle("Week"),
                  tablesAndCharts.tableTitle("Original Price"),
                  tablesAndCharts.tableTitle("Sell Price"),
                  tablesAndCharts.tableTitle("Stock-out Price"),
                  tablesAndCharts.tableTitle("Profit"),
                ],
                rows: List.generate(pageKeys.length, (i) {
                  final key = pageKeys[i];
                  final List<StockOutModel> selectedList = weeklyMap[key] ?? [];
                  double totalOrgPrice = 0;
                  double totalSellPrice = 0;
                  double totalFinalSellPrice = 0;

                  for (final stockOut in selectedList) {
                    final List<StockOutItemModel> items = context
                        .read<TransactionsCubit>()
                        .getSelectedStockOutItemList(stockOut.id);
                    totalOrgPrice +=
                        CalculationFormula.getItemTotalOriginalPriceForStockOut(items);
                    totalSellPrice +=
                        CalculationFormula.getItemTotalFinalSellPriceForStockOut(items);
                    double finalPrice = stockOut.finalTotalPrice;
                    final DeliveryModel? delivery = stockOut.deliveryModelId == null
                        ? null
                        : context
                            .read<TransactionsCubit>()
                            .getDeliveryModel(stockOut.deliveryModelId!);
                    if (delivery?.deliveryCharges != null) {
                      finalPrice -= delivery!.deliveryCharges!;
                    }
                    totalFinalSellPrice += finalPrice;
                  }

                  return tablesAndCharts.dataRow(
                    index: start + i + 1,
                    txt: key,
                    originalPrice: totalOrgPrice,
                    sellPrice: totalSellPrice,
                    finalSellPrice: totalFinalSellPrice,
                    profit: totalFinalSellPrice - totalOrgPrice,
                    isEven: i.isEven,
                  );
                }),
              ),
            ),
          ),
        ),
        if (totalPages > 1) _paginationRow(safePage, totalPages),
      ],
    );
  }

  Widget _recordsHeader(BuildContext context, int totalCount, int page,
      int totalPages, int start, int end) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(UIConstants.bigSpace, UIConstants.smallSpace,
          UIConstants.bigSpace, UIConstants.smallSpace),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.mediumSpace, vertical: 3),
            decoration: BoxDecoration(
              color: UIConstants.redVioletClr.withValues(alpha: 0.1),
              borderRadius: UIConstants.smallBorderRadius,
            ),
            child: Text(
              "$totalCount week${totalCount == 1 ? '' : 's'}",
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: UIConstants.redVioletClr, fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            "Showing ${start + 1}–$end",
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _paginationRow(int page, int totalPages) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: UIConstants.mediumSpace, horizontal: UIConstants.bigSpace),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded),
            onPressed:
                page > 0 ? () => setState(() => _currentPage = page - 1) : null,
            color: UIConstants.redVioletClr,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: UIConstants.mediumSpace, vertical: UIConstants.smallSpace),
            decoration: BoxDecoration(
              border: Border.all(
                  color: UIConstants.redVioletClr.withValues(alpha: 0.3)),
              borderRadius: UIConstants.smallBorderRadius,
            ),
            child: Text("${page + 1} / $totalPages",
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded),
            onPressed: page < totalPages - 1
                ? () => setState(() => _currentPage = page + 1)
                : null,
            color: UIConstants.redVioletClr,
          ),
        ],
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.bar_chart_outlined,
              size: 64, color: Colors.grey.withValues(alpha: 0.4)),
          const SizedBox(height: UIConstants.mediumSpace),
          Text("No weekly sales data yet",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}

