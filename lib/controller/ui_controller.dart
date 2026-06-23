import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/business_theme_palette.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';

// NOTE : this class is not purely constant class and have private constructor for single instance
//NOTE : directClr means same color with theme and oppositeClr means opposite color to theme
class UIController {
  UIController._();

  static final UIController _instance = UIController._();

  static UIController get instance => _instance;

  double _deviceWidth = 0;
  double _deviceHeight = 0;
  BusinessType businessType = BusinessType.general;

  set setDeviceWidth(double width) => _deviceWidth = width;
  set setDeviceHeight(double height) => _deviceHeight = height;

  double get getDeviceWidth => _deviceWidth;
  double get getDeviceHeight => _deviceHeight;

  BusinessThemePalette _palette(ThemeModeType themeModeType) {
    if (businessType == BusinessType.general) {
      return themeModeType == ThemeModeType.light
          ? BusinessThemePalette.forType(BusinessType.general)
          : BusinessThemePalette.generalDark();
    }
    return BusinessThemePalette.forType(businessType);
  }

  Color accentColor() => _palette(ThemeModeType.light).accent;

  SizedBox sizedBox({
    required double? cusHeight,
    required double? cusWidth,
  }) {
    return SizedBox(
      width: cusWidth ?? 0,
      height: cusHeight ?? 0,
    );
  }

  ThemeData cusThemeData(ThemeModeType themeModeType) {
    final palette = _palette(themeModeType);
    final bool isGeneral = businessType == BusinessType.general;

    return ThemeData(
      appBarTheme: AppBarTheme(
        backgroundColor: palette.background,
        foregroundColor: palette.foreground,
        scrolledUnderElevation: 0,
        toolbarHeight: 50,
        titleTextStyle: cusTitleMedium(themeModeType),
        centerTitle: true,
      ),
      useMaterial3: true,
      scaffoldBackgroundColor: palette.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.accent,
        brightness: isGeneral && themeModeType == ThemeModeType.dark
            ? Brightness.dark
            : Brightness.light,
        surface: palette.surface,
        primary: palette.accent,
        onPrimary: palette.onAccent,
      ),
      textTheme: TextTheme(
        bodyLarge: cusBodyLarge(themeModeType),
        bodyMedium: cusBodyMedium(themeModeType),
        bodySmall: cusBodySmall(themeModeType),
        titleLarge: cusTitleLarge(themeModeType),
        titleMedium: cusTitleMedium(themeModeType),
        titleSmall: cusTitleSmall(themeModeType),
      ),
      cardTheme: CardThemeData(
        color: palette.surface,
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.mediumBorderRadius,
          side: BorderSide(color: palette.cardBorder, width: 1),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: palette.background,
        surfaceTintColor: palette.accent,
        headerBackgroundColor: palette.accent,
        headerForegroundColor: palette.onAccent,
        weekdayStyle: cusTitleMedium(themeModeType),
        dayStyle: cusBodyMedium(themeModeType),
        dayForegroundColor: WidgetStateProperty.all(palette.foreground),
        todayForegroundColor: WidgetStateProperty.all(palette.onAccent),
        todayBackgroundColor: WidgetStateProperty.all(palette.accent),
      ),
      popupMenuTheme: PopupMenuThemeData(
        surfaceTintColor: Colors.transparent,
        color: palette.popupSurface,
        shape: RoundedRectangleBorder(
          borderRadius: UIConstants.mediumBorderRadius,
          side: BorderSide(color: palette.accent.withValues(alpha: 0.5), width: 1),
        ),
        elevation: 8,
        shadowColor: Colors.black.withValues(alpha: 0.25),
        position: PopupMenuPosition.over,
      ),
      tabBarTheme: TabBarThemeData(
        dividerColor: palette.cardBorder,
        labelStyle: cusTitleSmall(themeModeType),
        labelColor: palette.tabIndicator,
        unselectedLabelStyle: cusTitleSmall(themeModeType),
        unselectedLabelColor: palette.foreground.withValues(alpha: 0.65),
        indicatorSize: TabBarIndicatorSize.label,
        overlayColor: WidgetStateProperty.all(
          palette.tabIndicator.withValues(alpha: 0.12),
        ),
        indicator: UnderlineTabIndicator(
          borderRadius: UIConstants.smallBorderRadius,
          borderSide: BorderSide(width: 4, color: palette.tabIndicator),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: palette.accent,
          foregroundColor: palette.onAccent,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),
    );
  }

  Color getDirectClr(ThemeModeType themeModeType) {
    return _palette(themeModeType).background;
  }

  Color getOppositeClr(ThemeModeType themeModeType) {
    return _palette(themeModeType).foreground;
  }

  Color getpureOppositeClr(ThemeModeType themeModeType) {
    if (businessType == BusinessType.general) {
      return themeModeType == ThemeModeType.light ? Colors.black : Colors.white;
    }
    return _palette(themeModeType).foreground;
  }

  Color getpureDirectClr(ThemeModeType themeModeType) {
    if (businessType == BusinessType.general) {
      return themeModeType == ThemeModeType.light ? Colors.white : Colors.black;
    }
    return _palette(themeModeType).background;
  }

  TextStyle cusBodyMedium(ThemeModeType themeModeType) {
    return TextStyle(
      fontSize: 14,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusBodyLarge(ThemeModeType themeModeType) {
    return TextStyle(
      fontSize: 18,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusBodySmall(ThemeModeType themeModeType) {
    return TextStyle(
      fontSize: 12,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusTitleLarge(ThemeModeType themeModeType) {
    return TextStyle(
      fontSize: 22,
      fontWeight: FontWeight.bold,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusTitleMedium(ThemeModeType themeModeType) {
    return TextStyle(
      fontSize: 19,
      fontWeight: FontWeight.bold,
      color: getOppositeClr(themeModeType),
    );
  }

  TextStyle cusTitleSmall(ThemeModeType themeModeType) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: getOppositeClr(themeModeType),
    );
  }

  BoxShadow boxShadow(ThemeModeType themeModeType) => BoxShadow(
        color: businessType == BusinessType.general &&
                themeModeType == ThemeModeType.dark
            ? Colors.transparent
            : Colors.black.withValues(alpha: 0.18),
        blurRadius: 4,
        spreadRadius: 0.5,
        offset: const Offset(0, 2),
      );
}
