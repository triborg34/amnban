// lib/widgets/cpu_observer_card.dart
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'app_card.dart';
import 'dashboard_charts.dart';

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
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            UsageDonutChart(
              title: '\u067e\u0631\u062f\u0627\u0632\u0646\u062f\u0647',
              totalLabel: '\u06f1\u06f0\u06f0\u066a',
              usedValue: load,
              totalValue: 100,
              usedLabel:
                  '\u0628\u0627\u0631 \u067e\u0631\u062f\u0627\u0632\u0646\u062f\u0647',
              freeLabel: '\u0622\u0632\u0627\u062f',
              usedColor: AppColors.danger,
              freeColor: AppColors.primary,
              height: 170,
            ),
            const SizedBox(height: 10),
            _row('\u062a\u0639\u062f\u0627\u062f \u0647\u0633\u062a\u0647',
                s.cores.toString().toPersianDigit()),
            const SizedBox(height: 6),
            _row(
              'فرکانس',
              s.freqMhz == null
                  ? '—'
                  : '${s.freqMhz.toString().toPersianDigit()} مگاهرتز',
            ),
            const SizedBox(height: 6),
            _row('حافظه',
                '${s.ramPercent.toStringAsFixed(0).toPersianDigit()}٪'),
            const SizedBox(height: 6),
            _row('مدل', s.model),
            if (err != null) ...[
              const SizedBox(height: 6),
              Text(err,
                  style:
                      const TextStyle(fontSize: 10, color: AppColors.danger)),
            ],
          ],
        );
      }),
    );
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
