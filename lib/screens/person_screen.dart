import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/widgets/AlphaBetSelector.dart';
import 'package:amnban/widgets/add_or_edit_person.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

class PersonScreen extends StatelessWidget {
  PersonScreen({
    super.key,
  });

  knowPersonController kcontroller = Get.find<knowPersonController>();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        textDirection: TextDirection.rtl,
        children: [
          SizedBox(
            height: 25,
          ),
          Obx(() => Container(
                width: MediaQuery.of(context).size.width,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemBuilder: (context, index) => Container(
                    height: 50,
                    width: MediaQuery.of(context).size.width,
                    child: Row(
                      textDirection: TextDirection.rtl,
                      children: [
                        SizedBox(
                          height: 50,
                          width: 4.w,
                          child: Center(
                            child: Text(
                              (index + 1).toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: purpule,
                        ),
                        SizedBox(
                          height: 50,
                          width: 6.w,
                          child: Center(
                            child: Text(
                              kcontroller.knowPerson[index].name!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: purpule,
                        ),
                        SizedBox(
                          height: 50,
                          width: 6.w,
                          child: Center(
                            child: Text(
                              kcontroller.knowPerson[index].isarvand == 'arvand'
                                  ? kcontroller.knowPerson[index].plateNumber!
                                  : convertToPersianString(
                                          kcontroller
                                              .knowPerson[index].plateNumber!,
                                          alphabetP2)
                                      .toString(),
                              textDirection: TextDirection.rtl,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: purpule,
                        ),
                        SizedBox(
                          height: 50,
                          width: 6.w,
                          child: Center(
                            child: Text(
                              kcontroller.knowPerson[index].carName!,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: purpule,
                        ),
                        SizedBox(
                          height: 50,
                          width: 6.w,
                          child: Center(
                            child: Text(
                              kcontroller.knowPerson[index].eDate!
                                  .toPersianDate(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: purpule,
                        ),
                        SizedBox(
                          height: 50,
                          width: 6.w,
                          child: Center(
                            child: Text(
                              kcontroller.knowPerson[index].eTime!
                                  .toPersianDigit(),
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        VerticalDivider(
                          color: purpule,
                        ),
                        SizedBox(
                          height: 50,
                          width: 4.w,
                          child: Center(
                              child: IconButton(
                                  onPressed: () async {
                                    String plateNum = kcontroller
                                        .knowPerson[index].plateNumber!
                                        .trim();
                                    String name = kcontroller
                                        .knowPerson[index].name!
                                        .split(' ')[0];
                                    String lastName = kcontroller
                                        .knowPerson[index].name!
                                        .split(' ')[1];
                                    String carName =
                                        kcontroller.knowPerson[index].carName!;
                                    String role =
                                        kcontroller.knowPerson[index].role!;
                                    bool isEdit = true;
                                    bool isDiscover = false;
                                    bool isArvand = kcontroller
                                                .knowPerson[index].isarvand ==
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
                                      firstTwoDigit = kcontroller
                                          .knowPerson[index].firstTwoDigit!;
                                      threeDigit = kcontroller
                                          .knowPerson[index].threeDigit!;
                                      lastTwoDigit = kcontroller
                                          .knowPerson[index].lastTwoDigit!;
                                      persianAlhpabet = kcontroller
                                          .knowPerson[index].persianAlhpabet!;
                                      engishAlphabet = kcontroller
                                          .knowPerson[index].engishAlphabet!;
                                    }

                                    await showAdaptiveDialog(
                                      context: context,
                                      builder: (context) => add_or_edit_person(
                                          name: name,
                                          lastName: lastName,
                                          carName: carName,
                                          firstTwoDigit: firstTwoDigit,
                                          threeDigit: threeDigit,
                                          lastTwoDigit: lastTwoDigit,
                                          role: role,
                                          arvandDigits: arvandDigits,
                                          isArvand: isArvand,
                                          isEdit: isEdit,
                                          index: index,
                                          isDiscover: isDiscover,
                                          engishAlphabet: engishAlphabet,
                                          persianAlhpabet: persianAlhpabet,
                                          kcontroller: kcontroller),
                                    );
                                  },
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                  ))),
                        ),
                        VerticalDivider(
                          color: purpule,
                        ),
                        SizedBox(
                          height: 50,
                          width: 4.w,
                          child: Center(
                              child: IconButton(
                                  onPressed: () async {
                                    await pb.collection('registredDb').delete(
                                        kcontroller.knowPerson[index].id!);
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ))),
                        ),
                        VerticalDivider(
                          color: purpule,
                        ),
                      ],
                    ),
                    decoration:
                        BoxDecoration(border: Border.all(color: purpule)),
                  ),
                  itemCount: kcontroller.knowPerson.length,
                ),
              )),
          SizedBox(
            height: 20,
          ),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
                onPressed: () async {
                  await showAdaptiveDialog(
                    context: context,
                    builder: (context) {
                      return add_or_edit_person(
                        kcontroller: kcontroller,
                        arvandDigits: '',
                        carName: '',
                        firstTwoDigit: '',
                        isArvand: false,
                        isDiscover: false,
                        isEdit: false,
                        lastName: '',
                        lastTwoDigit: '',
                        name: '',
                        role: "مجاز",
                        threeDigit: '',
                        engishAlphabet: '',
                        persianAlhpabet: '',
                      );
                    },
                  );
                },
                child: Text("اضافه کردن")),
          )
        ],
      ),
    );
  }
}

class ArvandGrapper extends StatelessWidget {
  ArvandGrapper({
    required this.kcontroller,
  });
  knowPersonController kcontroller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 323.6,
      child: CoustomTextField1(
          controller: kcontroller.arvandDigits, hint: '', width: 323.6),
    );
  }
}

class LicanceGrapper extends StatelessWidget {
  const LicanceGrapper({
    super.key,
    required this.kcontroller,
  });

  final knowPersonController kcontroller;

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.ltr,
      children: [
        CoustomTextField1(
          controller: kcontroller.firstTwoDigit,
          hint: "",
          width: 50,
        ),
        SizedBox(
          width: 15,
        ),
        SizedBox(
          height: 40,
          child: TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.white),
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => DraggableScrollableSheet(
                  initialChildSize:
                      0.47, // You can adjust the size of the bottom sheet
                  minChildSize: 0.3,
                  maxChildSize: 0.7,
                  expand: false,
                  builder: (context, scrollController) {
                    return Alphabetselector(
                      scrollController: scrollController,
                    );
                  },
                ),
              );
            },
            child: Obx(() => Text(
                  kcontroller.persianAlhpabet.value == ''
                      ? "انتخاب حرف"
                      : kcontroller.persianAlhpabet.value,
                  style: TextStyle(color: Colors.black),
                )),
          ),
        ),
        SizedBox(
          width: 15,
        ),
        CoustomTextField1(
            controller: kcontroller.threeDigit, hint: '', width: 70),
        SizedBox(
          width: 15,
        ),
        Text(
          "/",
          style: TextStyle(color: Colors.white),
        ),
        SizedBox(
          width: 15,
        ),
        CoustomTextField1(
          hint: '',
          controller: kcontroller.lastTwoDigit,
          width: 50,
        ),
      ],
    );
  }
}
