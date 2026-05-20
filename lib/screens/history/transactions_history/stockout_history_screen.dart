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

class StockOutHistoryScreen extends StatelessWidget {
  const StockOutHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<StockOutModel> stockOutList = context.watch<TransactionsCubit>().state.activeStockOutList;
    final List<StockOutHistoryModel> stockOutHistoryList = HistoryFilter.filterStockOutHistory(stockOutList);

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(
              vertical: UIConstants.bigSpace,
              horizontal: UIConstants.mediumSpace,
            ),
            itemCount: stockOutHistoryList.length,
            itemBuilder: (context, index) {
              // Since we want reversed, we access from the end
              final reversedIndex = stockOutHistoryList.length - 1 - index;
              final e = stockOutHistoryList[reversedIndex];
              
              List<StockOutModel> selectedStockOutList = e.stockOutList;
              double totalProfit = 0;
              
              for(int a = 0; a < selectedStockOutList.length; a++){
                final List<StockOutItemModel> selectedStockOutItemList = context.read<TransactionsCubit>().getSelectedStockOutItemList(selectedStockOutList[a].id);
                final double totalOrgPrice = CalculationFormula.getItemTotalOriginalPriceForStockOut(selectedStockOutItemList);
                final double finalprice = selectedStockOutList[a].finalTotalPrice;
                final DeliveryModel? deliveryModel = selectedStockOutList[a].deliveryModelId == null ? null : context.read<TransactionsCubit>().getDeliveryModel(selectedStockOutList[a].deliveryModelId!);
                if(deliveryModel != null && deliveryModel.deliveryCharges != null){
                  totalProfit = totalProfit + (finalprice - totalOrgPrice - deliveryModel.deliveryCharges!);
                }else{
                  totalProfit = totalProfit + (finalprice - totalOrgPrice );
                }
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
