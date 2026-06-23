import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';

import 'item_model_folder/item_model.dart';

class ItemModelWithUniqueItemCountWithPromotion{
  final ItemModel itemModel;
  final int count;
  final PromotionModel? promotion;
  /// Weighted average from unique units in cart (falls back to item catalog if zero).
  final double avgOriginalPrice;
  final double avgSellPrice;
  final double avgFinalSellPrice;
  final double lineTotal;

  ItemModelWithUniqueItemCountWithPromotion({
    required this.itemModel,
    required this.count,
    required this.promotion,
    required this.avgOriginalPrice,
    required this.avgSellPrice,
    required this.avgFinalSellPrice,
    required this.lineTotal,
  });
}