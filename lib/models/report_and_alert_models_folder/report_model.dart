import 'package:pos_mobile/models/abstract_models_folder/report_alert_model.dart';

class ReportModel extends ReportAndAlertSkeletalModel{
  final DateTime alertStartTime;
  final DateTime alertEndTime;

  ReportModel({
    required this.alertStartTime,
    required this.alertEndTime,
    required super.id,
    required super.createTime,
    required super.deleteTime,
    required super.lastUpdateTime,
    required super.createPersonId,
    required super.deletePersonId,
    required super.title,
    required super.description,
    required super.targetAudienceType,
    required super.importanceLevel,
    required super.activeStatus,
    required super.colorCode
  });

  @override
  ReportModel.fromJson(Map<String, dynamic> jsonData) :
      alertStartTime = DateTime.parse(jsonData["alertStartTime"]),
      alertEndTime = DateTime.parse(jsonData["alertEndTime"]),
      super.fromJson(jsonData);

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> jsonData = super.toJson();
    jsonData["alertStartTime"] = alertStartTime.toString();
    jsonData["alertEndTime"] = alertEndTime.toString();
    return jsonData;
  }
}