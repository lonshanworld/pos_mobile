import 'dart:ui';

import 'package:pos_mobile/models/abstract_models_folder/item_info_model.dart';

class TypeModel extends ItemInfoSkeletalModel{
  // final int id;
  final int groupId;
  final String name;
  // final DateTime createTime;
  // final DateTime? lastUpdateTime;
  // final DateTime? deleteTime;
  // final bool activeStatus;
  // final int createPersonId; // Foreign key
  // final int? deletePersonId; // Foreign key
  final Color? colorCode;
  final int? imageId;
  final String? generalDescription;
  final int? generalRestrictionId; // Foreign key with restrictiontable (Id)
  final bool hasExpire;

  TypeModel({
    required super.id,
    required this.groupId,
    required this.name,
    required super.createTime,
    required super.lastUpdateTime,
    required super.deleteTime,
    required super.activeStatus,
    required super.createPersonId,
    required super.deletePersonId,
    required this.colorCode,
    required this.imageId,
    required this.generalDescription,
    required this.generalRestrictionId,
    required this.hasExpire,
  });

  @override
  TypeModel.fromJson(Map<String, dynamic>jsonData):
      // id = jsonData["id"],
      groupId = jsonData["groupId"],
      name = jsonData["name"],
      // createTime = DateTime.parse(jsonData["createTime"]),
      // lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime
      //     .parse(jsonData["lastUpdateTime"]),
      // deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(
      //     jsonData["deleteTime"]),
      // activeStatus = jsonData["activeStatus"] == 1 ? true : false,
      // createPersonId = jsonData["createPersonId"],
      // deletePersonId = jsonData["deletePersonId"],
      colorCode = jsonData["colorCode"],
      imageId = jsonData["imageId"],
      generalDescription = jsonData["generalDescription"],
      generalRestrictionId = jsonData["generalRestrictionId"],
      hasExpire = jsonData["hasExpire"] == 1 ? true : false,
      super.fromJson(jsonData);

  @override
  Map<String, dynamic> toJson(){
    // "id" : id,
    // "groupId" : groupId,
    // "name" : name,
    // "createTime" : createTime.toString(),
    // "lastUpdateTime" : lastUpdateTime.toString(),
    // "deleteTime" : deleteTime.toString(),
    // "activeStatus" : activeStatus ? 1 : 0,
    // "createPersonId" : createPersonId,
    // "deletePersonId" : deletePersonId,
    // "colorCode" : colorCode,
    // "generalDescription" : generalDescription,
    // "generalRestrictionId" : generalRestrictionId,
    // "hasExpire" : hasExpire ? 1 : 0,
    final Map<String,dynamic> jsonData = super.toJson();
    jsonData["groupId"] = groupId;
    jsonData["name"] = name;
    jsonData["colorCode"] = colorCode;
    jsonData["imageId"] = imageId;
    jsonData["generalDescription"] = generalDescription;
    jsonData["generalRestrictionId"] = generalRestrictionId;
    jsonData["hasExpire"] = hasExpire ? 1 : 0;
    return jsonData;
  }
}