

import 'package:pos_mobile/models/abstract_models_folder/item_info_model.dart';

class UniqueItemModel extends ItemInfoSkeletalModel{
  // final int id;
  final int itemId; // NOTE : foreign key
  final int stockInId; // NOTE : foreign key
  final int? stockOutId; // NOTE : foreign key
  // final DateTime createTime;
  // final DateTime? deleteTime;
  final DateTime? itemManufactureDate;
  final DateTime? itemExpireDate;
  final String? code;
  // final int createPersonId; // NOTE : foreign key
  // final int? deletePersonId; // NOTE : foreign key
  final String? getItemFromWhere;
  final double originalPrice;
  final double profitPrice;
  final double taxPercentage;
  final int? moduleCount;

  // final DateTime? lastUpdateTime;
  // final bool activeStatus;

  UniqueItemModel({
    required super.id,
    required this.itemId,
    required this.stockInId,
    required this.stockOutId,
    required super.createTime,
    required super.deleteTime,
    required this.itemExpireDate,
    required this.itemManufactureDate,
    required this.code,
    required super.createPersonId,
    required super.deletePersonId,
    required this.getItemFromWhere,

    required super.lastUpdateTime,
    required super.activeStatus,
    required this.originalPrice,
    required this.profitPrice,
    required this.taxPercentage,
    required this.moduleCount,
  });
  
  @override
  UniqueItemModel.fromJson(Map<String, dynamic> jsonData) :
    // id = jsonData["id"],
    itemId = jsonData["itemId"],
    stockInId = jsonData["stockInId"],
    stockOutId = jsonData["stockOutId"],
    // createTime = DateTime.parse(jsonData["createTime"]),
    // deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
    itemManufactureDate = jsonData["itemManufactureDate"] == null ? null : DateTime.parse(jsonData["itemManufactureDate"]),
    itemExpireDate = jsonData["itemExpireDate"] == null ? null : DateTime.parse(jsonData["itemExpireDate"]),
    code = jsonData["code"],
    // createPersonId = jsonData["createPersonId"],
    // deletePersonId = jsonData["deletePersonId"],
    getItemFromWhere = jsonData["getItemFromWhere"],
    originalPrice = jsonData["originalPrice"],
    profitPrice = jsonData["profitPrice"],
    taxPercentage = jsonData["taxPercentage"],
    // lastUpdateTime = jsonData["lastUpdateTime"] == null ? null : DateTime.parse(jsonData["lastUpdateTime"]),
    // activeStatus = jsonData["activeState"] == 1 ? true : false,
    moduleCount = jsonData["moduleCount"],
    super.fromJson(jsonData);
  
  @override
  Map<String ,dynamic> toJson(){
    final Map<String,dynamic> jsonData = super.toJson();
    jsonData["itemId"] = itemId;
    jsonData["stockInId"] = stockInId;
    jsonData["stockOutId"] = stockOutId;
    jsonData["itemManufactureDate"] = itemManufactureDate?.toString();
    jsonData["itemExpireDate"] = itemExpireDate?.toString();
    jsonData["code"] = code;
    jsonData["getItemFromWhere"] = getItemFromWhere;
    jsonData["profitPrice"] = profitPrice;
    jsonData["originalPrice"] = originalPrice;
    jsonData["taxPercentage"] = taxPercentage;
    jsonData["moduleCount"] = moduleCount;
    return jsonData;
  }
}