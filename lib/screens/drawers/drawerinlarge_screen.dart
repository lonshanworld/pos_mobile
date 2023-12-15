import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:pos_mobile/blocs/theme_bloc/theme_cubit.dart";
import "package:pos_mobile/constants/enums.dart";
import "package:pos_mobile/controller/ui_controller.dart";

import "../../blocs/userData_bloc/user_data_cubit.dart";
import "../../constants/uiConstants.dart";
import "../../models/user_model_folder/user_model.dart";
import "../../routes/drawer_pagemodelList.dart";
import "../../widgets/dividers/cusDrawerDivider.dart";
import "../../widgets/drawer_widget.dart";
import "../../widgets/profile_widget.dart";

class DrawerInLargeScreen extends StatelessWidget {

  final int currentIndex;
  final Function(int) func;
  const DrawerInLargeScreen({
    super.key,
    required this.currentIndex,
    required this.func,
  });

  @override
  Widget build(BuildContext context) {
    final UIController uiController = UIController.instance;
    final UserModel? userModel= context.watch<UserDataCubit>().state.userModel;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;

    return  userModel == null
        ?
    const SizedBox.shrink()
        :
    SafeArea(
      child: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(UIConstants.bigSpace),
          decoration: BoxDecoration(
            color: uiController.getpureDirectClr(themeModeType),
            borderRadius: UIConstants.bigBorderRadius,
            border: Border.all(
              color: themeModeType == ThemeModeType.dark ? Colors.purpleAccent.withOpacity(0.4) : Colors.transparent,
              width: 1,
            ),
            boxShadow: [
              uiController.boxShadow(themeModeType),            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
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
