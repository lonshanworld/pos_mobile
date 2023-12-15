import '../models/transaction_model_folder/stockout_model_folder/stock_out_item_model.dart';

class CalculationFormula{
  static double getItemSellPrice({
    required double originalPrice,
    required double profitPrice,

    required double taxPercentage,
  }){
    double sellPrice = originalPrice + profitPrice;
    double taxPrice = (sellPrice / 100) * taxPercentage;


    return (sellPrice + taxPrice);
  }

  static double getItemProfitPrice({
    required double originalPrice,
    required double sellPrice,
  }) {
    return sellPrice - originalPrice;
  }

  // static double getStockOutTaxPrice({
  //   required double totalPrice,
  //   required double taxPercentage,
  // }){
  //   return (totalPrice / 100) * taxPercentage;
  //   return getPercentageToMMK(totalPrice, taxPercentage)
  // }

  static double getFinalStockOutTotalPriceWithDeliCharges({
    required double totalPrice,
    required double taxPrice,
    required double promotionPrice,
    required double additionalPromotionPrice,
    required double promotionPercentage,
    required double deliCharges,
  }){
    double promotionPercentagePrice = getPercentageToMMK(totalPrice + taxPrice, promotionPercentage);
    return (totalPrice + taxPrice + deliCharges ) - (promotionPrice + additionalPromotionPrice + promotionPercentagePrice);
  }

  static double getFinalStockOutTotalPriceWithoutDeliCharges({
    required double totalPrice,
    required double taxPrice,
    required double promotionPrice,
    // required double deliCharges,
  }){
    return (totalPrice + taxPrice ) - promotionPrice;
  }

  static double getTotalPriceForStockOutHistory(List<StockOutItemModel> itemList){
    double data = 0;
    for(int a = 0; a < itemList.length; a++){
      double calculatedData = itemList[a].finalSellPrice * itemList[a].count;
      data = data + calculatedData;
    }
    return data;
  }

  static double getPercentageToMMK(double price, double percentage){
    return (price/ 100) * percentage;
  }

  static double getItemTotalOriginalPriceForStockOut(List<StockOutItemModel> dataList){
    double value = 0;
    for(int i = 0; i < dataList.length; i++){
      value = value + (dataList[i].count * dataList[i].originalPrice);
    }
    return value;
  }

  static double getItemTotalFinalSellPriceForStockOut(List<StockOutItemModel> dataList){
    double value = 0;
    for(int i = 0; i < dataList.length; i++){
      value = value + (dataList[i].count * dataList[i].finalSellPrice);
    }
    return value;
  }

  static double getItemAfterPromotionPrice({
    required double sellPrice,
    required double? promotionPercentage,
    required double? promotionPrice,
  }){
    if(promotionPercentage != null){
      return sellPrice - getPercentageToMMK(sellPrice, promotionPercentage);
    }else if(promotionPrice != null){
      return sellPrice - promotionPrice;
    }else{
      return sellPrice;
    }
  }
}