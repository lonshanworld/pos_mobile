import 'package:flutter/material.dart';
class MainGlobalKeys{
  MainGlobalKeys._();

  static final MainGlobalKeys _instance = MainGlobalKeys._();

  static MainGlobalKeys get instance => _instance;

  final GlobalKey<NavigatorState> cusGlobalNavigatorKey = GlobalKey<NavigatorState>();
  final GlobalKey cusGlobalKey = GlobalKey();
  final GlobalKey<ScaffoldMessengerState> cusGlobalScaffoldKey = GlobalKey<ScaffoldMessengerState>();
}