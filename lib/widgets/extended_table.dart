import 'package:amnban/screens/details_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/arvandpelak.dart';
import 'package:amnban/widgets/lisancepage.dart';
import 'package:amnban/widgets/pdf_printig.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class ExtendedTable extends StatelessWidget {
  ExtendedTable(
      {required this.dcontroller,
      required this.kcontroller,
      required this.index,
      super.key});

  databaseController dcontroller;
  knowPersonController kcontroller;
  int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() => Container(
          margin: EdgeInsets.all(15),
          height: 48,
          child: Row(
            textDirection: TextDirection.rtl,
            children: [
              Container(
                  decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: purpule))),
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  width: 10.w,
                  height: 48,
                  child: dcontroller.tableContect.value.isarvand == 'arvand'
                      ? ArvandPelak(entry: dcontroller.tableContect.value)
                      : LicanceNumber(entry: dcontroller.tableContect.value)),
              InkWell(
                onTap: () {
                  print("?");
                  Get.to(()=> Detailedscreen(
                      selectedModel: dcontroller.tableContect.value,
                      index: index,
                      kcontroller: kcontroller));
                },
                child: Container(
                  height: 48,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border(left: BorderSide(color: purpule))),
                  padding: EdgeInsets.symmetric(horizontal: 0),
                  width: 10.w,
                  child: Center(
                    child: Hero(
                      tag: 'heroTag${dcontroller.selectedIndex.value}',
                      child: Image.network(
                        "http://127.0.0.1:8090/api/files/database/${dcontroller.tableContect.value.id}/${dcontroller.tableContect.value.imgpath}",
                        fit: BoxFit.fill,
                        width: 205,
                      ),
                    ),
                  ),
                ),
              ),
              Container(
                  decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: purpule))),
                  height: 98,
                  width: 10.w,
                  child: Center(
                      child: Text(
                    dcontroller.tableContect.value.platePercent.toString() +
                        "%",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ))),
              Container(
                  decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: purpule))),
                  height: 98,
                  width: 10.w,
                  child: Center(
                      child: Text(
                    kcontroller.knowPerson
                            .where(
                              (element) =>
                                  element.plateNumber ==
                                  dcontroller.tableContect.value.plateNum,
                            )
                            .isEmpty
                        ? "-"
                        : kcontroller
                            .knowPerson[kcontroller.knowPerson.indexWhere(
                            (element) =>
                                element.plateNumber ==
                                dcontroller.tableContect.value.plateNum,
                          )]
                            .name!,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ))),
              Container(
                  decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: purpule))),
                  height: 98,
                  width: 10.w,
                  child: Center(
                      child: Text(
                    dcontroller.tableContect.value.plateNum!.contains("x")
                        ? 'تاکسی'
                        : dcontroller.tableContect.value.plateNum!.contains('A')
                            ? "دولتی"
                            : dcontroller.tableContect.value.plateNum!
                                    .contains('PuV')
                                ? 'کامیون'
                                : "شخصی",
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ))),
              Container(
                  decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: purpule))),
                  height: 98,
                  width: 10.w,
                  child: Center(
                      child: Text(
                    dcontroller.tableContect.value.eDate!.toPersianDate(),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ))),
              Container(
                  decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: purpule))),
                  height: 98,
                  width: 10.w,
                  child: Center(
                      child: Text(
                    dcontroller.tableContect.value.eDate!.toPersianDate(),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ))),
              Container(
                  decoration: BoxDecoration(
                      border: Border(left: BorderSide(color: purpule))),
                  height: 98,
                  width: 10.w,
                  child: Center(
                      child: Text(
                    dcontroller.tableContect.value.eTime!.toPersianDigit(),
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white, fontSize: 10.sp),
                  ))),
              Container(
                decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: purpule))),
                width: 10.w,
                child: PdfPrintig(
                    kcontroller: kcontroller, dcontroller: dcontroller),
              ),
              //           Visibility(
              //   visible: Get.find<Boxes>().settingbox.last.isRfid!,
              //   child: IconButton(
              //       onPressed: () {
              //         onRelayOne();
              //       },
              //       icon: Icon(Icons.door_back_door)),
              // )
            ],
          ),
          decoration: BoxDecoration(border: Border.all(color: purpule)),
        ));
  }
}
