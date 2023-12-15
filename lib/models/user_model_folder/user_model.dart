
import 'package:pos_mobile/constants/enums.dart';

class UserModel{
  final int id;
  final String userName;
  final String password;
  final UserLevel userLevel;
  final DateTime userCreatedTime;
  final DateTime? userLoginTime;
  final DateTime? userLogoutTime;
  final bool activeStatus;
  final int? imageId;
  // late List<String> updateIdList;

  UserModel({
    required this.id,
    required this.userName,
    required this.password,
    required this.userLevel,
    required this.userCreatedTime,
    required this.userLoginTime,
    required this.userLogoutTime,
    required this.activeStatus,
    required this.imageId,
    // required this.updateIdList,
  });

  UserModel.fromJson(Map<String , dynamic> jsonData) :
    id = jsonData["id"],
    userName = jsonData["userName"],
    password = jsonData["password"],
    userLevel = UserLevel.values.byName(jsonData["userLevel"]),
    userCreatedTime = DateTime.parse(jsonData["userCreateTime"]),
    userLoginTime = jsonData["userLoginTime"] == null ? null : DateTime.parse(jsonData["userLoginTime"]),
    userLogoutTime = jsonData["userLogoutTime"] == null ? null : DateTime.parse(jsonData["userLogoutTime"]),
    activeStatus = jsonData["activeStatus"] == 1 ? true : false,
    imageId = jsonData["imageId"];
    // updateIdList = json.decode(jsonData["updateIdList"]);

  Map<String, dynamic> toJson() =>{
    "id" : id,
    "userName" : userName,
    "password" : password,
    "userLevel" : userLevel.name,
    "userCreateTime" : userCreatedTime.toString(),
    "userLoginTime" : userLoginTime?.toString(),
    "userLogoutTime" : userLogoutTime?.toString(),
    "activeStatus" : activeStatus ? 1 : 0,
    "imageId" : imageId,
    // "updateIdList" : json.encode(updateIdList),
  };
}