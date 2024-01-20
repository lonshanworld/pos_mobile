import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:pos_mobile/features/accounts/domain/entities/user_entity.dart';



part 'user_list_state.freezed.dart';

@freezed
class UserListState with _$UserListState{
  const factory UserListState.initial() = _Initial;
  const factory UserListState.loading() = _Loading;
  const factory UserListState.loaded(List<UserEntity> userList) = _Loaded;
  const factory UserListState.failed(String error) = _Failed;
}
