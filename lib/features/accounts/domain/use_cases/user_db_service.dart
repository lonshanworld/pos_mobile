import 'package:pos_mobile/features/accounts/data/data_sources/local/user_db_storage.dart';
import 'package:pos_mobile/features/accounts/data/models/user_model/user_model.dart';
import 'package:pos_mobile/features/auth/domain/entities/user_form_entity/user_form_entity.dart';
import 'package:sqflite/sqflite.dart';

class UserDbService extends UserDbStorage{
  UserDbService(Database db) : super(db);

  Future<List<UserModel>>getAllUsers()async{
    List<dynamic> dataList = await super.getAllData();
    return dataList.map((e) => UserModel.fromJson(e)).toList();
  }

  Future<UserModel> getSingleUser(int id)async{
    List<dynamic> dataList = await super.getSingleData(id);
    return UserModel.fromJson(dataList[0]);
  }

  Future<bool> createNewUser(UserFormEntity userFormEntity)async{
    int value = await super.insertSingleData(userFormEntity);
    return value != -1;
  }


  Future<bool>loginUserUpdate(int id, DateTime dateTime)async{
    int value = await super.updateLoginTime(id, dateTime);
    return value != -1;
  }

  Future<bool>logoutUseUpdate(int id, DateTime dateTime)async{
    int value = await super.updateLogoutTime(id, dateTime);
    return value != -1;
  }
}
