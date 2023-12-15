import 'dart:convert';

class StockInModel{
  final int id;
  // final List<int> uniqueIdList;
  final int createPersonId; // NOTE : foreign key
  final int? deletePersonId; // NOTE : foreign key
  final DateTime createTime;
  final DateTime? deleteTime;
  final bool activeStatus;
  // late List<String> updateIdList;
  final DateTime? lastUpdateTime;

  StockInModel({
    required this.id,
    // required this.uniqueIdList,
    required this.createTime,
    required this.deleteTime,
    required this.createPersonId,
    required this.deletePersonId,
    required this.activeStatus,
    // required this.updateIdList,
    required this.lastUpdateTime,
  });

  StockInModel.fromJson(Map<String ,dynamic> jsonData) :
    id = jsonData["id"],
    // uniqueIdList = json.decode(jsonData["uniqueIdList"]),
    createTime = DateTime.parse(jsonData["createTime"]),
    deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
    createPersonId = jsonData["createPersonId"],
    deletePersonId = jsonData["deletePersonId"],
    activeStatus = jsonData["activeStatus"] == 1 ? true : false,
    // updateIdList = json.decode(jsonData["updateIdList"]);
    lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]);

  Map<String, dynamic> toJson()=>{
    "id" : id,
    // "uniqueIdList" : json.encode(uniqueIdList),
    "createTime" : createTime.toString(),
    "deleteTime" : deleteTime?.toString(),
    "lastUpdateTime" : lastUpdateTime?.toString(),
    "createPersonId" : createPersonId,
    "deletePersonId" : deletePersonId,
    "activeStatus" : activeStatus ? 1 : 0,
    // "updateIdList" : json.encode(updateIdList),
  };
}