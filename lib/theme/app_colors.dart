import 'package:flutter/material.dart';

/// "امن آفرین" dark palette.
///
/// The application is permanently dark — there is no light variant.
class AppColors {
  const AppColors._();

  // --- base ----------------------------------------------------------------
  /// Scaffold background (near black, slightly blue).
  static const Color background = Color(0xFF0B0F14);

  /// Card / surface level 1.
  static const Color surface = Color(0xFF131A22);

  /// Card / surface level 2 (raised, inputs, headers).
  static const Color surfaceHigh = Color(0xFF1A2430);

  /// Hairline border used on every card and input.
  static const Color border = Color(0xFF22303D);

  /// Softer divider for table rows.
  static const Color divider = Color(0xFF1A2530);

  // --- accents -------------------------------------------------------------
  /// Primary action colour — cool electric cyan.
  static const Color primary = Color(0xFF2EE6D6);
  static const Color primaryDim = Color(0xFF1FB3A7);
  static const Color primarySoft = Color(0x1A2EE6D6);

  /// Secondary accent — amber (warnings, exits).
  static const Color warning = Color(0xFFFFB547);
  static const Color warningSoft = Color(0x1AFFB547);

  /// Denied / unauthorized events — soft red.
  static const Color danger = Color(0xFFFF5C6C);
  static const Color dangerSoft = Color(0x1AFF5C6C);

  /// Violet — unauthorized plates.
  static const Color unauthorized = Color(0xFF8B7CF6);
  static const Color unauthorizedSoft = Color(0x1A8B7CF6);

  /// Allowed entry — green cyan.
  static const Color success = Color(0xFF2EE6D6);
  static const Color successSoft = Color(0x1A2EE6D6);

  // --- text ----------------------------------------------------------------
  static const Color textPrimary = Color(0xFFE8EEF5);
  static const Color textSecondary = Color(0xFF8A97A8);
  static const Color textMuted = Color(0xFF5C6875);

  // --- plates --------------------------------------------------------------
  /// The blue "IR IRAN" band of an Iranian plate.
  static const Color plateBlue = Color(0xFF0B3C8C);
  static const Color plateBorder = Color(0xFF12202E);
}
