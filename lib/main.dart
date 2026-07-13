import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos_mobile/blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import 'package:pos_mobile/blocs/shop_info_bloc/shop_info_cubit.dart';
import 'package:pos_mobile/blocs/confirm_by_password_bloc/confirm_by_password_cubit.dart';
import 'package:pos_mobile/blocs/history_bloc/history_cubit.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/blocs/key_validation_bloc/key_validation_cubit.dart';
import 'package:pos_mobile/constants/business_type_utils.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/globalkeys.dart';
import 'package:pos_mobile/routes/router.dart';
import 'package:pos_mobile/services/crash_report_sync_manager.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pos_mobile/utils/crash_reporter.dart';
import 'package:pos_mobile/languages/app_language.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initiateAllDB();
  await GetStorage.init();

  // Load environment
  await dotenv.load(fileName: "assets/.env");
  final String appEnv = dotenv.env['APPLICATION_ENVIRONMENT'] ?? 'production';

  await CrashReporter.initialize(
    appRunner: () async {
      runApp(MyApp(appEnv: appEnv));
    },
  );

  // NOTE : don't put this at the top of runapp
  // configLoading();
}

// void configLoading() {
//   EasyLoading.instance
//     ..displayDuration = const Duration(milliseconds: 2000)
//     ..indicatorType = EasyLoadingIndicatorType.fadingCircle
//     ..loadingStyle = EasyLoadingStyle.custom
//     ..indicatorSize = 45.0
//     ..radius = 10.0
//     ..progressColor = Colors.orange
//     ..backgroundColor = Colors.black45
//     ..indicatorColor = Colors.orange
//     ..textColor = Colors.orange
//     ..userInteractions = false
//     ..dismissOnTap = false;
// }

class MyApp extends StatefulWidget {
  final String appEnv;
  const MyApp({super.key, required this.appEnv});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final UIController _uiController = UIController.instance;
  final MainGlobalKeys _mainGlobalKeys = MainGlobalKeys.instance;
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Initialize device dimensions before the first frame builds
    // This avoids zero width/height issues on the first screen
    if (_uiController.getDeviceWidth == 0 ||
        _uiController.getDeviceHeight == 0) {
      final size = MediaQuery.sizeOf(context);
      _uiController.setDeviceWidth = size.width;
      _uiController.setDeviceHeight = size.height;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    // Width change = rotation → update dimensions and rebuild.
    // Height-only change = keyboard show/hide → skip to avoid 30+ rebuilds.
    if (size.width != _uiController.getDeviceWidth) {
      _updateDeviceSize();
      if (mounted) setState(() {});
    }
  }

  void _updateDeviceSize() {
    final view = WidgetsBinding.instance.platformDispatcher.views.first;
    final size = view.physicalSize / view.devicePixelRatio;
    _uiController.setDeviceWidth = size.width;
    _uiController.setDeviceHeight = size.height;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(create: (ctx) => ThemeCubit(), lazy: false),
        BlocProvider<LanguageCubit>(
          create: (ctx) => LanguageCubit(),
          lazy: false,
        ),
        BlocProvider<BluetoothPrinterCubit>(
          create: (ctx) => BluetoothPrinterCubit(),
          lazy: false,
        ),
        BlocProvider<KeyValidationCubit>(
          create: (ctx) => KeyValidationCubit(appEnv: widget.appEnv),
          lazy: false,
        ),
        BlocProvider<LoadingCubit>(
          create: (ctx) => LoadingCubit(),
          lazy: false,
        ),
        BlocProvider<UserDataCubit>(
          create: (ctx) => UserDataCubit(),
          lazy: false,
        ),
        BlocProvider<ItemCubit>(create: (ctx) => ItemCubit(), lazy: false),
        BlocProvider<TransactionsCubit>(
          create: (ctx) => TransactionsCubit(),
          lazy: false,
        ),
        BlocProvider<HistoryCubit>(
          create: (ctx) => HistoryCubit(),
          lazy: false,
        ),
        BlocProvider<PromotionCubit>(
          create: (ctx) => PromotionCubit(),
          lazy: false,
        ),
        BlocProvider<ShopInfoCubit>(
          create: (ctx) => ShopInfoCubit(),
          lazy: false,
        ),
        BlocProvider<ConfirmByPasswordCubit>(
          create: (ctx) {
            return ConfirmByPasswordCubit(
              userModel: ctx.watch<UserDataCubit>().state.userModel,
            );
          },
          lazy: true,
        ),
      ],
      child: Builder(
        builder: (ctx) {
          return BlocBuilder<ShopInfoCubit, ShopInfoState>(
            builder: (context, shopState) {
              final bool allowsThemeToggle =
                  shopState.businessType.allowsThemeToggle;

              return _LifecycleAwareApp(
                child: MaterialApp(
                  key: _mainGlobalKeys.cusGlobalKey,
                  scaffoldMessengerKey: _mainGlobalKeys.cusGlobalScaffoldKey,
                  navigatorKey: _mainGlobalKeys.cusGlobalNavigatorKey,
                  title: 'POS Mobile',
                  locale: Locale(ctx.watch<LanguageCubit>().state.code),
                  debugShowCheckedModeBanner: false,
                  theme: _uiController.cusThemeData(ThemeModeType.light),
                  darkTheme: allowsThemeToggle
                      ? _uiController.cusThemeData(ThemeModeType.dark)
                      : _uiController.cusThemeData(ThemeModeType.light),
                  themeMode: allowsThemeToggle
                      ? ctx.watch<ThemeCubit>().getThemeMode()
                      : ThemeMode.light,
                  onGenerateRoute: _appRouter.onGenerateRoute,
                  builder: (context, child) {
                    return SafeArea(
                      child: BlocBuilder<KeyValidationCubit, KeyValidationState>(
                        builder: (context, state) {
                          if (state.isAppLocked) {
                            return Stack(
                              children: [
                                ?child,
                                Positioned.fill(
                                  child: Container(
                                    color: Colors.black.withOpacity(0.85),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Center(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 24,
                                          ),
                                          child: Card(
                                            color: Colors.grey[900],
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                              side: const BorderSide(
                                                color: Colors.red,
                                                width: 2,
                                              ),
                                            ),
                                            elevation: 24,
                                            child: Padding(
                                              padding: const EdgeInsets.all(
                                                28.0,
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.gpp_bad_rounded,
                                                    color: Colors.redAccent,
                                                    size: 72,
                                                  ),
                                                  const SizedBox(height: 16),
                                                  const Text(
                                                    'SECURITY ALERT',
                                                    style: TextStyle(
                                                      color: Colors.redAccent,
                                                      fontSize: 22,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      letterSpacing: 1.5,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 16),
                                                  Text(
                                                    state.lockErrorMessage ??
                                                        'Duplicate Device detect and The app is locked. Please contact NanoNux for more information',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16,
                                                      height: 1.5,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                    textAlign: TextAlign.center,
                                                  ),
                                                  const SizedBox(height: 24),
                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 16,
                                                          vertical: 8,
                                                        ),
                                                    decoration: BoxDecoration(
                                                      color: Colors.red
                                                          .withOpacity(0.1),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: const Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Icon(
                                                          Icons.lock,
                                                          color:
                                                              Colors.redAccent,
                                                          size: 16,
                                                        ),
                                                        SizedBox(width: 8),
                                                        Text(
                                                          'DEVICE TERMINATED',
                                                          style: TextStyle(
                                                            color: Colors
                                                                .redAccent,
                                                            fontSize: 12,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            letterSpacing: 1,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }
                          return child ?? const SizedBox.shrink();
                        },
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _LifecycleAwareApp extends StatefulWidget {
  final Widget child;
  const _LifecycleAwareApp({required this.child});

  @override
  State<_LifecycleAwareApp> createState() => _LifecycleAwareAppState();
}

class _LifecycleAwareAppState extends State<_LifecycleAwareApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize crash report sync manager
    CrashReportSyncManager.instance.initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    CrashReportSyncManager.instance.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) {
      context.read<UserDataCubit>().onAppDetached();
    } else if (state == AppLifecycleState.resumed) {
      // Trigger crash report sync when app comes to foreground
      CrashReportSyncManager.instance.manualSync();

      // Auto-unlock or refresh key validation status when app comes to foreground
      final keyValidationCubit = context.read<KeyValidationCubit>();
      if (keyValidationCubit.state.isKeyValidated) {
        keyValidationCubit.verifyKeyWithServer();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

//
