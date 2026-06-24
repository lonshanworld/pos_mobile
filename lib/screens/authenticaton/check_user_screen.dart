import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/blocs/key_validation_bloc/key_validation_cubit.dart';

import 'package:pos_mobile/constants/enums.dart';

import 'package:pos_mobile/screens/authenticaton/login_screen.dart';
import 'package:pos_mobile/screens/authenticaton/merchant_setup_screen.dart';
import 'package:pos_mobile/screens/authenticaton/key_validation_screen.dart';
import 'package:pos_mobile/widgets/loading_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';

class CheckUserScreen extends StatelessWidget {
  static const String routeName = "/";

  const CheckUserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Duration duration = Duration(seconds: 4);
    final UIController uiController = UIController.instance;
    final ThemeModeType themeModeType = context
        .watch<ThemeCubit>()
        .state
        .themeModeType;
    final KeyValidationState keyValidationState = context
        .watch<KeyValidationCubit>()
        .state;
    final userDataState = context.watch<UserDataCubit>().state;
    Timer? timer;

    // If key is not validated, show key validation screen
    if (!keyValidationState.isKeyValidated) {
      return const KeyValidationScreen();
    }

    if (!userDataState.isInitialized) {
      return const Scaffold(
        body: Center(
          child: LoadingWidget(),
        ),
      );
    }

    // If it's first time setup and key is validated, go to merchant setup
    final bool hasMerchant = userDataState.allUserModelList.any(
      (u) => u.userLevel == UserLevel.merchant,
    );

    if (keyValidationState.isFirstTimeSetup && !hasMerchant) {
      return const MerchantSetupScreen();
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.center,
            child: GestureDetector(
              onLongPressStart: (_) {
                timer = Timer(duration, () {
                  throw Exception("Test Crash Report");
                });
              },
              onLongPressEnd: (_) {
                if (timer != null) {
                  timer!.cancel();
                }
              },
              child: const LogoImageWidget(widthandheight: 200),
            ),
          ),
          uiController.sizedBox(
            cusHeight: 3 * UIConstants.bigSpace,
            cusWidth: null,
          ),
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
                    Navigator.of(
                      context,
                    ).pushNamed(MerchantSetupScreen.routeName);
                  }
                },
              ),
              uiController.sizedBox(
                cusHeight: null,
                cusWidth: UIConstants.bigSpace,
              ),
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
                    arguments: {"userLevel": UserLevel.staff},
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
