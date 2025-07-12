import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';

import 'package:amnban/widgets/licance_searcher.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Reportscreen extends StatelessWidget {
  Reportscreen({super.key});

  reportController rcontroller = Get.find<reportController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.height,
      padding: EdgeInsets.all(15),
      child: Column(
        textDirection: TextDirection.rtl,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () async {
                  await showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return licanceSearcher(rcontroller: rcontroller);
                    },
                  );
                },
                child: Container(
                  width: 150,
                  height: 50,
                  child: Center(
                      child: Obx(
                    () => Text(
                      rcontroller.pickerPlate.value.length > 0
                          ? rcontroller.pickerPlate.value
                          : "انتخاب",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  )),
                  decoration: BoxDecoration(
                      color: purpule, borderRadius: BorderRadius.circular(15)),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
