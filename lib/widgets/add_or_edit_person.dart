import 'package:amnban/screens/person_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class add_or_edit_person extends StatelessWidget {
  add_or_edit_person({
    super.key,
    required this.name,
    required this.lastName,
    required this.carName,
    required this.firstTwoDigit,
    required this.threeDigit,
    required this.lastTwoDigit,
    required this.role,
    required this.arvandDigits,
    required this.isArvand,
    required this.isEdit,
    required this.isDiscover,
    required this.engishAlphabet,
    required this.persianAlhpabet,
    required this.kcontroller,
    this.index,
  });

  final knowPersonController kcontroller;
  String name;
  String lastName;
  String carName;
  String firstTwoDigit;
  String threeDigit;
  String lastTwoDigit;
  String role;
  String arvandDigits;
  String engishAlphabet;
  String persianAlhpabet;

  bool isArvand;
  bool isEdit;
  bool isDiscover;

  int? index;

  @override
  Widget build(BuildContext context) {
    kcontroller.name.text = name;
    kcontroller.lastName.text = lastName;
    kcontroller.carNmae.text = carName;
    kcontroller.firstTwoDigit.text = firstTwoDigit;
    kcontroller.engishAlphabet.value = engishAlphabet;
    kcontroller.persianAlhpabet.value = persianAlhpabet;
    kcontroller.threeDigit.text = threeDigit;
    kcontroller.lastTwoDigit.text = lastTwoDigit;
    kcontroller.role.value = role;
    kcontroller.arvandDigits.text = arvandDigits;
    kcontroller.isArvand.value = isArvand;

    return Center(
        child: Material(
      color: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(15),
        width: 450,
        decoration: BoxDecoration(
            color: const Color(0xFF6A5ACD),
            borderRadius: BorderRadius.circular(15)),
        height: 320,
        child: Column(
          textDirection: TextDirection.rtl,
          children: [
            Text(
              'ثبت افراد',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Obx(() => AnimatedCrossFade(
                    secondChild: ArvandGrapper(kcontroller: kcontroller),
                    duration: Duration(milliseconds: 350),
                    crossFadeState: kcontroller.isArvand.value
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: LicanceGrapper(kcontroller: kcontroller))),
                TextButton(
                    onPressed: () {
                      kcontroller.isArvand.value = !kcontroller.isArvand.value;
                    },
                    child: Text(
                      "پلاک اروند",
                      style: TextStyle(color: Colors.white),
                    ))
              ],
            ),
            SizedBox(
              height: 15,
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  CoustomTextField1(
                      controller: kcontroller.name, hint: "نام", width: 200),
                  SizedBox(
                    width: 15,
                  ),
                  CoustomTextField1(
                      controller: kcontroller.lastName,
                      hint: "نام خانوادگی",
                      width: 200)
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  CoustomTextField1(
                      controller: kcontroller.carNmae,
                      hint: "نام ماشین",
                      width: 200),
                  SizedBox(
                    width: 15,
                  ),
                  SizedBox(
                    width: 200,
                    child: DropdownButtonFormField(
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                            focusColor: Colors.transparent,
                            fillColor: Colors.white,
                            filled: true,
                            focusedBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            enabledBorder: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent)),
                            border: OutlineInputBorder(
                                borderSide:
                                    BorderSide(color: Colors.transparent))),
                        value: kcontroller.role.value,
                        onChanged: (value) {
                          kcontroller.role.value = value!;
                        },
                        items: [
                          DropdownMenuItem(value: 'مجاز', child: Text("مجاز")),
                          DropdownMenuItem(
                              value: 'غیر مجاز', child: Text("غیر مجاز"))
                        ]),
                  )
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            SizedBox(
                height: 45,
                width: 400,
                child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final String plateNumber;
                        if (kcontroller.isArvand.value) {
                          plateNumber = kcontroller.arvandDigits.text;
                        } else {
                          plateNumber =
                              '${kcontroller.firstTwoDigit.text}${kcontroller.engishAlphabet.value}${kcontroller.threeDigit.text}${kcontroller.lastTwoDigit.text}';
                        }

                        String name =
                            '${kcontroller.name.text.trim()} ${kcontroller.lastName.text.trim()}';
                        String eDate =
                            "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
                        String eTime =
                            "${TimeOfDay.now().hour}:${TimeOfDay.now().minute}";

                        var body = {
                          "name": name,
                          'plateNumber': plateNumber,
                          'carName': kcontroller.carNmae.text.trim(),
                          'isarvand': kcontroller.isArvand.value
                              ? 'arvand'
                              : 'notarvand',
                          'rtpath': '/rt1',
                          'eDate': eDate,
                          'eTime': eTime,
                          'role': kcontroller.role.value,
                          'firstTwoDigit': kcontroller.firstTwoDigit.text,
                          'threeDigit': kcontroller.threeDigit.text,
                          'lastTwoDigit': kcontroller.lastTwoDigit.text,
                          'englishAlphabet': kcontroller.engishAlphabet.value,
                          'persinalAlphabet': kcontroller.persianAlhpabet.value
                        };
                        if (isEdit) {
                          final record = await pb
                              .collection('registredDb')
                              .update(kcontroller.knowPerson[index!].id!,
                                  body: body);

                          ScaffoldMessenger.maybeOf(context)!.showSnackBar(
                              SnackBar(
                                  content: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                          "موفیت آمیز بود ${record.id}"))));
                        } else {
                          final record = await pb
                              .collection('registredDb')
                              .create(body: body);

                          ScaffoldMessenger.maybeOf(context)!.showSnackBar(
                              SnackBar(
                                  content: Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Text(
                                          "موفیت آمیز بود ${record.id}"))));
                        }
                      } catch (e) {
                        ScaffoldMessenger.maybeOf(context)!.showSnackBar(
                            SnackBar(
                                content: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Text("خطا دوباره امتحان کنید"))));
                      }

                      Navigator.pop(context);
                    },
                    child: Text("ثبت")))
          ],
        ),
      ),
    ));
  }
}
