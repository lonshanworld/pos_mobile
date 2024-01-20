
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/core/data/models/general_abstract_model.dart';


class UserFormEntity implements GeneralModel{
  final String userName;
  final String password;
  final UserLevel userLevel;

  UserFormEntity({
    required this.userLevel,
    required this.userName,
    required this.password,
  });

  @override
  UserFormEntity.fromJson(Map<String, dynamic> jsonData) :
      userName = jsonData["userName"],
      password = jsonData["password"],
      userLevel = UserLevel.values.byName(jsonData["userLevel"]);

  @override
  Map<String, dynamic> toJson() =>{
    "userName" : userName,
    "password" : password,
    "userLevel" : userLevel.name,
  };

}