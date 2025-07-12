import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/AlphaBetSelector.dart';
import 'package:amnban/widgets/reportTextField.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class licanceSearcher extends StatelessWidget {
  const licanceSearcher({
    super.key,
    required this.rcontroller,
  });

  final reportController rcontroller;

  @override
  Widget build(BuildContext context) {
    rcontroller.firstTwoDigit.clear();
    rcontroller.lastTwoDigit.clear();
    rcontroller.threeDigit.clear();
    rcontroller.persianalhpabet.value = '';
    rcontroller.engishalphabet.value = '';
    return Center(
        child: Container(
      padding: EdgeInsets.all(12),
      width: 400,
      height: 160,
      child: Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            " اطلاعات پلاک را وارد کنید",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            textDirection: TextDirection.ltr,
            children: [
              ReportTextField(
                  width: 50, tcontroller: rcontroller.firstTwoDigit),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 40,
                child: TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: Colors.deepPurple),
                  onPressed: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (context) => DraggableScrollableSheet(
                        initialChildSize:
                            0.47, // You can adjust the size of the bottom sheet
                        minChildSize: 0.3,
                        maxChildSize: 0.7,
                        expand: false,
                        builder: (context, scrollController) {
                          return Alphabetselector(
                            scrollController: scrollController,
                          );
                        },
                      ),
                    );
                  },
                  child: Obx(() => Text(
                        rcontroller.persianalhpabet.value == ''
                            ? "انتخاب حرف"
                            : rcontroller.persianalhpabet.value,
                        style: TextStyle(color: Colors.white),
                      )),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              ReportTextField(width: 70, tcontroller: rcontroller.threeDigit),
              SizedBox(
                width: 10,
              ),
              Text(
                '/',
                style: TextStyle(color: Colors.white),
              ),
              SizedBox(
                width: 10,
              ),
              ReportTextField(width: 50, tcontroller: rcontroller.lastTwoDigit),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Container(
            width: 200,
            child: ElevatedButton(
                onPressed: () {
                  rcontroller.pickerPlate.value =
                      "${rcontroller.firstTwoDigit.text}${rcontroller.engishalphabet}${rcontroller.threeDigit.text}${rcontroller.lastTwoDigit.text}";
                  Navigator.pop(context);
                },
                child: Text("ثبت")),
          )
        ],
      ),
      decoration: BoxDecoration(
          color: purpule, borderRadius: BorderRadius.circular(15)),
    ));
  }
}
