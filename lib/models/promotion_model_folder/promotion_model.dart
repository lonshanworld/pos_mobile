/*promotionLimit mean like if it is promotionLimitPerson,
this mean the amount of people that will get promotion like 100 people will get promotion*/


class PromotionModel{
  final int id;
  final String promotionName;
  final String? promotionDescription;
  final double? promotionPercentage;
  final double? promotionPrice;
  final int createPersonId; // NOTE : foreign key
  final int? deletePersonId; // NOTE : foreign key
  // late List<String> updateIdList;
  final bool activeStatus;
  final int? promotionLimitPerson;
  final double? promotionLimitPrice;
  final DateTime? promotionLimitTime;
  final int? requirementForItemCount;
  final double? requirementForPrice;
  final String? promotionCode;
  final DateTime createTime;
  final DateTime? deleteTime;
  final DateTime? lastUpdateTime;

  PromotionModel({
    required this.id,
    required this.promotionName,
    required this.promotionDescription,
    required this.promotionPercentage,
    required this.promotionPrice,
    required this.createPersonId,
    required this.deletePersonId,
    // required this.updateIdList,
    required this.activeStatus,
    required this.promotionLimitPerson,
    required this.promotionLimitPrice,
    required this.promotionLimitTime,
    required this.requirementForItemCount,
    required this.requirementForPrice,
    required this.promotionCode,
    required this.createTime,
    required this.lastUpdateTime,
    required this.deleteTime,
  });

  PromotionModel.fromJson(Map<String, dynamic> jsonData) :
    id = jsonData["id"],
    promotionName = jsonData["promotionName"],
    promotionDescription = jsonData["promotionDescription"],
    promotionPercentage = jsonData["promotionPercentage"],
    promotionPrice = jsonData["promotionPrice"],
    createPersonId = jsonData["createPersonId"],
    deletePersonId = jsonData["deletePersonId"],
    // updateIdList = json.decode(jsonData["updateIdList"]);
    activeStatus = jsonData["activeStatus"] == 1 ? true : false,
    promotionLimitPerson = jsonData["promotionLimitPerson"],
    promotionLimitPrice = jsonData["promotionLimitPrice"],
    promotionLimitTime = jsonData["promotionLimitTime"] == null ? null : DateTime.parse(jsonData["promotionLimitTime"]),
    requirementForItemCount = jsonData["requirementForItemCount"],
    requirementForPrice = jsonData["requirementForPrice"],
    promotionCode = jsonData["promotionCode"],
    createTime = DateTime.parse(jsonData["createTime"]),
    lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]),
    deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]);

  Map<String, dynamic> toJson()=>{
    "id" : id,
    "promotionName" : promotionName,
    "promotionDescription" : promotionDescription,
    "promotionPercentage" : promotionPercentage,
    "promotionPrice" : promotionPrice,
    "createPersonId" : createPersonId,
    "deletePersonId" : deletePersonId,
    // "updateIdList" : json.encode(updateIdList),
    "activeStatus" : activeStatus ? 1 : 0,
    "promotionLimitPerson" : promotionLimitPerson,
    "promotionLimitTime" : promotionLimitTime.toString(),
    "promotionLimitPrice" : promotionLimitPrice,
    "requirementForItemCount" : requirementForItemCount,
    "requirementForPrice" : requirementForPrice,
    "promotionCode" : promotionCode,
    "createTime" : createTime.toString(),
    "lastUpdateTime" : lastUpdateTime?.toString(),
    "deleteTime" : deleteTime?.toString(),
  };
}
