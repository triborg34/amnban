import 'package:amnban/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Compact field used by the plate searcher.
class ReportTextField extends StatelessWidget {
  ReportTextField({double? width, required this.tcontroller});
  double? width;
  TextEditingController tcontroller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: tcontroller,
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 14, color: AppColors.textPrimary),
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.surfaceHigh,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.border),
          ),
        ),
      ),
    );
  }
}
