import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/download.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/amar_dialog.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/iran_plate.dart';
import 'package:amnban/widgets/receipt_pdf.dart';
import 'package:amnban/widgets/safe_image.dart';
import 'package:amnban/widgets/status_chip.dart';
import 'package:easy_image_viewer/easy_image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Opens the detection detail.
///
/// Phones get a bottom sheet, wide screens a dialog anchored to the end
/// (left) side of the screen.
Future<void> showDetectionDetail(
  BuildContext context, {
  required databaseClass entry,
  required List rec,
  required knowPersonController kcontroller,
  int index = 0,
}) {
  final wide = MediaQuery.sizeOf(context).width >= 760;

  if (wide) {
    return showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.62),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Dialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          alignment: AlignmentDirectional.centerStart,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620),
            child: DetectionDetail(
              entry: entry,
              rec: rec,
              kcontroller: kcontroller,
              index: index,
            ),
          ),
        ),
      ),
    );
  }

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.surface,
    barrierColor: Colors.black.withValues(alpha: 0.62),
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, controller) => DetectionDetail(
          entry: entry,
          rec: rec,
          kcontroller: kcontroller,
          index: index,
          scrollController: controller,
        ),
      ),
    ),
  );
}

/// Full detail of one detection: camera frame, cropped plate, editable plate
/// fields and the download / report actions.
class DetectionDetail extends StatefulWidget {
  const DetectionDetail({
    super.key,
    required this.entry,
    required this.rec,
    required this.kcontroller,
    this.index = 0,
    this.scrollController,
  });

  final databaseClass entry;
  final List rec;
  final knowPersonController kcontroller;
  final int index;
  final ScrollController? scrollController;

  @override
  State<DetectionDetail> createState() => _DetectionDetailState();
}

class _DetectionDetailState extends State<DetectionDetail> {
  late final TextEditingController _modelController;
  late final TextEditingController _colorController;
  late String _plateType;
  late String _access;

  @override
  void initState() {
    super.initState();
    final person = widget.kcontroller.personFor(widget.entry.plateNum);
    _plateType = widget.entry.isarvand == 'arvand' ? 'اروند' : 'عادی';
    _access = person?.role ?? 'مجاز';
    _modelController = TextEditingController(text: person?.carName ?? '');
    _colorController = TextEditingController();
  }

  @override
  void dispose() {
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.entry;
    final person = widget.kcontroller.personFor(entry.plateNum);
    final direction = _directionOf(entry);

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: const BoxDecoration(
              color: AppColors.surfaceHigh,
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                const Icon(Icons.manage_search_rounded,
                    size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'مشاهده و ویرایش اطلاعات پلاک',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                StatusChip(status: statusForEntry(entry, widget.kcontroller)),
                const SizedBox(width: 6),
                IconButton(
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.close_rounded, size: 18),
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
          ),
          Flexible(
            child: SingleChildScrollView(
              controller: widget.scrollController,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _cameraFrame(entry),
                  const SizedBox(height: 14),
                  _plateBlock(entry, person, direction),
                  const SizedBox(height: 14),
                  _infoGrid(entry, person, direction),
                  const SizedBox(height: 14),
                  _actions(entry),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- sections

  Widget _cameraFrame(databaseClass entry) {
    final url = pbFileUrlOf('database', entry.id, entry.scrnPath);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 240,
        color: AppColors.surfaceHigh,
        alignment: Alignment.center,
        child: url.isEmpty
            ? const AppEmptyState(
                message: 'تصویری موجود نیست',
                icon: Icons.image_not_supported_outlined,
              )
            : EasyImageView(
                imageProvider: NetworkImage(url),
                onScaleChanged: (_) {},
              ),
      ),
    );
  }

  Widget _plateBlock(
      databaseClass entry, dynamic person, String direction) {
    final imageUrl = pbFileUrlOf('database', entry.id, entry.imgpath);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 520;

        final preview = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: EntryPlate(entry: entry, height: 52),
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SafeNetImage(
                url: imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                height: 100,
              ),
            ),
          ],
        );

        final form = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _dropdown(
              label: 'نوع پلاک',
              value: _plateType,
              items: const ['عادی', 'اروند'],
              onChanged: (v) => setState(() => _plateType = v),
            ),
            const SizedBox(height: 12),
            _field('مدل خودرو', _modelController),
            const SizedBox(height: 12),
            _field('رنگ خودرو', _colorController),
            const SizedBox(height: 12),
            _dropdown(
              label: 'وضعیت تردد',
              value: _access,
              items: const ['مجاز', 'غیر مجاز'],
              onChanged: (v) => setState(() => _access = v),
            ),
          ],
        );

        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              preview,
              const SizedBox(height: 16),
              form,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 3, child: preview),
            const SizedBox(width: 16),
            Expanded(flex: 2, child: form),
          ],
        );
      },
    );
  }

  Widget _infoGrid(
      databaseClass entry, dynamic person, String direction) {
    final rows = <List<String>>[
      ['جهت خودرو', direction],
      ['نوع خودرو', _carTypeOf(entry.plateNum ?? '')],
      ['مدل خودرو', person?.carName ?? '-'],
      [
        'رنگ خودرو',
        _colorController.text.isEmpty ? '-' : _colorController.text
      ],
      ['وضعیت تردد', person?.role ?? 'بدون مالک'],
      ['مدل تشخیص پلاک', '${entry.platePercent ?? 0}٪'],
      ['زمان دقیق ساخت', entry.created ?? '-'],
      [
        'موقعیت دقیق جغرافیایی',
        '${_provinceOf(entry.provice)} - ${_cityOf(entry.city)}'
      ],
      ['وضعیت پرداخت', 'پرداخت شده'],
      ['شماره پلاک', entry.plateNum ?? '-'],
      [
        'زمان دقیق ورود',
        '${(entry.eDate ?? '').toPersianDate()} ${(entry.eTime ?? '-').toPersianDigit()}'
      ],
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final row in rows)
          Container(
            width: 230,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  row[0],
                  style: const TextStyle(
                      fontSize: 10.5, color: AppColors.textMuted),
                ),
                const SizedBox(height: 3),
                Text(
                  row[1],
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _actions(databaseClass entry) {
    final frameUrl = pbFileUrlOf('database', entry.id, entry.scrnPath);
    final plateUrl = pbFileUrlOf('database', entry.id, entry.imgpath);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _save,
                icon: const Icon(Icons.check_rounded, size: 16),
                label: const Text('ثبت'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            OutlinedButton.icon(
              onPressed: frameUrl.isEmpty
                  ? null
                  : () => downloadUrl(frameUrl, fileName: 'frame.jpg'),
              icon: const Icon(Icons.image_outlined, size: 16),
              label: const Text('دانلود تصویر اصلی'),
            ),
            OutlinedButton.icon(
              onPressed: plateUrl.isEmpty
                  ? null
                  : () => downloadUrl(plateUrl, fileName: 'plate.jpg'),
              icon: const Icon(Icons.crop_free_rounded, size: 16),
              label: const Text('دانلود تصویر پلاک'),
            ),
            OutlinedButton.icon(
              onPressed: () => printReceipt(entry, widget.kcontroller),
              icon: const Icon(Icons.print_outlined, size: 16),
              label: const Text('چاپ رسید'),
            ),
            OutlinedButton.icon(
              onPressed: () async {
                try {
                  final temp = <databaseClass>[];
                  for (var data in widget.rec) {
                    try {
                      temp.add(databaseClass.fromJson(data.data));
                    } catch (e) {
                      appLog('detail rec parse failed', e);
                    }
                  }
                  if (!context.mounted) return;
                  await showAmarDialog(context, temp, widget.kcontroller);
                } catch (e) {
                  appLog('showAmarDialog failed', e);
                }
              },
              icon: const Icon(Icons.list_alt_rounded, size: 16),
              label: const Text('پلاک های مشابه'),
            ),
          ],
        ),
      ],
    );
  }

  // ------------------------------------------------------------------ save

  Future<void> _save() async {
    final plate = widget.entry.plateNum ?? '';
    if (plate.isEmpty) return;
    final person = widget.kcontroller.personFor(plate);
    if (person == null || person.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('این پلاک در لیست افراد ثبت نشده است')),
      );
      return;
    }

    final carName = [
      _modelController.text.trim(),
      _colorController.text.trim(),
    ].where((e) => e.isNotEmpty).join(' ');

    try {
      await pb.collection('registredDb').update(person.id!, body: {
        'carName': carName,
        'role': _access,
        'isarvand': _plateType == 'اروند' ? 'arvand' : 'notarvand',
      }).timeout(const Duration(seconds: 15));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('اطلاعات پلاک ذخیره شد ${person.id}')),
      );
      Navigator.of(context).maybePop();
    } catch (e) {
      appLog('save plate info failed', e);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('خطا در ذخیره اطلاعات')),
      );
    }
  }

  // ----------------------------------------------------------------- forms

  Widget _field(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          style: const TextStyle(fontSize: 12.5),
          decoration: const InputDecoration(hintText: '-'),
        ),
      ],
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 5),
        DropdownButtonFormField<String>(
          key: ValueKey<String>(value),
          initialValue: items.contains(value) ? value : items.first,
          items: [
            for (final item in items)
              DropdownMenuItem(value: item, child: Text(item)),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          isExpanded: true,
          style: const TextStyle(fontSize: 12.5, color: AppColors.textPrimary),
        ),
      ],
    );
  }

  // --------------------------------------------------------------- helpers

  String _directionOf(databaseClass entry) {
    final cameras = Get.find<cameraController>();
    for (final c in cameras.cameras) {
      if (c.path == entry.rtpath) {
        return (c.gate ?? 'entre') == 'entre' ? 'ورود' : 'خروج';
      }
    }
    return 'ورود';
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
