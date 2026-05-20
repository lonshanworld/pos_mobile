import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';

import 'package:pos_mobile/constants/enums.dart';

import 'package:pos_mobile/screens/authenticaton/login_screen.dart';
import 'package:pos_mobile/screens/authenticaton/merchant_setup_screen.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';

class CheckUserScreen extends StatelessWidget {
  static const String routeName = "/";

  const CheckUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Duration duration = Duration(seconds: 7);
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context.watch<ThemeCubit>().state.themeModeType;
    Timer? timer;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onLongPressStart: (_){
                timer = Timer(duration, () async {
                  await context.read<UserDataCubit>().initData();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamed(
                    LoginScreen.routeName,
                    arguments: {
                      "userLevel": UserLevel.superAdmin,
                    },
                  );
                });
              },
              onLongPressEnd: (_){
                if(timer != null){
                  timer!.cancel();
                }
              },
              child: const LogoImageWidget(widthandheight: 200),
            ),
          ),
          uiController.sizedBox(cusHeight: 3*UIConstants.bigSpace, cusWidth: null),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CusTxtElevatedBtn(
                txt: "Merchant",
                verticalpadding: 10,
                horizontalpadding: 30,
                bdrRadius: UIConstants.mediumRadius,
                bgClr: uiController.getpureOppositeClr(themeModeType),
                txtClr: uiController.getpureDirectClr(themeModeType),
                txtStyle: Theme.of(context).textTheme.titleLarge!,
                func: () async {
                  await context.read<UserDataCubit>().initData();
                  if (!context.mounted) return;
                  final hasMerchant = context
                      .read<UserDataCubit>()
                      .state
                      .allUserModelList
                      .any((u) => u.userLevel == UserLevel.merchant);
                  if (!context.mounted) return;
                  if (hasMerchant) {
                    Navigator.of(context).pushNamed(
                      LoginScreen.routeName,
                      arguments: {"userLevel": UserLevel.merchant},
                    );
                  } else {
                    Navigator.of(context).pushNamed(MerchantSetupScreen.routeName);
                  }
                },
              ),
              uiController.sizedBox(cusHeight: null, cusWidth:  UIConstants.bigSpace),
              CusTxtElevatedBtn(
                txt: "Staff",
                verticalpadding: 10,
                horizontalpadding: 30,
                bdrRadius: UIConstants.mediumRadius,
                bgClr: uiController.getpureOppositeClr(themeModeType),
                txtClr: uiController.getpureDirectClr(themeModeType),
                txtStyle: Theme.of(context).textTheme.titleLarge!,
                func: () async {
                  await context.read<UserDataCubit>().initData();
                  if (!context.mounted) return;
                  Navigator.of(context).pushNamed(
                    LoginScreen.routeName,
                    arguments: {
                      "userLevel": UserLevel.staff,
                    },
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
