import 'package:flutter/material.dart';
import 'package:pos_mobile/models/item_model_folder/item_model.dart';
import 'package:pos_mobile/screens/accounts/account_screen.dart';

import 'package:pos_mobile/screens/authenticaton/check_user_screen.dart';
import 'package:pos_mobile/screens/authenticaton/login_screen.dart';
import 'package:pos_mobile/screens/home_screen.dart';
import 'package:pos_mobile/screens/transaction/stockIn/uniqueItem/uniqueitem_screen.dart';

class AppRouter{

  Route onGenerateRoute(RouteSettings routeSettings){
    dynamic routeArgs = routeSettings.arguments;

    switch(routeSettings.name){
      case CheckUserScreen.routeName :
        return MaterialPageRoute(
          builder: (BuildContext ctx){
            return const CheckUserScreen();
          }
        );

      case LoginScreen.routeName :
        return MaterialPageRoute(
          builder: (BuildContext ctx){
            return LoginScreen(userLevel: routeArgs["userLevel"]);
          }
        );

      case AccountScreen.routeName :
        return MaterialPageRoute(
          builder: (BuildContext ctx){
            return const AccountScreen();
          },
        );

      case HomeScreen.routeName :
        return MaterialPageRoute(
          builder: (BuildContext ctx){
            return const HomeScreen();
          }
        );

      case UniqueItemScreen.routeName :
        return MaterialPageRoute(
          builder: (BuildContext ctx){
            ItemModel item = ItemModel.fromJson(routeArgs["item"]);
            return UniqueItemScreen(item: item,);
          }
        );

      default :
        return MaterialPageRoute(
            builder: (BuildContext ctx){
              return const CheckUserScreen();
            }
        );
    }
  }
}