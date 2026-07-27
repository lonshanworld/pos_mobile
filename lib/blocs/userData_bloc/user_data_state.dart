part of 'user_data_cubit.dart';

@immutable
abstract class UserDataState {
  final UserModel? userModel;
  final List<UserModel> allUserModelList;
  final List<UserModel> activeUserModelList;
  final bool isInitialized;
  final bool merchantExists;
  final String? setupStatusError;
  const UserDataState({
    required this.userModel,
    required this.allUserModelList,
    required this.activeUserModelList,
    required this.isInitialized,
    this.merchantExists = false,
    this.setupStatusError,
  });
}

class UserData extends UserDataState {
  const UserData({
    required super.userModel,
    required super.allUserModelList,
    required super.activeUserModelList,
    required super.isInitialized,
    super.merchantExists,
    super.setupStatusError,
  });
}
