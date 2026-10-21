import 'package:amnban/screens/details_screen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/iran_plate.dart';
import 'package:amnban/widgets/pdf_printig.dart';
import 'package:amnban/widgets/safe_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Detail row of the currently selected detection.
class ExtendedTable extends StatelessWidget {
  ExtendedTable(
      {required this.dcontroller,
      required this.kcontroller,
      required this.index,
      super.key});

  databaseController dcontroller;
  knowPersonController kcontroller;
  int index;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final entry = dcontroller.tableContect.value;
      final person = kcontroller.personFor(entry.plateNum);

      return BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CardHeader(
              title: 'جزئیات تردد انتخاب شده',
              icon: Icons.visibility_rounded,
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: EntryPlate(entry: entry, height: 38),
                    ),
                  ),
                  const SizedBox(width: 10),
                  InkWell(
                    onTap: () async {
                      final plate = entry.plateNum ?? '';
                      if (plate.isEmpty) return;
                      try {
                        final record = await pb
                            .collection('database')
                            .getFullList(
                              filter: 'plateNum="${pbEscape(plate)}"',
                            )
                            .timeout(const Duration(seconds: 15));

                        Get.to(() => Detailedscreen(
                          rec: record,
                          selectedModel: entry,
                          index: index,
                          kcontroller: kcontroller,
                        ));
                      } catch (e) {
                        appLog('extended detail fetch failed', e);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Hero(
                        tag: 'heroTag${entry.id ?? dcontroller.selectedIndex.value}',
                        child: SafeNetImage(
                          url: pbFileUrlOf('database', entry.id, entry.imgpath),
                          fit: BoxFit.cover,
                          width: 112,
                          height: 68,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  _cell('نام و نام خانوادگی', person?.name ?? '-'),
                  _cell('استان', _provinceOf(entry.provice)),
                  _cell('شهر', _cityOf(entry.city)),
                  _cell('نوع خودرو', _carTypeOf(entry.plateNum ?? '')),
                  _cell('تاریخ ورود', (entry.eDate ?? '').toPersianDate()),
                  _cell('ساعت ورود', (entry.eTime ?? '-').toPersianDigit()),
                  const SizedBox(width: 10),
                  PdfPrintig(kcontroller: kcontroller, dcontroller: dcontroller),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _cell(String title, String value) {
    return Container(
      width: 140,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  static String _provinceOf(String? value) =>
      (value == null || value.isEmpty || value == 'None') ? 'خوزستان' : value;

  static String _cityOf(String? value) =>
      (value == null || value.isEmpty || value == 'None') ? 'اهواز' : value;

  static String _carTypeOf(String plate) {
    if (plate.contains('x')) return 'تاکسی';
    if (plate.contains(RegExp(r'(?<![A-Za-z])A(?![A-Za-z])'))) return 'دولتی';
    if (plate.contains('EIN')) return 'کامیون';
    return 'شخصی';
  }
}
