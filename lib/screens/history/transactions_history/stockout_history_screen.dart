import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/features/historyFilter.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stockout_history_model.dart';
import 'package:pos_mobile/widgets/transaction_history_widgets_folder/stockout_history_widget.dart';

import '../../../constants/uiConstants.dart';
import '../../../utils/formula.dart';

class StockOutHistoryScreen extends StatefulWidget {
  const StockOutHistoryScreen({super.key});

  @override
  State<StockOutHistoryScreen> createState() => _StockOutHistoryScreenState();
}

class _StockOutHistoryScreenState extends State<StockOutHistoryScreen> {
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
      context.read<TransactionsCubit>().loadMoreStockOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TransactionsCubit>().state;
    final List<StockOutModel> stockOutList = state.activeStockOutList;
    final List<StockOutHistoryModel> stockOutHistoryList = HistoryFilter.filterStockOutHistory(stockOutList);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.bigSpace,
              horizontal: UIConstants.mediumSpace,
            ),
            itemCount: stockOutHistoryList.length + (state.isLoadingMoreStockOut ? 1 : 0),
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
              
              for(int a = 0; a < selectedStockOutList.length; a++){
                final StockOutModel stockOut = selectedStockOutList[a];
                final List<StockOutItemModel> selectedStockOutItemList = context.read<TransactionsCubit>().getSelectedStockOutItemList(stockOut.id);
                
                final double totalOrgPrice = CalculationFormula.getItemTotalOriginalPriceForStockOut(selectedStockOutItemList);
                final double totalItemFinalSellPrices = CalculationFormula.getItemTotalFinalSellPriceForStockOut(selectedStockOutItemList);
                
                final double finalprice = stockOut.finalTotalPrice;
                final double orderTax = CalculationFormula.getPercentageToMMK(totalItemFinalSellPrices, stockOut.taxPercentage ?? 0);
                
                final DeliveryModel? deliveryModel = stockOut.deliveryModelId == null ? null : context.read<TransactionsCubit>().getDeliveryModel(stockOut.deliveryModelId!);
                final double deliCharges = deliveryModel?.deliveryCharges ?? 0;
                
                // Profit = Final Collected - Delivery - OrderTax - Original Cost
                totalProfit = totalProfit + (finalprice - deliCharges - orderTax - totalOrgPrice);
              }
              
              return Padding(
                padding: const EdgeInsets.only(bottom: UIConstants.bigSpace),
                child: StockOutHistoryWidget(historyModel: e, totalProfit: totalProfit),
              );
            },
          ),
        ),
      ],
    );
  }
}
