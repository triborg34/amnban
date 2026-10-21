import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shamsi_date/shamsi_date.dart';

import '../theme/app_colors.dart';
import '../utils/dashboard_stats.dart';

/// Stacked bar chart of the traffic of the last 7 days.
///
/// Every day has two rods — ورود (entry) and خروج (exit) — and each rod is
/// stacked into مجاز / غیر مجاز / بدون مالک segments with value labels.
class WeeklyTrafficChart extends StatelessWidget {
  const WeeklyTrafficChart({
    super.key,
    required this.days,
    this.height = 300,
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

    final maxValue = days.fold<double>(0, (acc, d) {
      final value = d.entries > d.exits ? d.entries : d.exits;
      return value > acc ? value.toDouble() : acc;
    });
    final maxY = (maxValue * 1.25).clamp(10.0, 100000.0);

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
                  getTooltipColor: (_) => AppColors.sidebar,
                  tooltipBorderRadius: BorderRadius.circular(6),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      '${rod.toY.toInt().toString().toPersianDigit()}\n',
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      children: [
                        TextSpan(
                          text: rodIndex == 0 ? 'ورود' : 'خروج',
                          style: const TextStyle(
                            color: Colors.white70,
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
                horizontalInterval: (maxY / 4).ceilToDouble().clamp(1, 100000),
                getDrawingHorizontalLine: (_) => const FlLine(
                  color: AppColors.divider,
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
                    reservedSize: 42,
                    interval: (maxY / 4).ceilToDouble().clamp(1, 100000),
                    getTitlesWidget: (value, meta) => Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Text(
                        value.toInt().toString().toPersianDigit(),
                        textAlign: TextAlign.left,
                        style: const TextStyle(
                          fontSize: 10,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 34,
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
                          style: const TextStyle(
                            fontSize: 10,
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
                    barsSpace: 4,
                    barRods: [
                      _rod(
                        total: days[i].entries,
                        allowed: days[i].entriesAllowed,
                        denied: days[i].entriesDenied,
                        unknown: days[i].entriesUnknown,
                        color: AppColors.chartTeal,
                      ),
                      _rod(
                        total: days[i].exits,
                        allowed: days[i].exitsAllowed,
                        denied: days[i].exitsDenied,
                        unknown: days[i].exitsUnknown,
                        color: AppColors.chartGreen,
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const _ChartLegend(),
      ],
    );
  }

  BarChartRodData _rod({
    required int total,
    required int allowed,
    required int denied,
    required int unknown,
    required Color color,
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
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ));
    }

    push(allowed, AppColors.chartGreen);
    push(denied, AppColors.chartPurple);
    push(unknown, AppColors.chartOrange);

    return BarChartRodData(
      toY: total.toDouble(),
      width: 12,
      borderRadius: BorderRadius.circular(3),
      color: color.withValues(alpha: 0.25),
      rodStackItems: items,
    );
  }
}

class _ChartLegend extends StatelessWidget {
  const _ChartLegend();

  @override
  Widget build(BuildContext context) {
    const entries = [
      (label: 'ورود مجاز', color: AppColors.chartTeal),
      (label: 'خروج مجاز', color: AppColors.chartGreen),
      (label: 'غیر مجاز', color: AppColors.chartPurple),
      (label: 'بدون مالک', color: AppColors.chartOrange),
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
              const SizedBox(width: 5),
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
    this.height = 240,
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
          '$title  (کل فضا: $totalLabel)',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: height,
          child: Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  centerSpaceRadius: 52,
                  sectionsSpace: 2,
                  sections: [
                    if (used > 0)
                      PieChartSectionData(
                        value: used,
                        color: usedColor,
                        radius: 42,
                        title: '${usedPercent.toStringAsFixed(1)}٪',
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    if (free > 0)
                      PieChartSectionData(
                        value: free,
                        color: freeColor,
                        radius: 42,
                        title: '${freePercent.toStringAsFixed(1)}٪',
                        titleStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: 96,
                alignment: Alignment.center,
                child: Text(
                  '${totalLabel}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _legend(
          usedLabel: usedLabel,
          freeLabel: freeLabel,
          usedColor: usedColor,
          freeColor: freeColor,
        ),
      ],
    );
  }

  Widget _legend({
    required String usedLabel,
    required String freeLabel,
    required Color usedColor,
    required Color freeColor,
  }) {
    Widget item(String label, Color color) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        );

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 6,
      children: [
        item(usedLabel, usedColor),
        item(freeLabel, freeColor),
      ],
    );
  }
}
