import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/screens/accounts/account_screen.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/blocs/userData_bloc/user_data_cubit.dart';

import 'package:pos_mobile/screens/authenticaton/check_user_screen.dart';
import 'package:pos_mobile/screens/authenticaton/key_validation_screen.dart';
import 'package:pos_mobile/screens/authenticaton/login_screen.dart';
import 'package:pos_mobile/screens/authenticaton/merchant_setup_screen.dart';
import 'package:pos_mobile/screens/home_screen.dart';
import 'package:pos_mobile/screens/settings_screen.dart';
import 'package:pos_mobile/screens/settings/general_settings_screen.dart';
import 'package:pos_mobile/screens/settings/printer_settings_screen.dart';
import 'package:pos_mobile/screens/settings/language_settings_screen.dart';
import 'package:pos_mobile/screens/settings/tax_settings_screen.dart';
import 'package:pos_mobile/screens/settings/sync_settings_screen.dart';
import 'package:pos_mobile/screens/transaction/stockIn/uniqueItem/uniqueitem_screen.dart';
import 'package:pos_mobile/screens/print_barcode_screen.dart';

class AppRouter {
  Route onGenerateRoute(RouteSettings routeSettings) {
    dynamic routeArgs = routeSettings.arguments;

    switch (routeSettings.name) {
      case CheckUserScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            return const CheckUserScreen();
          },
        );

      case KeyValidationScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            return const KeyValidationScreen();
          },
        );

      case LoginScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            return LoginScreen(userLevel: routeArgs["userLevel"]);
          },
        );

      case MerchantSetupScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            return const MerchantSetupScreen();
          },
        );

      case AccountScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            return const AccountScreen();
          },
        );

      case HomeScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            return const HomeScreen();
          },
        );

      case UniqueItemScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            ItemModel item = ItemModel.fromJson(routeArgs["item"]);
            return UniqueItemScreen(item: item);
          },
        );

      case PrinterSettingsScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) => const PrinterSettingsScreen(),
        );
      case LanguageSettingsScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) => const LanguageSettingsScreen(),
        );

      case PrintBarcodeScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) => const PrintBarcodeScreen(),
        );

      case GeneralSettingsScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) => _ownerOnlySettingsRoute(
            ctx,
            const GeneralSettingsScreen(),
          ),
        );

      case TaxSettingsScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) => _ownerOnlySettingsRoute(
            ctx,
            const TaxSettingsScreen(),
          ),
        );

      case SyncSettingsScreen.routeName:
        return MaterialPageRoute(
          builder: (BuildContext ctx) => const SyncSettingsScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (BuildContext ctx) {
            return const CheckUserScreen();
          },
        );
    }
  }

  Widget _ownerOnlySettingsRoute(BuildContext context, Widget page) {
    final userLevel = context.read<UserDataCubit>().state.userModel?.userLevel;
    final isOwner =
        userLevel == UserLevel.merchant || userLevel == UserLevel.superAdmin;

    return isOwner ? page : const SettingScreen();
  }
}
