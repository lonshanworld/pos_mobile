import 'package:pos_mobile/models/transaction_model_folder/stockin_model_folder/stock_in_model.dart';


class StockInHistoryModel{
  final String dateTxt;
  final List<StockInModel> stockInList;

  StockInHistoryModel({
    required this.dateTxt,
    required this.stockInList,
  });
}