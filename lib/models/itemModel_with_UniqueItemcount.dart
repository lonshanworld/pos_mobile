import 'package:pos_mobile/models/promotion_model_folder/promotion_model.dart';

import 'item_model_folder/item_model.dart';

class ItemModelWithUniqueItemCountWithPromotion{
  final ItemModel itemModel;
  final int count;
  final PromotionModel? promotion;

  ItemModelWithUniqueItemCountWithPromotion({
    required this.itemModel,
    required this.count,
    required this.promotion,
  });
}