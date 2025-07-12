import 'dart:math';

import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/widgets/arvandpelak.dart';
import 'package:amnban/widgets/lisancepage.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class Detailedscreen extends StatelessWidget {
  databaseClass selectedModel = databaseClass();
  knowPersonController kcontroller;
  int index;
  Detailedscreen({required this.selectedModel, required this.index,required this.kcontroller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.black,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.symmetric(vertical: 15),
                alignment: Alignment.topCenter,
                decoration: BoxDecoration(
                    border: Border.all(color: purpule),
                    borderRadius: BorderRadius.circular(15)),
                height: 450,
                width: 800,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: EasyImageView(
                    imageProvider: NetworkImage(
                      "http://127.0.0.1:8090/api/files/database/${selectedModel.id}/${selectedModel.scrnPath}",
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: header3(),
              ),
              Container(
                height: 48,
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: purpule))),
                alignment: Alignment.center,
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [

                    
                      Container(
                              decoration: BoxDecoration(
                                  border: Border(
                                      right: BorderSide(color: purpule),
                                      left: BorderSide(color: purpule))),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 0, vertical: 5),
                              width: 12.w,
                              height: 48,
                              child: selectedModel.isarvand == 'arvand'
                                  ? ArvandPelak(entry: selectedModel)
                                  : LicanceNumber(entry: selectedModel))
                        ,
                      

                    Container(
                      decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: purpule))),
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      width: 12.w,
                      child: Center(
                        child: Hero(
                          tag: "heroTag${index}",
                          child: Image.network(
                            "http://127.0.0.1:8090/api/files/database/${selectedModel.id}/${selectedModel.imgpath}",
                            fit: BoxFit.fill,
                            width: 12.w,
                            height: 48,
                          ),
                        ),
                      ),
                    ),
                    contactOfTable3(kcontroller.knowPerson
                            .where(
                              (element) =>
                                  element.plateNumber == selectedModel.plateNum,
                            )
                            .isEmpty
                        ? "-"
                        : kcontroller.knowPerson[kcontroller.knowPerson.indexWhere(
                                  (element) =>
                                      element.plateNumber ==
                                      selectedModel.plateNum,
                                )]
                            .name!),
                    contactOfTable3(kcontroller.knowPerson
                            .where(
                              (element) =>
                                  element.plateNumber == selectedModel.plateNum,
                            )
                            .isEmpty
                        ? "-"
                        : kcontroller.knowPerson[kcontroller.knowPerson.indexWhere(
                                  (element) =>
                                      element.plateNumber ==
                                      selectedModel.plateNum,
                                )]
                            .carName!),
                    contactOfTable3(
                        selectedModel.platePercent.toString() + "%"),
                    contactOfTable3(selectedModel.charPercent.toString() + "%"),
                    contactOfTable3(selectedModel.eDate!.toPersianDate()),
                    contactOfTable3( selectedModel.eTime!)
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.print),
                onPressed: () async {
                  final doc = pw.Document();
                  final ttf =
                      await fontFromAssetBundle('assets/fonts/arial.ttf');
                  // final image = await networkImage(
                  //     "${imagesPath}${selectedModel.id}/${selectedModel.imgpath}");
                  doc.addPage(pw.Page(
                      orientation: pw.PageOrientation.landscape,
                      pageFormat: PdfPageFormat.a5,
                      build: (pw.Context context) {
                        return pw.Container(
                            padding: pw.EdgeInsets.all(10),
                            height: double.infinity,
                            width: double.infinity,
                            decoration:
                                pw.BoxDecoration(border: pw.Border.all()),
                            child: pw.Column(
                                mainAxisAlignment: pw.MainAxisAlignment.start,
                                crossAxisAlignment: pw.CrossAxisAlignment.start,
                                children: [
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Text(
                                            "تاریخ : ${DateTime.now().toPersianDate()}",
                                            textDirection: pw.TextDirection.rtl,
                                            style: pw.TextStyle(font: ttf)),
                                        pw.Spacer(),
                                              pw.Text(
                                            ' ساعت : ${DateTime.now().hour.toString().toPersianDigit()}:${DateTime.now().minute.toString().toPersianDigit()}',
                                            style: pw.TextStyle(font: ttf),
                                            textDirection:
                                                pw.TextDirection.rtl),
                                                pw.Spacer(),
                                        pw.Text(
                                            'شماره قبض : ${Random().nextInt(200).toString().toPersianDigit()}',
                                            style: pw.TextStyle(font: ttf),
                                            textDirection:
                                                pw.TextDirection.rtl),
                                      ]),
                                  pw.SizedBox(height: 15),
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text("دسترسی",
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text("نام ماشین",
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text("نام و نام خانوادگی",
                                              style: pw.TextStyle(
                                                  font: ttf, fontSize: 8.0),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text("ساعت ورود",
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text("تاریخ ورود",
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text("شماره پلاک",
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                      ]),
                                  pw.Row(
                                      mainAxisAlignment:
                                          pw.MainAxisAlignment.end,
                                      crossAxisAlignment:
                                          pw.CrossAxisAlignment.end,
                                      children: [
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text(
                                            kcontroller.knowPerson
                                                      .where(
                                                        (element) =>
                                                            element
                                                                .plateNumber ==
                                                            selectedModel
                                                                .plateNum,
                                                      )
                                                      .isEmpty
                                                  ? "-"
                                                  : kcontroller.knowPerson[kcontroller.knowPerson
                                                          .indexWhere(
                                                            (element) =>
                                                                element
                                                                    .plateNumber ==
                                                                selectedModel
                                                                    .plateNum,
                                                          )]
                                                      .role!,
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text(
                                              kcontroller.knowPerson
                                                      .where(
                                                        (element) =>
                                                            element
                                                                .plateNumber ==
                                                            selectedModel
                                                                .plateNum,
                                                      )
                                                      .isEmpty
                                                  ? "-"
                                                  : kcontroller.knowPerson[kcontroller.knowPerson
                                                          .indexWhere(
                                                            (element) =>
                                                                element
                                                                    .plateNumber ==
                                                                selectedModel
                                                                    .plateNum,
                                                          )]
                                                      .carName!,
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text(
                                            kcontroller.knowPerson
                                                      .where(
                                                        (element) =>
                                                            element
                                                                .plateNumber ==
                                                            selectedModel
                                                                .plateNum,
                                                      )
                                                      .isEmpty
                                                  ? "-"
                                                  :kcontroller.knowPerson[kcontroller.knowPerson
                                                          .indexWhere(
                                                            (element) =>
                                                                element
                                                                    .plateNumber ==
                                                                selectedModel
                                                                    .plateNum,
                                                          )]
                                                      .name!,
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text(
                                              selectedModel.eTime!
                                                  .toPersianDigit(),
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text(
                                              selectedModel.eDate!
                                                  .toPersianDate(),
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                        pw.SizedBox(width: 0),
                                        pw.Container(
                                          height: 30,
                                          width: 70,
                                          alignment: pw.Alignment.center,
                                          decoration: pw.BoxDecoration(
                                              border: pw.Border.all()),
                                          child: pw.Text(
                                            selectedModel.isarvand=='arvand' ? selectedModel.plateNum!.toPersianDigit():
                                              convertToPersianString(
                                                  selectedModel.plateNum!,
                                                  alphabetP2),
                                              style: pw.TextStyle(
                                                font: ttf,
                                              ),
                                              textDirection:
                                                  pw.TextDirection.rtl),
                                        ),
                                      ]),
                                  pw.SizedBox(height: 25),
                                  pw.SizedBox(
                                      height: 15,
                                      child: pw.Align(
                                          alignment: pw.Alignment.topRight,
                                          child: pw.Text('توضیحات',
                                              textDirection:
                                                  pw.TextDirection.rtl,
                                              style: pw.TextStyle(font: ttf))))
                                ]));
                      })); // Page
                  await Printing.layoutPdf(
                      format: PdfPageFormat.a5,
                      dynamicLayout: true,
                      usePrinterSettings: true,
                      onLayout: (PdfPageFormat format) async => doc.save());

//                 await Printing.layoutPdf(onLayout: (PdfPageFormat format,) async {
//   const body = '''
//     <h1>Heading Example</h1>
//     <p>This is a paragraph.</p>
//     <img src="image.jpg" alt="Example Image" />
//     <blockquote>This is a quote.</blockquote>
//     <ul>
//       <li>سلام item</li>
//       <li>Second item</li>
//       <li>Third item</li>
//     </ul>
//     ''';

//   final pdf = pw.Document();
//   final widgets = await htmltopdf.HTMLToPdf().convert(body);
//   pdf.addPage(pw.MultiPage(build: (context) => widgets));
//   return await pdf.save();
// });
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

Container header3() {
  return Container(
    alignment: Alignment.center,
    height: 50,
    decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: purpule),
            top: BorderSide(color: purpule))),
    child: Row(

      textDirection: TextDirection.rtl,
      children: [
        headerOftable3("شماره پلاک"),
        headerOftable3("عکس پلاک"),
        headerOftable3(" نام و نام خانوادگی"),
        headerOftable3("نوع ماشین"),
        headerOftable3("درصد تشخیص پلاک"),
        headerOftable3("درصد تشخیص حروف"),
        headerOftable3("تاریخ ورود"),
        headerOftable3("ساعت ورود")
      ],
    ),
  );
}

Container headerOftable3(String title) {
  return Container(
      decoration: BoxDecoration(
          border: Border(
              left: BorderSide(color: purpule),
              right: title == "شماره پلاک"
                  ? BorderSide(color: purpule)
                  : BorderSide.none)),
      height: 50,
      width: 12.w,
      child: Center(
          child: Text(
        title,
        style: TextStyle(color: Colors.white,fontSize: 10.sp),
      )));
}

Container contactOfTable3(String title) {
  return Container(
      decoration:
          BoxDecoration(border: Border(left: BorderSide(color: purpule))),
      height: 98,
      width: 12.w,
      child: Center(
          child: Text(
        title,
        textDirection: TextDirection.rtl,
        style: TextStyle(color: Colors.white, fontSize: 10.sp),
      )));
}

