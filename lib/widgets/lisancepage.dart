import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:flutter/material.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class LicanceNumber extends StatelessWidget {
  const LicanceNumber({
    super.key,
    required this.entry,
  });

  final databaseClass entry;

  @override
  Widget build(BuildContext context) {

    return Container(
      width: 1.5.w,
      margin: EdgeInsets.only(right: 3),
      height: 40,
      decoration: BoxDecoration(
        
        borderRadius: BorderRadius.circular(5),
          color: Colors.white,
          border: Border.all(width: 3)),
      child: Row(
        children: [
          Container(
            height: 40,
            child: Center(
              child: Image.network(
                  'assets/images/iranFlag.png') 
          
            ),
            width: 1.5.w,
            padding: EdgeInsets.all(3),
            decoration: BoxDecoration(
              border: Border(
                  right: BorderSide(
                      color: Colors.black)),
              color: Color.fromRGBO(
                  0, 51, 153, 1.0),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: 5),
            decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                    right: BorderSide(
                        color:
                            Colors.black))),
            child: Center(
              child: Text(
              
                convertToPersian(
                    entry.plateNum!,
                    alphabetP2)[0].contains('آ') ? convertToPersian(
                    entry.plateNum!,
                    alphabetP2)[0].replaceAll("آ", "الف")  :   convertToPersian(
                    entry.plateNum!,
                    alphabetP2)[0], 
                textDirection:
                    TextDirection.rtl,
                style:
                    TextStyle(fontSize: 11.sp),
              ),
            ),
          ),
          SizedBox(
            width: 1.5.w,
            height:40,
            child: Container(
                padding: EdgeInsets.only(
                    left: 0),
                color: Colors.white,
                child: Center(
                  child: Text(
                      convertToPersian(
                          entry.plateNum!,
                          alphabetP2)[1],
                      textDirection:
                          TextDirection.rtl,
                      style: TextStyle(
                          fontSize:11.sp
                          )),
                )),
          )
        ],
      ),
    );
  }
}
