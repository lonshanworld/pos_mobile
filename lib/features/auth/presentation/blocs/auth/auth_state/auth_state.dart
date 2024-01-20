
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_mobile/core/domain/entities/error_entity/error_entity.dart';
import 'package:pos_mobile/features/accounts/domain/entities/user_entity.dart';

part 'auth_state.freezed.dart';

@freezed
class AuthState with _$AuthState{
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.success(UserEntity userEntity) = _Success;
  const factory AuthState.fail(ErrorEntity error) = _Fail;
}