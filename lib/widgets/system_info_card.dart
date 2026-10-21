import 'package:flutter/material.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/system_info.dart';
import 'app_card.dart';
import 'dashboard_charts.dart';

/// Small monospaced strip with uptime, CPU core count and CPU model.
class SystemInfoStrip extends StatelessWidget {
  const SystemInfoStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final uptime = SystemInfo.uptime;

    return BentoCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Wrap(
        spacing: 22,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          _item('مدت زمان روشن بودن سیستم', _formatUptime(uptime)),
          _item(
            'تعداد هسته',
            SystemInfo.cpuCoreCount.toString().toPersianDigit(),
          ),
          _item('مدل', SystemInfo.cpuModel),
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

  Widget _item(String label, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTheme.numeric(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}

/// A single usage donut (storage or RAM) as a bento cell.
class UsageDonutCard extends StatefulWidget {
  const UsageDonutCard({
    super.key,
    required this.title,
    required this.loader,
    required this.usedColor,
  });

  final String title;
  final Future<SystemUsage?> Function() loader;
  final Color usedColor;

  @override
  State<UsageDonutCard> createState() => _UsageDonutCardState();
}

class _UsageDonutCardState extends State<UsageDonutCard> {
  SystemUsage? _usage;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final usage = await widget.loader();
    if (!mounted) return;
    setState(() {
      _usage = usage;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const BentoCard(
        child: SizedBox(
          height: 200,
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

    final usage = _usage;

    return BentoCard(
      child: UsageDonutChart(
        title: widget.title,
        totalLabel: usage == null
            ? 'نامشخص'
            : formatBytes(usage.total, convertDigits: _digits),
        usedValue: usage?.used ?? 0,
        totalValue: usage?.total ?? 0,
        usedLabel: 'استفاده شده',
        freeLabel: 'آزاد',
        usedColor: widget.usedColor,
        freeColor: AppColors.primary,
      ),
    );
  }

  static String _digits(String value) => value.toPersianDigit();
}

/// Storage + RAM usage side by side.
class SystemUsagePanel extends StatelessWidget {
  const SystemUsagePanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 760;
        final storage = UsageDonutCard(
          title: 'گزارش فضای ذخیره سازی',
          loader: SystemInfo.storageUsage,
          usedColor: AppColors.warning,
        );
        final memory = UsageDonutCard(
          title: 'گزارش فضای RAM',
          loader: () async => SystemInfo.memoryUsage(),
          usedColor: AppColors.unauthorized,
        );

        if (!wide) {
          return Column(
            children: [
              storage,
              const SizedBox(height: 14),
              memory,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: storage),
            const SizedBox(width: 14),
            Expanded(child: memory),
          ],
        );
      },
    );
  }
}
