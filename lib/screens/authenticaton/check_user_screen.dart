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
import 'package:pos_mobile/screens/home_screen.dart';
import 'package:pos_mobile/services/network_environment.dart';
import 'package:pos_mobile/services/pos_repository.dart';
import 'package:pos_mobile/services/pos_data_reload_service.dart';
import 'package:pos_mobile/blocs/sync_bloc/sync_status_cubit.dart';
import 'package:pos_mobile/widgets/loading_widget.dart';
import 'package:pos_mobile/widgets/btns_folder/cusTxtElevatedButton_widget.dart';
import 'package:pos_mobile/widgets/logo_folder/logo_image_widget.dart';

import '../../constants/uiConstants.dart';
import '../../controller/ui_controller.dart';

class CheckUserScreen extends StatefulWidget {
  static const String routeName = "/";

  const CheckUserScreen({super.key});

  @override
  State<CheckUserScreen> createState() => _CheckUserScreenState();
}

class _CheckUserScreenState extends State<CheckUserScreen> {
  bool _redirectingToHome = false;

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
      return const Scaffold(body: Center(child: LoadingWidget()));
    }

    if (userDataState.setupStatusError != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(userDataState.setupStatusError!),
              const SizedBox(height: UIConstants.mediumSpace),
              CusTxtElevatedBtn(
                txt: 'Retry',
                verticalpadding: 10,
                horizontalpadding: 30,
                bdrRadius: UIConstants.mediumRadius,
                bgClr: uiController.getpureOppositeClr(themeModeType),
                txtClr: uiController.getpureDirectClr(themeModeType),
                txtStyle: Theme.of(context).textTheme.titleMedium!,
                func: () => context.read<UserDataCubit>().initData(),
              ),
            ],
          ),
        ),
      );
    }

    // Merchant existence is the source of truth for first-time setup.
    final bool hasMerchant =
        userDataState.allUserModelList.any(
          (u) => u.userLevel == UserLevel.merchant,
        ) ||
        userDataState.merchantExists;

    if (!hasMerchant) {
      return const MerchantSetupScreen();
    }

    // On web, restore the dashboard after a browser reload when the
    // persisted backend token successfully loaded the user list. If the
    // token is missing or invalid, keep the user at the normal check/login
    // screen instead of opening the dashboard without an authenticated user.
    final canRestoreSession =
        NetworkConfiguration.usesBackend &&
        PosRepository.instance.api.token != null &&
        userDataState.allUserModelList.isNotEmpty;
    if (canRestoreSession) {
      if (!_redirectingToHome) {
        _redirectingToHome = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _bootstrapRestoredSession();
        });
      }
      return const Scaffold(body: Center(child: LoadingWidget()));
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
                  final userState = context.read<UserDataCubit>().state;
                  final hasMerchant =
                      userState.merchantExists ||
                      userState.allUserModelList.any(
                        (u) => u.userLevel == UserLevel.merchant,
                      );
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

  Future<void> _bootstrapRestoredSession() async {
    if (!mounted) return;
    final changesApplied = await context.read<SyncStatusCubit>().retry();
    if (!mounted) return;
    if (!changesApplied) {
      await PosDataReloadService.reloadAll(context);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(HomeScreen.routeName);
  }
}
