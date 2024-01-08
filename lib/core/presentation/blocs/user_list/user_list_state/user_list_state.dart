import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../../../models/user_model_folder/user_model.dart';


part 'user_list_state.freezed.dart';

@freezed
class UserListState with _$UserListState{
  const factory UserListState.initial() = _Initial;
  const factory UserListState.loading() = _Loading;
  const factory UserListState.loaded(List<UserModel> userList) = _Loaded;
  const factory UserListState.failed(String error) = _Failed;
}
