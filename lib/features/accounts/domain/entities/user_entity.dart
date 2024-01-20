import 'package:pos_mobile/features/accounts/data/models/user_model/user_model.dart';

import '../../../../constants/enums.dart';

class UserEntity{
  final int id;
  final String userName;
  final String password;
  final UserLevel userLevel;
  final DateTime userCreatedTime;
  final DateTime? userLoginTime;
  final DateTime? userLogoutTime;
  final bool activeStatus;
  final int? imageId;

  UserEntity(UserModel userModel) :
      id = userModel.id,
      userName = userModel.userName,
      password = userModel.password,
      userLevel = userModel.userLevel,
      userCreatedTime = userModel.userCreatedTime,
      userLoginTime = userModel.userLoginTime,
      userLogoutTime = userModel.userLogoutTime,
      activeStatus = userModel.activeStatus,
      imageId = userModel.imageId;
}