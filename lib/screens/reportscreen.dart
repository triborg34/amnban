import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/screens/details_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/widgets/arvandpelak.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:printing/printing.dart';
import 'package:amnban/widgets/licance_searcher.dart';
import 'package:amnban/widgets/lisancepage.dart';
import 'package:amnban/widgets/plate_picked.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_datetime_picker/persian_datetime_picker.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

class Reportscreen extends StatelessWidget {
  Reportscreen({super.key});

  reportController rcontroller = Get.find<reportController>();
  knowPersonController kcontroller = Get.find<knowPersonController>();
  @override
  Widget build(BuildContext context) {
    rcontroller.inilazed();
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
              GetBuilder<reportController>(
                  builder: (controller) => rcontroller.isArvand.value
                      ? Container(
                          height: 40,
                          width: 210,
                          decoration: BoxDecoration(
                              color: purpule,
                              borderRadius: BorderRadius.circular(15)),
                          child: Center(
                            child: Text(
                              rcontroller.pickerPlate.value,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      : PlatePicked(rcontroller: rcontroller)),
              TextButton(
                onPressed: () async {
                  await showAdaptiveDialog(
                    context: context,
                    builder: (context) =>
                        licanceSearcher(rcontroller: rcontroller),
                  );
                },
                child: Text(
                  "انتخاب",
                  style: TextStyle(color: Colors.white),
                ),
                style: TextButton.styleFrom(),
              ),
              SizedBox(
                width: 25,
              ),
              SizedBox(
                height: 40,
                width: 130,
                child: FilledButton(
                    style: TextButton.styleFrom(backgroundColor: purpule),
                    onPressed: () async {
                      Jalali? picked = await showPersianDatePicker(
                          context: context,
                          textDirection: TextDirection.ltr,
                          initialDate: Jalali.now(),
                          firstDate: Jalali(1385),
                          lastDate: Jalali(1499));

                      var d = picked!.toGregorian();
                      rcontroller.firstDate.value =
                          d.toDateTime().toString().split(' ')[0];
                      print(rcontroller.firstDate.value);
                      rcontroller.isDate.value = true;
                    },
                    child: Obx(() => Text(
                        rcontroller.firstDate.value.length == 0
                            ? "از تاریخ"
                            : rcontroller.firstDate.value.toPersianDate(),
                        style: TextStyle(fontSize: 14)))),
              ),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 40,
                width: 130,
                child: FilledButton(
                    style: TextButton.styleFrom(backgroundColor: purpule),
                    onPressed: () async {
                      Jalali? picked = await showPersianDatePicker(
                          context: context,
                          initialDate: Jalali.now(),
                          textDirection: TextDirection.ltr,
                          firstDate: Jalali(1385),
                          lastDate: Jalali(1499));

                      var d = picked!.toGregorian();
                      rcontroller.lastDate.value =
                          d.toDateTime().toString().split(' ')[0];
                      print(rcontroller.lastDate.value);
                    },
                    child: Obx(() => Text(
                        rcontroller.lastDate.value.length == 0
                            ? "به تاریخ"
                            : rcontroller.lastDate.value.toPersianDate(),
                        style: TextStyle(fontSize: 14)))),
              ),
              SizedBox(
                width: 25,
              ),
              SizedBox(
                height: 40,
                width: 130,
                child: FilledButton(
                    style: TextButton.styleFrom(backgroundColor: purpule),
                    onPressed: () async {
                      var t = await showTimePicker(
                        context: context,
                        helpText: "ساعت را وارد کنید",
                        confirmText: "تایید",
                        cancelText: "لغو",
                        hourLabelText: "ساعت",
                        minuteLabelText: "دقیقه",
                        initialTime: TimeOfDay.now(),
                        initialEntryMode: TimePickerEntryMode.input,
                        builder: (context, child) {
                          return MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(alwaysUse24HourFormat: true),
                              child: child!);
                        },
                      );
                      rcontroller.fistTime.value = '${t!.hour}:${t.minute}';
                      rcontroller.isTime.value = true;
                    },
                    child: Obx(() => Text(
                          rcontroller.fistTime.value.length == 0
                              ? " از ساعت"
                              : rcontroller.fistTime.toString(),
                          style: TextStyle(fontSize: 16),
                        ))),
              ),
              SizedBox(
                width: 10,
              ),
              SizedBox(
                height: 40,
                width: 130,
                child: FilledButton(
                    style: TextButton.styleFrom(backgroundColor: purpule),
                    onPressed: () async {
                      var t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        helpText: "ساعت را وارد کنید",
                        confirmText: "تایید",
                        cancelText: "لغو",
                        hourLabelText: "ساعت",
                        minuteLabelText: "دقیقه",
                        initialEntryMode: TimePickerEntryMode.input,
                        builder: (context, child) {
                          return MediaQuery(
                              data: MediaQuery.of(context)
                                  .copyWith(alwaysUse24HourFormat: true),
                              child: child!);
                        },
                      );
                      rcontroller.lastTime.value = '${t!.hour}:${t.minute}';
                    },
                    child: Obx(() => Text(
                          rcontroller.lastTime.value.length == 0
                              ? " به ساعت"
                              : rcontroller.lastTime.toString(),
                          style: TextStyle(fontSize: 16),
                        ))),
              ),
              SizedBox(
                width: 25,
              ),
              ElevatedButton(
                  onPressed: () async {
                    rcontroller.isLoading.value = true;

                    rcontroller.isCompleted.value =
                        await searchFunction(rcontroller);
                    rcontroller.isLoading.value = false;
                  },
                  child: Text("جستجو")),
              SizedBox(
                width: 10,
              ),
              ElevatedButton(onPressed: saveToPdf, child: Text("ذخیره"))
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Obx(() => AnimatedCrossFade(
                duration: Duration(milliseconds: 300),
                crossFadeState: rcontroller.isCompleted.value
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: rcontroller.isLoading.value
                    ? Center(
                        child: SizedBox(
                            width:100,
                            height: 100,
                            child: CircularProgressIndicator()),
                      )
                    : SizedBox.shrink(),
                secondChild: SingleChildScrollView(
                  child: Container(
                    width: Get.width,
                    height: 700,
                    child: ListView.builder(
                      itemBuilder: (context, index) => Visibility(
                        visible: rcontroller.selectedModel[index].isarvand ==
                                'arvand'
                            ? rcontroller.selectedModel[index].plateNum!
                                    .contains(RegExp('[a-zA-Z]'))
                                ? false
                                : true
                            : convertToPersian(
                                    rcontroller.selectedModel[index].plateNum!,
                                    alphabetP2)[0] !=
                                '-',
                        child: Container(
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                  padding: EdgeInsets.all(5.0),
                                  height: 50,
                                  width: 10.w,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          right: BorderSide(color: purpule),
                                          left: BorderSide(color: purpule))),
                                  child: rcontroller
                                              .selectedModel[index].isarvand ==
                                          "arvand"
                                      ? SizedBox(
                                          width: 12.w,
                                          height: 50,
                                          child: ArvandPelak(
                                              entry: rcontroller
                                                  .selectedModel[index]))
                                      : LicanceNumber(
                                          entry: rcontroller
                                              .selectedModel[index])),
                              Container(
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(color: purpule))),
                                  width: 12.w,
                                  child: Center(
                                    child: InkWell(
                                        onTap: () {
                                          Get.to(() => Detailedscreen(
                                                kcontroller: kcontroller,
                                                selectedModel: rcontroller
                                                    .selectedModel[index],
                                                index: index,
                                              ));
                                        },
                                        child: Hero(
                                            tag: "heroTag${index}",
                                            child: Image.network(
                                              "http://${url}:8090/api/files/database/${rcontroller.selectedModel[index].id}/${rcontroller.selectedModel[index].imgpath}",
                                              fit: BoxFit.fill,
                                              width: 12.w,
                                              height: 48,
                                            ))),
                                  )),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(color: purpule))),
                                width: 10.w,
                                height: 50,
                                child: Center(
                                  child: Text(
                                    kcontroller.knowPerson
                                            .where(
                                              (element) =>
                                                  element.plateNumber ==
                                                  rcontroller
                                                      .selectedModel[index]
                                                      .plateNum,
                                            )
                                            .isEmpty
                                        ? "-"
                                        : kcontroller
                                            .knowPerson[kcontroller.knowPerson
                                                .indexWhere(
                                            (element) =>
                                                element.plateNumber ==
                                                rcontroller.selectedModel[index]
                                                    .plateNum,
                                          )]
                                            .name!,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                    border: Border(
                                        left: BorderSide(color: purpule))),
                                width: 9.w,
                                height: 50,
                                child: Center(
                                  child: Text(
                                    kcontroller.knowPerson
                                            .where(
                                              (element) =>
                                                  element.plateNumber ==
                                                  rcontroller
                                                      .selectedModel[index]
                                                      .plateNum,
                                            )
                                            .isEmpty
                                        ? "-"
                                        : kcontroller
                                            .knowPerson[kcontroller.knowPerson
                                                .indexWhere(
                                            (element) =>
                                                element.plateNumber ==
                                                rcontroller.selectedModel[index]
                                                    .plateNum,
                                          )]
                                            .carName!,
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 18),
                                  ),
                                ),
                              ),
                              Container(
                                  padding: EdgeInsets.all(3.0),
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(color: purpule))),
                                  width: 5.w,
                                  child: Center(
                                    child: Text(
                                      kcontroller.knowPerson
                                              .where(
                                                (element) =>
                                                    element.plateNumber ==
                                                    rcontroller
                                                        .selectedModel[index]
                                                        .plateNum,
                                              )
                                              .isEmpty
                                          ? "-"
                                          : kcontroller
                                              .knowPerson[kcontroller.knowPerson
                                                  .indexWhere(
                                              (element) =>
                                                  element.plateNumber ==
                                                  rcontroller
                                                      .selectedModel[index]
                                                      .plateNum,
                                            )]
                                              .role!,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )),
                              Container(
                                  padding: EdgeInsets.all(3.0),
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(color: purpule))),
                                  width: 12.w,
                                  child: Center(
                                    child: Text(
                                      rcontroller
                                              .selectedModel[index].platePercent
                                              .toString() +
                                          "%",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )),
                              Container(
                                  padding: EdgeInsets.all(3.0),
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(color: purpule))),
                                  width: 12.w,
                                  child: Center(
                                    child: Get.find<cameraController>()
                                                .cameras
                                                .length <
                                            1
                                        ? SizedBox(
                                            child: Text("No Camera"),
                                          )
                                        : Builder(
                                          builder: (context) {
                                            try {
                                                return Text(
                                                Get.find<cameraController>()
                                                            .cameras
                                                            .firstWhere(
                                                              (element) =>
                                                                  element.path ==
                                                                  rcontroller
                                                                      .selectedModel[
                                                                          index]
                                                                      .rtpath,
                                                            )
                                                            .name.toString(),
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              );
                                            } catch (e) {
                                              return Text("دوربین",          style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),);
                                            }
                                          
                                          }
                                        ),
                                  )),
                              Container(
                                  padding: EdgeInsets.all(3.0),
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(color: purpule))),
                                  width: 12.w,
                                  child: Center(
                                    child: Text(
                                      rcontroller.selectedModel[index].eTime!,
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )),
                              Container(
                                  padding: EdgeInsets.all(3.0),
                                  height: 50,
                                  decoration: BoxDecoration(
                                      border: Border(
                                          left: BorderSide(color: purpule))),
                                  width: 12.w,
                                  child: Center(
                                    child: Text(
                                      rcontroller.selectedModel[index].eDate!
                                          .toPersianDate(),
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )),
                            ],
                          ),
                          margin: EdgeInsets.only(bottom: 10),
                          height: 50,
                          decoration: BoxDecoration(
                              border: Border.all(color: purpule),
                              borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      itemCount: rcontroller.selectedModel.length,
                    ),
                  ),
                ),
              ))
        ],
      ),
    );
  }

  void saveToPdf() async {
    final doc = pw.Document();
    final ttf = await fontFromAssetBundle('assets/fonts/arial.ttf');
    doc.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        build: (pw.Context context) {
          return [
            // Replace the Column with a list of widgets
            pw.Row(children: [
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('پلاک',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('تاریخ',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('ساعت',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('نام و نام خانوادگی',
                    style:
                        pw.TextStyle(font: ttf, fontSize: 8) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('ماشین',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('نام دوربین',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
            ]),
            for (var i in rcontroller.selectedModel)
              i.isarvand == 'arvand' ||
                      convertToPersianString(i.plateNum!, alphabetP2) != '-'
                  ? pw.Container(
                      child: pw.Row(children: [
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(
                            i.isarvand == 'arvand'
                                ? i.plateNum!.contains(RegExp('[a-zA-Z]'))
                                    ? "-"
                                    : i.plateNum.toString().toPersianDigit()
                                : convertToPersianString(
                                    i.plateNum!, alphabetP2),
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(i.eDate.toString().toPersianDate(),
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(i.eTime.toString().toPersianDigit(),
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(
                            kcontroller.knowPerson
                                    .where(
                                      (element) =>
                                          element.plateNumber == i.plateNum,
                                    )
                                    .isEmpty
                                ? "-"
                                : kcontroller
                                    .knowPerson[
                                        kcontroller.knowPerson.indexWhere(
                                    (element) =>
                                        element.plateNumber == i.plateNum,
                                  )]
                                    .name!,
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(
                            kcontroller.knowPerson
                                    .where((element) =>
                                        element.plateNumber == i.plateNum)
                                    .isEmpty
                                ? '-'
                                : kcontroller
                                    .knowPerson[kcontroller.knowPerson
                                        .indexWhere((element) =>
                                            element.plateNumber == i.plateNum)]
                                    .carName!,
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: Get.find<cameraController>().cameras.length == 0
                            ? pw.Text("No Camera")
                            :pw.Builder(builder: (context) {
                              try {
                                 return pw.Text(
                                Get.find<cameraController>()
                                            .cameras
                                            .firstWhere(
                                              (element) =>
                                                  element.path == i.rtpath,
                                            )
                                            .name.toString(),
                                style: pw.TextStyle(font: ttf) // Apply the font
                                );
                              } catch (e) {
                                return pw.Text("دوربین",     style: pw.TextStyle(font: ttf) );
                              }
                             
                            },) 
                      ),
                    ]))
                  : pw.SizedBox()
          ];
        },
        // Optional: Add header/footer to all pages
        footer: (pw.Context context) => pw.Text(' صفحه  ${context.pageNumber}',
            style: pw.TextStyle(font: ttf),
            textDirection: pw.TextDirection.rtl),
      ),
    );
    await Printing.layoutPdf(
        format: PdfPageFormat.a4,
        dynamicLayout: true,
        usePrinterSettings: true,
        onLayout: (PdfPageFormat format) async => doc.save());
  }

  Future<bool> searchFunction(reportController rcontroller) async {
    // Clear previous results
    if (rcontroller.isDate.value && rcontroller.lastDate.value.length == 0) {
      rcontroller.lastDate.value = rcontroller.firstDate.value;
    }
    if (rcontroller.isTime.value && rcontroller.lastTime.value.length == 0) {
      rcontroller.lastTime.value = rcontroller.fistTime.value;
    }

    // Build the filter string based on active filters
    List<String> filters = [];

    // Add plate number filter (exact match)
    if (rcontroller.selectedModel.length != 0) {
      filters.add('plateNum = "${rcontroller.selectedModel}"');
    }
    // Add plate picker filter (contains match)
    else if (rcontroller.pickerPlate.value.length != 0) {
      filters.add('plateNum ~ "${rcontroller.pickerPlate.value}"');
    }

    // Build the complete filter string
    String filterString = filters.join(' && ');
    ;

    // Fetch records from PocketBase
    final records = await pb
        .collection('database')
        .getFullList(filter: filterString, sort: '-created');

    // Process each record

    var tempList = records.where((element) {
      bool passesDateFilter = true;
      bool passesTimeFilter = true;

      // Apply date filter if active
      if (rcontroller.isDate.value) {
        DateTime fromDate = DateTime.parse(rcontroller.firstDate.value);
        DateTime untilDate = DateTime.parse(rcontroller.lastDate.value);
        DateTime initDate = DateTime.parse(element.data['eDate']);
        print("${fromDate} , ${untilDate} , ${initDate}");

        if (rcontroller.firstDate.value == rcontroller.lastDate.value ||
            rcontroller.lastDate.value == '') {
          passesDateFilter =
              element.data['eDate'] == rcontroller.firstDate.value;
        } else {
          passesDateFilter =
              initDate.isBefore(untilDate) && initDate.isAfter(fromDate);
        }
      }

      // Apply time filter if active
      if (rcontroller.isTime.value) {
        TimeOfDay fromTime = TimeOfDay(
            hour: int.parse(rcontroller.fistTime.value.split(':')[0]),
            minute: int.parse(rcontroller.fistTime.value.split(':')[1]));
        TimeOfDay untilTime = TimeOfDay(
            hour: int.parse(rcontroller.lastTime.value.split(':')[0]),
            minute: int.parse(rcontroller.lastTime.value.split(':')[1]));
        TimeOfDay initTime = TimeOfDay(
            hour: int.parse(element.data['eTime'].split(':')[0]),
            minute: int.parse(element.data['eTime'].split(':')[1]));

        if (rcontroller.fistTime.value == rcontroller.lastTime.value) {
          passesTimeFilter =
              element.data['eTime'] == rcontroller.fistTime.value;
        } else {
          passesTimeFilter = getTime(fromTime, untilTime, initTime);
        }
      }

      return passesDateFilter && passesTimeFilter;
    }).toList();

    // Add results to report list
    for (var json in tempList) {
      rcontroller.selectedModel.add(databaseClass.fromJson(json.data));
    }
    
    return true;
  }

  bool getTime(TimeOfDay ft, TimeOfDay lt, TimeOfDay it) {
    int ftMin = ft.hour * 60 + ft.minute;
    int ltMin = lt.hour * 60 + ft.minute;
    int itMin = it.hour * 60 + it.minute;

    return ftMin < itMin && itMin <= ltMin;
  }
}
