import 'dart:ui';

import 'package:flutter/cupertino.dart';

class UIConstants {
  // Color code
  static const Color whiteClr = Color(0xFFF8F8F8);
  static const Color blackClr = Color(0xFF181818);
  static const Color goldClr = Color(0xFFFFD700);
  static const Color lightPurpleClr = Color(0xFFE6D5F6);
  static const Color redVioletClr = Color(0xFF922b3e);
  static const Color deepBlueClr = Color(0xFF0021f3);

  // for borderRadius
  static const double bigRadius = 20;
  static const double mediumRadius = 10;
  static const double smallRadius = 5;

  // for spacing
  static const double bigSpace = 20;
  static const double mediumSpace = 10;
  static const double smallSpace = 5;

  //for iconsize
  static const double bigIcon = 24;
  static const double mediumIcon = 20;
  static const double smallIcon = 16;

  //for responsive screenbreakpoint
  static const double screenBreakPoint = 800;

  //for smalldrawerwidth
  static const double smallDrawerWidth = 240;
  static const double bigDrawerWidth = 280;

  //for loading icon
  static const double normalLoadingIconSize = 35;
  static const double bigLoadingIconSize = 45;

  // static const double printerFontSize = 23;

  static const double normalBigIconSize = 40;
  static const double normalNormalIconSize = 30;
  static const double normalsmallIconSize = 20;

  static const double checkMoreTableAndChartsWidth = 200;


  // box width and height
  static const double itemBoxWidth = 250;
  static const double itemBoxHeight = 100;

  static const double stockoutBoxWidth = 310;

  static const double uniqueItemBoxWidth = 320;

  static const BorderRadius smallBorderRadius = BorderRadius.all(
      Radius.circular(smallRadius));
  static const BorderRadius mediumBorderRadius = BorderRadius.all(
      Radius.circular(mediumRadius));
  static const BorderRadius bigBorderRadius = BorderRadius.all(Radius.circular(bigRadius));
}