import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/futurs_of_system_row.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Detection accuracy sliders.
class SlidersWidgets extends StatelessWidget {
  const SlidersWidgets({
    super.key,
    required this.scontroller,
  });

  final settingController scontroller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _slider(
          label: "دقت تشخیص پلاک",
          read: () => scontroller.plateConf.value,
          onChanged: (value) => scontroller.plateConf.value = value,
        ),
        const SizedBox(height: 12),
        _slider(
          label: "دقت تشخیص حروف",
          read: () => scontroller.charConf.value,
          onChanged: (value) => scontroller.charConf.value = value,
        ),
        const SizedBox(height: 12),
        _slider(
          label: "کیفیت عکس",
          read: () => scontroller.quality.value,
          min: 0,
          max: 100,
          divisions: 10,
          onChanged: (value) => scontroller.quality.value = value,
        ),
      ],
    );
  }

  Widget _slider({
    required String label,
    required double Function() read,
    required ValueChanged<double> onChanged,
    double min = 0,
    double max = 1,
    int? divisions,
  }) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        FutursOfSystemRow(lable: label),
        Expanded(
          child: Obx(
            () => Slider(
              value: read().clamp(min, max).toDouble(),
              min: min,
              max: max,
              divisions: divisions,
              onChanged: onChanged,
            ),
          ),
        ),
        SizedBox(
          width: 46,
          child: Obx(
            () => Text(
              '${(read() * 100).round()}٪',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
