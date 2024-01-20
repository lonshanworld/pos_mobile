import 'package:pos_mobile/features/accounts/data/models/user_model/user_model.dart';

class CustomerModel{
  final int id;
  final String? name;
  final String? address;
  final String? phoneNo;
  final String? request;

  CustomerModel({
    required this.id,
    required this.name,
    required this.address,
    required this.phoneNo,
    required this.request,
  });

  CustomerModel.fromJson(Map<String, dynamic> jsonData) :
      id = jsonData["id"],
      name = jsonData["name"],
      address = jsonData["address"],
      phoneNo = jsonData["phoneNo"],
      request = jsonData["request"];


  Map<String, dynamic> toJson()=>{
    "id" : id,
    "name" : name,
    "address" : address,
    "phoneNo" : phoneNo,
    "request" : request,
  };


}