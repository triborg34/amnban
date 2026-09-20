import 'package:amnban/models/databaseEntry.dart';

import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:responsive_sizer/responsive_sizer.dart';



class ArvandPelak extends StatelessWidget {
  late databaseClass entry;
  ArvandPelak({required this.entry});

  String _label() {
    final plate = entry.plateNum ?? '';
    if (plate.isEmpty) return '-';
    if (plate.length <= 5) return plate.toPersianDigit();
    try {
      return "${plate.toPersianDigit().substring(0, plate.length - 2)} | ${plate.toPersianDigit().substring(plate.length - 2)}";
    } catch (_) {
      return plate.toPersianDigit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(0),
        width: 10.w,
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.white,
        ),
        child: Center(
          child: Row(
            children: [
              Container(
                width: 30,
                color: const Color.fromARGB(255, 64, 107, 180),
                child: Center(
                  child:  Image.asset('assets/images/arvand.png')
                     
                ),
              ),
              Container(
                alignment: Alignment.topCenter,
                padding: EdgeInsets.symmetric(horizontal: 0),
                child: Center(
                  child: Text(
                    _label(),
                    style: TextStyle(color: Colors.black, fontSize: 11.sp),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}

class ArvandPelak2 extends StatelessWidget {
  late databaseClass entry;
  ArvandPelak2({required this.entry});

  String _label() {
    final plate = entry.plateNum ?? '';
    if (plate.isEmpty) return '-';
    if (plate.length <= 5) return plate.toPersianDigit();
    try {
      return "${plate.toPersianDigit().substring(0, plate.length - 2)} | ${plate.toPersianDigit().substring(plate.length - 2)}";
    } catch (_) {
      return plate.toPersianDigit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.all(0),
        width: 10.w,
        height: 35,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
          color: Colors.white,
        ),
        child: Center(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 30,
                color: const Color.fromARGB(255, 64, 107, 180),
                child: Center(
                  child: Image.asset('assets/images/arvand.png')
            
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                       alignment: Alignment.topCenter,
                    padding: EdgeInsets.symmetric(horizontal: 0),
                    child: Center(
                      child: Text(
                        _label(),
                        style: TextStyle(color: Colors.black, fontSize: 11.sp),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ));
  }
}
