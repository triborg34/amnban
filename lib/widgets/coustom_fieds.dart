import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:flutter/material.dart';

/// Light, borderless field used inside the plate-grabber rows.
class CoustomTextField1 extends StatelessWidget {
  CoustomTextField1({
    required this.controller,
    required this.hint,
    required this.width,
    super.key,
  });
  double width;
  String hint;
  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 44,
      child: TextField(
        textDirection: hint != '' ? TextDirection.rtl : TextDirection.ltr,
        controller: controller,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          fillColor: AppColors.surfaceHigh,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

/// Field used by the camera / RTSP forms.
class CoustomTextField2 extends StatelessWidget {
  CoustomTextField2({
    required this.hint,
    required this.tcontroller,
    super.key,
  });

  final String hint;
  final TextEditingController tcontroller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      textDirection:
          hint.toLowerCase() != 'نام' ? TextDirection.ltr : TextDirection.rtl,
      controller: tcontroller,
      style: const TextStyle(
          fontFamily: 'arial', fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceHigh,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          hintTextDirection: hint.toLowerCase() != 'نام'
              ? TextDirection.ltr
              : TextDirection.rtl,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            borderSide: const BorderSide(color: AppColors.border),
          )),
    );
  }
}

/// Field used by the user form (obscures the password hint).
class CoustomTextField3 extends StatelessWidget {
  CoustomTextField3({
    required this.controller,
    required this.hint,
    required this.width,
    super.key,
  });
  double width;
  String hint;
  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 46,
      child: TextField(
        textDirection: hint != '' ? TextDirection.rtl : TextDirection.ltr,
        controller: controller,
        obscureText: hint == 'رمز عبور' ? true : false,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          fillColor: AppColors.surfaceHigh,
          filled: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppTheme.fieldRadius),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
