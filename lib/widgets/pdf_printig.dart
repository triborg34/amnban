import 'dart:math';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:printing/printing.dart';

class PdfPrintig extends StatelessWidget {
  const PdfPrintig({
    super.key,
    required this.kcontroller,
    required this.dcontroller,
  });

  final knowPersonController kcontroller;
  final databaseController dcontroller;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
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
                          mainAxisAlignment:
                              pw.MainAxisAlignment.start,
                          crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                          children: [
                            pw.Row(
                                mainAxisAlignment:
                                    pw.MainAxisAlignment.end,
                                crossAxisAlignment:
                                    pw.CrossAxisAlignment.end,
                                children: [
                                  pw.Text(
                                      "تاریخ : ${DateTime.now().toPersianDate()}",
                                      textDirection:
                                          pw.TextDirection.rtl,
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
                                    child: pw.Text(
                                        "نام و نام خانوادگی",
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
                                                 dcontroller.tableContect.value
                                                          .plateNum,
                                                )
                                                .isEmpty
                                            ? "-"
                                            : kcontroller.knowPerson[
                                                    kcontroller.knowPerson
                                                        .indexWhere(
                                                          (element) =>
                                                              element
                                                                  .plateNumber ==
                                                         dcontroller.tableContect.value
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
                                         dcontroller.tableContect.value
                                                          .plateNum,
                                                )
                                                .isEmpty
                                            ? "-"
                                            : kcontroller.knowPerson[
                                                  kcontroller.knowPerson
                                                        .indexWhere(
                                                          (element) =>
                                                              element
                                                                  .plateNumber ==
                                                         dcontroller.tableContect.value
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
                                          dcontroller.tableContect.value
                                                          .plateNum,
                                                )
                                                .isEmpty
                                            ? "-"
                                            : kcontroller.knowPerson[
                                                    kcontroller.knowPerson
                                                        .indexWhere(
                                                          (element) =>
                                                              element
                                                                  .plateNumber ==
                                                     dcontroller.tableContect.value
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
                                      dcontroller.tableContect.value.eTime!
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
                                         dcontroller.tableContect.value.eDate!
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
                                     dcontroller.tableContect.value
                                                    .isarvand ==
                                                'arvand'
                                            ?    dcontroller.tableContect.value
                                                .plateNum!
                                                .toPersianDigit()
                                            : convertToPersianString(
                                                dcontroller.tableContect.value
                                                    .plateNum!,
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
                                        style:
                                            pw.TextStyle(font: ttf))))
                          ]));
                })); // Page
            await Printing.layoutPdf(
                format: PdfPageFormat.a5,
                dynamicLayout: true,
                usePrinterSettings: true,
                onLayout: (PdfPageFormat format) async => doc.save());
          },
          icon: Icon(Icons.print)),
    );
  }
}
