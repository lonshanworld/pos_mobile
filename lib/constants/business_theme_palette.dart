import 'package:flutter/material.dart';
import 'package:pos_mobile/constants/enums.dart';
import 'package:pos_mobile/constants/uiConstants.dart';

class BusinessThemePalette {
  final Color background;
  final Color foreground;
  final Color accent;
  final Color secondary;
  final Color surface;
  final Color onAccent;
  final Color tabIndicator;
  final Color cardBorder;
  final Color popupSurface;

  const BusinessThemePalette({
    required this.background,
    required this.foreground,
    required this.accent,
    required this.secondary,
    required this.surface,
    required this.onAccent,
    required this.tabIndicator,
    required this.cardBorder,
    required this.popupSurface,
  });

  static BusinessThemePalette forType(BusinessType type) {
    switch (type) {
      // ──────────────────────────────────────────────
      // GENERAL  —  pure black / white, unchanged
      // ──────────────────────────────────────────────
      case BusinessType.general:
        return const BusinessThemePalette(
          background: UIConstants.whiteClr,
          foreground: UIConstants.blackClr,
          accent: UIConstants.blackClr,
          secondary: UIConstants.lightPurpleClr,
          surface: Colors.white,
          onAccent: Colors.white,
          tabIndicator: Colors.deepOrange,
          cardBorder: Color(0xFFE0E0E0),
          popupSurface: Colors.white,
        );

      // ──────────────────────────────────────────────
      // CLOTHING  —  deep rose / pink
      // ──────────────────────────────────────────────
      case BusinessType.clothing:
        return const BusinessThemePalette(
          background: Color(0xFFFCE4EC), // pink-rose tint
          foreground: Color(0xFF880E4F), // deep rose-maroon
          accent: Color(0xFFC2185B),    // rose-red
          secondary: Color(0xFFF48FB1), // light pink
          surface: Color(0xFFFFF0F5),   // very light rose
          onAccent: Colors.white,
          tabIndicator: Color(0xFFE91E63),
          cardBorder: Color(0xFFF8BBD0),
          popupSurface: Color(0xFFFCE4EC),
        );

      // ──────────────────────────────────────────────
      // ELECTRONICS  —  steel blue / cyan
      // ──────────────────────────────────────────────
      case BusinessType.electronics:
        return const BusinessThemePalette(
          background: Color(0xFFE3F2FD), // sky-blue tint
          foreground: Color(0xFF0D47A1), // deep navy
          accent: Color(0xFF0277BD),    // strong blue
          secondary: Color(0xFF81D4FA), // light blue
          surface: Color(0xFFF0F8FF),   // near-white blue
          onAccent: Colors.white,
          tabIndicator: Color(0xFF0288D1),
          cardBorder: Color(0xFFBBDEFB),
          popupSurface: Color(0xFFE3F2FD),
        );

      // ──────────────────────────────────────────────
      // GROCERY  —  warm amber / orange
      // ──────────────────────────────────────────────
      case BusinessType.grocery:
        return const BusinessThemePalette(
          background: Color(0xFFFFF3E0), // warm amber tint
          foreground: Color(0xFFBF360C), // deep burnt-orange
          accent: Color(0xFFE65100),    // strong orange
          secondary: Color(0xFFFFCC80), // light amber
          surface: Color(0xFFFFFBF0),   // near-white warm
          onAccent: Colors.white,
          tabIndicator: Color(0xFFF57C00),
          cardBorder: Color(0xFFFFE0B2),
          popupSurface: Color(0xFFFFF3E0),
        );

      // ──────────────────────────────────────────────
      // CONVENIENCE  —  aqua teal / emerald
      // ──────────────────────────────────────────────
      case BusinessType.convenience:
        return const BusinessThemePalette(
          background: Color(0xFFE0F2F1), // aqua-teal tint
          foreground: Color(0xFF004D40), // deep dark teal
          accent: Color(0xFF00695C),    // strong teal
          secondary: Color(0xFF80CBC4), // light teal
          surface: Color(0xFFF0FAFA),   // near-white teal
          onAccent: Colors.white,
          tabIndicator: Color(0xFF00897B),
          cardBorder: Color(0xFFB2DFDB),
          popupSurface: Color(0xFFE0F2F1),
        );

      // ──────────────────────────────────────────────
      // BASIC PHARMACY  —  mint green / medical
      // ──────────────────────────────────────────────
      case BusinessType.basicPharmacy:
        return const BusinessThemePalette(
          background: Color(0xFFE8F5E9), // mint green tint
          foreground: Color(0xFF1B5E20), // deep forest green
          accent: Color(0xFF2E7D32),    // rich forest green
          secondary: Color(0xFFA5D6A7), // light green
          surface: Color(0xFFF4FBF4),   // near-white mint
          onAccent: Colors.white,
          tabIndicator: Color(0xFF388E3C),
          cardBorder: Color(0xFFC8E6C9),
          popupSurface: Color(0xFFE8F5E9),
        );

      // ──────────────────────────────────────────────
      // PHONE / LAPTOP / TABLETS  —  deep indigo / navy
      // ──────────────────────────────────────────────
      case BusinessType.phoneLaptopTablets:
        return const BusinessThemePalette(
          background: Color(0xFFE8EAF6), // soft indigo tint
          foreground: Color(0xFF1A237E), // deep navy indigo
          accent: Color(0xFF283593),    // navy indigo
          secondary: Color(0xFF9FA8DA), // periwinkle
          surface: Color(0xFFF3F4FC),   // near-white indigo
          onAccent: Colors.white,
          tabIndicator: Color(0xFF3949AB),
          cardBorder: Color(0xFFC5CAE9),
          popupSurface: Color(0xFFE8EAF6),
        );

      // ──────────────────────────────────────────────
      // FOOD & BEVERAGE  —  Rich Brown / Mocha
      // ──────────────────────────────────────────────
      case BusinessType.food:
        return const BusinessThemePalette(
          background: Color(0xFFEFEBE9), // warm off-white brown tint
          foreground: Color(0xFF3E2723), // very deep espresso brown
          accent: Color(0xFF4E342E),    // rich mocha brown
          secondary: Color(0xFFBCAAA4), // dusty rose-brown
          surface: Color(0xFFFAF7F5),   // near-white warm
          onAccent: Colors.white,
          tabIndicator: Color(0xFF6D4C41),
          cardBorder: Color(0xFFD7CCC8),
          popupSurface: Color(0xFFEFEBE9),
        );
    }
  }

  // ──────────────────────────────────────────────
  // GENERAL DARK  —  pure black / white dark mode
  // ──────────────────────────────────────────────
  static BusinessThemePalette generalDark() {
    return const BusinessThemePalette(
      background: UIConstants.blackClr,
      foreground: UIConstants.whiteClr,
      accent: UIConstants.whiteClr,
      secondary: UIConstants.lightPurpleClr,
      surface: Color(0xFF222222),
      onAccent: UIConstants.blackClr,
      tabIndicator: Colors.deepOrange,
      cardBorder: Color(0xFF444444),
      popupSurface: Color(0xFF2A2A2A),
    );
  }
}
