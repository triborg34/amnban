import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/amar_dialog.dart';
import 'package:amnban/widgets/arvandpelak.dart';
import 'package:amnban/widgets/lisancepage.dart';
import 'package:amnban/widgets/receipt_pdf.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';

import 'package:flutter/material.dart';

import 'package:persian_number_utility/persian_number_utility.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

class Detailedscreen extends StatelessWidget {
  databaseClass selectedModel = databaseClass();
  knowPersonController kcontroller;
  int index;
  List rec;
  Detailedscreen(
      {required this.selectedModel,
      required this.index,
      required this.kcontroller,
      required this.rec});

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
                      "http://${url}:8090/api/files/database/${selectedModel.id}/${selectedModel.scrnPath}",
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
                        padding:
                            EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                        width: 12.w,
                        height: 48,
                        child: selectedModel.isarvand == 'arvand'
                            ? ArvandPelak(entry: selectedModel)
                            : LicanceNumber(entry: selectedModel)),
                    Container(
                      decoration: BoxDecoration(
                          border: Border(left: BorderSide(color: purpule))),
                      padding: EdgeInsets.symmetric(horizontal: 0),
                      width: 12.w,
                      child: Center(
                        child: Hero(
                          tag: "heroTag${index}",
                          child: Image.network(
                            "http://${url}:8090/api/files/database/${selectedModel.id}/${selectedModel.imgpath}",
                            fit: BoxFit.fill,
                            width: 12.w,
                            height: 48,
                          ),
                        ),
                      ),
                    ),
                    contactOfTable3(kcontroller
                            .personFor(selectedModel.plateNum)
                            ?.name ??
                        "-"),
                    contactOfTable3(kcontroller
                            .personFor(selectedModel.plateNum)
                            ?.carName ??
                        "-"),
                    contactOfTable3(
                        selectedModel.platePercent.toString() + "%"),
                    InkWell(
                      child: contactOfTable3(rec.length.toString()),
                      onTap: () async {
                        var temp = <databaseClass>[];
                        for (var data in rec) {
                          temp.add(databaseClass.fromJson(data.data));
                        }

                        await showAmarDialog(context, temp, kcontroller);
                      },
                    ),
                    contactOfTable3(selectedModel.eDate!.toPersianDate()),
                    contactOfTable3(selectedModel.eTime!.toPersianDigit())
                  ],
                ),
              ),
              IconButton(
                icon: Icon(Icons.print),
                onPressed: () => printReceipt(selectedModel, kcontroller),
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
        headerOftable3("تعداد دیده شدن پلاک"),
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
        style: TextStyle(color: Colors.white, fontSize: 10.sp),
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
