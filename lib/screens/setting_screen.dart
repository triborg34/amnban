import 'package:amnban/screens/general_setting.dart';
import 'package:amnban/screens/user_box.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingScreen extends StatelessWidget {
  SettingScreen({
    super.key,
  });

  userController ucontroller = Get.find<userController>();
  settingController scontroller = Get.find<settingController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      height: MediaQuery.maybeOf(context)!.size.height,
      width: MediaQuery.maybeOf(context)!.size.height,
      child: SingleChildScrollView(
        child: Column(
          textDirection: TextDirection.rtl,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () {
                scontroller.isUsers.value = !scontroller.isUsers.value;
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: purpule,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        "کاربران",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Obx(
                        () => scontroller.isUsers.value
                            ? Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Obx(
              () => AnimatedCrossFade(
                firstChild: SizedBox.shrink(),
                secondChild: UserBox(
                  scontroller: scontroller,
                  ucontroller: ucontroller,
                ),
                crossFadeState: scontroller.isUsers.value
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: Duration(milliseconds: 350),
                firstCurve: Curves.decelerate,
                secondCurve: Curves.decelerate,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                scontroller.isGeneral.value = !scontroller.isGeneral.value;
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: purpule,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        "عمومی",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Obx(
                        () => scontroller.isGeneral.value
                            ? Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Obx(() => AnimatedCrossFade(
                  firstChild: SizedBox.shrink(),
                  secondChild: GeneralSetting(scontroller: scontroller),
                  crossFadeState: scontroller.isGeneral.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 350),
                  firstCurve: Curves.decelerate,
                  secondCurve: Curves.decelerate,
                )),
            SizedBox(
              height: 15,
            ),
            InkWell(
              onTap: () {
                scontroller.isInfo.value = !scontroller.isInfo.value;
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 15),
                width: MediaQuery.of(context).size.width,
                height: 50,
                color: purpule,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Text(
                        "درباره",
                        style: TextStyle(color: Colors.white),
                      ),
                      Spacer(),
                      Obx(
                        () => scontroller.isInfo.value
                            ? Icon(
                                Icons.arrow_downward,
                                color: Colors.white,
                              )
                            : Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                              ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Obx(() => AnimatedCrossFade(
                  firstChild: SizedBox.shrink(),
                  secondChild: InfoBox(),
                  crossFadeState: scontroller.isInfo.value
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: Duration(milliseconds: 350),
                  firstCurve: Curves.decelerate,
                  secondCurve: Curves.decelerate,
                )),
          ],
        ),
      ),
    );
  }
}

class InfoBox extends StatelessWidget {
  const InfoBox({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      width: Get.width,
      height: 200,
      decoration: BoxDecoration(
          border: Border.all(color: purpule), borderRadius: BorderRadius.circular(15),),
          child: Column(
            children: [
              KeyValueRow(
                    keyString: "BuilDNumber", valueString: "SN/1404717"),
                Divider(
                  color: purpule,
                ),
                KeyValueRow(keyString: "UpdateNo", valueString: "14040423"),
                Divider(
                  color: purpule,
                ),
                KeyValueRow(
                    keyString: "Last Update",
                    valueString:
                        "${DateTime.now().year.toString()}/${DateTime.now().month.toString()}/${DateTime.now().day.toString()}"),
                Divider(color: purpule),
                KeyValueRow(
                    keyString: "Train Model Serial",
                    valueString: "YOLOV5M100300"),
                Divider(
                  color: purpule,
                ),
            ],
          ),
    );
  }
}

class KeyValueRow extends StatelessWidget {
  late String keyString;
  late String valueString;
  KeyValueRow({required this.keyString, required this.valueString});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          color: Colors.transparent,
          width: 150,
          child: Text(
            keyString + " : ",
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
                fontFamily: 'arial'),
          ),
        ),
        Text(
          "  " + valueString,
          style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: "arial"),
        )
      ],
    );
  }
}
