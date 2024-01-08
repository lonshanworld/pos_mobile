import 'package:flutter/material.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/models/deliver_model_folder/delivery_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stockout_history_model.dart';
import 'package:pos_mobile/utils/formula.dart';
import 'package:pos_mobile/widgets/tables_folder/tables_charts_widget.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../feature/historyFilter.dart';

class DailySales extends StatelessWidget {

  final bool showChart;
  const DailySales({
    super.key,
    required this.showChart,
  });

  @override
  Widget build(BuildContext context) {
    final TablesAndCharts tablesAndCharts = TablesAndCharts(context: context);
    final List<StockOutModel> stockOutList = context.watch<TransactionsCubit>().state.activeStockOutList;
    final List<StockOutHistoryModel> stockOutHistoryList = HistoryFilter.filterStockOutHistory(stockOutList);

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
          rows: stockOutHistoryList.reversed.map((e){
            List<StockOutModel> selectedStockOutList = e.stockOutList;
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
              index: stockOutHistoryList.indexOf(e) + 1,
              txt: e.dateTimeTxt,
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
