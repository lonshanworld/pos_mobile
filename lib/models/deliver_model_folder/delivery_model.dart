class DeliveryModel{
  final int id;
  final String? startAddress;
  final String? endAddress;
  final double? deliveryCharges;
  final DateTime? startDeliveryTime;

  DeliveryModel({
    required this.id,
    required this.startAddress,
    required this.endAddress,
    required this.deliveryCharges,
    required this.startDeliveryTime,
  });

  DeliveryModel.fromJson(Map<String, dynamic> jsonData) :
      id = jsonData["id"],
      startAddress = jsonData["startAddress"],
      endAddress = jsonData["endAddress"],
      deliveryCharges = jsonData["deliveryCharges"],
      startDeliveryTime = jsonData["startDeliveryTime"] == null ? null : DateTime.parse(jsonData["startDeliveryTime"]);

  Map<String, dynamic> toJson()=>{
    "id" : id,
    "startAddress" : startAddress,
    "endAddress" : endAddress,
    "deliveryCharges" : deliveryCharges,
    "startDeliveryTime" : startDeliveryTime.toString(),
  };

}