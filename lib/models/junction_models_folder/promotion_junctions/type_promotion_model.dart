import 'package:pos_mobile/models/abstract_models_folder/someModel_promotion_model.dart';

class TypePromotionModel extends SomeModelPromotionSkeletalModel{
  final int typeId;

  TypePromotionModel({
    required super.id,
    required this.typeId,
    required super.promotionId,
    required super.createTime,
    required super.deleteTime,
    required super.createPersonId,
    required super.deletePersonId,
    required super.activeStatus,
  });

  @override
  TypePromotionModel.fromJson(Map<String, dynamic> jsonData) :
        typeId = jsonData["typeId"],
        super.fromJson(jsonData);

  @override
  Map<String, dynamic> toJson(){
    final Map<String,dynamic> jsonData = super.toJson();
    jsonData["typeId"] = typeId;
    return jsonData;
  }
}