import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/features/historyFilter.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stockout_history_model.dart';
import 'package:pos_mobile/widgets/transaction_history_widgets_folder/stockout_history_widget.dart';
import 'package:pos_mobile/screens/barcode_scanner_screen.dart';

import '../../../constants/uiConstants.dart';
import '../../../utils/formula.dart';
import '../../../utils/txt_formatters.dart';

class StockOutHistoryScreen extends StatefulWidget {
  const StockOutHistoryScreen({super.key});

  @override
  State<StockOutHistoryScreen> createState() => _StockOutHistoryScreenState();
}

class _StockOutHistoryScreenState extends State<StockOutHistoryScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null && mounted) {
      setState(() => _selectedDate = pickedDate);
    }
  }

  List<StockOutModel> _filteredStockOuts(List<StockOutModel> stockOuts) {
    final query = _searchController.text.trim().toLowerCase();
    return stockOuts.where((stockOut) {
      final matchesCode =
          query.isEmpty || stockOut.code.toLowerCase().contains(query);
      final matchesDate =
          _selectedDate == null ||
          DateUtils.isSameDay(stockOut.createTime, _selectedDate);
      return matchesCode && matchesDate;
    }).toList();
  }

  Future<void> _scanStockOutCode() async {
    final scannedCode = await Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const BarcodeScannerScreen()),
    );
    if (!mounted || scannedCode == null || scannedCode.trim().isEmpty) return;

    final normalizedCode = scannedCode.trim();
    final stockOut = context
        .read<TransactionsCubit>()
        .state
        .activeStockOutList
        .where(
          (item) => item.code.toLowerCase() == normalizedCode.toLowerCase(),
        )
        .firstOrNull;
    if (stockOut == null) {
      _searchController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('The QR code is not valid or was not found.'),
        ),
      );
      return;
    }

    _searchController.text = stockOut.code;
    setState(() {});
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      context.read<TransactionsCubit>().loadMoreStockOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.select((TransactionsCubit cubit) => cubit.state);
    final List<StockOutModel> stockOutList = _filteredStockOuts(
      state.activeStockOutList,
    );
    final List<StockOutHistoryModel> stockOutHistoryList =
        HistoryFilter.filterStockOutHistory(stockOutList);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UIConstants.mediumSpace,
            UIConstants.smallSpace,
            UIConstants.mediumSpace,
            0,
          ),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  labelText: 'Search stock-out code',
                  hintText: 'Enter StockOut-... code',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_searchController.text.isNotEmpty)
                        IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
                        ),
                      IconButton(
                        tooltip: 'Scan stock-out QR code',
                        onPressed: _scanStockOutCode,
                        icon: const Icon(Icons.qr_code_scanner),
                      ),
                    ],
                  ),
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: UIConstants.smallSpace),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month),
                      label: Text(
                        _selectedDate == null
                            ? 'Filter by date'
                            : TextFormatters.getDate(_selectedDate),
                      ),
                    ),
                  ),
                  if (_selectedDate != null) ...[
                    const SizedBox(width: UIConstants.smallSpace),
                    IconButton(
                      tooltip: 'Clear date filter',
                      onPressed: () => setState(() => _selectedDate = null),
                      icon: const Icon(Icons.clear),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.bigSpace,
              horizontal: UIConstants.mediumSpace,
            ),
            itemCount:
                stockOutHistoryList.length +
                (state.isLoadingMoreStockOut ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == stockOutHistoryList.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final e = stockOutHistoryList[index];

              List<StockOutModel> selectedStockOutList = e.stockOutList;
              double totalProfit = 0;

              for (int a = 0; a < selectedStockOutList.length; a++) {
                final StockOutModel stockOut = selectedStockOutList[a];
                final List<StockOutItemModel> selectedStockOutItemList = context
                    .read<TransactionsCubit>()
                    .getSelectedStockOutItemList(stockOut.id);

                final double totalOrgPrice =
                    CalculationFormula.getItemTotalOriginalPriceForStockOut(
                      selectedStockOutItemList,
                    );
                final double totalItemFinalSellPrices =
                    CalculationFormula.getItemTotalFinalSellPriceForStockOut(
                      selectedStockOutItemList,
                    );

                final double finalprice = stockOut.finalTotalPrice;
                final double orderTax = CalculationFormula.getPercentageToMMK(
                  totalItemFinalSellPrices,
                  stockOut.taxPercentage ?? 0,
                );

                final DeliveryModel? deliveryModel =
                    stockOut.deliveryModelId == null
                    ? null
                    : context.read<TransactionsCubit>().getDeliveryModel(
                        stockOut.deliveryModelId!,
                      );
                final double deliCharges = deliveryModel?.deliveryCharges ?? 0;

                // Profit = Final Collected - Delivery - OrderTax - Original Cost
                totalProfit =
                    totalProfit +
                    (finalprice - deliCharges - orderTax - totalOrgPrice);
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.bigSpace),
                child: StockOutHistoryWidget(
                  historyModel: e,
                  totalProfit: totalProfit,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
