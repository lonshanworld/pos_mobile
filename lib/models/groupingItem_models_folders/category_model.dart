
import "package:flutter/material.dart";
import "package:pos_mobile/models/abstract_models_folder/item_info_model.dart";

class CategoryModel extends ItemInfoSkeletalModel{
  // final int id;
  final String name;
  // final DateTime createTime;
  // final DateTime? lastUpdateTime;
  // final DateTime? deleteTime;
  // final bool activeStatus;
  // late List<String> groupIdList;

  // final int createPersonId; // NOTE : foreign key
  // final int? deletePersonId; // NOTE : foreign key
  // late List<String> updateIdList;
  final Color? colorCode;

  CategoryModel({
    required super.id,
    required this.name,
    required super.createTime,
    required super.lastUpdateTime,
    required super.deleteTime,
    required super.activeStatus,
    // required this.groupIdList,
    required super.createPersonId,
    required super.deletePersonId,
    // required this.updateIdList,
    required this.colorCode,

  });

  @override
  CategoryModel.fromJson(Map<String, dynamic> jsonData):
    // id = jsonData["id"],
    name = jsonData["name"],
    // createTime = DateTime.parse(jsonData["createTime"]),
    // lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]),
    // deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
    // activeStatus = jsonData["activeStatus"] == 1 ? true : false,
    // groupIdList = json.decode(jsonData["groupIdList"]);

    // createPersonId = jsonData["createPersonId"],
    // deletePersonId = jsonData["deletePersonId"],
    // updateIdList = json.decode(jsonData["updateIdList"]);
    colorCode = jsonData["colorCode"],
    super.fromJson(jsonData);


  @override
  Map<String, dynamic> toJson(){
    // "id" : id,
    // "name" : name,
    // "createTime" : createTime.toString(),
    // "lastUpdateTime" : lastUpdateTime?.toString(),
    // "deleteTime" : deleteTime?.toString(),
    // "activeStatus" :activeStatus ? 1 : 0,
    // // "groupIdList" : json.encode(groupIdList),
    // "description" : description,
    // "createPersonId" : createPersonId,
    // "deletePersonId" : deletePersonId,
    // // "updateIdList" : json.encode(updateIdList),
    // "colorCode" : colorCode,
    final Map<String,dynamic> jsonData = super.toJson();
    jsonData["name"] = name;
    jsonData["colorCode"] = colorCode;
    return jsonData;
  }
}