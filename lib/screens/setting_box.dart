import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/sliders_widgets.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SettingBox extends StatelessWidget {
  SettingBox({
    required this.scontroller,
    super.key,
  });
  settingController scontroller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      width: Get.width,
      height: 250,
      decoration: BoxDecoration(
          border: Border.all(color: purpule),
          borderRadius: BorderRadius.circular(15)),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          Expanded(
              child: Container(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  SlidersWidgets(scontroller: scontroller),
                  SizedBox(
                    width: 15,
                  ),
                  Expanded(
                      child: Container(
                    child: Column(
                      children: [
                        ipFunction("نام شبکه", "Lan"),
                        SizedBox(
                          height: 10,
                        ),
                        ipFunction("آدرس شبکه", "127.0.0.1"),
                        SizedBox(
                          height: 10,
                        ),
                        ipFunction("نوع آدرس", 'IPV4'),
                      ],
                    ),
                  ))
                ],
              ),
            ),
          )),
          SizedBox(
            width: 15,
          ),
          VerticalDivider(
            color: purpule,
          ),
          SizedBox(
            width: 15,
          ),
          Expanded(
              child: Container(
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: Column(children: [
                Row(
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        "اتصال به رله",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                    Obx(() => Switch(
                          value: scontroller.isRfid.value,
                          onChanged: (value) async {
                            scontroller.isRfid.value = value;
                          },
                        )),
                    Obx(() => Visibility(
                          visible: scontroller.isRfid.value,
                          child: Row(
                            children: [
                              SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                      controller: scontroller.rfipController,
                                      readOnly: false,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'arial'),
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'eg:192.168.1.91',
                                          hintTextDirection:
                                              TextDirection.ltr))),
                              SizedBox(
                                width: 15,
                              ),
                              SizedBox(
                                  width: 100,
                                  child: TextFormField(
                                      controller: scontroller.rfportConroller,
                                      readOnly: false,
                                      textDirection: TextDirection.ltr,
                                      style: TextStyle(
                                          color: Colors.white70,
                                          fontFamily: 'arial'),
                                      decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          hintText: 'eg:2000',
                                          hintTextDirection:
                                              TextDirection.ltr))),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "رله یک",
                                style: TextStyle(color: Colors.white),
                              ),
                              Obx(() => Checkbox(
                                    value: scontroller.isrlOne.value,
                                    onChanged: (value) {
                                      scontroller.isrlOne.value = value!;
                                    },
                                  )),
                              SizedBox(
                                width: 15,
                              ),
                              Text(
                                "رله دو",
                                style: TextStyle(color: Colors.white),
                              ),
                              Obx(() => Checkbox(
                                    value: scontroller.isrlTwo.value,
                                    onChanged: (value) {
                                      scontroller.isrlTwo.value = value!;
                                    },
                                  )),
                              TextButton(
                                  onPressed: () async {
                                    //TODO:DO ITS MAJIC
                                    scontroller.rfconnect.value =
                                        !scontroller.rfconnect.value;
                                  },
                                  child: Text(
                                    scontroller.rfconnect.value ? "قطع" : "اتصال",
                                    style: TextStyle(fontSize: 16),
                                  )),
                            ],
                          ),
                        ))
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 100,
                          child: Text(
                            "فعال سازی آلارم",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Obx(() => Switch(
                              value: scontroller.isAlarm.value,
                              onChanged: (value) {
                                scontroller.isAlarm.value = value;
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text("فعال شد",
                                            textDirection: TextDirection.rtl)));
                              },
                            )),
                      ],
                    )),
              ]),
            ),
          ))
        ],
      ),
    );
  }

  Padding ipFunction(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Row(
        children: [
          Container(
            width: 110,
            child: Text(
              "${label}:",
              style: TextStyle(color: Colors.white, fontSize: 17),
            ),
          ),
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 18),
          )
        ],
      ),
    );
  }
}
