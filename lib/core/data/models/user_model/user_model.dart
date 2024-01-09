import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_mobile/constants/enums.dart';

part "user_model.freezed.dart";
part "user_model.g.dart";

@freezed
class UserModel with _$UserModel{
  const factory UserModel({
    required int id,
    required String userName,
    required String password,
    required UserLevel userLevel,
    required DateTime userCreatedTime,
    required DateTime? userLoginTime,
    required DateTime? userLogoutTime,
    required bool activeStatus,
    required int? imageId,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> jsonData) => _$UserModelFromJson(jsonData);
}