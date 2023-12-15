import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';


// NOTE : this class is not purely constant class and have private constructor for single instance
//NOTE : directClr means same color with theme and oppositeClr means opposite color to theme
class UIController{
  // Private constructor
  UIController._();

  // Private static instance variable
  static final UIController _instance = UIController._();

  // Static method to access the instance
  static UIController get instance => _instance;

  // device width and height
  double _deviceWidth = 0;
  double _deviceHeight = 0;

  set setDeviceWidth(double width) => _deviceWidth = width;
  set setDeviceHeight(double height) => _deviceHeight = height;

  double get getDeviceWidth => _deviceWidth;
  double get getDeviceHeight => _deviceHeight;



  SizedBox sizedBox({
    required double? cusHeight,
    required double? cusWidth,
  }){
    return SizedBox(
      width: cusWidth ?? 0,
      height: cusHeight ?? 0,
    );
  }

  ThemeData cusThemeData(ThemeModeType themeModeType){
    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: getDirectClr(themeModeType),
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        titleTextStyle: cusTitleMedium(themeModeType),
        centerTitle: true,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: getDirectClr(themeModeType),
      textTheme: TextTheme(
        bodyLarge: cusBodyLarge(themeModeType),
        bodyMedium: cusBodyMedium(themeModeType),
        bodySmall: cusBodySmall(themeModeType),
        titleLarge: cusTitleLarge(themeModeType),
        titleMedium: cusTitleMedium(themeModeType),
        titleSmall: cusTitleSmall(themeModeType),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: getDirectClr(themeModeType),
        surfaceTintColor: Colors.indigoAccent,
        headerBackgroundColor: Colors.indigoAccent,
        headerForegroundColor: getpureOppositeClr(themeModeType),
        weekdayStyle: cusTitleMedium(themeModeType),
        dayStyle: cusBodyMedium(themeModeType),
        dayForegroundColor: MaterialStateProperty.all(getpureOppositeClr(themeModeType)),
        todayForegroundColor: MaterialStateProperty.all(getpureDirectClr(themeModeType)),
        todayBackgroundColor: MaterialStateProperty.all(Colors.indigoAccent),
      ),
      popupMenuTheme: const PopupMenuThemeData(
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        color: UIConstants.lightPurpleClr,
        shape: RoundedRectangleBorder(
            borderRadius: UIConstants.mediumBorderRadius,
            side: BorderSide(
              color: Colors.purple,
              width: 1,
            )
        ),
        position: PopupMenuPosition.over,
      ),
      tabBarTheme: TabBarTheme(
        dividerColor: Colors.grey.withOpacity(0.5),
        labelStyle: cusTitleSmall(themeModeType),
        labelColor: Colors.deepOrange,
        unselectedLabelStyle: cusTitleSmall(themeModeType),
        unselectedLabelColor: getpureOppositeClr(themeModeType),
        indicatorSize: TabBarIndicatorSize.label,
        overlayColor: MaterialStateProperty.all(Colors.deepOrange.withOpacity(0.1)),
        indicator: const UnderlineTabIndicator(
          borderRadius: UIConstants.smallBorderRadius,
          borderSide: BorderSide(
            width: 4,
            color: Colors.deepOrange,
          )
        ),
      ),
      // filledButtonTheme: FilledButtonThemeData(
      //   style: FilledButton.styleFrom(
      //     backgroundColor: getOppositeClr(themeModeType),
      //     foregroundColor: getDirectClr(themeModeType),
      //     shape: const RoundedRectangleBorder(
      //       borderRadius: BorderRadius.all(Radius.circular(10)),
      //     ),
      //   ),
      // )
    );
  }


  //for color
  Color getDirectClr(ThemeModeType themeModeType){
    return themeModeType == ThemeModeType.light ? UIConstants.whiteClr : UIConstants.blackClr;
  }

  Color getOppositeClr(ThemeModeType themeModeType){
    return themeModeType == ThemeModeType.light ? UIConstants.blackClr : UIConstants.whiteClr;
  }

  Color getpureOppositeClr(ThemeModeType themeModeType){
    return themeModeType == ThemeModeType.light ? Colors.black : Colors.white;
  }

  Color getpureDirectClr(ThemeModeType themeModeType){
    return themeModeType == ThemeModeType.light ? Colors.white : Colors.black;
  }


  // for body fontstyle
  TextStyle cusBodyMedium(ThemeModeType themeModeType){
    return TextStyle(
      fontSize: 14,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusBodyLarge(ThemeModeType themeModeType){
    return TextStyle(
      fontSize: 18,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusBodySmall(ThemeModeType themeModeType){
    return TextStyle(
      fontSize: 12,
      color: getOppositeClr(themeModeType),
    );
  }


  // for title style
  TextStyle cusTitleLarge(ThemeModeType themeModeType){
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusTitleMedium(ThemeModeType themeModeType){
    return TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusTitleSmall(ThemeModeType themeModeType){
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: getOppositeClr(themeModeType),
    );
  }

  BoxShadow boxShadow(ThemeModeType themeModeType) =>BoxShadow(
    color: themeModeType == ThemeModeType.dark ? Colors.transparent : Colors.black.withOpacity(0.4),
    blurRadius: 4,
    spreadRadius: 0.5,
    offset: const Offset(0, 2),
  );
}