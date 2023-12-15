import 'package:flutter/material.dart';
import 'package:pos_mobile/models/abstract_models_folder/item_info_model.dart';

class GroupModel extends ItemInfoSkeletalModel{
  // final int id;
  final int categoryId; // NOTE : foreign key
  final String name;
  // final DateTime createTime;
  // final DateTime? lastUpdateTime;
  // final DateTime? deleteTime;
  // final bool activeStatus;

  // final String? description;
  // final bool hasExpire;
  // final int createPersonId;// NOTE : foreign key
  // final int? deletePersonId; // NOTE : foreign key

  final Color? colorCode;
  final String? description;
  // final List<int> promotionIdList;

  GroupModel({
    required super.id,
    required this.categoryId,
    required this.name,
    required super.createTime,
    required super.lastUpdateTime,
    required super.deleteTime,
    required super.activeStatus,
    // required this.itemIdList,

    required super.createPersonId,
    required super.deletePersonId,
    // required this.updateIdList,
    required this.colorCode,
    required this.description,

  });

  @override
  GroupModel.fromJson(Map<String, dynamic> jsonData):
    // id = jsonData["id"],
    categoryId = jsonData["categoryId"],
    name = jsonData["name"],
    // createTime = DateTime.parse(jsonData["createTime"]),
    // lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]),
    // deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
    // activeStatus = jsonData["activeStatus"] == 1 ? true : false,
    // itemIdList = json.decode(jsonData["groupIdList"]);

    // createPersonId = jsonData["createPersonId"],
    // deletePersonId = jsonData["deletePersonId"],
    // updateIdList = json.decode(jsonData["updateIdList"]);
    description = jsonData["description"],
    colorCode = jsonData["colorCode"],
    super.fromJson(jsonData);



  @override
  Map<String, dynamic> toJson(){
    // "id" : id,
    // "categoryId" : categoryId,
    // "name" : name,
    // "createTime" : createTime.toString(),
    // "lastUpdateTime" : lastUpdateTime?.toString(),
    // "deleteTime" : deleteTime?.toString(),
    // "activeStatus" : activeStatus ? 1 : 0,
    // // "itemIdList" : json.encode(itemIdList),
    // "createPersonId" : createPersonId,
    // "deletePersonId" : deletePersonId,
    // // "updateIdList" : json.encode(updateIdList),
    // "colorCode" : colorCode,
    final jsonData = super.toJson();
    jsonData["categoryId"] = categoryId;
    jsonData["name"] = name;
    jsonData["description"] = description;
    jsonData["colorCode"] = colorCode;
    return jsonData;
  }
}