import 'package:pos_mobile/models/abstract_models_folder/someModel_promotion_model.dart';

class ItemPromotionModel extends SomeModelPromotionSkeletalModel{
  final int itemId;

  ItemPromotionModel({
    required super.id,
    required this.itemId,
    required super.promotionId,
    required super.createTime,
    required super.deleteTime,
    required super.createPersonId,
    required super.deletePersonId,
    required super.activeStatus,
  });

  @override
  ItemPromotionModel.fromJson(Map<String, dynamic> jsonData) :
      itemId = jsonData["itemId"],
      super.fromJson(jsonData);

  @override
  Map<String, dynamic> toJson(){
    final Map<String,dynamic> jsonData = super.toJson();
    jsonData["itemId"] = itemId;
    return jsonData;
  }
}