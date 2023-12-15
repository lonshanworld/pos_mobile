import 'dart:ui';

import 'package:pos_mobile/constants/enums.dart';

abstract class ReportAndAlertSkeletalModel{
  final int id;
  final DateTime createTime;
  final DateTime? deleteTime;
  final DateTime? lastUpdateTime;
  final int createPersonId; // foreign key
  final int? deletePersonId; // foreign key
  final String title;
  final String description;
  final TargetAudienceType targetAudienceType;
  final ImportanceLevel importanceLevel;
  final bool activeStatus;
  final Color colorCode;

  ReportAndAlertSkeletalModel({
    required this.id,
    required this.createTime,
    required this.deleteTime,
    required this.lastUpdateTime,
    required this.createPersonId,
    required this.deletePersonId,
    required this.title,
    required this.description,
    required this.targetAudienceType,
    required this.importanceLevel,
    required this.activeStatus,
    required this.colorCode,
  });

  ReportAndAlertSkeletalModel.fromJson(Map<String, dynamic>jsonData) :
      id = jsonData["id"],
      createTime = DateTime.parse(jsonData["createTime"]),
      deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
      lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]),
      createPersonId = jsonData["createPersonId"],
      deletePersonId = jsonData["deletePersonId"],
      title = jsonData["title"],
      description = jsonData["description"],
      targetAudienceType = TargetAudienceType.values.byName(jsonData["targetAudienceType"]),
      importanceLevel = ImportanceLevel.values.byName(jsonData["importanceLevel"]),
      activeStatus = jsonData["activeStatus"] == 1 ? true : false,
      colorCode = jsonData["colorCode"];

  Map<String, dynamic> toJson()=>{
    "id" : id,
    "createTime" : createTime.toString(),
    "deleteTime" : deleteTime?.toString(),
    "lastUpdateTime" : lastUpdateTime?.toString(),
    "createPersonId" : createPersonId,
    "deletePersonId" : deletePersonId,
    "title" : title,
    "description" : description,
    "targetAudienceType" : targetAudienceType.name,
    "importanceLevel" : importanceLevel.name,
    "activeStatus" : activeStatus ? 1 : 0,
    "colorCode" : colorCode,
  };
}