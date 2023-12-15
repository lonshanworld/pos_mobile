import 'package:pos_mobile/models/transaction_model_folder/stockout_model_folder/stock_out_model.dart';

class StockOutHistoryModel{
  final String dateTimeTxt;
  final List<StockOutModel> stockOutList;

  StockOutHistoryModel({
    required this.dateTimeTxt,
    required this.stockOutList,
  });
}