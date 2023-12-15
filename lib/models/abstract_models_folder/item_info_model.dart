abstract class ItemInfoSkeletalModel{
  final int id;
  final int createPersonId;
  final int? deletePersonId;
  final DateTime createTime;
  final DateTime? deleteTime;
  final DateTime? lastUpdateTime;
  final bool activeStatus;

  ItemInfoSkeletalModel({
    required this.id,
    required this.createPersonId,
    required this.deletePersonId,
    required this.createTime,
    required this.deleteTime,
    required this.lastUpdateTime,
    required this.activeStatus,
  });

  ItemInfoSkeletalModel.fromJson(Map<String, dynamic> jsonData) :
      id = jsonData["id"],
      createPersonId = jsonData["createPersonId"],
      deletePersonId = jsonData["deletePersonId"],
      createTime = DateTime.parse(jsonData["createTime"]),
      deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
      lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]),
      activeStatus = jsonData["activeStatus"] == 1 ? true : false;

  Map<String, dynamic>toJson()=>{
    "id" : id,
    "createPersonId" : createPersonId,
    "deletePersonId" : deletePersonId,
    "createTime" : createTime.toString(),
    "deleteTime" : deleteTime?.toString(),
    "lastUpdateTime" : lastUpdateTime?.toString(),
    "activeStatus" : activeStatus ? 1 : 0,
  };
}