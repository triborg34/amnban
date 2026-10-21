import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/utils/converFunctions.dart'
    show alphabetP2, convertToPersianString;
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/data_base_entries.dart' show isEntryVisible;
import 'package:amnban/widgets/detail_sheet.dart';
import 'package:amnban/widgets/iran_plate.dart';
import 'package:amnban/widgets/jalali_picker.dart';
import 'package:amnban/widgets/licance_searcher.dart';
import 'package:amnban/widgets/plate_picked.dart';
import 'package:amnban/widgets/safe_image.dart';
import 'package:amnban/widgets/status_chip.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:printing/printing.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Reports screen — collapsible filter panel + results table.
class Reportscreen extends StatefulWidget {
  Reportscreen({super.key});

  @override
  State<Reportscreen> createState() => _ReportscreenState();
}

class _ReportscreenState extends State<Reportscreen> {
  reportController rcontroller = Get.find<reportController>();
  knowPersonController kcontroller = Get.find<knowPersonController>();

  bool _filtersOpen = true;

  // ---- presentation-only filters (applied on top of the server results) --
  String _userType = 'همه';
  String _period = 'همه';
  String _carType = 'همه';
  String _plateType = 'همه';
  String _carColor = 'همه';
  final TextEditingController _carModelController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  int _pageSize = 50;

  static const List<String> _userTypes = [
    'همه',
    'مجاز',
    'غیر مجاز',
    'بدون مالک',
  ];
  static const List<String> _periods = [
    'همه',
    'امروز',
    'هفت روز اخیر',
    'سی روز اخیر',
    'سال جاری',
  ];
  static const List<String> _carTypes = [
    'همه',
    'شخصی',
    'تاکسی',
    'دولتی',
    'کامیون',
  ];
  static const List<String> _plateTypes = ['همه', 'عادی', 'اروند'];
  static const List<String> _carColors = [
    'همه',
    'سفید',
    'مشکی',
    'نقره ای',
    'خاکستری',
    'آبی',
    'قرمز',
  ];

  @override
  void initState() {
    // Reset search state once per visit, not on every rebuild (a rebuild used
    // to wipe whatever the user was typing).
    rcontroller.inilazed();
    super.initState();
  }

  @override
  void dispose() {
    _carModelController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _filterPanel(),
          const SizedBox(height: 14),
          _resultsTable(),
        ],
      ),
    );
  }

  // ------------------------------------------------------------ filter UI

  Widget _filterPanel() {
    return BentoCard(
      glass: true,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _filtersOpen = !_filtersOpen),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.tune_rounded,
                      size: 17, color: AppColors.primary),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'جستجو در گزارش',
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _filtersOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 220),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        size: 20, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(top: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _fields(),
                  const SizedBox(height: 14),
                  _plateField(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _reset,
                        icon: const Icon(Icons.refresh_rounded, size: 16),
                        label: const Text('ریست'),
                      ),
                      const SizedBox(width: 10),
                      OutlinedButton.icon(
                        onPressed: () => saveToPdf(_filtered()),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: const Text('دانلود'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton.icon(
                        onPressed: _search,
                        icon: const Icon(Icons.search_rounded, size: 16),
                        label: const Text('جستجو'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            crossFadeState:
                _filtersOpen ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          ),
        ],
      ),
    );
  }

  Widget _fields() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= 1000
            ? 4
            : constraints.maxWidth >= 640
                ? 3
                : 2;

        final fields = <Widget>[
          _dropdownField(
            label: 'نوع کاربر',
            value: _userType,
            items: _userTypes,
            onChanged: (v) => setState(() => _userType = v),
          ),
          _dropdownField(
            label: 'بازه زمانی',
            value: _period,
            items: _periods,
            onChanged: (v) {
              setState(() => _period = v);
              _applyPeriod(v);
            },
          ),
          _dateField(
            label: 'تاریخ شروع',
            value: rcontroller.firstDate.value,
            onPicked: (iso) {
              rcontroller.firstDate.value = iso;
              rcontroller.isDate.value = true;
              setState(() {});
            },
          ),
          _dateField(
            label: 'تاریخ پایان',
            value: rcontroller.lastDate.value,
            onPicked: (iso) {
              rcontroller.lastDate.value = iso;
              rcontroller.isDate.value = true;
              setState(() {});
            },
          ),
          _timeField(
            label: 'از ساعت',
            value: rcontroller.fistTime.value,
            onPicked: (time) {
              rcontroller.fistTime.value = time;
              rcontroller.isTime.value = true;
              setState(() {});
            },
          ),
          _timeField(
            label: 'تا ساعت',
            value: rcontroller.lastTime.value,
            onPicked: (time) {
              rcontroller.lastTime.value = time;
              setState(() {});
            },
          ),
          _dropdownField(
            label: 'نوع خودرو',
            value: _carType,
            items: _carTypes,
            onChanged: (v) => setState(() => _carType = v),
          ),
          _dropdownField(
            label: 'نوع پلاک',
            value: _plateType,
            items: _plateTypes,
            onChanged: (v) => setState(() => _plateType = v),
          ),
          _dropdownField(
            label: 'رنگ خودرو',
            value: _carColor,
            items: _carColors,
            onChanged: (v) => setSetColor(v),
          ),
          _textField(
            label: 'مدل خودرو',
            controller: _carModelController,
            onChanged: () => setState(() {}),
          ),
          _textField(
            label: 'توضیحات',
            controller: _descriptionController,
            onChanged: () => setState(() {}),
          ),
        ];

        final width = (constraints.maxWidth - 12 * (columns - 1)) / columns;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final field in fields) SizedBox(width: width, child: field),
          ],
        );
      },
    );
  }

  void setSetColor(String value) {
    setState(() => _carColor = value);
  }

  Widget _dropdownField({
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

  Widget _textField({
    required String label,
    required TextEditingController controller,
    required VoidCallback onChanged,
  }) {
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
          onChanged: (_) => onChanged(),
          style: const TextStyle(fontSize: 12.5),
          textAlign: TextAlign.right,
          decoration: const InputDecoration(hintText: '-'),
        ),
      ],
    );
  }

  Widget _dateField({
    required String label,
    required String value,
    required ValueChanged<String> onPicked,
  }) {
    return _tapField(
      label: label,
      value: value,
      icon: Icons.calendar_month_rounded,
      onTap: () async {
        final picked = await showJalaliDateTimePicker(
          context,
          initialDate: DateTime.now(),
          title: label,
        );
        if (picked == null) return;
        if (!mounted) return;
        onPicked(_isoOf(picked));
      },
    );
  }

  Widget _timeField({
    required String label,
    required String value,
    required ValueChanged<String> onPicked,
  }) {
    return _tapField(
      label: label,
      value: value,
      icon: Icons.schedule_rounded,
      onTap: () async {
        final picked = await showJalaliDateTimePicker(
          context,
          initialDate: DateTime.now(),
          title: label,
        );
        if (picked == null) return;
        if (!mounted) return;
        final hh = picked.hour.toString().padLeft(2, '0');
        final mm = picked.minute.toString().padLeft(2, '0');
        onPicked('$hh:$mm');
      },
    );
  }

  Widget _tapField({
    required String label,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 5),
        InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            height: 44,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: AlignmentDirectional.centerStart,
            decoration: BoxDecoration(
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(icon, size: 15, color: AppColors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    value.isEmpty ? '-' : value,
                    textAlign: TextAlign.right,
                    style: AppTheme.numeric(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _plateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'شماره پلاک',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            SizedBox(
              width: 210,
              child: Obx(() => rcontroller.isArvand.value
                  ? Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: AlignmentDirectional.centerStart,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        rcontroller.pickerPlate.value.isEmpty
                            ? '-'
                            : rcontroller.pickerPlate.value,
                        style: const TextStyle(
                            fontSize: 12.5, color: AppColors.textPrimary),
                      ),
                    )
                  : PlatePicked(rcontroller: rcontroller)),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () async {
                await showAdaptiveDialog(
                  context: context,
                  builder: (context) =>
                      licanceSearcher(rcontroller: rcontroller),
                );
              },
              icon: const Icon(Icons.search_rounded, size: 15),
              label: const Text('انتخاب'),
            ),
          ],
        ),
      ],
    );
  }

  // ----------------------------------------------------------- results UI

  Widget _resultsTable() {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Expanded(
                child: CardHeader(
                  title: 'نتایج گزارش',
                  icon: Icons.table_chart_rounded,
                ),
              ),
              Obx(() {
                final count = _filtered().length;
                return Text(
                  'گزارشی که یافت شد (${count.toString().toPersianDigit()} مورد یافت شد)',
                  style: AppTheme.numeric(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textMuted,
                  ),
                );
              }),
              const SizedBox(width: 12),
              SizedBox(
                width: 104,
                child: DropdownButtonFormField<int>(
                  key: ValueKey<int>(_pageSize),
                  initialValue: _pageSize,
                  items: const [
                    DropdownMenuItem(value: 50, child: Text('۵۰')),
                    DropdownMenuItem(value: 100, child: Text('۱۰۰')),
                    DropdownMenuItem(value: 500, child: Text('۵۰۰')),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _pageSize = v);
                  },
                  isExpanded: true,
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Obx(() {
            if (rcontroller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: SizedBox(
                    width: 26,
                    height: 26,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              );
            }
            if (rcontroller.searchError.value.isNotEmpty) {
              return const AppEmptyState(
                message: 'خطا در جستجو',
                icon: Icons.error_outline_rounded,
              );
            }

            final rows = _filtered();
            if (rows.isEmpty) {
              return const AppEmptyState(
                message: 'رکوردی یافت نشد',
                icon: Icons.search_off_rounded,
              );
            }

            final visible = rows.take(_pageSize).toList();

            return SizedBox(
              height: 520,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: 720,
                  child: Column(
                    children: [
                      const _TableHeader(),
                      const SizedBox(height: 6),
                      Expanded(
                        child: ListView.separated(
                          itemCount: visible.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 5),
                          itemBuilder: (context, index) =>
                              _TableRow(entry: visible[index]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------- filter logic

  /// Applies the presentation-only filters on top of the server results.
  List<databaseClass> _filtered() {
    final model = _carModelController.text.trim();
    final description = _descriptionController.text.trim();

    return rcontroller.selectedModel.where((entry) {
      // Rows with an unreadable plate were hidden before the redesign too.
      if (!isEntryVisible(entry)) return false;

      final plate = entry.plateNum ?? '';
      final person = kcontroller.personFor(plate);

      // --- user type ---
      if (_userType != 'همه') {
        if (_userType == 'بدون مالک') {
          if (person != null) return false;
        } else if (_userType == 'مجاز') {
          if (person == null || person.role != 'مجاز') return false;
        } else {
          if (person == null || person.role == 'مجاز') return false;
        }
      }

      // --- plate type ---
      if (_plateType != 'همه') {
        final isArvand = entry.isarvand == 'arvand';
        if (_plateType == 'اروند' && !isArvand) return false;
        if (_plateType == 'عادی' && isArvand) return false;
      }

      // --- car type (derived from the plate itself) ---
      if (_carType != 'همه') {
        if (_carTypeOf(plate) != _carType) return false;
      }

      // --- car model / colour (matched against the person's car name) ---
      final carName = person?.carName ?? '';
      if (model.isNotEmpty && !carName.contains(model)) return false;
      if (_carColor != 'همه' && !carName.contains(_carColor)) return false;

      // --- free text ---
      if (description.isNotEmpty) {
        final haystack = [
          plate,
          person?.name ?? '',
          carName,
          entry.city ?? '',
          entry.provice ?? '',
        ].join(' ');
        if (!haystack.contains(description)) return false;
      }

      return true;
    }).toList();
  }

  static String _carTypeOf(String plate) {
    if (plate.contains('x')) return 'تاکسی';
    if (plate.contains(RegExp(r'(?<![A-Za-z])A(?![A-Za-z])'))) return 'دولتی';
    if (plate.contains('EIN')) return 'کامیون';
    return 'شخصی';
  }

  /// Maps the "بازه زمانی" selection onto the existing date filters.
  void _applyPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'امروز':
        final iso = _isoOf(now);
        rcontroller.firstDate.value = iso;
        rcontroller.lastDate.value = iso;
        rcontroller.isDate.value = true;
        break;
      case 'هفت روز اخیر':
        rcontroller.firstDate.value =
            _isoOf(now.subtract(const Duration(days: 6)));
        rcontroller.lastDate.value = _isoOf(now);
        rcontroller.isDate.value = true;
        break;
      case 'سی روز اخیر':
        rcontroller.firstDate.value =
            _isoOf(now.subtract(const Duration(days: 29)));
        rcontroller.lastDate.value = _isoOf(now);
        rcontroller.isDate.value = true;
        break;
      case 'سال جاری':
        rcontroller.firstDate.value = _isoOf(DateTime(now.year, 1, 1));
        rcontroller.lastDate.value = _isoOf(now);
        rcontroller.isDate.value = true;
        break;
      default:
        rcontroller.firstDate.value = '';
        rcontroller.lastDate.value = '';
        rcontroller.isDate.value = false;
        break;
    }
  }

  static String _isoOf(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '${date.year}-$m-$d';
  }

  void _reset() {
    rcontroller.inilazed();
    rcontroller.update();
    setState(() {
      _userType = 'همه';
      _period = 'همه';
      _carType = 'همه';
      _plateType = 'همه';
      _carColor = 'همه';
      _carModelController.clear();
      _descriptionController.clear();
    });
  }

  Future<void> _search() async {
    if (rcontroller.isLoading.value) return;
    rcontroller.isLoading.value = true;
    rcontroller.searchError.value = '';

    try {
      rcontroller.isCompleted.value = await searchFunction(rcontroller);
    } catch (e) {
      rcontroller.searchError.value = 'خطا در جستجو';
      appLog('search failed', e);
    } finally {
      rcontroller.isLoading.value = false;
    }
  }

  Future<bool> searchFunction(reportController rcontroller) async {
    // Fill missing "to" bounds from the "from" values
    if (rcontroller.isDate.value && rcontroller.lastDate.value.isEmpty) {
      rcontroller.lastDate.value = rcontroller.firstDate.value;
    }
    if (rcontroller.isTime.value && rcontroller.lastTime.value.isEmpty) {
      rcontroller.lastTime.value = rcontroller.fistTime.value;
    }

    // Build the filter string based on active filters. Dates/times are
    // filtered server-side so we never download the whole collection.
    List<String> filters = [];

    if (rcontroller.pickerPlate.value.isNotEmpty) {
      filters.add('plateNum ~ "${pbEscape(rcontroller.pickerPlate.value)}"');
    }

    if (rcontroller.isDate.value) {
      if (rcontroller.firstDate.value == rcontroller.lastDate.value) {
        filters.add('eDate = "${pbEscape(rcontroller.firstDate.value)}"');
      } else {
        filters.add(
            'eDate >= "${pbEscape(rcontroller.firstDate.value)}" && eDate <= "${pbEscape(rcontroller.lastDate.value)}"');
      }
    }

    // eTime is stored zero-padded (HH:MM) so string comparison works.
    if (rcontroller.isTime.value) {
      if (rcontroller.fistTime.value == rcontroller.lastTime.value) {
        filters.add('eTime = "${pbEscape(rcontroller.fistTime.value)}"');
      } else {
        filters.add(
            'eTime >= "${pbEscape(rcontroller.fistTime.value)}" && eTime <= "${pbEscape(rcontroller.lastTime.value)}"');
      }
    }

    String filterString = filters.join(' && ');

    try {
      // Fetch records from PocketBase
      final records = await pb
          .collection('database')
          .getFullList(filter: filterString, sort: '-created')
          .timeout(const Duration(seconds: 30));

      // Replace previous results in one shot instead of appending (appending
      // also made the second search filter on the first search's plate).
      rcontroller.selectedModel
          .assignAll(records.map((r) => databaseClass.fromJson(r.data)));

      return true;
    } catch (e) {
      appLog('searchFunction failed', e);
      rcontroller.searchError.value = 'خطا در جستجو — اتصال را بررسی کنید';
      rethrow;
    }
  }

  // ------------------------------------------------------------------ PDF

  void saveToPdf(List<databaseClass> rows) async {
    final doc = pw.Document();
    final ttf = await fontFromAssetBundle('assets/fonts/arial.ttf');
    doc.addPage(
      pw.MultiPage(
        textDirection: pw.TextDirection.rtl,
        mainAxisAlignment: pw.MainAxisAlignment.start,
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        build: (pw.Context context) {
          return [
            pw.Row(children: [
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('پلاک',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('تاریخ',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('ساعت',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('نام و نام خانوادگی',
                    style:
                        pw.TextStyle(font: ttf, fontSize: 8) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('ماشین',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
              pw.Container(
                height: 30,
                width: 75,
                alignment: pw.Alignment.center,
                decoration: pw.BoxDecoration(border: pw.Border.all()),
                child: pw.Text('نام دوربین',
                    style: pw.TextStyle(font: ttf) // Apply the font
                    ),
              ),
            ]),
            for (var i in rows)
              () {
                try {
                  final plate = i.plateNum ?? '';
                  if (plate.isEmpty) return pw.SizedBox();
                  final ok = i.isarvand == 'arvand' ||
                      convertToPersianString(plate, alphabetP2) != '-';
                  if (!ok) return pw.SizedBox();
                  return pw.Container(
                      child: pw.Row(children: [
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(
                            i.isarvand == 'arvand'
                                ? plate.contains(RegExp('[a-zA-Z]'))
                                    ? "-"
                                    : plate.toPersianDigit()
                                : convertToPersianString(
                                    plate, alphabetP2),
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(i.eDate.toString().toPersianDate(),
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(i.eTime.toString().toPersianDigit(),
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(
                            kcontroller.personFor(i.plateNum)?.name ?? "-",
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                        height: 30,
                        width: 75,
                        alignment: pw.Alignment.center,
                        decoration: pw.BoxDecoration(border: pw.Border.all()),
                        child: pw.Text(
                            kcontroller.personFor(i.plateNum)?.carName ?? '-',
                            style: pw.TextStyle(font: ttf) // Apply the font
                            ),
                      ),
                      pw.Container(
                          height: 30,
                          width: 75,
                          alignment: pw.Alignment.center,
                          decoration: pw.BoxDecoration(border: pw.Border.all()),
                          child: pw.Text(
                            Get.find<cameraController>().cameraNameFor(i.rtpath),
                            style: pw.TextStyle(
                                font: ttf) // Apply the font
                            ),
                        ),
                    ]));
                } catch (_) {
                  return pw.SizedBox();
                }
              }()
          ];
        },
        footer: (pw.Context context) => pw.Text(' صفحه  ${context.pageNumber}',
            style: pw.TextStyle(font: ttf),
            textDirection: pw.TextDirection.rtl),
      ),
    );
    await Printing.layoutPdf(
        format: PdfPageFormat.a4,
        dynamicLayout: true,
        usePrinterSettings: true,
        onLayout: (PdfPageFormat format) async => doc.save());
  }
}

/// Sticky header of the results table.
class _TableHeader extends StatelessWidget {
  const _TableHeader();

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          head('پلاک', 130),
          head('وضعیت تردد', 120),
          head('جهت', 80),
          head('تصویر', 90),
          head('زمان تردد', 130),
          head('عملیات', 120),
        ],
      ),
    );
  }
}

/// A single row of the results table.
class _TableRow extends StatelessWidget {
  const _TableRow({required this.entry});

  final databaseClass entry;

  @override
  Widget build(BuildContext context) {
    final kcontroller = Get.find<knowPersonController>();
    final person = kcontroller.personFor(entry.plateNum);
    final status = statusForEntry(entry, kcontroller);

    String? gate;
    for (final c in Get.find<cameraController>().cameras) {
      if (c.path == entry.rtpath) {
        gate = c.gate ?? 'entre';
        break;
      }
    }
    final direction = (gate == null || gate == 'entre') ? 'ورود' : 'خروج';

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () => _open(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 130,
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: EntryPlate(entry: entry, height: 34),
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Center(child: StatusChip(status: status, dense: true)),
            ),
            SizedBox(
              width: 80,
              child: Center(
                child: Text(
                  direction,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: direction == 'ورود'
                        ? AppColors.primary
                        : AppColors.warning,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 90,
              child: Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(7),
                  child: SafeNetImage(
                    url: pbFileUrlOf('database', entry.id, entry.imgpath),
                    fit: BoxFit.cover,
                    width: 72,
                    height: 42,
                  ),
                ),
              ),
            ),
            SizedBox(
              width: 130,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      (entry.eTime ?? '-').toString().toPersianDigit(),
                      style: AppTheme.numeric(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      (entry.eDate ?? '').toPersianDate(),
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 120,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => _open(context),
                    icon: const Icon(Icons.visibility_outlined, size: 17),
                    tooltip: 'مشاهده جزئیات',
                    visualDensity: VisualDensity.compact,
                  ),
                  IconButton(
                    onPressed: () => _open(context),
                    icon: const Icon(Icons.print_outlined, size: 17),
                    tooltip: 'چاپ رسید',
                    visualDensity: VisualDensity.compact,
                  ),
                  if (person != null)
                    IconButton(
                      onPressed: () => _open(context),
                      icon: const Icon(Icons.person_outline, size: 17),
                      tooltip: person.name ?? '',
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

  Future<void> _open(BuildContext context) async {
    final plate = entry.plateNum ?? '';
    if (plate.isEmpty) return;
    try {
      final record = await pb
          .collection('database')
          .getFullList(filter: 'plateNum="${pbEscape(plate)}"')
          .timeout(const Duration(seconds: 15));

      if (!context.mounted) return;
      await showDetectionDetail(
        context,
        entry: entry,
        rec: record,
        kcontroller: Get.find<knowPersonController>(),
      );
    } catch (e) {
      appLog('report detail fetch failed', e);
    }
  }
}
