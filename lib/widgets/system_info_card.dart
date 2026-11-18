import 'dart:async';

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

/// Fetches both backend percentages with one request every five seconds.
class BackendUsageCards extends StatefulWidget {
  const BackendUsageCards({super.key, required this.cpuCard});

  final Widget cpuCard;

  @override
  State<BackendUsageCards> createState() => _BackendUsageCardsState();
}

class _BackendUsageCardsState extends State<BackendUsageCards> {
  static const double _cardHeight = 390;

  Timer? _timer;
  double? _ram;
  double? _disk;
  bool _requestInFlight = false;

  @override
  void initState() {
    super.initState();
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _refresh());
  }

  Future<void> _refresh() async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    try {
      final values = await SystemInfo.backendUsage();
      if (!mounted || values == null) return;
      setState(() {
        _ram = values['ram'];
        _disk = values['disk'];
      });
    } finally {
      _requestInFlight = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  SystemUsage? _asUsage(double? percent) =>
      percent == null ? null : SystemUsage(used: percent, total: 100);

  @override
  Widget build(BuildContext context) {
    final disk =
        _card('گزارش فضای ذخیره سازی', _asUsage(_disk), AppColors.warning);
    final ram = _card('گزارش فضای RAM', _asUsage(_ram), AppColors.unauthorized);
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1180) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: SizedBox(height: _cardHeight, child: ram)),
              const SizedBox(width: 14),
              Expanded(child: SizedBox(height: _cardHeight, child: disk)),
              const SizedBox(width: 14),
              Expanded(
                  child: SizedBox(height: _cardHeight, child: widget.cpuCard)),
            ],
          );
        }
        if (constraints.maxWidth < 760) {
          return Column(
            children: [
              SizedBox(height: _cardHeight, child: ram),
              const SizedBox(height: 14),
              SizedBox(height: _cardHeight, child: disk),
              const SizedBox(height: 14),
              SizedBox(height: _cardHeight, child: widget.cpuCard),
            ],
          );
        }
        return Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: SizedBox(height: _cardHeight, child: ram)),
                const SizedBox(width: 14),
                Expanded(child: SizedBox(height: _cardHeight, child: disk)),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(height: _cardHeight, child: widget.cpuCard),
          ],
        );
      },
    );
  }

  Widget _card(String title, SystemUsage? usage, Color color) {
    return BentoCard(
      child: UsageDonutChart(
        title: title,
        totalLabel: usage == null ? 'نامشخص' : '۱۰۰٪',
        usedValue: usage?.used ?? 0,
        totalValue: usage?.total ?? 0,
        usedLabel: 'استفاده شده',
        freeLabel: 'آزاد',
        usedColor: color,
        freeColor: AppColors.primary,
      ),
    );
  }
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
