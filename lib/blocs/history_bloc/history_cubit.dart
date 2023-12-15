
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/models/update_history_model.dart';
import 'package:pos_mobile/utils/debug_print.dart';

import '../../constants/enums.dart';
import '../../models/user_model_folder/user_model.dart';

part 'history_state.dart';

class HistoryCubit extends Cubit<HistoryState> {
  HistoryCubit() : super(const HistoryData(historyList: []));

  Future<void>_initHistoryList()async{
    List<UpdateHistoryModel> historyList = await DBHelper.getHistoryList();
    emit(HistoryData(historyList: historyList));
  }

  Future<void>reloadHistoryList()async{
    await _initHistoryList();
  }

  Future<void>getAllHistoryList()async{
    await _initHistoryList();
  }

  void clearHistory(){
    emit(const HistoryData(historyList: []));
  }

  List<UserModel> getUserModelHistoryList(){
    List<UserModel> userModelHistoryList = [];
    cusDebugPrint("start -----");
    for (var element in state.historyList) {
      cusDebugPrint("${element.oldData} || ${element.newData}");
      // TODO : do filtering
      if(element.modelType == ModelType.userModel){
        if(element.oldData != null && element.oldData != "")userModelHistoryList.add(UserModel.fromJson(jsonDecode(element.oldData!)));
        if(element.newData != null && element.newData != "")userModelHistoryList.add(UserModel.fromJson(jsonDecode(element.newData!)));
      }
    }
    return userModelHistoryList;
  }
}
