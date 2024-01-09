// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserModelImpl _$$UserModelImplFromJson(Map<String, dynamic> json) =>
    _$UserModelImpl(
      id: json['id'] as int,
      userName: json['userName'] as String,
      password: json['password'] as String,
      userLevel: $enumDecode(_$UserLevelEnumMap, json['userLevel']),
      userCreatedTime: DateTime.parse(json['userCreatedTime'] as String),
      userLoginTime: json['userLoginTime'] == null
          ? null
          : DateTime.parse(json['userLoginTime'] as String),
      userLogoutTime: json['userLogoutTime'] == null
          ? null
          : DateTime.parse(json['userLogoutTime'] as String),
      activeStatus: json['activeStatus'] as bool,
      imageId: json['imageId'] as int?,
    );

Map<String, dynamic> _$$UserModelImplToJson(_$UserModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userName': instance.userName,
      'password': instance.password,
      'userLevel': _$UserLevelEnumMap[instance.userLevel]!,
      'userCreatedTime': instance.userCreatedTime.toIso8601String(),
      'userLoginTime': instance.userLoginTime?.toIso8601String(),
      'userLogoutTime': instance.userLogoutTime?.toIso8601String(),
      'activeStatus': instance.activeStatus,
      'imageId': instance.imageId,
    };

const _$UserLevelEnumMap = {
  UserLevel.staff: 'staff',
  UserLevel.admin: 'admin',
  UserLevel.superAdmin: 'superAdmin',
};
