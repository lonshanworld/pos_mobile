import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pos_mobile/blocs/bluetooth_printer_bloc/bluetooth_printer_cubit.dart';
import 'package:pos_mobile/blocs/confirm_by_password_bloc/confirm_by_password_cubit.dart';
import 'package:pos_mobile/blocs/history_bloc/history_cubit.dart';
import 'package:pos_mobile/blocs/item_bloc/item_cubit.dart';
import 'package:pos_mobile/blocs/loading_bloc/loading_cubit.dart';
import 'package:pos_mobile/blocs/promotion_bloc/promotion_cubit.dart';
import 'package:pos_mobile/blocs/theme_bloc/theme_cubit.dart';
import 'package:pos_mobile/blocs/transactions_bloc/transactions_cubit.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/controller/DB_helper.dart';
import 'package:pos_mobile/controller/ui_controller.dart';
import 'package:pos_mobile/globalkeys.dart';
import 'package:pos_mobile/routes/router.dart';


void main() async{

  WidgetsFlutterBinding.ensureInitialized();
  await DBHelper.initiateAllDB();
  await GetStorage.init();

  runApp(const MyApp());

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final AppRouter appRouter = AppRouter();
    final UIController uiController = UIController.instance;
    final MainGlobalKeys mainGlobalKeys = MainGlobalKeys.instance;
    final double deviceHeight = MediaQuery.of(context).size.height;
    final double deviceWidth = MediaQuery.of(context).size.width;
    uiController.setDeviceWidth = deviceWidth;
    uiController.setDeviceHeight = deviceHeight;

    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeCubit>(
          create: (ctx)=>ThemeCubit(),
          lazy: false,
        ),
        BlocProvider<BluetoothPrinterCubit>(
          create: (ctx)=>BluetoothPrinterCubit(),
          lazy: false,
        ),
        BlocProvider<LoadingCubit>(
          create: (ctx)=>LoadingCubit(),
          lazy: false,
        ),
        BlocProvider<UserDataCubit>(
          create: (ctx) =>UserDataCubit(),
          lazy: false,
        ),
        BlocProvider<ItemCubit>(
          create: (ctx) => ItemCubit(),
          lazy: false,
        ),
        BlocProvider<TransactionsCubit>(
          create: (ctx)=>TransactionsCubit(),
          lazy: false,
        ),
        BlocProvider<HistoryCubit>(
          create: (ctx) =>HistoryCubit(),
          lazy: false,
        ),
        BlocProvider<PromotionCubit>(
          create: (ctx) => PromotionCubit(),
          lazy: false,
        ),
        BlocProvider<ConfirmByPasswordCubit>(
          create: (ctx) {
            return ConfirmByPasswordCubit(userModel: ctx.watch<UserDataCubit>().state.userModel);
          },
          lazy: true,
        ),
      ],
      child: Builder(
        builder: (ctx) {
          return MaterialApp(
            key: mainGlobalKeys.cusGlobalKey,
            scaffoldMessengerKey: mainGlobalKeys.cusGlobalScaffoldKey,
            navigatorKey: mainGlobalKeys.cusGlobalNavigatorKey,
            title: 'POS Mobile',
            debugShowCheckedModeBanner: false,
            theme: uiController.cusThemeData(ThemeModeType.light),
            darkTheme: uiController.cusThemeData(ThemeModeType.dark),
            themeMode: ctx.watch<ThemeCubit>().getThemeMode(),
            onGenerateRoute: appRouter.onGenerateRoute,

          );
        }
      ),
    );
  }
}

//
