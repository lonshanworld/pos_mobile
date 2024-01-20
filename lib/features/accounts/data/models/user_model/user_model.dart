
import 'package:pos_mobile/core/data/models/general_abstract_model.dart';

// @freezed
// class UserModel with _$UserModel{
//   const factory UserModel({
//     required int id,
//     required String userName,
//     required String password,
//     required UserLevel userLevel,
//     required DateTime userCreatedTime,
//     required DateTime? userLoginTime,
//     required DateTime? userLogoutTime,
//     required bool activeStatus,
//     required int? imageId,
//   }) = _UserModel;
//
//   factory UserModel.fromJson(Map<String, dynamic> jsonData) => _$UserModelFromJson(jsonData);
// }


import 'package:pos_mobile/constants/enums.dart';

class UserModel implements GeneralModel{
  final int id;
  final String userName;
  final String password;
  final UserLevel userLevel;
  final DateTime userCreatedTime;
  final DateTime? userLoginTime;
  final DateTime? userLogoutTime;
  final bool activeStatus;
  final int? imageId;

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
  });

  @override
  UserModel.fromJson(Map<String , dynamic> jsonData) :
        id = jsonData["id"],
        userName = jsonData["userName"],
        password = jsonData["password"],
        userLevel = UserLevel.values.byName(jsonData["userLevel"]),
        userCreatedTime = DateTime.parse(jsonData["userCreatedTime"]),
        userLoginTime = jsonData["userLoginTime"] == null ? null : DateTime.parse(jsonData["userLoginTime"]),
        userLogoutTime = jsonData["userLogoutTime"] == null ? null : DateTime.parse(jsonData["userLogoutTime"]),
        activeStatus = jsonData["activeStatus"] == 1 ? true : false,
        imageId = jsonData["imageId"];
  // updateIdList = json.decode(jsonData["updateIdList"]);

  @override
  Map<String, dynamic> toJson() =>{
    "id" : id,
    "userName" : userName,
    "password" : password,
    "userLevel" : userLevel.name,
    "userCreatedTime" : userCreatedTime.toString(),
    "userLoginTime" : userLoginTime?.toString(),
    "userLogoutTime" : userLogoutTime?.toString(),
    "activeStatus" : activeStatus ? 1 : 0,
    "imageId" : imageId,
  };
}