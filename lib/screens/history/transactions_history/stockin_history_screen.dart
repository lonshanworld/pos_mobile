import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/features/historyFilter.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';
import 'package:pos_mobile/widgets/transaction_history_widgets_folder/stockin_history_widget.dart';

import '../../../constants/uiConstants.dart';

class StockInHistoryScreen extends StatefulWidget {
  const StockInHistoryScreen({super.key});

  @override
  State<StockInHistoryScreen> createState() => _StockInHistoryScreenState();
}

class _StockInHistoryScreenState extends State<StockInHistoryScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionsCubit>().loadMoreStockIn();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionsCubit>().state;
    final List<StockInModel> stockInList = state.activeStockInList;
    final List<StockInHistoryModel> stockInHistoryList = HistoryFilter.filterStockInHistory(stockInList);

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        vertical: UIConstants.bigSpace,
        horizontal: UIConstants.mediumSpace,
      ),
      itemCount: stockInHistoryList.length + (state.isLoadingMoreStockIn ? 1 : 0),
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
    );
  }
}
