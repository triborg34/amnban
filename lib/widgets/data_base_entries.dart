import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/add_or_edit_person.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/iran_plate.dart';
import 'package:amnban/widgets/safe_image.dart';
import 'package:amnban/widgets/status_chip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Parses a stored plate like `12P34567` into person-dialog fields without
/// ever throwing RangeError on malformed plates.
Map<String, String> splitPlateSafe(String? plateNum) {
  final out = <String, String>{
    'ch': '',
    'fa': '',
    'first': '',
    'three': '',
    'last': '',
  };
  if (plateNum == null || plateNum.isEmpty) return out;
  try {
    final parts = plateNum.split(RegExp(r'[0-9]'));
    String ch = '';
    if (parts.length > 2) ch = parts[2].toString();
    if (ch.isNotEmpty && plateAlphabet.containsKey(ch)) {
      out['ch'] = ch;
      out['fa'] = plateAlphabet[ch] ?? '';
    }
    final digitParts = plateNum.split(RegExp(r'[a-zA-Z]'));
    if (digitParts.isNotEmpty) out['first'] = digitParts[0].toString();
    if (digitParts.length > 1) {
      final rest = digitParts[1].toString();
      if (rest.length >= 3) out['three'] = rest.substring(0, 3);
      if (rest.length >= 5) out['last'] = rest.substring(3, 5);
    }
  } catch (e) {
    appLog('splitPlate failed', e);
  }
  return out;
}

bool isEntryVisible(databaseClass e) {
  try {
    final plate = e.plateNum ?? '';
    if (plate.isEmpty) return false;
    if (e.isarvand == 'arvand') {
      return !plate.contains(latinLetters);
    }
    return convertToPersian(plate, alphabetP2)[0] != '-';
  } catch (_) {
    return false;
  }
}

/// Rolling list of the latest detections — compact rows.
class dataBaseEntries extends StatefulWidget {
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
  State<dataBaseEntries> createState() => _dataBaseEntriesState();
}

class _dataBaseEntriesState extends State<dataBaseEntries> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Filter once here instead of Visibility-per-row (which kept invalid
    // rows in itemCount/separators and built them anyway).
    return Obx(() {
      final entries = widget.dcontroller.entries;
      final visible = entries.where(isEntryVisible).toList();

      if (entries.isEmpty) {
        return SizedBox(
          height: 190,
          child: Center(
            child: widget.dcontroller.isLoadingMore.value
                ? const CircularProgressIndicator()
                : const AppEmptyState(
                    message: 'رکوردی وجود ندارد',
                    icon: Icons.inbox_outlined,
                  ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.filter_list_rounded,
                  size: 14, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                '${visible.length.toString().toPersianDigit()} تردد ثبت شده',
                style: AppTheme.numeric(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textMuted,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: widget.dcontroller.isLoadingMore.value
                    ? null
                    : () {
                        widget.dcontroller.inilazedPage =
                            widget.dcontroller.inilazedPage + 1;
                        widget.dcontroller.fetchFirstData(
                            widget.dcontroller.inilazedPage, 30);
                      },
                icon: widget.dcontroller.isLoadingMore.value
                    ? const SizedBox(
                        width: 13,
                        height: 13,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.expand_more_rounded, size: 16),
                label: const Text('بار گزاری بیشتر'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(12),
              color: AppColors.surfaceHigh.withValues(alpha: 0.35),
            ),
            clipBehavior: Clip.antiAlias,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.all(6),
              itemBuilder: (context, index) {
                final entry = visible[index];
                // Map back to the full-list index for selection.
                final fullIndex =
                    entries.indexWhere((e) => e.id == entry.id);
                return DetectionRow(
                  entry: entry,
                  fullIndex: fullIndex == -1 ? index : fullIndex,
                  dcontroller: widget.dcontroller,
                  mController: widget.mController,
                  kcontroller: widget.kcontroller,
                );
              },
              separatorBuilder: (context, index) => const SizedBox(height: 5),
              itemCount: visible.length,
            ),
          ),
        ],
      );
    });
  }
}

/// Compact detection row: thumbnail, plate, status chip and time.
class DetectionRow extends StatelessWidget {
  const DetectionRow({
    super.key,
    required this.entry,
    required this.fullIndex,
    required this.dcontroller,
    required this.mController,
    required this.kcontroller,
  });

  final databaseClass entry;
  final int fullIndex;
  final databaseController dcontroller;
  final mainPageConroller mController;
  final knowPersonController kcontroller;

  @override
  Widget build(BuildContext context) {
    final person = kcontroller.personFor(entry.plateNum);
    final status = statusForEntry(entry, kcontroller);

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        mController.isSelected.value = true;
        dcontroller.tableContect.value = entry;
        dcontroller.selectedIndex.value = fullIndex;
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: SafeNetImage(
                url: pbFileUrlOf('database', entry.id, entry.imgpath),
                fit: BoxFit.cover,
                width: 52,
                height: 38,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 86,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: EntryPlate(entry: entry, height: 30),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    person?.name ?? 'ثبت نشده',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    Get.find<cameraController>().cameraNameFor(entry.rtpath),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            StatusChip(status: status, dense: true),
            const SizedBox(width: 10),
            SizedBox(
              width: 54,
              child: Text(
                (entry.eTime ?? '-').toString().toPersianDigit(),
                textAlign: TextAlign.end,
                style: AppTheme.numeric(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            if (person == null)
              IconButton(
                onPressed: () async {
                  final plateNum = (entry.plateNum ?? '').trim();
                  final parsed = splitPlateSafe(plateNum);
                  await showAdaptiveDialog(
                    context: context,
                    builder: (context) => add_or_edit_person(
                      name: '',
                      lastName: '',
                      carName: '',
                      firstTwoDigit: parsed['first'] ?? '',
                      threeDigit: parsed['three'] ?? '',
                      lastTwoDigit: parsed['last'] ?? '',
                      role: "مجاز",
                      arvandDigits:
                          entry.isarvand == 'arvand' ? plateNum : '',
                      isArvand: entry.isarvand == 'arvand',
                      isEdit: false,
                      index: fullIndex,
                      isDiscover: true,
                      engishAlphabet: parsed['ch'] ?? '',
                      persianAlhpabet: parsed['fa'] ?? '',
                      kcontroller: kcontroller,
                    ),
                  );
                },
                hoverColor: AppColors.primarySoft,
                icon: const Icon(Icons.add_box_outlined),
                color: AppColors.primary,
                iconSize: 18,
                tooltip: 'افزودن به لیست مجاز',
              ),
            IconButton(
              onPressed: () async {
                // Capture id first: the old code read cameras[index].id AFTER
                // delete for the snackbar, using a stale index (RangeError).
                final id = entry.id;
                if (id == null || id.isEmpty) return;
                try {
                  await pb.collection('database').delete(id);
                } catch (e) {
                  appLog('delete database record failed', e);
                  if (context.mounted) {
                    ScaffoldMessenger.maybeOf(context)?.showSnackBar(
                        const SnackBar(content: Text('خطا در حذف رکورد')));
                  }
                }
              },
              icon: const Icon(Icons.delete_outline, color: AppColors.danger),
              iconSize: 18,
              tooltip: 'حذف',
            ),
          ],
        ),
      ),
    );
  }
}
