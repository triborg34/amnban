import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/screens/details_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/arvandpelak.dart';
import 'package:amnban/widgets/lisancepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Shared "today's plates" list dialog (was duplicated in
/// home_sceen.dart and details_screen.dart).
Future<dynamic> showAmarDialog(
  BuildContext context,
  List<databaseClass> data,
  knowPersonController kcontroller,
) {
  return showDialog(
    context: context,
    builder: (context) {
      return Center(
        child: Container(
          color: purpule,
          width: 500,
          height: 300,
          child: Material(
            color: Colors.purple,
            child: ListView.separated(
              separatorBuilder: (context, index) => SizedBox(
                height: 2,
              ),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) => GestureDetector(
                onTap: () async {
                  var record = await pb.collection('database').getFullList(
                        filter: 'plateNum="${data[index].plateNum}"',
                      );
                  Get.to(() => Detailedscreen(
                        rec: record,
                        selectedModel: data[index],
                        index: index,
                        kcontroller: kcontroller,
                      ));
                },
                child: Container(
                  width: 500,
                  height: 50,
                  decoration: BoxDecoration(
                    color: selecetpurpule,
                    border: Border.all(color: Colors.black),
                  ),
                  child: Row(
                    textDirection: TextDirection.rtl,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 50,
                        child: data[index].isarvand == 'arvand'
                            ? ArvandPelak2(entry: data[index])
                            : LicanceNumber(entry: data[index]),
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
                            kcontroller.personFor(data[index].plateNum)?.name ??
                                '-',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              itemCount: data.length,
            ),
          ),
        ),
      );
    },
  );
}
