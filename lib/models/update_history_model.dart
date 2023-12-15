import 'package:pos_mobile/constants/enums.dart';


class UpdateHistoryModel{
  final int id;
  final String? oldData;
  final String? newData;
  final DateTime createTime;
  final ModelType modelType;
  final UpdateType updateType;
  final int createPersonId; // NOTE : foreign key
  final int? deletePersonId; // NOTE : foreign key
  final bool activeStatus;

  UpdateHistoryModel({
    required this.id,
    required this.oldData,
    required this.newData,
    required this.createTime,
    required this.modelType,
    required this.updateType,
    required this.createPersonId,
    required this.deletePersonId,
    required this.activeStatus,
  });

  UpdateHistoryModel.fromJson(Map<String, dynamic> jsonData) :
    id = jsonData["id"],
    oldData = jsonData["oldData"],
    newData = jsonData["newData"],
    createTime = DateTime.parse(jsonData["createTime"]),
    modelType = ModelType.values.byName(jsonData["modelType"]),
    updateType = UpdateType.values.byName(jsonData["updateType"]),
    createPersonId = jsonData["createPersonId"],
    deletePersonId = jsonData["deletePersonId"],
    activeStatus = jsonData["activeStatus"] == 1 ? true : false;

  Map<String, dynamic> toJson()=>{
    "id" : id,
    "oldData" : oldData,
    "newData" : newData ,
    "createTime" : createTime.toString(),
    "modelType" : modelType.name,
    "updateType" : updateType.name,
    "createPersonId" : createPersonId,
    "deletePersonId" : deletePersonId,
    "activeStatus" : activeStatus ? 1 : 0,
  };

}