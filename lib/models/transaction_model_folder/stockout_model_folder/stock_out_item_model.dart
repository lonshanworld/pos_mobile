

class StockOutItemModel{
  final int id;
  final int itemId; // foreign key
  final int stockOutId; // foreign key
  final int count;
  final double originalPrice;
  final double sellPrice;
  final double finalSellPrice;

  StockOutItemModel({
    required this.id,
    required this.itemId,
    required this.stockOutId,
    required this.count,
    required this.originalPrice,
    required this.sellPrice,
    required this.finalSellPrice,
  });

  StockOutItemModel.fromJson(Map<String, dynamic> jsonData) :
    id = jsonData["id"],
    itemId = jsonData["itemId"],
    stockOutId = jsonData["stockOutId"],
    count = jsonData["count"],
    originalPrice = jsonData["originalPrice"],
    sellPrice = jsonData["sellPrice"],
    finalSellPrice = jsonData["finalSellPrice"];

  Map<String, dynamic>toJson()=>{
    "id" : id,
    "itemId" : itemId,
    "stockOutId" : stockOutId,
    "count" : count,
    "originalPrice" : originalPrice,
    "sellPrice" : sellPrice,
    "finalSellPrice" : finalSellPrice,
  };
}