import 'package:pos_mobile/models/abstract_models_folder/item_info_model.dart';

class ModuleComponentItemModel extends ItemInfoSkeletalModel{
  final String? name;
  final String? parentId;
  final int? uniqueId; // foreign key
  final int? componentCount;
  final double originalPrice;
  final double profitPrice;
  final double taxPercentage;
  final int disposePersonId; //foreign key
  final int? stockInId; // foreign key
  final int? stockOutId; // foreign key
  final String? code;

  ModuleComponentItemModel({
    required this.name,
    required this.parentId,
    required this.uniqueId,
    required this.componentCount,
    required this.originalPrice,
    required this.profitPrice,
    required this.taxPercentage,
    required this.disposePersonId,
    required this.stockInId,
    required this.stockOutId,
    required this.code,
    required super.id,
    required super.createPersonId,
    required super.deletePersonId,
    required super.createTime,
    required super.deleteTime,
    required super.lastUpdateTime,
    required super.activeStatus,
  });

  @override
  ModuleComponentItemModel.fromJson(Map<String, dynamic>jsonData):
      name = jsonData["name"],
      parentId = jsonData["parentId"],
      uniqueId = jsonData["uniqueId"],
      componentCount = jsonData["componentCount"],
      originalPrice = jsonData["originalPrice"],
      profitPrice = jsonData["profitPrice"],
      taxPercentage = jsonData["taxPercentage"],
      disposePersonId = jsonData["disposePersonId"],
      stockInId = jsonData["stockInId"],
      stockOutId = jsonData["stockOutId"],
      code = jsonData["code"],
      super.fromJson(jsonData);

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> jsonData = super.toJson();
    jsonData["name"] = name;
    jsonData["parentId"] = parentId;
    jsonData["uniqueId"] = uniqueId;
    jsonData["componentCount"] = componentCount;
    jsonData["originalPrice"] = originalPrice;
    jsonData["profitPrice"] = profitPrice;
    jsonData["taxPercentage"] = taxPercentage;
    jsonData["disposePersonId"] = disposePersonId;
    jsonData["stockInId"] = stockInId;
    jsonData["stockOutId"] = stockOutId;
    jsonData["code"] = code;
    return jsonData;
  }
}