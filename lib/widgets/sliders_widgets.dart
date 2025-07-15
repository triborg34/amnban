import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/futurs_of_system_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SlidersWidgets extends StatelessWidget {
  const SlidersWidgets({
    super.key,
    required this.scontroller,
  });

  final settingController scontroller;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Container(
      child: Column(
        children: [
          Row(
            textDirection: TextDirection.rtl,
            children: [
              FutursOfSystemRow(
                lable: "دقت تشخیص پلاک",
              ),
              SizedBox(
                width: 5,
              ),
              Obx(() => SizedBox(
                    height: 10,
                    child: Slider(
                      activeColor: selecetpurpule,
                      inactiveColor: Colors.white70,
                      value: scontroller.plateConf.value,
                      onChanged: (value) {
                        scontroller.plateConf.value = value;
                      },
                    ),
                  )),
              SizedBox(
                width: 0,
              ),
              Obx(
                () => Text(
                  textDirection: TextDirection.rtl,
                  "${(scontroller.plateConf.value * 100).round()}%",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              )
            ],
          ),
          SizedBox(
            height: 35,
          ),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              FutursOfSystemRow(
                lable: "دقت تشخیص حروف",
              ),
              Obx(() => SizedBox(
                    height: 10,
                    child: Slider(
                      activeColor: selecetpurpule,
                      inactiveColor: Colors.white70,
                      value: scontroller.charConf.value,
                      onChanged: (value) {
                        scontroller.charConf.value = value;
                      },
                    ),
                  )),
              SizedBox(
                width: 0,
              ),
              Obx(
                () => Text(
                  "${(scontroller.charConf.value * 100).round()}%",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 25,
          ),
          Row(
            textDirection: TextDirection.rtl,
            children: [
              FutursOfSystemRow(
                lable: "کیفیت عکس",
              ),
              Obx(() => SizedBox(
                    height: 10,
                    child: Slider(
                      min: 0,
                      max: 100,
                      divisions: 10,
                      activeColor: selecetpurpule,
                      inactiveColor: Colors.white70,
                      value: scontroller.quality.value,
                      onChanged: (value) {
                        scontroller.quality.value = value;
                      },
                    ),
                  )),
              SizedBox(
                width: 0,
              ),
              Obx(
                () => Text(
                  "${(scontroller.quality.value)}%",
                  style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }
}
