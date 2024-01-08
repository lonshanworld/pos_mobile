import 'dart:collection';

import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';
import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stockin_history_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';
import 'package:pos_mobile/utils/txt_formatters.dart';

import '../models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';
import '../models/transaction_model_folder/stockout_model_folder/stockout_history_model.dart';

class HistoryFilter{
  static List<StockOutHistoryModel> filterStockOutHistory(List<StockOutModel> dataList ){
    // cusDebugPrint("start filter");
    List<String> dateList = [];
    List<StockOutHistoryModel> historyList = [];
    for(int i = 0; i < dataList.length; i++){
      String itemdateTime = TextFormatters.getDate(dataList[i].createTime);
      if(!dateList.contains(itemdateTime)){
        dateList.add(itemdateTime);
        StockOutHistoryModel data = StockOutHistoryModel(
          dateTimeTxt: itemdateTime,
          stockOutList: [dataList[i]],
        );
        historyList.add(data);
      }else{
        for(int j=0; j< historyList.length; j++){
          if(historyList[j].dateTimeTxt == itemdateTime){
            historyList[j].stockOutList.add(dataList[i]);
          }
        }
      }
    }
    return historyList;
  }

  static List<StockInHistoryModel> filterStockInHistory(List<StockInModel> dataList){

    List<String> dateList = [];
    List<StockInHistoryModel> historyList = [];
    for(int j = 0; j < dataList.length; j++){
      String itemDateTime = TextFormatters.getDate(dataList[j].createTime);
      if(!dateList.contains(itemDateTime)){
        dateList.add(itemDateTime);
        StockInHistoryModel data = StockInHistoryModel(
            dateTxt: itemDateTime, 
            stockInList: [dataList[j]]
        );
        historyList.add(data);
      }else{
        for(int k = 0; k < historyList.length; k++){
          if(historyList[k].dateTxt == itemDateTime){
            historyList[k].stockInList.add(dataList[j]);
          }
        }
      }
    }

    return historyList;
  }

  static LinkedHashMap<String, List<StockOutModel>> filterWeeklyStockOut(List<StockOutModel> dataList){
    LinkedHashMap<String, List<StockOutModel>> groupedDates = LinkedHashMap.from({});
    for(int a = 0; a < dataList.length; a++){
      String dateStr = TextFormatters.getDate(dataList[a].createTime);
      DateTime dateTime = TextFormatters.reverseDate(dateStr);
      // cusDebugPrint(dateTime);
      DateTime weekStart = dateTime.subtract(Duration(days: dateTime.weekday - 1));

      // Calculate the end of the week (Sunday)
      DateTime weekEnd = weekStart.add(const Duration(days: 6));

      // Format the week range as a string
      String weekKey = "${TextFormatters.getDate(weekStart)}\n${TextFormatters.getDate(weekEnd)}";

      // Add the date to the corresponding week
      groupedDates.putIfAbsent(weekKey, () => []);
      groupedDates[weekKey]!.add(dataList[a]);
    }
    cusDebugPrint(groupedDates);
    return groupedDates;
    // groupedDates.forEach((key, value) {
    //   int index = groupedDates.keys.toList().indexOf(key);
    //   cusDebugPrint(index);
    // });
    // cusDebugPrint(groupedDates);
  }

  static LinkedHashMap<String, List<StockOutModel>> filterMonthlyStockOut(List<StockOutModel> dataList){
    LinkedHashMap<String, List<StockOutModel>> groupedDates = LinkedHashMap.from({});
    for(int a = 0; a < dataList.length; a++){
      String dateStr = TextFormatters.getDate(dataList[a].createTime);
      DateTime dateTime = TextFormatters.reverseDate(dateStr);

      String monthKey = TextFormatters.getMonthAndYear(dateTime);

      // Add the date to the corresponding week
      groupedDates.putIfAbsent(monthKey, () => []);
      groupedDates[monthKey]!.add(dataList[a]);
    }
    cusDebugPrint(groupedDates);
    return groupedDates;
  }
}