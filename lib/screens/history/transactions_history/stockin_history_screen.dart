import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/features/historyFilter.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';
import 'package:pos_mobile/widgets/transaction_history_widgets_folder/stockin_history_widget.dart';
import 'package:pos_mobile/screens/history/transactions_history/stock_in_export_service.dart';

import '../../../constants/uiConstants.dart';
import '../../../utils/txt_formatters.dart';

class StockInHistoryScreen extends StatefulWidget {
  const StockInHistoryScreen({super.key});

  @override
  State<StockInHistoryScreen> createState() => _StockInHistoryScreenState();
}

class _StockInHistoryScreenState extends State<StockInHistoryScreen> {
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

  List<StockInModel> _filteredStockIns(List<StockInModel> stockIns) {
    final query = _searchController.text.trim().toLowerCase();
    return stockIns.where((stockIn) {
      final matchesCode =
          query.isEmpty || stockIn.code.toLowerCase().contains(query);
      final matchesDate =
          _selectedDate == null ||
          DateUtils.isSameDay(stockIn.createTime, _selectedDate);
      return matchesCode && matchesDate;
    }).toList();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 500) {
      context.read<TransactionsCubit>().loadMoreStockIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.select((TransactionsCubit cubit) => cubit.state);
    final List<StockInModel> stockInList = _filteredStockIns(
      state.activeStockInList,
    );
    final List<StockInHistoryModel> stockInHistoryList =
        HistoryFilter.filterStockInHistory(stockInList);

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
                  labelText: 'Search stock-in code',
                  hintText: 'Enter StockIn-... code',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: () {
                            _searchController.clear();
                            setState(() {});
                          },
                          icon: const Icon(Icons.clear),
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
        Padding(
          padding: const EdgeInsets.fromLTRB(
            UIConstants.mediumSpace,
            UIConstants.smallSpace,
            UIConstants.mediumSpace,
            UIConstants.smallSpace,
          ),
          child: Align(
            alignment: Alignment.centerRight,
            child: OutlinedButton.icon(
              onPressed: () => StockInExportService.requestExport(context),
              icon: const Icon(Icons.download_outlined, size: 18),
              label: const Text('Export Stock-In'),
            ),
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
                stockInHistoryList.length +
                (state.isLoadingMoreStockIn ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == stockInHistoryList.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              final e = stockInHistoryList[index];

              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.bigSpace),
                child: StockInHistoryWidget(
                  stockInHistoryModel: e,
                  showDate: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
