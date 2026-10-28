// lib/widgets/cpu_observer_card.dart
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';


import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';

class CpuObserverCard extends StatelessWidget {
  const CpuObserverCard({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CpuController());

    return BentoCard(
      child: Obx(() {
        final s = c.stats.value;
        final err = c.error.value;

        if (s == null) {
          return Text(
            err ?? 'در حال دریافت...',
            style: const TextStyle(color: AppColors.textMuted),
          );
        }

        final load = s.load.clamp(0, 100).toDouble();
        final color = _colorFor(load);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const CardHeader(
              title: 'پردازنده',
              subtitle: 'بار واقعی سرور',
              icon: Icons.memory_rounded,
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${load.toStringAsFixed(0)}٪'.toPersianDigit(),
                  style: AppTheme.numeric(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                    color: color,
                    height: 1.05,
                  ),
                ),
                const SizedBox(width: 8),
                const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    'بار پردازنده',
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: SizedBox(
                height: 8,
                child: Stack(
                  children: [
                    Container(color: AppColors.surface),
                    FractionallySizedBox(
                      widthFactor: (load / 100).clamp(0.02, 1.0),
                      child: Container(color: color),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            _row('تعداد هسته', s.cores.toString().toPersianDigit()),
            const SizedBox(height: 6),
            _row(
              'فرکانس',
              s.freqMhz == null
                  ? '—'
                  : '${s.freqMhz.toString().toPersianDigit()} مگاهرتز',
            ),
            const SizedBox(height: 6),
            _row('حافظه', '${s.ramPercent.toStringAsFixed(0).toPersianDigit()}٪'),
            const SizedBox(height: 6),
            _row('مدل', s.model),
            if (err != null) ...[
              const SizedBox(height: 6),
              Text(err,
                  style: const TextStyle(fontSize: 10, color: AppColors.danger)),
            ],
          ],
        );
      }),
    );
  }

  Color _colorFor(double load) {
    if (load < 45) return AppColors.primary;
    if (load < 75) return AppColors.warning;
    return AppColors.danger;
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: AppTheme.numeric(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}