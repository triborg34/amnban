import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class FutursOfSystemRow extends StatelessWidget {
  String lable;

  FutursOfSystemRow({required this.lable});
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 6.w,
      child: Text(
        lable,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}