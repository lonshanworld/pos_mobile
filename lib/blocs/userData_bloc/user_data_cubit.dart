
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collection/collection.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';


import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/txtconstants.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/error_handlers/error_handler.dart';

import 'package:pos_mobile/models/user_model_folder/user_model.dart';

import '../../constants/uiConstants.dart';
import '../../screens/loading_screen.dart';


part 'user_data_state.dart';

class UserDataCubit extends Cubit<UserDataState> {
  final ErrorHandlers _errorHandler = ErrorHandlers();
  // List<UserModel> _allUserModelList = [];
  // final List<UserModel> _activeUserModelList = [];
  // final DBHelper dbHelper = DBHelper.instance;

  UserDataCubit() : super(const UserData(userModel: null, allUserModelList: [],activeUserModelList: [])){
    _initializeUserModelList();
  }

  Future<void> _initializeUserModelList()async{
    final List<UserModel> allUserModelList = await DBHelper.getAllUsersFromDB();
    final List<UserModel> activeUserModelList = [];
    UserModel? currentUserModel = state.userModel;

    for(UserModel data in allUserModelList){
      if(data.activeStatus){
        activeUserModelList.add(data);
      }
      if(state.userModel != null){
        if(state.userModel!.id == data.id){
          currentUserModel = data;
        }
      }
    }
    emit(UserData(userModel: currentUserModel, allUserModelList: allUserModelList, activeUserModelList: activeUserModelList));

  }
  //
  Future<void>initData()async{
    await _initializeUserModelList();
  }

  UserModel? getSingleUser(int index){
    UserModel? userModel = state.allUserModelList.firstWhereOrNull((element) => element.id == index);
    return userModel;
  }

  Future<bool> login({
    required String userName,
    required String password,
    required UserLevel userLevel,
    required BuildContext buildContext,
  })async{
    showDialog(
      barrierColor: Colors.transparent,
      barrierDismissible: false,
      context: buildContext,
      builder: (buildCtx){
        return const LoadingScreen(
          txt: "Loading ...",
          widget: SpinKitCircle(
            color: Colors.grey,
            size: UIConstants.bigLoadingIconSize,
          ),
          clr: Colors.black,
        );
      },
    );
    bool value = isAuthenticated(userName,password,userLevel);
    if(value){
      if(userLevel == UserLevel.superAdmin){
        Navigator.of(buildContext).pop();
        await _initializeUserModelList();
        return true;
      }else{
        bool returnBool = false;
        await DBHelper.loginAndLogOut(
          userModel: state.userModel!,
          isLogin : true,
        ).then((historySuccess)async {
          Navigator.of(buildContext).pop();
          await _initializeUserModelList();
          if(!historySuccess){
            _errorHandler.showErrorWithBtn(title: null, txt: "History update is not successful");
          }
          returnBool = historySuccess;
        });
        return returnBool;
      }

    }else{
      Navigator.of(buildContext).pop();
      _errorHandler.showErrorWithBtn(title: null, txt: "Login failed. Please try again.");
      return false;
    }

  }


  bool isAuthenticated(String userName, String password, UserLevel userLevel){
    UserModel? userModel;
    if(userLevel == UserLevel.superAdmin){
      if(userName == TxtConstants.superAdminModelData.userName && password ==TxtConstants.superAdminModelData.password){
        userModel = TxtConstants.superAdminModelData;
      }
    }else{
      userModel = state.activeUserModelList.firstWhereOrNull(
            (element){
          if(element.userName == userName && element.password == password && element.userLevel == userLevel){
            return true;
          }else{
            return false;
          }
        },
      );
    }

    if(userModel == null){
      return false;
    }else{
      emit( UserData(userModel: userModel, allUserModelList: state.allUserModelList, activeUserModelList: state.activeUserModelList));
      return true;
    }
  }

  Future<bool>createNewUser({
    required String userName,
    required String password,
    required UserLevel userLevel,
  })async{
    bool value = await DBHelper.createNewUser(userName: userName, password: password, userLevel: userLevel);
    await _initializeUserModelList();
    return value;
  }


  Future<void> clearAllData()async{
    emit(const UserData(userModel: null, allUserModelList: [], activeUserModelList: []));
  }

  Future<bool>logout()async{
    if(state.userModel!.userLevel == UserLevel.superAdmin){
      return true;
    }else{
      bool value = await DBHelper.loginAndLogOut(
        userModel: state.userModel!,
        isLogin : false,
      );
      if(value){
        clearAllData();
      }
      return value;
    }
  }

}
