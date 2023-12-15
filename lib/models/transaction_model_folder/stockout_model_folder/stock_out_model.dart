
import 'dart:convert';

import '../../../constants/enums.dart';

class StockOutModel{
  final int id;

  final int createPersonId; // NOTE : foreign key
  final int? deletePersonId; // NOTE : foreign key
  final DateTime createTime;
  final DateTime? deleteTime;
  // final String? customerName;
  final String? description;
  final ShoppingType shoppingType;
  final PaymentMethod paymentMethod;
  final double? additionalPromotionAmount;
  final double? taxPercentage;
  // final double? deliveryCharges;
  final bool activeStatus;

  final DateTime? lastUpdateTime;
  final String code;
  final int? customerId; // foreign key
  final int? deliveryPersonId; // foreign key
  final int? deliveryModelId; // foreign key
  final double finalTotalPrice;
  final double? customerCash;
  final double? refunds;

  StockOutModel({
    required this.id,
    required this.createPersonId,
    required this.deletePersonId,
    required this.createTime,
    required this.deleteTime,
    // required this.customerName,
    required this.description,
    required this.shoppingType,
    required this.paymentMethod,
    // required this.deliveryCharges,
    required this.additionalPromotionAmount,
    required this.taxPercentage,
    required this.activeStatus,
    required this.lastUpdateTime,
    required this.code,
    required this.customerId,
    required this.deliveryPersonId,
    required this.deliveryModelId,
    required this.finalTotalPrice,
    required this.customerCash,
    required this.refunds,
  });

  StockOutModel.fromJson(Map<String,dynamic> jsonData) :
    id = jsonData["id"],

    createPersonId = jsonData["createPersonId"],
    deletePersonId = jsonData["deletePersonId"],
    createTime = DateTime.parse(jsonData["createTime"]),
    deleteTime = jsonData["deleteTime"] == null ? null : DateTime.parse(jsonData["deleteTime"]),
    // customerName = jsonData["customerName"],
    description = jsonData["description"],
    shoppingType = ShoppingType.values.byName(jsonData["shoppingType"]),
    paymentMethod = PaymentMethod.values.byName(jsonData["paymentMethod"]),
    // deliveryCharges = jsonData["deliveryCharges"],
    additionalPromotionAmount = jsonData["additionalPromotionAmount"],
    taxPercentage = jsonData["taxPercentage"],
    activeStatus = jsonData["activeStatus"] == 1 ? true : false,

    lastUpdateTime = jsonData["lastUpdateTime"],
    code = jsonData["code"],
    customerId = jsonData["customerId"],
    deliveryPersonId = jsonData["deliveryPersonId"],
    deliveryModelId = jsonData["deliveryModelId"],
    finalTotalPrice = jsonData["finalTotalPrice"],
    customerCash = jsonData["customerCash"],
    refunds = jsonData["refunds"];


  Map<String,dynamic> toJson()=>{
    "id" : id,
    "createPersonId" : createPersonId,
    "deletePersonId" : deletePersonId,
    "createTime" : createTime.toString(),
    "deleteTime" : deleteTime.toString(),
    // "customerName" : customerName,
    "description" : description,
    "shoppingType" : shoppingType.name,
    "paymentMethod" : paymentMethod.name,
    // "deliveryCharges" : deliveryCharges,
    "additionalPromotionAmount" : additionalPromotionAmount,
    "taxPercentage" : taxPercentage,
    "activeStatus" : activeStatus ? 1 : 0,
    "lastUpdateTime" : lastUpdateTime.toString(),
    "code" : code,
    "customerId" : customerId,
    "deliveryModelId" : deliveryModelId,
    "deliveryPersonId" : deliveryPersonId,
    "finalTotalPrice" : finalTotalPrice,
    "customerCash" : customerCash,
    "refunds" : refunds,
  };
}