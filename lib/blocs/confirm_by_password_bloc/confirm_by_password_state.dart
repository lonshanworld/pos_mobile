part of 'confirm_by_password_cubit.dart';

@immutable
abstract class ConfirmByPasswordState {
  final UserModel? userModel;
  const ConfirmByPasswordState({
    required this.userModel,
  });
}

class ConfirmByPasswordData extends ConfirmByPasswordState {
  const ConfirmByPasswordData({required super.userModel});

}
