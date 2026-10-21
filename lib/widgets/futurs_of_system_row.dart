import 'package:amnban/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Fixed-width caption used next to the detection sliders.
class FutursOfSystemRow extends StatelessWidget {
  String lable;

  FutursOfSystemRow({required this.lable});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 110,
      child: Text(
        lable,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
    );
  }
}
