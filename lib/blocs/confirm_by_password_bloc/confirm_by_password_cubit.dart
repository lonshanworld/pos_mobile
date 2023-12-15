import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:pos_mobile/utils/debug_print.dart';

import '../../models/user_model_folder/user_model.dart';

part 'confirm_by_password_state.dart';

class ConfirmByPasswordCubit extends Cubit<ConfirmByPasswordState> {

  final UserModel? userModel;
  final TextEditingController textEditingController = TextEditingController();
  ConfirmByPasswordCubit({required this.userModel}) : super(ConfirmByPasswordData(
    userModel: userModel,
  ));

  TextEditingController get pinController => textEditingController;

  void confirmFunc(){
    if(userModel != null && userModel!.password == textEditingController.text.trim()){
      cusDebugPrint("success");
    }else{
      cusDebugPrint("fail");
    }
  }
}
