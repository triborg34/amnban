import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/widgets/AlphaBetSelector.dart';
import 'package:amnban/widgets/add_or_edit_person.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/coustom_fieds.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Allow-list ("لیست پلاک") screen.
class PersonScreen extends StatelessWidget {
  PersonScreen({
    super.key,
  });

  knowPersonController kcontroller = Get.find<knowPersonController>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
      child: BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              title: 'لیست پلاک ها',
              subtitle: 'پلاک های مجاز و غیر مجاز سامانه',
              icon: Icons.confirmation_number_rounded,
              trailing: Obx(() => Text(
                    '${kcontroller.knowPerson.length.toString().toPersianDigit()} پلاک',
                    style: AppTheme.numeric(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  )),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
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
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('اضافه کردن'),
                ),
                OutlinedButton.icon(
                  onPressed: () => getBackup("registredDb"),
                  icon: const Icon(Icons.backup_outlined, size: 16),
                  label: const Text('پشتیبان گیری'),
                ),
                OutlinedButton.icon(
                  onPressed: () => restoreBackup("registredDb"),
                  icon: const Icon(Icons.restore_rounded, size: 16),
                  label: const Text('بازگردانی'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Obx(() {
                final people = kcontroller.knowPerson;
                if (people.isEmpty) {
                  return const AppEmptyState(
                    message: 'پلاکی ثبت نشده است',
                    icon: Icons.confirmation_number_outlined,
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _headerRow(),
                    const SizedBox(height: 6),
                    Expanded(
                      child: ListView.separated(
                        itemCount: people.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 5),
                        itemBuilder: (context, index) => _personRow(
                          context,
                          index,
                        ),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerRow() {
    Widget head(String title, double width) => SizedBox(
          width: width,
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            head('#', 40),
            head('نام و نام خانوادگی', 180),
            head('شماره پلاک', 180),
            head('ماشین', 160),
            head('تاریخ', 110),
            head('ساعت', 80),
            head('عملیات', 100),
          ],
        ),
      ),
    );
  }

  Widget _personRow(BuildContext context, int index) {
    final person = kcontroller.knowPerson[index];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            SizedBox(
              width: 40,
              child: Text(
                '${index + 1}'.toPersianDigit(),
                textAlign: TextAlign.center,
                style: AppTheme.numeric(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: Text(
                person.name ?? '-',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 180,
              child: Text(
                _plateOf(person),
                textDirection: TextDirection.rtl,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 160,
              child: Text(
                person.carName ?? '-',
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontSize: 12, color: AppColors.textSecondary),
              ),
            ),
            SizedBox(
              width: 110,
              child: Text(
                person.eDate != null ? person.eDate!.toPersianDate() : "-",
                textAlign: TextAlign.center,
                style: AppTheme.numeric(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(
              width: 80,
              child: Text(
                person.eTime != null ? person.eTime!.toPersianDigit() : "-",
                textAlign: TextAlign.center,
                style: AppTheme.numeric(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(
              width: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _edit(context, index),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    tooltip: 'ویرایش',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => _delete(context, index),
                    icon: const Icon(Icons.delete_outline,
                        size: 18, color: AppColors.danger),
                    tooltip: 'حذف',
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _plateOf(dynamic person) {
    final plate = person.plateNumber;
    if (plate == null || plate.isEmpty) return '-';
    if (person.isarvand == 'arvand') return plate;
    try {
      return convertToPersianString(plate, alphabetP2).toString();
    } catch (_) {
      return '-';
    }
  }

  Future<void> _edit(BuildContext context, int index) async {
    final p = kcontroller.knowPerson[index];
    final plateNum = (p.plateNumber ?? '').trim();
    final nameParts = (p.name ?? '').trim();
    final nameSplit = nameParts.isEmpty ? [''] : nameParts.split(' ');
    final name = nameSplit[0];
    final lastName =
        nameSplit.length > 1 ? nameSplit.sublist(1).join(' ') : '';
    final isArvand = p.isarvand == "arvand";

    await showAdaptiveDialog(
      context: context,
      builder: (context) => add_or_edit_person(
        name: name,
        lastName: lastName,
        carName: p.carName ?? '',
        firstTwoDigit: p.firstTwoDigit ?? '',
        threeDigit: p.threeDigit ?? '',
        lastTwoDigit: p.lastTwoDigit ?? '',
        role: p.role ?? 'مجاز',
        arvandDigits: isArvand ? plateNum : '',
        isArvand: isArvand,
        isEdit: true,
        index: index,
        isDiscover: false,
        engishAlphabet: p.engishAlphabet ?? '',
        persianAlhpabet: p.persianAlhpabet ?? '',
        kcontroller: kcontroller,
      ),
    );
  }

  Future<void> _delete(BuildContext context, int index) async {
    final id = kcontroller.knowPerson[index].id;
    if (id == null || id.isEmpty) return;
    try {
      await pb
          .collection('registredDb')
          .delete(id)
          .timeout(const Duration(seconds: 15));
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
            const SnackBar(content: Text('خطا در حذف')));
      }
    }
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
        const SizedBox(width: 15),
        SizedBox(
          height: 40,
          child: TextButton(
            style: TextButton.styleFrom(
              backgroundColor: AppColors.surfaceHigh,
              foregroundColor: AppColors.textPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: const BorderSide(color: AppColors.border),
              ),
            ),
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
                  style: const TextStyle(color: AppColors.textPrimary),
                )),
          ),
        ),
        const SizedBox(width: 15),
        CoustomTextField1(
            controller: kcontroller.threeDigit, hint: '', width: 70),
        const SizedBox(width: 15),
        const Text(
          "/",
          style: TextStyle(color: AppColors.textMuted),
        ),
        const SizedBox(width: 15),
        CoustomTextField1(
            hint: '', controller: kcontroller.lastTwoDigit, width: 50),
      ],
    );
  }
}
