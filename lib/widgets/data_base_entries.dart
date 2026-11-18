import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/screens/details_screen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/converFunctions.dart';
import 'package:amnban/utils/detection_meta.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/add_or_edit_person.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/iran_plate.dart';
import 'package:amnban/widgets/receipt_pdf.dart';
import 'package:amnban/widgets/safe_image.dart';
import 'package:amnban/widgets/status_chip.dart';
import 'package:amnban/widgets/thumb_image.dart';
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
            height: 340,
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
                final fullIndex = entries.indexWhere((e) => e.id == entry.id);
                return DetectionRow(
                  // A stable key based on the record id (never the list
                  // index) keeps the row — and its cached image — alive
                  // while the list is scrolled.
                  key: entry.id != null && entry.id!.isNotEmpty
                      ? ValueKey('detection_${entry.id}')
                      : ObjectKey(entry),
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
///
/// * tapping the **plate** expands an inline mini table under the row
/// * tapping the mini table (or its "جزئیات" button) opens [Detailedscreen]
/// * tapping the **thumbnail** opens [Detailedscreen] directly
class DetectionRow extends StatefulWidget {
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
  State<DetectionRow> createState() => _DetectionRowState();
}

class _DetectionRowState extends State<DetectionRow> {
  bool _expanded = false;

  databaseClass get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final person = widget.kcontroller.personFor(entry.plateNum);
    final status = statusForEntry(entry, widget.kcontroller);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: _expanded
                  ? AppColors.primary.withValues(alpha: 0.45)
                  : AppColors.border,
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              // The row adapts to the width of the panel so the plate keeps
              // its size and nothing ever overflows.
              final width = constraints.maxWidth;
              final thumbWidth =
                  width >= 480 ? 64.0 : (width >= 380 ? 48.0 : 0.0);
              final plateHeight =
                  width >= 480 ? 40.0 : (width >= 380 ? 34.0 : 28.0);
              final plateWidth = (plateHeight * 3.2).roundToDouble();

              return Row(
                children: [
                  // Thumbnail → opens the full detail page directly.
                  if (thumbWidth > 0) ...[
                    InkWell(
                      borderRadius: BorderRadius.circular(7),
                      onTap: () => _openDetail(),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(7),
                        child: SizedBox(
                          width: thumbWidth,
                          height: plateHeight * 1.15,
                          child: _thumbnail(entry),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  // Plate → expands the inline mini table (step 1).
                  SizedBox(
                    width: plateWidth,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => setState(() => _expanded = !_expanded),
                      child: Tooltip(
                        message:
                            _expanded ? 'بستن جزئیات' : 'نمایش جزئیات پلاک',
                        child: Padding(
                          padding: const EdgeInsets.all(2),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: AlignmentDirectional.centerStart,
                            child: EntryPlate(
                              entry: entry,
                              height: plateHeight,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 4,
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
                          Get.find<cameraController>()
                              .cameraNameFor(entry.rtpath),
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
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 60,
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
                      onPressed: () => _addPerson(),
                      hoverColor: AppColors.primarySoft,
                      icon: const Icon(Icons.add_box_outlined),
                      color: AppColors.primary,
                      iconSize: 18,
                      tooltip: 'افزودن به لیست مجاز',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints:
                          const BoxConstraints.tightFor(width: 30, height: 30),
                    ),
                  IconButton(
                    onPressed: () => _delete(),
                    icon: const Icon(Icons.delete_outline,
                        color: AppColors.danger),
                    iconSize: 18,
                    tooltip: 'حذف',
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                    constraints:
                        const BoxConstraints.tightFor(width: 30, height: 30),
                  ),
                ],
              );
            },
          ),
        ),
        // Step 1 result — the inline mini table.
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _expanded ? _miniTable() : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ------------------------------------------------------------ mini table

  Widget _miniTable() {
    final person = widget.kcontroller.personFor(entry.plateNum);
    final cameras = Get.find<cameraController>().cameras;
    final direction = DetectionMeta.direction(entry.rtpath, cameras);

    final rows = <List<String>>[
      ['مالک', person?.name ?? 'ثبت نشده'],
      ['استان', DetectionMeta.province(entry.provice)],
      ['شهر', DetectionMeta.city(entry.city)],
      ['نوع خودرو', DetectionMeta.carType(entry.plateNum)],
      ['تاریخ', (entry.eDate ?? '-').toPersianDate()],
      ['ساعت', (entry.eTime ?? '-').toString().toPersianDigit()],
      ['جهت دوربین', direction],
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        // Step 2 — opens the full detail page.
        onTap: () => _openDetail(),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  SizedBox(
                    width: 112,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: AlignmentDirectional.centerStart,
                      child: EntryPlate(entry: entry, height: 40),
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: () => printReceipt(entry, widget.kcontroller),
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('چاپ رسید'),
                                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      textStyle: const TextStyle(fontSize: 11.5,fontFamily: 'Vazir'))
                  ),SizedBox(width: 10,),
                  OutlinedButton.icon(
                    onPressed: () => _openDetail(),
                    icon: const Icon(Icons.open_in_new_rounded, size: 14),
                    label: const Text('جزئیات'),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 32),
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      textStyle: const TextStyle(fontSize: 11.5,fontFamily: 'Vazir'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const GradientDivider(height: 1),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final row in rows)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            row[0],
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            row[1],
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------- images

  /// The cropped-plate thumbnail.
  ///
  /// It is a cached image with a fixed, small decode size so scrolling the
  /// list never re-decodes (and never blanks) the picture. The Hero tag is
  /// derived from the record id only — an index based tag changes while
  /// scrolling and makes Flutter drop the flight.
  Widget _thumbnail(databaseClass entry) {
    final heroTag = detectionHeroTag(entry.id);
    final image = ThumbImage(
      url: pbFileUrlOf('database', entry.id, entry.imgpath),
      width: 64,
      height: 46,
      fit: BoxFit.contain,
      cacheWidth: 240,
      borderRadius: 7,
    );

    if (heroTag == null) return image;
    return Hero(tag: heroTag, child: image);
  }

  // ---------------------------------------------------------------- actions

  Future<void> _openDetail() async {
    final plate = entry.plateNum ?? '';
    if (plate.isEmpty) return;
    try {
      final record = await pb
          .collection('database')
          .getFullList(filter: 'plateNum="${pbEscape(plate)}"')
          .timeout(const Duration(seconds: 15));

      if (!mounted) return;
      Get.to(() => Detailedscreen(
            rec: record,
            kcontroller: widget.kcontroller,
            selectedModel: entry,
            index: widget.fullIndex,
          ));
    } catch (e) {
      appLog('detection detail fetch failed', e);
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('خطا در دریافت اطلاعات تردد')),
      );
    }
  }

  Future<void> _addPerson() async {
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
        arvandDigits: entry.isarvand == 'arvand' ? plateNum : '',
        isArvand: entry.isarvand == 'arvand',
        isEdit: false,
        index: widget.fullIndex,
        isDiscover: true,
        engishAlphabet: parsed['ch'] ?? '',
        persianAlhpabet: parsed['fa'] ?? '',
        kcontroller: widget.kcontroller,
      ),
    );
  }

  Future<void> _delete() async {
    // Capture id first: the old code read cameras[index].id AFTER delete for
    // the snackbar, using a stale index (RangeError).
    final id = entry.id;
    if (id == null || id.isEmpty) return;
    try {
      await pb.collection('database').delete(id);
    } catch (e) {
      appLog('delete database record failed', e);
      if (!mounted) return;
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(const SnackBar(content: Text('خطا در حذف رکورد')));
    }
  }
}
