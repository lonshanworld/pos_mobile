part of 'promotion_cubit.dart';

@immutable
abstract class PromotionState {
  final List<PromotionModel> activePromotionList;
  final List<PromotionModel> inActivePromotionList;
  final List<ItemPromotionModel> activeItemPromotionList;
  final List<ItemPromotionModel> inActiveItemPromotionList;
  final List<StockOutPromotionModel> stockOutPromotionList;
  const PromotionState({
    required this.activePromotionList,
    required this.inActivePromotionList,
    required this.activeItemPromotionList,
    required this.inActiveItemPromotionList,
    required this.stockOutPromotionList,
  });
  
}

class PromotionData extends PromotionState {
  const PromotionData({required super.activePromotionList, required super.inActivePromotionList, required super.activeItemPromotionList, required super.inActiveItemPromotionList, required super.stockOutPromotionList});
}
