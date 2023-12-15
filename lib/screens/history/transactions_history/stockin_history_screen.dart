import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/features/historyFilter.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';
import 'package:pos_mobile/widgets/transaction_history_widgets_folder/stockin_history_widget.dart';

import '../../../constants/uiConstants.dart';

class StockInHistoryScreen extends StatelessWidget {
  const StockInHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // List<UniqueItemModel> filterInActiveUniqueItemList (List<UniqueItemModel> dataList){
    //   List<UniqueItemModel> newList = [];
    //   for(int i = 0; i < dataList.length; i++){
    //     if(dataList[i].activeStatus == false && dataList[i].stockOutId != null){
    //       newList.add(dataList[i]);
    //     }
    //   }
    //   return newList;
    // }
    
    final List<StockInModel> stockInList = context.watch<TransactionsCubit>().state.activeStockInList;

    final List<StockInHistoryModel> stockInHistoryList = HistoryFilter.filterStockInHistory(stockInList);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: UIConstants.bigSpace,
        ),
        child: Wrap(
          spacing: UIConstants.bigSpace,
          runSpacing: UIConstants.bigSpace,
          alignment: WrapAlignment.center,
          children: stockInHistoryList.reversed.toList().map((e){

            return StockInHistoryWidget(
                stockInHistoryModel: e,
                showDate: true,
                // itemList: itemList,
                // uniqueItemList: uniqueItemList
            );
          }).toList(),
        ),
      ),
    );
  }
}
