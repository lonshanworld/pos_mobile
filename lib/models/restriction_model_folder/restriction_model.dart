

class RestrictionModel{
  final int id;
  final String title;
  final String reason;
  final DateTime createTime;
  final DateTime? deleteTime;
  // late List<String> updateIdList;
  final DateTime? lastUpdateTime;
  final bool activeStatus;
  final int createPersonId; // NOTE : foreign key
  final int? deletePersonId; // NOTE : foreign key

  RestrictionModel({
    required this.id,
    required this.title,
    required this.reason,
    required this.createTime,
    required this.deleteTime,
    // required this.updateIdList,
    required this.lastUpdateTime,
    required this.activeStatus,
    required this.createPersonId,
    required this.deletePersonId,
  });

  RestrictionModel.fromJson(Map<String, dynamic> jsonData) :
    id = jsonData["id"],
    title = jsonData["title"],
    reason = jsonData["reason"],
    createTime = DateTime.parse(jsonData["createTime"]),
    deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
    // updateIdList = json.decode(jsonData["updateIdList"]);
    lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]),
    activeStatus = jsonData["activeStatus"] == 1 ? true : false,
    createPersonId = jsonData["createPersonId"],
    deletePersonId = jsonData["deletePersonId"];


  Map<String, dynamic> toJson()=>{
    "id" : id,
    "title" : title,
    "reason" : reason,
    "createTime" : createTime.toString(),
    "deleteTime" : deleteTime?.toString(),
    // "updateIdList" : json.encode(updateIdList),
    "lastUpdateTime" : lastUpdateTime?.toString(),
    "activeStatus" : activeStatus ? 1 : 0,
    "createPersonId" : createPersonId,
    "deletePersonId" : deletePersonId,
  };
}