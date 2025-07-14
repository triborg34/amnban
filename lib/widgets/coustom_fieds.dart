import 'package:flutter/material.dart';

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
        decoration: InputDecoration(
            hintTextDirection: TextDirection.rtl,
            hintText: hint,
            fillColor: Colors.white,
            filled: true,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.transparent, width: 3.0)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent, width: 3.0),
            )),
      ),
    );
  }
}

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
      style: TextStyle(fontFamily: 'arial', color: Colors.white),
      decoration: InputDecoration(
          filled: true,
          fillColor: Color.fromARGB(255, 25, 32, 71),
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
          hintTextDirection: hint.toLowerCase() != 'نام'
              ? TextDirection.ltr
              : TextDirection.rtl,
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.transparent, width: 3.0)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.transparent, width: 3.0),
          )),
    );
  }
}

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
        decoration: InputDecoration(
            hintTextDirection: TextDirection.rtl,
            hintText: hint,
            fillColor: Colors.white,
            filled: true,
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.black, width: 1.0)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.black, width: 1.0),
            )),
      ),
    );
  }
}
