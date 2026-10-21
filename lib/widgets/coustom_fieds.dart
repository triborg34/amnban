import 'package:amnban/theme/app_colors.dart';
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
      child: TextField(
        textDirection: hint != '' ? TextDirection.rtl : TextDirection.ltr,
        controller: controller,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintTextDirection: TextDirection.rtl,
          hintText: hint,
          fillColor: AppColors.surfaceHigh,
          filled: true,
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}

/// Dark field used by the camera / RTSP forms.
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
      style: const TextStyle(fontFamily: 'arial', fontSize: 13),
      decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surfaceHigh,
          hintText: hint,
          hintStyle: const TextStyle(color: AppColors.textMuted),
          hintTextDirection: hint.toLowerCase() != 'نام'
              ? TextDirection.ltr
              : TextDirection.rtl,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 1.4)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          )),
    );
  }
}

/// Light field used by the user form (obscures the password hint).
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
      child: TextField(
        textDirection: hint != '' ? TextDirection.rtl : TextDirection.ltr,
        controller: controller,
        obscureText: hint == 'رمز عبور' ? true : false,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
            hintTextDirection: TextDirection.rtl,
            hintText: hint,
            fillColor: AppColors.surfaceHigh,
            filled: true,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.4)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            )),
      ),
    );
  }
}
