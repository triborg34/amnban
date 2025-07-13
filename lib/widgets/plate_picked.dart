import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:flutter/material.dart';

class PlatePicked extends StatelessWidget {
  const PlatePicked({
    super.key,
    required this.rcontroller,
  });

  final reportController rcontroller;

  @override
  Widget build(BuildContext context) {
    return Container(
          height: 40,
          width: 210,
          decoration: BoxDecoration(
              color: purpule,
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: rcontroller.firstTwoDigit.text.length != 0 &&
                    rcontroller.threeDigit.text.length != 0 &&
                    rcontroller.lastTwoDigit.text.length != 0
                // &&
                // rcontroller.engishalphabet.value.length < 0
                ? Text(
                    convertToPersianString(
                        rcontroller.pickerPlate.value,
                        alphabetP2),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        color: Colors.white, fontSize: 18),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 30,
                        width: 36,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius:
                                BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            rcontroller.firstTwoDigit.text
                                        .length !=
                                    0
                                ? rcontroller.firstTwoDigit.text
                                : '-',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 30,
                        width: 36,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius:
                                BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            rcontroller.persianalhpabet.value,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 10),
                        height: 30,
                        width: 36,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius:
                                BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            rcontroller.threeDigit.text.length !=
                                    0
                                ? rcontroller.threeDigit.text
                                : '-',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        '/',
                        style: TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Container(
                        height: 30,
                        width: 36,
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius:
                                BorderRadius.circular(10)),
                        child: Center(
                          child: Text(
                            rcontroller.lastTwoDigit.text
                                        .length !=
                                    0
                                ? rcontroller.lastTwoDigit.text
                                : '-',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
  }
}
