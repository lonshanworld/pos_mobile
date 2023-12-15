part of 'user_data_cubit.dart';

@immutable
abstract class UserDataState {
  final UserModel? userModel;
  final List<UserModel> allUserModelList;
  final List<UserModel> activeUserModelList;
  const UserDataState({
    required this.userModel,
    required this.allUserModelList,
    required this.activeUserModelList,
  });
}

class UserData extends UserDataState {
  const UserData({required super.userModel, required super.allUserModelList,required super.activeUserModelList});
}
