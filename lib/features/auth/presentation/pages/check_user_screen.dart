import 'dart:async';


import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';

import 'package:pos_mobile/constants/enums.dart';

import 'package:pos_mobile/features/auth/presentation/pages/login_screen.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

import '../../../../constants/uiConstants.dart';
import '../../../../controller/ui_controller.dart';

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
                timer = Timer(duration, () {
                  context.read<UserDataCubit>().initData().then((_) {
                    Navigator.of(context).pushNamed(
                        LoginScreen.routeName,
                        arguments:  {
                          "userLevel" : UserLevel.superAdmin,
                        }
                    );
                  });
                });
              },
              onLongPressEnd: (_){
                if(timer != null){
                  timer!.cancel();
                }
              },
              // onTap: (){
              //   context.read<UserDataCubit>().initData().then((_) {
              //     Navigator.of(context).pushNamed(
              //         LoginScreen.routeName,
              //         arguments:  {
              //           "userLevel" : UserLevel.superAdmin,
              //         }
              //     );
              //   });
              // },
              child: const LogoImageWidget(widthandheight: 200),
            ),
          ),
          uiController.sizedBox(cusHeight: 3*UIConstants.bigSpace, cusWidth: null),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CusTxtElevatedBtn(
                txt: "Admin",
                verticalpadding: 10,
                horizontalpadding: 30,
                bdrRadius: UIConstants.mediumRadius,
                bgClr: uiController.getpureOppositeClr(themeModeType),
                txtClr: uiController.getpureDirectClr(themeModeType),
                txtStyle: Theme.of(context).textTheme.titleLarge!,
                func: () {
                  context.read<UserDataCubit>().initData().then((_) {
                    Navigator.of(context).pushNamed(
                        LoginScreen.routeName,
                        arguments:  {
                          "userLevel" : UserLevel.admin,
                        }
                    );
                  });

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
                func: () {
                  context.read<UserDataCubit>().initData().then((_) {
                    Navigator.of(context).pushNamed(
                        LoginScreen.routeName,
                        arguments:  {
                          "userLevel" : UserLevel.staff,
                        }
                    );
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
