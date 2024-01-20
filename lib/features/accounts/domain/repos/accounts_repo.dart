import 'package:pos_mobile/features/accounts/domain/entities/user_entity.dart';
import 'package:pos_mobile/features/auth/domain/entities/user_form_entity/user_form_entity.dart';

abstract class AccountRepo{
  Future<List<UserEntity>> getAllUserList();
  Future<bool>createAccount(UserFormEntity entity);
}