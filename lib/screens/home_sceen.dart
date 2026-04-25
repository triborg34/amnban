import 'package:amnban/screens/details_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/arvandpelak.dart';
import 'package:amnban/widgets/extended_table.dart';
import 'package:amnban/widgets/data_base_entries.dart';
import 'package:amnban/widgets/lisancepage.dart';
import 'package:amnban/widgets/video_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

class HomeSceen extends StatelessWidget {
  HomeSceen({
    required this.mController,
    super.key,
  });
  mainPageConroller mController;
  databaseController dcontroller = Get.find<databaseController>();
  knowPersonController kcontroller = Get.find<knowPersonController>();
  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.digit1) {
          onRelayOne();
        }
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.digit2) {
          onRelayTwo();
        }
      },
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(15),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.height,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            textDirection: TextDirection.rtl,
            children: [
              Row(
                textDirection: TextDirection.rtl,
                children: [
                  VideoBox(mController: mController),
                  SizedBox(
                    width: 15,
                  ),
                  dataBaseEntries(
                      dcontroller: dcontroller,
                      mController: mController,
                      kcontroller: kcontroller)
                ],
              ),
              SizedBox(
                height: 15,
              ),
              Obx(() => dcontroller.entries.isEmpty
                  ? SizedBox.shrink()
                  : Visibility(
                      visible: mController.isSelected.value,
                      child: ExtendedTable(
                          index: dcontroller.selectedIndex.value,
                          dcontroller: dcontroller,
                          kcontroller: kcontroller),
                    )),

              //TODO:ADD ALL NEW THINGS IN CONTROLLER
              SizedBox(
                height: 15,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                textDirection: TextDirection.rtl,
                children: [
                  Container(
                      width: 300,
                      decoration: BoxDecoration(
                          color: purpule,
                          borderRadius: BorderRadius.circular(15)),
                      child: Obx(() => Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            textDirection: TextDirection.rtl,
                            children: [
                              amarWidget(
                                title: "تعداد کل پلاک های امروز",
                                value: dcontroller.todayCount.value.toString(),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              amarWidget(
                                  title: "تعداد کل پلاک های مجاز امروز ",
                                  value: dcontroller.todayallowd.length
                                      .toString()),
                              SizedBox(
                                height: 5,
                              ),
                              amarWidget(
                                  title: "تعداد کل پلاک های غیر مجاز امروز ",
                                  value: dcontroller.todayunallowed.length
                                      .toString()),
                              SizedBox(
                                height: 5,
                              ),
                              amarWidget(
                                  title: "تعداد کل پلاک های سالم امروز ",
                                  value:
                                      dcontroller.goodPlate.value.toString()),
                              SizedBox(
                                height: 5,
                              ),
                              amarWidget(
                                  title: "تعداد کل پلاک های مخدوش امروز ",
                                  value: dcontroller.badPlate.value.toString()),
                              SizedBox(
                                height: 5,
                              ),
                              TextButton(
                                  onPressed: () async {
                                    await showAmar(
                                        context, dcontroller.todayallowd);
                                  },
                                  child: Text(
                                    "لیست پلاک های مجاز امروز",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  )),
                              SizedBox(
                                height: 5,
                              ),
                              TextButton(
                                  onPressed: () async {
                                    await showAmar(
                                        context, dcontroller.todayunallowed);
                                  },
                                  child: Text(
                                    "لیست پلاک های غیر مجاز امروز",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 16),
                                  )),
                            ],
                          ))),
                  SizedBox(
                    width: 15,
                  ),
                  Obx(
                    () {
                      if (dcontroller.todayCount.value == 0) {
                        return SizedBox.shrink();
                      } else {
                        return Container(
                          color: Colors.transparent,
                          width: 300,
                          height: 300,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              barChartWidget(
                                total: dcontroller.todayCount.value,
                                portiant: dcontroller.goodPlate.value,
                                title: "سالم",
                                color: Colors.red,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              barChartWidget(
                                total: dcontroller.todayCount.value,
                                portiant: dcontroller.badPlate.value,
                                title: "مخدوش",
                                color: Colors.yellow,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              barChartWidget(
                                total: dcontroller.todayCount.value,
                                portiant: dcontroller.todayallowd.length,
                                title: "مجاز",
                                color: Colors.blue,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              barChartWidget(
                                total: dcontroller.todayCount.value,
                                portiant: dcontroller.todayunallowed.length,
                                title: "غیر مجاز",
                                color: Colors.cyan,
                              )
                            ],
                          ),
                        );
                      }
                    },
                  )
                  // dcontroller.todayCount.value == 0
                  //     ? SizedBox.shrink()
                  //     :
                  //
                  //                 ),
                ],
              ),
              Spacer(),
              Get.find<settingController>().settings.last.isRfid! &&
                      Get.find<settingController>().settings.last.rfconnect!
                  ? Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        IconButton(
                            onPressed: () => onRelayOne(),
                            icon: Icon(Icons.door_back_door)),
                        SizedBox(
                          width: 25,
                        ),
                        IconButton(
                            onPressed: () => onRelayTwo(),
                            icon: Icon(Icons.door_front_door))
                      ],
                    )
                  : SizedBox.shrink()
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> showAmar(BuildContext context, var data) {
    return showDialog(
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            color: purpule,
            width: 500,
            height: 300,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(
                height: 2,
              ),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () {
                  Get.to(() => Detailedscreen(
                      selectedModel: data[index],
                      index: index,
                      kcontroller: kcontroller));
                },
                child: Container(
                  width: 500,
                  height: 50,
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (data[index].isarvand == 'arvand')
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: ArvandPelak2(entry: data[index]),
                        )
                      else
                        SizedBox(
                          width: 150,
                          height: 50,
                          child: LicanceNumber(
                            entry: data[index],
                          ),
                        ),
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Center(
                          child: Text(
                            data[index].eDate!.toString().toPersianDate(),
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Center(
                          child: Text(
                            data[index].eTime!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                      VerticalDivider(
                        color: Colors.black,
                      ),
                      SizedBox(
                        width: 100,
                        height: 50,
                        child: Center(
                          child: Text(
                            kcontroller
                                .knowPerson[kcontroller.knowPerson.indexWhere(
                              (element) =>
                                  element.plateNumber == data[index].plateNum,
                            )]
                                .name!,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  decoration: BoxDecoration(
                    color: selecetpurpule,
                    border: Border.all(color: Colors.black),
                  ),
                ),
              ),
              itemCount: data.length,
            ),
          ),
        );
      },
    );
  }
}

class amarWidget extends StatelessWidget {
  amarWidget({super.key, required this.title, required this.value});

  String? title;
  String? value;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.all(10),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Text(
              ": $title",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            Spacer(),
            Text(
              "$value",
              style: TextStyle(color: Colors.white, fontSize: 16),
            )
          ],
        ));
  }
}

class barChartWidget extends StatelessWidget {
  barChartWidget(
      {super.key,
      required this.total,
      required this.portiant,
      required this.title,
      required this.color});

  int total;
  int portiant;
  String title;
  Color color;

  @override
  Widget build(BuildContext context) {
    int cacul=0;
    try{
       cacul = caculate(total, portiant);
   
    }catch(e){
      cacul=0;
    }
    
    
    return Column(mainAxisAlignment: MainAxisAlignment.end, children: [
      Container(
        width: 50,
        child: Center(child: Text("${cacul}%")),
        color: color,
        height: cacul==0 ? 0 : cacul.toDouble() + 20,
      ),
      SizedBox(
        height: 15,
      ),
      Text(
        title,
        style: TextStyle(color: Colors.white),
      )
    ]);
  }

  int caculate(int total, int section) {
    double res = section / total;
    return (res * 100).toInt();
  }
}



/*


PieChart(PieChartData(sections: [
                        PieChartSectionData(
                          radius: 50,
                            titleStyle: TextStyle(color: Colors.white),
                            showTitle: true,
                            title:
                                "سالم\n %${(caculate(dcontroller.todayCount.value, dcontroller.goodPlate.value) * 100).toInt()}",
                            value: caculate(dcontroller.todayCount.value,
                                dcontroller.goodPlate.value),
                            color: Colors.red),
                        PieChartSectionData(
                          radius: 50,
                            titleStyle: TextStyle(color: Colors.white),
                            showTitle: true,
                            title:
                                "مخدوش \n%${(caculate(dcontroller.todayCount.value, dcontroller.badPlate.value) * 100).toInt()}",
                            value: caculate(dcontroller.todayCount.value,
                                dcontroller.badPlate.value),
                            color: Colors.green),
                             PieChartSectionData(
                              radius: 50,
                            titleStyle: TextStyle(color: Colors.black),
                            showTitle: true,
                            title:
                                "مجاز \n%${(caculate(dcontroller.todayCount.value, dcontroller.todayallowd.length) * 100).toInt()}",
                            value: caculate(dcontroller.todayCount.value,
                                dcontroller.todayallowd.length),
                            color: Colors.white),
                                    PieChartSectionData(
                                      radius: 50,
                            titleStyle: TextStyle(color: Colors.black),
                            showTitle: true,
                            title:
                                "غیر مجاز \n%${(caculate(dcontroller.todayCount.value, dcontroller.todayunallowed.length) * 100).toInt()}",
                            value: caculate(dcontroller.todayCount.value,
                                dcontroller.todayunallowed.length),
                            color: Colors.cyan),
                      ]))
*/