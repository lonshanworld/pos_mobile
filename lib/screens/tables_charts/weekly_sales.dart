import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/features/historyFilter.dart';

import '../../blocs/transactions_bloc/transactions_cubit.dart';
import '../../constants/uiConstants.dart';
import '../../models/deliver_model_folder/delivery_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import '../../models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import '../../utils/formula.dart';
import '../../widgets/tables_folder/tables_charts_widget.dart';

class WeeklySales extends StatelessWidget {

  final bool showCharts;
  const WeeklySales({
    super.key,
    required this.showCharts,
  });

  @override
  Widget build(BuildContext context) {
    final TablesAndCharts tablesAndCharts = TablesAndCharts(context: context);
    final List<StockOutModel> stockOutList = context.watch<TransactionsCubit>().state.activeStockOutList;
    final LinkedHashMap<String, List<StockOutModel>> stockOutWeeklyList = HistoryFilter.filterWeeklyStockOut(stockOutList);
    List<String> keysReversed = stockOutWeeklyList.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: DataTable(
          headingRowColor: MaterialStateProperty.resolveWith((states) {
            return UIConstants.redVioletClr.withOpacity(0.4);
          }),
          columns: [
            tablesAndCharts.tableTitle("No."),
            tablesAndCharts.tableTitle("Date"),
            tablesAndCharts.tableTitle("Original Price"),
            tablesAndCharts.tableTitle("Sell Price"),
            tablesAndCharts.tableTitle("Stock-out Price"),
            tablesAndCharts.tableTitle("Profit"),
          ],
          rows: keysReversed.reversed.map((e){
            List<StockOutModel> selectedStockOutList = stockOutWeeklyList[e] ?? [];
            double totalOrgPrice = 0;
            double totalSellPrice = 0;
            double totalFinalSellPrice = 0;

            for(int a = 0; a < selectedStockOutList.length; a++){
              final List<StockOutItemModel> selectedStockOutItemList = context.read<TransactionsCubit>().getSelectedStockOutItemList(selectedStockOutList[a].id);

              final double orgPrice = CalculationFormula.getItemTotalOriginalPriceForStockOut(selectedStockOutItemList);
              totalOrgPrice = totalOrgPrice + orgPrice;

              final double itemFinalSellPrice = CalculationFormula.getItemTotalFinalSellPriceForStockOut(selectedStockOutItemList);
              totalSellPrice = totalSellPrice + itemFinalSellPrice;

              double finalprice = selectedStockOutList[a].finalTotalPrice;
              final DeliveryModel? deliveryModel = selectedStockOutList[a].deliveryModelId == null ? null : context.read<TransactionsCubit>().getDeliveryModel(selectedStockOutList[a].deliveryModelId!);
              if(deliveryModel != null && deliveryModel.deliveryCharges != null){
                finalprice = finalprice - deliveryModel.deliveryCharges!;
              }
              totalFinalSellPrice = totalFinalSellPrice + finalprice;
            }


            return tablesAndCharts.dataRow(
              index: keysReversed.indexOf(e) + 1,
              txt: e,
              originalPrice: totalOrgPrice,
              sellPrice: totalSellPrice,
              finalSellPrice: totalFinalSellPrice,
              profit: totalFinalSellPrice - totalOrgPrice,
            );
          }).toList(),
        ),
      ),
    );
  }
}
