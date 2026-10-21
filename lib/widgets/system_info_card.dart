import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../theme/app_colors.dart';
import '../utils/system_info.dart';
import 'app_card.dart';
import 'dashboard_charts.dart';

/// Small footer card with uptime, CPU core count and CPU model.
class SystemInfoCard extends StatelessWidget {
  const SystemInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final uptime = SystemInfo.uptime;

    return AppCard(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              'اطلاعات سیستم',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoColumn(
                  label: 'مدت زمان روشن بودن سیستم',
                  value: _formatUptime(uptime),
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  label: 'تعداد هسته',
                  value: SystemInfo.cpuCoreCount.toString().toPersianDigit(),
                ),
              ),
              Expanded(
                child: _InfoColumn(
                  label: 'مدل',
                  value: SystemInfo.cpuModel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatUptime(Duration duration) {
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final parts = <String>[
      if (days > 0) '${days.toString().toPersianDigit()} روز',
      '${hours.toString().toPersianDigit()} ساعت',
      '${minutes.toString().toPersianDigit()} دقیقه',
    ];
    return parts.join(' و ');
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          value,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// Two donut charts (storage + memory) mirroring the reference dashboard.
class SystemUsagePanel extends StatefulWidget {
  const SystemUsagePanel({super.key});

  @override
  State<SystemUsagePanel> createState() => _SystemUsagePanelState();
}

class _SystemUsagePanelState extends State<SystemUsagePanel> {
  SystemUsage? _storage;
  SystemUsage? _memory;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final storage = await SystemInfo.storageUsage();
    final memory = SystemInfo.memoryUsage();
    if (!mounted) return;
    setState(() {
      _storage = storage;
      _memory = memory;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const AppCard(
        child: SizedBox(
          height: 180,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final storage = _storage;
        final memory = _memory;

        final storageChart = AppCard(
          child: UsageDonutChart(
            title: 'گزارش فضای ذخیره سازی',
            totalLabel: storage == null
                ? 'نامشخص'
                : formatBytes(storage.total, convertDigits: _digits),
            usedValue: storage?.used ?? 0,
            totalValue: storage?.total ?? 0,
            usedLabel: 'فضای استفاده شده',
            freeLabel: 'فضای آزاد',
            usedColor: AppColors.chartOrange,
            freeColor: AppColors.chartGreen,
          ),
        );

        final memoryChart = AppCard(
          child: UsageDonutChart(
            title: 'گزارش فضای RAM',
            totalLabel: memory == null
                ? 'نامشخص'
                : formatBytes(memory.total, convertDigits: _digits),
            usedValue: memory?.used ?? 0,
            totalValue: memory?.total ?? 0,
            usedLabel: 'فضای استفاده شده',
            freeLabel: 'فضای آزاد',
            usedColor: AppColors.chartTeal,
            freeColor: AppColors.chartPurple,
          ),
        );

        if (!wide) {
          return Column(
            children: [
              storageChart,
              const SizedBox(height: 14),
              memoryChart,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: storageChart),
            const SizedBox(width: 14),
            Expanded(child: memoryChart),
          ],
        );
      },
    );
  }

  static String _digits(String value) => value.toPersianDigit();
}
