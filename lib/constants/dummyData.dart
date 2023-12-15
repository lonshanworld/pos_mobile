import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';

class DummyData{

  static final UserModel superAdminModel = UserModel(
    id: 1,
    userName: "superAdmin",
    password: "superAdmin123",
    userLevel: UserLevel.superAdmin,
    userCreatedTime: DateTime.now(),
    activeStatus: true,
    imageId: null,
    userLoginTime: DateTime.now(),
    userLogoutTime: null,
  );

  static final UserModel adminModel = UserModel(
    id: 2,
    userName: "admin",
    password: "admin123",
    userLevel: UserLevel.admin,
    userCreatedTime: DateTime.now(),
    activeStatus: false,
    imageId: null,
    userLoginTime: DateTime.now(), userLogoutTime: null,
  );

  static final UserModel staffModel = UserModel(
    id: 3,
    userName: "staff",
    password: "staff123",
    userLevel: UserLevel.staff,
    userCreatedTime: DateTime.now(),
    activeStatus: true,
    imageId: null,
    userLoginTime: DateTime.now(), userLogoutTime: null,
  );
}