// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  int get id => throw _privateConstructorUsedError;
  String get userName => throw _privateConstructorUsedError;
  String get password => throw _privateConstructorUsedError;
  UserLevel get userLevel => throw _privateConstructorUsedError;
  DateTime get userCreatedTime => throw _privateConstructorUsedError;
  DateTime? get userLoginTime => throw _privateConstructorUsedError;
  DateTime? get userLogoutTime => throw _privateConstructorUsedError;
  bool get activeStatus => throw _privateConstructorUsedError;
  int? get imageId => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {int id,
      String userName,
      String password,
      UserLevel userLevel,
      DateTime userCreatedTime,
      DateTime? userLoginTime,
      DateTime? userLogoutTime,
      bool activeStatus,
      int? imageId});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userName = null,
    Object? password = null,
    Object? userLevel = null,
    Object? userCreatedTime = null,
    Object? userLoginTime = freezed,
    Object? userLogoutTime = freezed,
    Object? activeStatus = null,
    Object? imageId = freezed,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      userLevel: null == userLevel
          ? _value.userLevel
          : userLevel // ignore: cast_nullable_to_non_nullable
              as UserLevel,
      userCreatedTime: null == userCreatedTime
          ? _value.userCreatedTime
          : userCreatedTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userLoginTime: freezed == userLoginTime
          ? _value.userLoginTime
          : userLoginTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userLogoutTime: freezed == userLogoutTime
          ? _value.userLogoutTime
          : userLogoutTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeStatus: null == activeStatus
          ? _value.activeStatus
          : activeStatus // ignore: cast_nullable_to_non_nullable
              as bool,
      imageId: freezed == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as int?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String userName,
      String password,
      UserLevel userLevel,
      DateTime userCreatedTime,
      DateTime? userLoginTime,
      DateTime? userLogoutTime,
      bool activeStatus,
      int? imageId});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? userName = null,
    Object? password = null,
    Object? userLevel = null,
    Object? userCreatedTime = null,
    Object? userLoginTime = freezed,
    Object? userLogoutTime = freezed,
    Object? activeStatus = null,
    Object? imageId = freezed,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      userName: null == userName
          ? _value.userName
          : userName // ignore: cast_nullable_to_non_nullable
              as String,
      password: null == password
          ? _value.password
          : password // ignore: cast_nullable_to_non_nullable
              as String,
      userLevel: null == userLevel
          ? _value.userLevel
          : userLevel // ignore: cast_nullable_to_non_nullable
              as UserLevel,
      userCreatedTime: null == userCreatedTime
          ? _value.userCreatedTime
          : userCreatedTime // ignore: cast_nullable_to_non_nullable
              as DateTime,
      userLoginTime: freezed == userLoginTime
          ? _value.userLoginTime
          : userLoginTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      userLogoutTime: freezed == userLogoutTime
          ? _value.userLogoutTime
          : userLogoutTime // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      activeStatus: null == activeStatus
          ? _value.activeStatus
          : activeStatus // ignore: cast_nullable_to_non_nullable
              as bool,
      imageId: freezed == imageId
          ? _value.imageId
          : imageId // ignore: cast_nullable_to_non_nullable
              as int?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl implements _UserModel {
  const _$UserModelImpl(
      {required this.id,
      required this.userName,
      required this.password,
      required this.userLevel,
      required this.userCreatedTime,
      required this.userLoginTime,
      required this.userLogoutTime,
      required this.activeStatus,
      required this.imageId});

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final int id;
  @override
  final String userName;
  @override
  final String password;
  @override
  final UserLevel userLevel;
  @override
  final DateTime userCreatedTime;
  @override
  final DateTime? userLoginTime;
  @override
  final DateTime? userLogoutTime;
  @override
  final bool activeStatus;
  @override
  final int? imageId;

  @override
  String toString() {
    return 'UserModel(id: $id, userName: $userName, password: $password, userLevel: $userLevel, userCreatedTime: $userCreatedTime, userLoginTime: $userLoginTime, userLogoutTime: $userLogoutTime, activeStatus: $activeStatus, imageId: $imageId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.userName, userName) ||
                other.userName == userName) &&
            (identical(other.password, password) ||
                other.password == password) &&
            (identical(other.userLevel, userLevel) ||
                other.userLevel == userLevel) &&
            (identical(other.userCreatedTime, userCreatedTime) ||
                other.userCreatedTime == userCreatedTime) &&
            (identical(other.userLoginTime, userLoginTime) ||
                other.userLoginTime == userLoginTime) &&
            (identical(other.userLogoutTime, userLogoutTime) ||
                other.userLogoutTime == userLogoutTime) &&
            (identical(other.activeStatus, activeStatus) ||
                other.activeStatus == activeStatus) &&
            (identical(other.imageId, imageId) || other.imageId == imageId));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      userName,
      password,
      userLevel,
      userCreatedTime,
      userLoginTime,
      userLogoutTime,
      activeStatus,
      imageId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel implements UserModel {
  const factory _UserModel(
      {required final int id,
      required final String userName,
      required final String password,
      required final UserLevel userLevel,
      required final DateTime userCreatedTime,
      required final DateTime? userLoginTime,
      required final DateTime? userLogoutTime,
      required final bool activeStatus,
      required final int? imageId}) = _$UserModelImpl;

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  int get id;
  @override
  String get userName;
  @override
  String get password;
  @override
  UserLevel get userLevel;
  @override
  DateTime get userCreatedTime;
  @override
  DateTime? get userLoginTime;
  @override
  DateTime? get userLogoutTime;
  @override
  bool get activeStatus;
  @override
  int? get imageId;
  @override
  @JsonKey(ignore: true)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
