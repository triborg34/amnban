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

/// Detail view of a single detection.
///
/// Shows the full camera frame, the cropped plate, the editable plate
/// information and the download / report actions.
class Detailedscreen extends StatefulWidget {
  Detailedscreen(
      {required this.selectedModel,
      required this.index,
      required this.kcontroller,
      required this.rec,
      super.key});

  databaseClass selectedModel;
  knowPersonController kcontroller;
  int index;
  List rec;

  @override
  State<Detailedscreen> createState() => _DetailedscreenState();
}

class _DetailedscreenState extends State<Detailedscreen> {
  late final TextEditingController _modelController;
  late final TextEditingController _colorController;
  late String _plateType;
  late String _carType;
  late String _access;

  @override
  void initState() {
    super.initState();
    final person = widget.kcontroller.personFor(widget.selectedModel.plateNum);
    _plateType = widget.selectedModel.isarvand == 'arvand' ? 'اروند' : 'عادی';
    _carType = _carTypeOf(widget.selectedModel.plateNum ?? '');
    _access = person?.role ?? 'مجاز';
    final carName = person?.carName ?? '';
    _modelController = TextEditingController(text: carName);
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
    final entry = widget.selectedModel;
    final person = widget.kcontroller.personFor(entry.plateNum);
    final camera = Get.find<cameraController>();
    String? gate;
    for (final c in camera.cameras) {
      if (c.path == entry.rtpath) {
        gate = c.gate ?? 'entre';
        break;
      }
    }
    final direction = (gate == null || gate == 'entre') ? 'ورود' : 'خروج';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('مشاهده و ویرایش اطلاعات پلاک'),
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.close),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _cameraFrame(entry),
                const SizedBox(height: 16),
                _platePreview(entry),
                const SizedBox(height: 16),
                _infoCard(entry, person, direction),
                const SizedBox(height: 16),
                _actions(entry),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // -------------------------------------------------------------- camera

  Widget _cameraFrame(databaseClass entry) {
    final url = pbFileUrlOf('database', entry.id, entry.scrnPath);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionTitle(
            title: 'تصویر لحظه شناسایی',
            icon: Icons.videocam_outlined,
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 380,
              color: const Color(0xFF10201F),
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
          ),
        ],
      ),
    );
  }

  // --------------------------------------------------------------- plate

  Widget _platePreview(databaseClass entry) {
    final imageUrl = pbFileUrlOf('database', entry.id, entry.imgpath);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionTitle(
            title: 'پلاک خوانده شده',
            icon: Icons.confirmation_number_outlined,
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 560;
              final preview = Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: EntryPlate(entry: entry, height: 56),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SafeNetImage(
                      url: imageUrl,
                      fit: BoxFit.contain,
                      width: double.infinity,
                      height: 110,
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
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------- info

  Widget _infoCard(
      databaseClass entry, dynamic person, String direction) {
    final rows = <List<String>>[
      ['جهت خودرو', direction],
      ['نوع خودرو', _carType],
      ['مدل خودرو', person?.carName ?? '-'],
      ['رنگ خودرو', _colorController.text.isEmpty ? '-' : _colorController.text],
      ['وضعیت تردد', person?.role ?? 'بدون مالک'],
      ['مدل تشخیص پلاک', '${entry.platePercent ?? 0}٪'],
      ['زمان دقیق ساخت', entry.created ?? '-'],
      ['موقعیت دقیق جغرافیایی',
        '${_provinceOf(entry.provice)} - ${_cityOf(entry.city)}'],
      ['وضعیت پرداخت', 'پرداخت شده'],
      ['شماره پلاک', entry.plateNum ?? '-'],
      ['زمان دقیق ورود',
        '${(entry.eDate ?? '').toPersianDate()} ${(entry.eTime ?? '-').toPersianDigit()}'],
    ];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionTitle(
            title: 'اطلاعات پلاک',
            icon: Icons.info_outline,
            trailing: StatusChip(
              status: statusForEntry(entry, widget.kcontroller),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final row in rows)
                Container(
                  width: 240,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
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
          ),
          const SizedBox(height: 14),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.check, size: 16),
              label: const Text('ثبت'),
            ),
          ),
        ],
      ),
    );
  }

  // -------------------------------------------------------------- actions

  Widget _actions(databaseClass entry) {
    final frameUrl = pbFileUrlOf('database', entry.id, entry.scrnPath);
    final plateUrl = pbFileUrlOf('database', entry.id, entry.imgpath);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionTitle(
            title: 'خروجی گرفتن',
            icon: Icons.download_outlined,
          ),
          const SizedBox(height: 12),
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
                icon: const Icon(Icons.crop_free, size: 16),
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
                icon: const Icon(Icons.list_alt_outlined, size: 16),
                label: const Text('لیست پلاک های مشابه'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- save

  Future<void> _save() async {
    final plate = widget.selectedModel.plateNum ?? '';
    if (plate.isEmpty) return;
    final person = widget.kcontroller.personFor(plate);
    if (person == null || person.id == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('این پلاک در لیست افراد ثبت نشده است'),
        ),
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

  // ---------------------------------------------------------------- forms

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

  // -------------------------------------------------------------- helpers

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
