abstract class SomeModelPromotionSkeletalModel{
  final int id;
  final int promotionId; // foreign key
  final DateTime createTime;
  final DateTime? deleteTime;
  final int createPersonId; // foreign key
  final int? deletePersonId; // foreign key
  final bool activeStatus;

  SomeModelPromotionSkeletalModel({
    required this.id,
    required this.promotionId,
    required this.createTime,
    required this.deleteTime,
    required this.createPersonId,
    required this.deletePersonId,
    required this.activeStatus
  });

  SomeModelPromotionSkeletalModel.fromJson(Map<String, dynamic> jsonData):
        id = jsonData["id"],
        promotionId = jsonData["promotionId"],
        createTime = DateTime.parse(jsonData["createTime"]),
        deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
        createPersonId = jsonData["createPersonId"],
        deletePersonId = jsonData["deletePersonId"],
        activeStatus = jsonData["activeStatus"] == 1 ? true : false;

  Map<String,dynamic> toJson()=>{
    "id" : id,
    "promotionId" : promotionId,
    "createTime" : createTime.toString(),
    "deleteTime" : deleteTime?.toString(),
    "createPersonId" : createPersonId,
    "deletePersonId" : deletePersonId,
    "activeStatus" : activeStatus ? 1 : 0,
  };
}