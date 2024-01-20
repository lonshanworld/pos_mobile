import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/features/accounts/data/repo_impls/account_repo_impl.dart';
import 'package:pos_mobile/features/accounts/domain/use_cases/user_db_service.dart';

import 'core/data/data_sources/local/db_helper.dart';
import 'features/accounts/domain/repos/accounts_repo.dart';

class Dependencies{

  Dependencies._();
  static final Dependencies instance = Dependencies._();
  factory Dependencies() => instance;

  static final DBHelper _dbHelper = DBHelper();

  static final UserDbService _userDbService = UserDbService(_dbHelper.database!);

  static final AccountRepo accountRepo = AccountRepoImpl(userDbService: _userDbService);
}