import 'package:flutter/material.dart';

/// DIESPI inspired palette.
///
/// The app used to be a single purple (`purpule`) theme; the redesign keeps
/// those globals alive for backwards compatibility but every new widget uses
/// this palette instead.
class AppColors {
  const AppColors._();

  // --- brand ---------------------------------------------------------------
  /// Primary green — logo, primary buttons, active states.
  static const Color primary = Color(0xFF14922F);
  static const Color primaryDark = Color(0xFF0E6B22);
  static const Color primaryLight = Color(0xFFE8F5EB);

  // --- dark accents --------------------------------------------------------
  /// Sidebar / dark teal.
  static const Color sidebar = Color(0xFF1F4B4F);
  static const Color sidebarDeep = Color(0xFF17393C);
  static const Color sidebarBorder = Color(0xFF2E666A);
  static const Color sidebarText = Color(0xFFE7F1F0);
  static const Color sidebarMuted = Color(0xFF9DBDBB);

  // --- login ---------------------------------------------------------------
  static const Color loginBackground = Color(0xFF2E4A4E);
  static const Color loginCard = Color(0xFFF3E9D6);
  static const Color loginCardBorder = Color(0xFFE2D5BC);

  // --- surfaces ------------------------------------------------------------
  static const Color background = Color(0xFFF1F5F4);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF7FAFA);
  static const Color border = Color(0xFFE1E8E6);
  static const Color divider = Color(0xFFEDF2F1);

  // --- text ----------------------------------------------------------------
  static const Color textPrimary = Color(0xFF1E2C2F);
  static const Color textSecondary = Color(0xFF5B6B6D);
  static const Color textMuted = Color(0xFF93A3A5);
  static const Color textOnDark = Color(0xFFFFFFFF);

  // --- status --------------------------------------------------------------
  /// Entry / success / allowed.
  static const Color success = Color(0xFF14922F);
  static const Color successSoft = Color(0xFFE6F4E9);

  /// Exit / cash / unpaid / unrecognised plate.
  static const Color warning = Color(0xFFF28C4E);
  static const Color warningSoft = Color(0xFFFDF0E6);

  /// Unauthorized (known person, not allowed).
  static const Color unauthorized = Color(0xFF5B4BB0);
  static const Color unauthorizedSoft = Color(0xFFEDEBFA);

  /// "Not allowed" text colour.
  static const Color danger = Color(0xFFE04F39);
  static const Color dangerSoft = Color(0xFFFBEBE7);

  // --- charts --------------------------------------------------------------
  static const Color chartTeal = Color(0xFF1A9AA6);
  static const Color chartGreen = Color(0xFF14922F);
  static const Color chartOrange = Color(0xFFF28C4E);
  static const Color chartPurple = Color(0xFF5B4BB0);

  // --- plates --------------------------------------------------------------
  static const Color plateBlue = Color(0xFF003399);
  static const Color plateBorder = Color(0xFF1B1B1B);
}
