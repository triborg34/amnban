import 'dart:math';

import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/utils/controller.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:printing/printing.dart';

/// Shared A5 entry receipt (was duplicated in details_screen.dart and
/// pdf_printig.dart).
Future<void> printReceipt(
  databaseClass entry,
  knowPersonController kcontroller,
) async {
  final doc = pw.Document();
  final ttf = await fontFromAssetBundle('assets/fonts/arial.ttf');
  final person = kcontroller.personFor(entry.plateNum);

  pw.Widget cell(String text, pw.Font font, {double? fontSize}) => pw.Container(
        height: 30,
        width: 70,
        alignment: pw.Alignment.center,
        decoration: pw.BoxDecoration(border: pw.Border.all()),
        child: pw.Text(
          text,
          style: pw.TextStyle(font: font, fontSize: fontSize),
          textDirection: pw.TextDirection.rtl,
        ),
      );

  doc.addPage(pw.Page(
      orientation: pw.PageOrientation.landscape,
      pageFormat: PdfPageFormat.a5,
      build: (pw.Context context) {
        return pw.Container(
            padding: pw.EdgeInsets.all(10),
            height: double.infinity,
            width: double.infinity,
            decoration: pw.BoxDecoration(border: pw.Border.all()),
            child: pw.Column(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(
                            "تاریخ : ${DateTime.now().toPersianDate()}",
                            textDirection: pw.TextDirection.rtl,
                            style: pw.TextStyle(font: ttf)),
                        pw.Spacer(),
                        pw.Text(
                            ' ساعت : ${DateTime.now().hour.toString().toPersianDigit()}:${DateTime.now().minute.toString().toPersianDigit()}',
                            style: pw.TextStyle(font: ttf),
                            textDirection: pw.TextDirection.rtl),
                        pw.Spacer(),
                        pw.Text(
                            'شماره قبض : ${Random().nextInt(200).toString().toPersianDigit()}',
                            style: pw.TextStyle(font: ttf),
                            textDirection: pw.TextDirection.rtl),
                      ]),
                  pw.SizedBox(height: 15),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        cell("دسترسی", ttf),
                        cell("نام ماشین", ttf),
                        cell("نام و نام خانوادگی", ttf, fontSize: 8.0),
                        cell("ساعت ورود", ttf),
                        cell("تاریخ ورود", ttf),
                        cell("شماره پلاک", ttf),
                      ]),
                  pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.end,
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        cell(person?.role ?? '-', ttf),
                        cell(person?.carName ?? '-', ttf),
                        cell(person?.name ?? '-', ttf),
                        cell(entry.eTime?.toPersianDigit() ?? '-', ttf),
                        cell(entry.eDate?.toPersianDate() ?? '-', ttf),
                        cell(
                            entry.isarvand == 'arvand'
                                ? (entry.plateNum?.toPersianDigit() ?? '-')
                                : (entry.plateNum == null
                                    ? '-'
                                    : convertToPersianString(
                                        entry.plateNum!, alphabetP2)),
                            ttf),
                      ]),
                  pw.SizedBox(height: 25),
                  pw.SizedBox(
                      height: 15,
                      child: pw.Align(
                          alignment: pw.Alignment.topRight,
                          child: pw.Text('توضیحات',
                              textDirection: pw.TextDirection.rtl,
                              style: pw.TextStyle(font: ttf))))
                ]));
      })); // Page
  await Printing.layoutPdf(
      format: PdfPageFormat.a5,
      dynamicLayout: true,
      usePrinterSettings: true,
      onLayout: (PdfPageFormat format) async => doc.save());
}
