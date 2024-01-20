import 'package:pos_mobile/features/accounts/data/models/user_model/user_model.dart';
import 'package:pos_mobile/features/accounts/domain/entities/user_entity.dart';
import 'package:pos_mobile/features/accounts/domain/repos/accounts_repo.dart';
import 'package:pos_mobile/features/accounts/domain/use_cases/user_db_service.dart';
import 'package:pos_mobile/features/auth/domain/entities/user_form_entity/user_form_entity.dart';

class AccountRepoImpl implements AccountRepo{
  final UserDbService _userDbService;

  AccountRepoImpl({
    required UserDbService userDbService,
  }) :
    _userDbService = userDbService;


  @override
  Future<List<UserEntity>> getAllUserList() async{
    List<UserModel> dataList = await _userDbService.getAllUsers();
    return dataList.map((e) => UserEntity(e)).toList();
  }

  @override
  Future<bool> createAccount(UserFormEntity userFormEntity) async{
    return await _userDbService.createNewUser(userFormEntity);
  }

}