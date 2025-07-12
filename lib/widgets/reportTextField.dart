import 'package:amnban/utils/consts.dart';
import 'package:flutter/material.dart';

class ReportTextField extends StatelessWidget {
  double? width;
  TextEditingController tcontroller;
  ReportTextField({this.width, required this.tcontroller});

  @override
  Widget build(BuildContext context) {
    return Container(
        color: purpule,
        height: 40,
        width: width,
        child: Material(
          color: purpule,
          borderOnForeground: false,
          child: TextField(
            controller: tcontroller,
            style: TextStyle(color: Colors.white, fontSize: 16),
            cursorColor: Colors.white,
            textDirection: TextDirection.ltr,
            decoration: InputDecoration(
                focusColor: Colors.white,
                filled: true,
                fillColor: Colors.deepPurpleAccent,
                disabledBorder: OutlineInputBorder(),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15))),
          ),
        ));
  }
}