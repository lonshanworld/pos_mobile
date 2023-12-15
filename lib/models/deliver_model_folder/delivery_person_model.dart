class DeliveryPersonModel{
  final int id;
  final String? name;
  final String? address;
  final String? request;
  final String? phoneNo;
  final bool activeStatus;

  DeliveryPersonModel({
    required this.id,
    required this.name,
    required this.address,
    required this.request,
    required this.phoneNo,
    required this.activeStatus,
  });

  DeliveryPersonModel.fromJson(Map<String, dynamic> jsonData) :
    id = jsonData["id"],
    name = jsonData["name"],
    address = jsonData["address"],
    request = jsonData["request"],
    phoneNo = jsonData["phoneNo"],
    activeStatus = jsonData["activeStatus"] == 1 ? true : false;

  Map<String, dynamic>toJson()=>{
    "id" : id,
    "name" : name,
    "address" : address,
    "request" : request,
    "phoneNo" : phoneNo,
    "activeStatus" : activeStatus ? 1 : 0,
  };
}