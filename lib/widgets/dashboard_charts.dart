import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/dashboard_stats.dart';

/// Seven day stacked bar chart — entries and exits split into authorized and
/// unauthorized.
class WeeklyTrafficChart extends StatelessWidget {
  const WeeklyTrafficChart({
    super.key,
    required this.days,
    this.height = 280,
  });

  final List<DayTraffic> days;
  final double height;

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) {
      return SizedBox(
        height: height,
        child: const Center(
          child: Text(
            'داده‌ای برای نمایش وجود ندارد',
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      );
    }

    var maxValue = 0.0;
    for (final d in days) {
      if (d.entries > maxValue) maxValue = d.entries.toDouble();
      if (d.exits > maxValue) maxValue = d.exits.toDouble();
    }
    final maxY = (maxValue * 1.3).clamp(10.0, 100000.0);
    final interval = (maxY / 4).ceilToDouble().clamp(1, 100000).toDouble();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: height,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              minY: 0,
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppColors.surfaceHigh,
                  tooltipBorderRadius: BorderRadius.circular(8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt().toString().toPersianDigit()}\n',
                      const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text: rodIndex == 0 ? 'ورود' : 'خروج',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: interval,
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.border,
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(),
                rightTitles: const AxisTitles(),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    interval: interval,
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        value.toInt().toString().toPersianDigit(),
                        textAlign: TextAlign.left,
                        style: AppTheme.numeric(
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= days.length) {
                        return const SizedBox.shrink();
                      }
                      final jalali = Jalali.fromDateTime(days[index].date);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${jalali.month}/${jalali.day}'.toPersianDigit(),
                          style: AppTheme.numeric(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textMuted,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: [
                for (int i = 0; i < days.length; i++)
                  BarChartGroupData(
                    x: i,
                    barsSpace: 3,
                    barRods: [
                      _rod(
                        allowed: days[i].entriesAllowed,
                        denied: days[i].entriesDenied + days[i].entriesUnknown,
                        base: AppColors.primary,
                      ),
                      _rod(
                        allowed: days[i].exitsAllowed,
                        denied: days[i].exitsDenied + days[i].exitsUnknown,
                        base: AppColors.warning,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        const _ChartLegend(),
      ],
    );
  }

  BarChartRodData _rod({
    required int allowed,
    required int denied,
    required Color base,
  }) {
    final items = <BarChartRodStackItem>[];
    var cursor = 0.0;

    void push(int value, Color segmentColor) {
      if (value <= 0) return;
      final from = cursor;
      cursor += value.toDouble();
      items.add(BarChartRodStackItem(
        from,
        cursor,
        segmentColor,
        label: value.toString().toPersianDigit(),
        labelStyle: const TextStyle(
          fontSize: 9.5,
          color: Color(0xFF04211F),
          fontWeight: FontWeight.w700,
        ),
      ));
    }

    push(allowed, base);
    push(denied, AppColors.unauthorized);

    return BarChartRodData(
      toY: cursor,
      width: 11,
      // Rounded bar tops.
      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      color: base.withValues(alpha: 0.22),
      rodStackItems: items,
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    const entries = [
      (label: 'ورود مجاز', color: AppColors.primary),
      (label: 'خروج مجاز', color: AppColors.warning),
      (label: 'غیر مجاز', color: AppColors.unauthorized),
    ];

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 6,
      children: [
        for (final e in entries)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: e.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                e.label,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Donut chart used for the storage / RAM usage panels.
///
/// The used percentage is rendered in the centre and a Persian caption sits
/// below the chart.
class UsageDonutChart extends StatelessWidget {
  const UsageDonutChart({
    super.key,
    required this.title,
    required this.totalLabel,
    required this.usedValue,
    required this.totalValue,
    required this.usedLabel,
    required this.freeLabel,
    required this.usedColor,
    required this.freeColor,
    this.height = 210,
  });

  final String title;
  final String totalLabel;
  final double usedValue;
  final double totalValue;
  final String usedLabel;
  final String freeLabel;
  final Color usedColor;
  final Color freeColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    final used =
        usedValue.clamp(0, totalValue <= 0 ? 0 : totalValue).toDouble();
    final free = (totalValue - used).clamp(0, double.infinity).toDouble();
    final usedPercent = totalValue <= 0 ? 0.0 : (used / totalValue) * 100;
    final freePercent = totalValue <= 0 ? 0.0 : (free / totalValue) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              if (totalValue > 0)
                PieChart(
                  PieChartData(
                    centerSpaceRadius: 44,
                    sectionsSpace: 3,
                    sections: [
                      if (used > 0)
                        PieChartSectionData(
                          value: used,
                          color: usedColor,
                          radius: 34,
                          // The percentage is rendered in the centre.
                          showTitle: false,
                        ),
                      if (free > 0)
                        PieChartSectionData(
                          value: free,
                          color: freeColor,
                          radius: 34,
                          showTitle: false,
                        ),
                    ],
                  ),
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${usedPercent.toStringAsFixed(1).toPersianDigit()}٪',
                    style: AppTheme.numeric(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: usedColor,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    totalValue > 0 ? 'استفاده شده' : 'نامشخص',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _legendDot(
              usedColor,
              '$usedLabel ${usedPercent.toStringAsFixed(1).toPersianDigit()}٪',
            ),
            const SizedBox(width: 14),
            _legendDot(
              freeColor,
              '$freeLabel ${freePercent.toStringAsFixed(1).toPersianDigit()}٪',
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'کل فضا: $totalLabel',
          textAlign: TextAlign.center,
          style: AppTheme.numeric(
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
