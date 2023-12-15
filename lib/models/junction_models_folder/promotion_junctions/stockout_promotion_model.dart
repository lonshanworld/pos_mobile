class StockOutPromotionModel{
  final int stockOutId;
  final int promotionId;

  StockOutPromotionModel({
    required this.stockOutId,
    required this.promotionId,
  });

  StockOutPromotionModel.fromJson(Map<String, dynamic> jsonData) :
      stockOutId = jsonData["stockOutId"],
      promotionId = jsonData["promotionId"];

  Map<String, dynamic> toJson()=>{
    "stockOutId" : stockOutId,
    "promotionId" : promotionId,
  };
}