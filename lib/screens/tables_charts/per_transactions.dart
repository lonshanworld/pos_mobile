import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/features/historyFilter.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_model.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stockout_history_model.dart';
import 'package:pos_mobile/screens/history/transactions_history/merchant_order_detail_sheet.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';
import 'package:pos_mobile/widgets/tables_folder/tables_charts_widget.dart';

class PerTransactions extends StatefulWidget {
  const PerTransactions({super.key});

  @override
  State<PerTransactions> createState() => _PerTransactionsState();
}

class _PerTransactionsState extends State<PerTransactions> {
  int _currentPage = 0;
  static const int _pageSize = 15;

  @override
  Widget build(BuildContext context) {
    final tablesAndCharts = TablesAndCharts(context: context);
    final stockOutList = context.watch<TransactionsCubit>().state.activeStockOutList;
    final List<StockOutHistoryModel> allRows =
        HistoryFilter.filterStockOutHistory(stockOutList);
    final List<StockOutModel> allTransactions = allRows
        .expand((history) => history.stockOutList)
        .toList()
      ..sort((left, right) => right.createTime.compareTo(left.createTime));
    final int totalCount = allTransactions.length;

    if (totalCount == 0) return _emptyState(context);

    final int totalPages = ((totalCount - 1) ~/ _pageSize) + 1;
    final int safePage = _currentPage.clamp(0, totalPages - 1);
    final int start = safePage * _pageSize;
    final int end = (start + _pageSize).clamp(0, totalCount);
    final List<StockOutModel> pageRows = allTransactions.sublist(start, end);
    final List<ItemModel> allItemModelList = [
      ...context.read<ItemCubit>().state.activeItemList,
      ...context.read<ItemCubit>().state.inActiveItemList,
    ];

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
                dataRowMinHeight: 36,
                dataRowMaxHeight: 72,
                horizontalMargin: 8,
                columnSpacing: 12,
                columns: [
                  tablesAndCharts.tableTitle("No."),
                  tablesAndCharts.tableTitle("Date"),
                  tablesAndCharts.tableTitle("Item Name"),
                  tablesAndCharts.tableTitle("Original Price"),
                  tablesAndCharts.tableTitle("Sell Price"),
                  tablesAndCharts.tableTitle("Final Sell Price"),
                  tablesAndCharts.tableTitle("Profit"),
                  tablesAndCharts.tableTitle("Action"),
                ],
                rows: List.generate(pageRows.length, (index) {
                  final transaction = pageRows[index];
                  final List<StockOutItemModel> selectedStockOutItemList =
                      context
                          .read<TransactionsCubit>()
                          .getSelectedStockOutItemList(transaction.id);

                  final List<String> itemNames = [];
                  final List<String> originalPrices = [];
                  final List<String> sellPrices = [];
                  double totalOrgPrice = 0;
                  double totalFinalSellPrices = 0;

                  for (final item in selectedStockOutItemList) {
                    final ItemModel? itemModel = allItemModelList.firstWhereOrNull(
                      (element) => element.id == item.itemId,
                    );
                    itemNames.add(itemModel?.name ?? "Unknown");
                    originalPrices.add(
                      TablesAndCharts.formatNum(item.originalPrice * item.count),
                    );
                    sellPrices.add(
                      TablesAndCharts.formatNum(item.sellPrice * item.count),
                    );
                    totalOrgPrice += item.originalPrice * item.count;
                    totalFinalSellPrices += item.finalSellPrice * item.count;
                  }

                  final DeliveryModel? deliveryModel = transaction.deliveryModelId == null
                      ? null
                      : context.read<TransactionsCubit>().getDeliveryModel(transaction.deliveryModelId!);
                  final double deliCharges = deliveryModel?.deliveryCharges ?? 0;
                  final double orderTax = CalculationFormula.getPercentageToMMK(
                    totalFinalSellPrices,
                    transaction.taxPercentage ?? 0,
                  );
                  final double finalSellPrice = transaction.finalTotalPrice;
                  final double profit = finalSellPrice - deliCharges - orderTax - totalOrgPrice;

                  return tablesAndCharts.transactionDataRow(
                    index: start + index + 1,
                    dateTxt: TextFormatters.getDateTime(transaction.createTime),
                    itemNames: itemNames.isEmpty ? const ["-"] : itemNames,
                    originalPrices:
                        originalPrices.isEmpty ? const ["-"] : originalPrices,
                    sellPrices: sellPrices.isEmpty ? const ["-"] : sellPrices,
                    finalSellPrice: TablesAndCharts.formatNum(finalSellPrice),
                    profit: TablesAndCharts.formatNum(profit),
                    isEven: index.isEven,
                    maxVisibleValues: 2,
                    onCheckDetail: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => MerchantOrderDetailSheet(
                            stockOutModel: transaction,
                          ),
                        ),
                      );
                    },
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
              "$totalCount record${totalCount == 1 ? '' : 's'}",
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
          Text("No daily sales data yet",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey)),
        ],
      ),
    );
  }
}
