import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../theme/app_colors.dart';

const List<String> _jalaliMonthNames = [
  'فروردین',
  'اردیبهشت',
  'خرداد',
  'تیر',
  'مرداد',
  'شهریور',
  'مهر',
  'آبان',
  'آذر',
  'دی',
  'بهمن',
  'اسفند',
];

const List<String> _jalaliWeekDayShort = ['ش', 'ی', 'د', 'س', 'چ', 'پ', 'ج'];

/// Opens the Jalali (Persian) date + time picker.
///
/// Returns the picked `DateTime` (Gregorian) or `null` when cancelled.
Future<DateTime?> showJalaliDateTimePicker(
  BuildContext context, {
  DateTime? initialDate,
  String title = 'انتخاب تاریخ و ساعت',
}) {
  return showDialog<DateTime>(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.35),
    builder: (context) => Directionality(
      textDirection: TextDirection.rtl,
      child: _JalaliDateTimeDialog(
        initialDate: initialDate,
        title: title,
      ),
    ),
  );
}

class _JalaliDateTimeDialog extends StatefulWidget {
  const _JalaliDateTimeDialog({this.initialDate, required this.title});

  final DateTime? initialDate;
  final String title;

  @override
  State<_JalaliDateTimeDialog> createState() => _JalaliDateTimeDialogState();
}

class _JalaliDateTimeDialogState extends State<_JalaliDateTimeDialog> {
  late Jalali _selected;

  @override
  void initState() {
    super.initState();
    final base = widget.initialDate ?? DateTime.now();
    final jalali = Jalali.fromDateTime(base);
    _selected = Jalali(
      jalali.year,
      jalali.month,
      jalali.day,
      base.hour,
      base.minute,
      base.second,
    );
  }

  Jalali get _view => _selected;

  void _changeMonth(int delta) {
    var month = _view.month + delta;
    var year = _view.year;
    while (month > 12) {
      month -= 12;
      year++;
    }
    while (month < 1) {
      month += 12;
      year--;
    }
    final maxDay = Jalali(year, month, 1).monthLength;
    final day = _view.day > maxDay ? maxDay : _view.day;
    setState(() {
      _selected = Jalali(year, month, day, _view.hour, _view.minute, _view.second);
    });
  }

  void _changeYear(int delta) {
    final year = _view.year + delta;
    final maxDay = Jalali(year, _view.month, 1).monthLength;
    final day = _view.day > maxDay ? maxDay : _view.day;
    setState(() {
      _selected =
          Jalali(year, _view.month, day, _view.hour, _view.minute, _view.second);
    });
  }

  void _pickDay(int day) {
    setState(() {
      _selected = Jalali(
        _view.year,
        _view.month,
        day,
        _view.hour,
        _view.minute,
        _view.second,
      );
    });
  }

  void _setTime({int? hour, int? minute, int? second}) {
    setState(() {
      _selected = Jalali(
        _view.year,
        _view.month,
        _view.day,
        hour ?? _view.hour,
        minute ?? _view.minute,
        second ?? _view.second,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final leading = _leadingBlanks();

    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 380),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _header(),
              const SizedBox(height: 12),
              _weekHeader(),
              const SizedBox(height: 4),
              _dayGrid(leading),
              const SizedBox(height: 12),
              const Divider(height: 1, color: AppColors.divider),
              const SizedBox(height: 12),
              _timeSection(),
              const SizedBox(height: 14),
              _actions(),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ header

  Widget _header() {
    return Row(
      children: [
        Text(
          widget.title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        _iconButton(Icons.chevron_left, 'سال قبل', () => _changeYear(-1)),
        _iconButton(Icons.chevron_right, 'ماه قبل', () => _changeMonth(-1)),
        const SizedBox(width: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '${_jalaliMonthNames[_view.month - 1]} ${_view.year.toString().toPersianDigit()}',
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ),
        const SizedBox(width: 4),
        _iconButton(Icons.chevron_right, 'ماه بعد', () => _changeMonth(1)),
        _iconButton(Icons.chevron_left, 'سال بعد', () => _changeYear(1)),
      ],
    );
  }

  Widget _iconButton(IconData icon, String tooltip, VoidCallback onTap) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      color: AppColors.textSecondary,
      tooltip: tooltip,
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _weekHeader() {
    return Row(
      children: [
        for (final name in _jalaliWeekDayShort)
          Expanded(
            child: Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.textMuted,
              ),
            ),
          ),
      ],
    );
  }

  // ------------------------------------------------------------------ days

  /// Number of empty cells before the first day of the month.
  int _leadingBlanks() {
    final firstGregorian =
        Jalali(_view.year, _view.month, 1).toGregorian().toDateTime();
    // DateTime.weekday: 1 = Monday … 7 = Sunday. Persian week starts on
    // Saturday, so Saturday maps to 0.
    return (firstGregorian.weekday + 1) % 7;
  }

  Widget _dayGrid(int leading) {
    final days = Jalali(_view.year, _view.month, 1).monthLength;
    final cells = <Widget>[];

    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var day = 1; day <= days; day++) {
      final selected = day == _view.day;
      cells.add(
        Padding(
          padding: const EdgeInsets.all(2),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () => _pickDay(day),
            child: Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                day.toString().toPersianDigit(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 7,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.1,
      children: cells,
    );
  }

  // ------------------------------------------------------------------ time

  Widget _timeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: SizedBox(
            width: 150,
            height: 150,
            child: CustomPaint(
              painter: _ClockPainter(
                hour: _view.hour,
                minute: _view.minute,
                second: _view.second,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _TimeStepper(
              value: _view.hour,
              onUp: () => _setTime(hour: (_view.hour + 1) % 24),
              onDown: () => _setTime(hour: (_view.hour + 23) % 24),
            ),
            const SizedBox(width: 10),
            _TimeStepper(
              value: _view.minute,
              onUp: () => _setTime(minute: (_view.minute + 1) % 60),
              onDown: () => _setTime(minute: (_view.minute + 59) % 60),
            ),
            const SizedBox(width: 10),
            _TimeStepper(
              value: _view.second,
              onUp: () => _setTime(second: (_view.second + 1) % 60),
              onDown: () => _setTime(second: (_view.second + 59) % 60),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------------------------------------------------------- actions

  Widget _actions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('انصراف'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              final gregorian = _selected.toGregorian().toDateTime();
              Navigator.of(context).pop(gregorian);
            },
            child: const Text('تایید'),
          ),
        ),
      ],
    );
  }
}

/// Up / down stepper used for the hour, minute and second of the clock.
class _TimeStepper extends StatelessWidget {
  const _TimeStepper({
    required this.value,
    required this.onUp,
    required this.onDown,
  });

  final int value;
  final VoidCallback onUp;
  final VoidCallback onDown;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _button(Icons.keyboard_arrow_up, onUp),
        Container(
          width: 52,
          height: 30,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surfaceMuted,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: AppColors.border),
          ),
          child: Text(
            value.toString().padLeft(2, '0').toPersianDigit(),
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        _button(Icons.keyboard_arrow_down, onDown),
      ],
    );
  }

  Widget _button(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Icon(icon, size: 18, color: AppColors.textSecondary),
      ),
    );
  }
}

/// Analogue clock face drawn with the brand green.
class _ClockPainter extends CustomPainter {
  _ClockPainter({
    required this.hour,
    required this.minute,
    required this.second,
  });

  final int hour;
  final int minute;
  final int second;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    final face = Paint()..color = AppColors.primary;
    canvas.drawCircle(center, radius, face);

    final ring = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawCircle(center, radius - 2, ring);

    // Hour ticks.
    final tick = Paint()..color = Colors.white.withValues(alpha: 0.85);
    for (var i = 0; i < 12; i++) {
      final angle = (i * 30 - 90) * math.pi / 180;
      final outer = Offset(
        center.dx + (radius - 10) * math.cos(angle),
        center.dy + (radius - 10) * math.sin(angle),
      );
      final inner = Offset(
        center.dx + (radius - 16) * math.cos(angle),
        center.dy + (radius - 16) * math.sin(angle),
      );
      canvas.drawLine(inner, outer, tick..strokeWidth = 2);
    }

    void hand(double angleDegrees, double length, double width) {
      final angle = (angleDegrees - 90) * math.pi / 180;
      final end = Offset(
        center.dx + length * math.cos(angle),
        center.dy + length * math.sin(angle),
      );
      canvas.drawLine(
        center,
        end,
        Paint()
          ..color = Colors.white
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    hand((hour % 12) * 30 + minute * 0.5, radius * 0.48, 4);
    hand(minute * 6, radius * 0.72, 3);
    hand(second * 6, radius * 0.80, 1.4);

    canvas.drawCircle(center, 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(covariant _ClockPainter oldDelegate) {
    return oldDelegate.hour != hour ||
        oldDelegate.minute != minute ||
        oldDelegate.second != second;
  }
}
