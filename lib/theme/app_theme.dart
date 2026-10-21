import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Global light theme for the redesigned UI.
class AppTheme {
  const AppTheme._();

  /// Persian web-font family (the Vazirmatn files are registered as `Vazir`).
  static const String fontFamily = 'Vazir';

  static const double cardRadius = 12;
  static const double fieldRadius = 8;
  static const double buttonRadius = 8;
  static const double buttonHeight = 44;

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);

    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.sidebar,
        onSecondary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        error: AppColors.danger,
        outline: AppColors.border,
      ),
      dividerColor: AppColors.divider,
      splashFactory: InkRipple.splashFactory,
      textTheme: _textTheme(base.textTheme),
      cardTheme: const CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
        ),
      ),
      appBarTheme: const AppBarThemeData(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(cardRadius)),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceMuted,
        isDense: true,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        labelStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
        floatingLabelStyle: const TextStyle(fontSize: 12, color: AppColors.primary),
        border: _fieldBorder(),
        enabledBorder: _fieldBorder(),
        focusedBorder: _fieldBorder(AppColors.primary, 1.4),
        errorBorder: _fieldBorder(AppColors.danger),
        focusedErrorBorder: _fieldBorder(AppColors.danger, 1.4),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.textMuted,
          elevation: 0,
          minimumSize: const Size(0, buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(0, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          minimumSize: const Size(0, buttonHeight),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(buttonRadius),
          ),
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: AppColors.textSecondary),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.sidebar,
        contentTextStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: Colors.white,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(fieldRadius),
        ),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.sidebar,
          borderRadius: BorderRadius.circular(6),
        ),
        textStyle: const TextStyle(fontSize: 11, color: Colors.white),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? Colors.white
                : AppColors.textMuted),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.border),
        trackOutlineColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.primary,
        inactiveTrackColor: AppColors.border,
        thumbColor: AppColors.primary,
        overlayColor: Color(0x1F14922F),
        trackHeight: 4,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? AppColors.primary
                : Colors.transparent),
        checkColor: const WidgetStatePropertyAll<Color>(Colors.white),
        side: const BorderSide(color: AppColors.border),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primary,
        linearTrackColor: AppColors.border,
      ),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),
      dataTableTheme: const DataTableThemeData(
        headingTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textSecondary,
        ),
        dataTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: AppColors.textPrimary,
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
    );
  }

  static OutlineInputBorder _fieldBorder([
    Color color = AppColors.border,
    double width = 1,
  ]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  static TextTheme _textTheme(TextTheme base) {
    return base
        .copyWith(
          headlineSmall: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          titleLarge: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
          titleMedium: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
          bodyMedium: const TextStyle(
            fontSize: 13,
            color: AppColors.textPrimary,
            height: 1.6,
          ),
          bodySmall: const TextStyle(
            fontSize: 11.5,
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          labelLarge: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          labelSmall: const TextStyle(fontSize: 11, color: AppColors.textMuted),
        )
        .apply(fontFamily: fontFamily);
  }

  /// Standard rounded white card with a subtle shadow.
  static BoxDecoration cardDecoration({
    Color? color,
    double radius = cardRadius,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(radius),
      border:
          borderColor == null ? null : Border.all(color: borderColor, width: 1),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}
