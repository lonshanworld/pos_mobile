import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_exit_app/flutter_exit_app.dart';
import 'package:pos_mobile/blocs/history_bloc/history_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';

class Logout{
  static Future<bool> logout(BuildContext context)async{
    try{
      Future.wait(
        [
          context.read<UserDataCubit>().logout(),
        ],
      );
      context.read<HistoryCubit>().clearHistory();
      return true;
    }catch(err){
      return false;
    }

  }

  static void forceLogout(){
    if(defaultTargetPlatform == TargetPlatform.iOS){
      FlutterExitApp.exitApp(iosForceExit: true);
      SystemNavigator.pop();
    }if(defaultTargetPlatform ==  TargetPlatform.android){
      SystemNavigator.pop();
    }else{
      SystemNavigator.pop();
    }
  }
}