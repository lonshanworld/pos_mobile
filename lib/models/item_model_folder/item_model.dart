import "package:flutter/material.dart";
import "package:pos_mobile/models/abstract_models_folder/item_info_model.dart";

class ItemModel extends ItemInfoSkeletalModel{
  // final int id;
  final int typeId; // NOTE : foreign key
  final String name;
  // final DateTime createTime;
  // final DateTime? lastUpdateTime;
  // final DateTime? deleteTime;
  // final bool activeStatus;

  final bool hasExpire;
  final String? description;
  final int? restrictionId; // NOTE : foreign key
  final double profitPrice;
  final double originalPrice;
  final int? imageId;
  // final List<int> promotionIdList;
  // final int createPersonId; // NOTE : foreign key
  // final int? deletePersonId; // NOTE : foreign key
  final String? code;
  final Color? colorCode;
  final double? taxPercentage;

  ItemModel({
    required super.id,
    required this.typeId,
    required this.name,
    required super.createTime,
    required super.lastUpdateTime,
    required super.deleteTime,
    required super.activeStatus,
    // required this.updateIdList,
    // required this.uniqueItemIdList,
    required this.hasExpire,
    required this.description,
    required this.restrictionId,
    required this.profitPrice,
    required this.originalPrice,
    // required this.promotionIdList,
    required this.colorCode,
    required super.deletePersonId,
    required super.createPersonId,
    required this.imageId,
    required this.code,
    required this.taxPercentage,
  });

  @override
  ItemModel.fromJson(Map<String, dynamic> jsonData) :
    // id = jsonData["id"],
    typeId = jsonData["typeId"],
    name = jsonData["name"],
    // createTime = DateTime.parse(jsonData["createTime"]),
    // lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]),
    // deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
    // activeStatus = jsonData["activeStatus"] == 1 ? true : false,
    // updateIdList = json.decode(jsonData["updateIdList"]);
    // uniqueItemIdList = json.decode(jsonData["uniqueItemIdList"]);
    hasExpire = jsonData["hasExpire"] == 1 ? true : false,
    description = jsonData["description"],
    restrictionId = jsonData["restrictionId"],
    profitPrice = jsonData["profitPrice"],
    originalPrice = jsonData["originalPrice"],
    // promotionIdList = json.decode(jsonData["promotionIdList"]),
    colorCode = jsonData["colorCode"],
    code = jsonData["code"],
    // deletePersonId = jsonData["deletePersonId"],
    // createPersonId = jsonData["createPersonId"],
    imageId = jsonData["imageId"],
    taxPercentage = jsonData["taxPercentage"],
    super.fromJson(jsonData);


  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> jsonData = super.toJson();
    jsonData["typeId"] = typeId;
    jsonData["name"] = name;
    jsonData["hasExpire"] = hasExpire ? 1 : 0;
    jsonData["description"] = description;
    jsonData["restrictionId"] = restrictionId;
    jsonData["profitPrice"] = profitPrice;
    jsonData["originalPrice"] = originalPrice;
    jsonData["colorCode"] = colorCode;
    jsonData["code"] = code;
    jsonData["imageId"] = imageId;
    jsonData["taxPercentage"] = taxPercentage;
    return jsonData;
  }
}
