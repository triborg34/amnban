import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Compact field used by the plate picker.
///
/// The fields are styled as "plate segments" (cyan outline on a raised
/// surface) so they stay readable against the dark dialog background.
class ReportTextField extends StatelessWidget {
  ReportTextField({double? width, required this.tcontroller});
  double? width;
  TextEditingController tcontroller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 46,
      child: TextField(
        controller: tcontroller,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceHigh,
          hintText: '۰',
          hintStyle: const TextStyle(
            fontSize: 13,
            color: AppColors.textMuted,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.6),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(alpha: 0.45),
            ),
          ),
        ),
      ),
    );
  }
}
