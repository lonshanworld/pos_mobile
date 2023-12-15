import 'package:pos_mobile/models/abstract_models_folder/report_alert_model.dart';

class AlertModel extends ReportAndAlertSkeletalModel{
  final bool completeStatus;
  final int? completePersonId; // foreign key

  AlertModel({
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
    required super.colorCode,
    required this.completeStatus,
    required this.completePersonId,
  });

  @override
  AlertModel.fromJson(Map<String, dynamic> jsonData) :
      completeStatus = jsonData["completeStatus"] == 1 ? true : false,
      completePersonId = jsonData["completePersonId"],
      super.fromJson(jsonData);

  @override
  Map<String, dynamic> toJson(){
    final Map<String, dynamic> jsonData = super.toJson();
    jsonData["completeStatus"] = completeStatus ? 1 : 0;
    jsonData["completePersonId"] = completePersonId;
    return jsonData;
  }
}