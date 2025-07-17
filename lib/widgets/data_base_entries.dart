import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/widgets/add_or_edit_person.dart';
import 'package:amnban/widgets/arvandpelak.dart';
import 'package:amnban/widgets/lisancepage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class dataBaseEntries extends StatelessWidget {
  const dataBaseEntries({
    super.key,
    required this.dcontroller,
    required this.mController,
    required this.kcontroller,
  });

  final databaseController dcontroller;
  final mainPageConroller mController;
  final knowPersonController kcontroller;

  @override
  Widget build(BuildContext context) {
    return  Obx(() => Expanded(
            child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  border: Border.all(color: purpule),
                  borderRadius: BorderRadius.circular(15)),
              child: ListView.separated(
                controller: ScrollController(initialScrollOffset: 0.0),
                  itemBuilder: (context, index) => Visibility(
                        replacement: SizedBox.shrink(),
                        visible: dcontroller.entries[index].isarvand == 'arvand'
                            ? dcontroller.entries[index].plateNum!
                                    .contains(RegExp('[a-zA-Z]'))
                                ? false
                                : true
                            : convertToPersian(
                                    dcontroller.entries[index].plateNum!,
                                    alphabetP2)[0] !=
                                '-',
                        child: InkWell(
                          onTap: () {
                            mController.isSelected.value = true;
                            dcontroller.tableContect.value =
                                dcontroller.entries[index];
                            dcontroller.selectedIndex.value = index;
                          },
                          child: Container(
                            height: 80,
                            child: Row(
                              textDirection: TextDirection.rtl,
                              children: [
                                Container(
                                    width: 10.w,
                                    child: dcontroller
                                                .entries[index].isarvand ==
                                            'arvand'
                                        ? ArvandPelak2(
                                            entry: dcontroller.entries[index])
                                        : LicanceNumber(
                                            entry: dcontroller.entries[index])),
                                VerticalDivider(
                                  color: Colors.black,
                                ),
                                Container(
                                  height: 48,
                                  child: Center(
                                      child: ClipRRect(
                                    borderRadius: BorderRadius.circular(5),
                                    child: Image.network(
                                      ("http://${url}:8090/api/files/database/${dcontroller.entries[index].id}/${dcontroller.entries[index].imgpath}"),

                                      ///
                                      fit: BoxFit.fill,
                                      width: 10.w,
                                      height: 48,
                                    ),
                                  )),
                                ),
                                VerticalDivider(
                                  color: Colors.black,
                                ),
                                Obx(() => Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Container(
                                        width: 8.w,
                                        child: kcontroller.knowPerson
                                                .where(
                                                  (element) =>
                                                      element.plateNumber ==
                                                      dcontroller.entries[index]
                                                          .plateNum,
                                                )
                                                .isNotEmpty
                                            ? Container(
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: Colors.transparent),
                                                child: Center(
                                                  child: Text(
                                                    kcontroller
                                                        .knowPerson[kcontroller
                                                            .knowPerson
                                                            .indexWhere(
                                                      (element) =>
                                                          element.plateNumber ==
                                                          dcontroller
                                                              .entries[index]
                                                              .plateNum,
                                                    )]
                                                        .name!,
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              )
                                            : IconButton(
                                                onPressed: () async {
                                                  String plateNum = dcontroller
                                                      .entries[index].plateNum!
                                                      .trim();
                                                  String name = '';
                                                  String lastName = '';
                                                  String carName = '';
                                                  String role = "مجاز";
                                                  bool isEdit = false;
                                                  bool isDiscover = true;
                                                  bool isArvand = dcontroller
                                                              .entries[index]
                                                              .isarvand ==
                                                          "arvand"
                                                      ? true
                                                      : false;
                                                  String arvandDigits = '';
                                                  String firstTwoDigit = '';
                                                  String threeDigit = '';
                                                  String lastTwoDigit = '';
                                                  String persianAlhpabet = '';
                                                  String engishAlphabet = '';
                                                  if (isArvand) {
                                                    arvandDigits = plateNum;
                                                  } else {
                                                    String charechter = plateNum
                                                        .split(RegExp(r'[0-9]'))
                                                        .toList()[2]
                                                        .toString();
                                                    var persianLetterIndex =
                                                        plateAlphabet.keys
                                                            .toList()
                                                            .indexOf(
                                                                charechter);
                                                    var persianCharechter =
                                                        plateAlphabet.values
                                                            .elementAt(
                                                                persianLetterIndex);

                                                    persianAlhpabet =
                                                        persianCharechter;
                                                    engishAlphabet = charechter;

                                                    firstTwoDigit = plateNum
                                                        .split(RegExp(
                                                            r'[a-z,A-Z]'))[0]
                                                        .toString();
                                                    threeDigit = plateNum
                                                        .split(RegExp(
                                                            r'[a-z,A-Z]'))[1]
                                                        .substring(0, 3);
                                                    lastTwoDigit = plateNum
                                                        .split(RegExp(
                                                            r'[a-z,A-Z]'))[1]
                                                        .substring(3, 5);
                                                  }

                                                  await showAdaptiveDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        add_or_edit_person(
                                                            name: name,
                                                            lastName: lastName,
                                                            carName: carName,
                                                            firstTwoDigit:
                                                                firstTwoDigit,
                                                            threeDigit:
                                                                threeDigit,
                                                            lastTwoDigit:
                                                                lastTwoDigit,
                                                            role: role,
                                                            arvandDigits:
                                                                arvandDigits,
                                                            isArvand: isArvand,
                                                            isEdit: isEdit,
                                                            index: index,
                                                            isDiscover:
                                                                isDiscover,
                                                            engishAlphabet:
                                                                engishAlphabet,
                                                            persianAlhpabet:
                                                                persianAlhpabet,
                                                            kcontroller:
                                                                kcontroller),
                                                  );
                                                },
                                                hoverColor:
                                                    const Color.fromARGB(
                                                        255, 29, 14, 55),
                                                icon: Icon(
                                                    Icons.add_box_outlined),
                                                color: Colors.white70,
                                                iconSize: 36,
                                              ),
                                        height: 50,
                                      ),
                                    )),
                                VerticalDivider(
                                  color: Colors.black,
                                ),
                                Expanded(
                                    child: Center(
                                        child: Container(
                                  child: Text(
                                    Get.find<cameraController>().cameras.isEmpty
                                        ? '-'
                                        : Get.find<cameraController>()
                                                    .cameras
                                                    .firstWhere(
                                                      (element) =>
                                                          element.path ==
                                                          dcontroller
                                                              .entries[index]
                                                              .rtpath,
                                                    )
                                                    .gate ==
                                                "exit"
                                            ? "دوربین خروجی"
                                            : "دوربین ورودی",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 12.sp),
                                  ),
                                ))),
                                VerticalDivider(
                                  color: Colors.black,
                                ),
                                SizedBox(
                                  width: 6.w,
                                  height: 50,
                                  child: IconButton(
                                      onPressed: () async {
                                        await pb.collection('database').delete(
                                            dcontroller.entries[index].id!);
                                      },
                                      icon: Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      )),
                                )
                              ],
                            ),
                            decoration: BoxDecoration(
                                color: purpule,
                                borderRadius: BorderRadius.circular(5)),
                          ),
                        ),
                      ),
                  separatorBuilder: (context, index) => SizedBox(
                        height: 5,
                      ),
                      reverse: true,
                  itemCount: dcontroller.entries.length),
              height: 450,
              
            ),
          )));
  }
}
