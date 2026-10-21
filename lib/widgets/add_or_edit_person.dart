import 'package:amnban/screens/person_screen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class add_or_edit_person extends StatefulWidget {
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
  State<add_or_edit_person> createState() => _add_or_edit_personState();
}

class _add_or_edit_personState extends State<add_or_edit_person> {
  late final knowPersonController kcontroller;
  late final bool isEdit;
  late final int? index;

  @override
  void initState() {
    kcontroller = widget.kcontroller;
    isEdit = widget.isEdit;
    index = widget.index;
    // Seed the fields once on open; doing this in build() wiped the user's
    // edits on every rebuild.
    kcontroller.name.text = widget.name;
    kcontroller.lastName.text = widget.lastName;
    kcontroller.carNmae.text = widget.carName;
    kcontroller.firstTwoDigit.text = widget.firstTwoDigit;
    kcontroller.engishAlphabet.value = widget.engishAlphabet;
    kcontroller.persianAlhpabet.value = widget.persianAlhpabet;
    kcontroller.threeDigit.text = widget.threeDigit;
    kcontroller.lastTwoDigit.text = widget.lastTwoDigit;
    kcontroller.role.value = widget.role;
    kcontroller.arvandDigits.text = widget.arvandDigits;
    kcontroller.isArvand.value = widget.isArvand;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                isEdit ? "ویرایش افراد" : 'ثبت افراد',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Obx(() => AnimatedCrossFade(
                        duration: const Duration(milliseconds: 250),
                        crossFadeState: kcontroller.isArvand.value
                            ? CrossFadeState.showSecond
                            : CrossFadeState.showFirst,
                        firstChild:
                            LicanceGrapper(kcontroller: kcontroller),
                        secondChild:
                            ArvandGrapper(kcontroller: kcontroller))),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () {
                      kcontroller.isArvand.value = !kcontroller.isArvand.value;
                    },
                    icon: const Icon(Icons.swap_horiz, size: 16),
                    label: const Text("پلاک اروند"),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: CoustomTextField1(
                        controller: kcontroller.name, hint: "نام", width: 200),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: CoustomTextField1(
                        controller: kcontroller.lastName,
                        hint: "نام خانوادگی",
                        width: 200),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: CoustomTextField1(
                        controller: kcontroller.carNmae,
                        hint: "نام ماشین",
                        width: 200),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() => DropdownButtonFormField<String>(
                      initialValue: (kcontroller.role.value == 'مجاز' ||
                              kcontroller.role.value == 'غیر مجاز')
                          ? kcontroller.role.value
                          : 'مجاز',
                      onChanged: (value) {
                        if (value != null) kcontroller.role.value = value;
                      },
                      isExpanded: true,
                      style: const TextStyle(
                          fontSize: 12.5, color: AppColors.textPrimary),
                      items: const [
                        DropdownMenuItem(
                            value: 'مجاز', child: Text("مجاز")),
                        DropdownMenuItem(
                            value: 'غیر مجاز', child: Text("غیر مجاز")),
                      ],
                    )),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
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
                        "${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}";

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
                      final id = (index != null &&
                              index! >= 0 &&
                              index! < kcontroller.knowPerson.length)
                          ? kcontroller.knowPerson[index!].id
                          : null;
                      if (id == null || id.isEmpty) {
                        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                            const SnackBar(
                                content: Directionality(
                                    textDirection: TextDirection.rtl,
                                    child:
                                        Text("خطا دوباره امتحان کنید"))));
                        return;
                      }
                      final record = await pb
                          .collection('registredDb')
                          .update(id, body: body)
                          .timeout(const Duration(seconds: 15));

                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                          content: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text("موفیت آمیز بود ${record.id}"))));
                    } else {
                      final record = await pb
                          .collection('registredDb')
                          .create(body: body)
                          .timeout(const Duration(seconds: 15));

                      ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                          content: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Text("موفیت آمیز بود ${record.id}"))));
                    }
                  } catch (e) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(
                        content: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Text("خطا دوباره امتحان کنید"))));
                  }

                  if (context.mounted) Navigator.pop(context);
                },
                icon: const Icon(Icons.check, size: 16),
                label: const Text("ثبت"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
