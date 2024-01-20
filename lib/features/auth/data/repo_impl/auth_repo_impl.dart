import 'package:pos_mobile/features/accounts/domain/use_cases/user_db_service.dart';
import 'package:pos_mobile/features/auth/domain/repos/auth_repo.dart';

class AuthRepoImpl implements AuthRepo{
  final UserDbService _userDbService;

  AuthRepoImpl(UserDbService userDbService) : _userDbService = userDbService;

  @override
  Future<void> afterLogin() {
    // TODO: implement afterLogin
    throw UnimplementedError();
  }

  @override
  Future<void> afterLogout() {
    // TODO: implement afterLogout
    throw UnimplementedError();
  }

}