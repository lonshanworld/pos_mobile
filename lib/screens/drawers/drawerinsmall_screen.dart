import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/uiConstants.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/models/user_model_folder/user_model.dart';
import 'package:pos_mobile/routes/drawer_pagemodelList.dart';
import 'package:pos_mobile/widgets/dividers/cusDrawerDivider.dart';
import 'package:pos_mobile/widgets/drawer_widget.dart';

import '../../widgets/profile_widget.dart';

class DrawerInSmallScreen extends StatelessWidget {

  final Function(int) func;
  final int currentIndex;
  const DrawerInSmallScreen({
    super.key,
    required this.func,
    required this.currentIndex,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final UserModel? userModel= context.watch<UserDataCubit>().state.userModel;

    return userModel == null
        ?
    const SizedBox.shrink()
        :
    Drawer(
      width: UIConstants.smallDrawerWidth,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const ProfileWidget(),
              const CusDrawerDivider(),
              for(int a = 0; a < PageList.getPages(userModel.userLevel).length; a++)DrawerWidget(
                index: a,
                txt: PageList.getPages(userModel.userLevel)[a].title,
                func:(){
                  func(a);
                },
                isSelected: currentIndex == a,
              ),
              uiController.sizedBox(cusHeight: UIConstants.bigSpace, cusWidth: null),
            ],
          ),
        ),
      ),
    );
  }
}
