import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/dashboard_stats.dart';
import 'package:amnban/utils/system_info.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/dashboard_charts.dart';
import 'package:amnban/widgets/data_base_entries.dart';
import 'package:amnban/widgets/amar_dialog.dart';
import 'package:amnban/widgets/live_view.dart';
import 'package:amnban/widgets/stat_tile.dart';
import 'package:amnban/widgets/system_info_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Main page — dashboard with live view, statistics, charts and the
/// detection list, laid out as a bento grid.
class HomeSceen extends StatefulWidget {
  HomeSceen({
    required this.mController,
    super.key,
  });
  mainPageConroller mController;

  @override
  State<HomeSceen> createState() => _HomeSceenState();
}

class _HomeSceenState extends State<HomeSceen> {
  final FocusNode _keyboardFocusNode = FocusNode();
  databaseController dcontroller = Get.find<databaseController>();
  knowPersonController kcontroller = Get.find<knowPersonController>();

  @override
  void dispose() {
    _keyboardFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _keyboardFocusNode,
      autofocus: true,
      onKeyEvent: (event) {
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.digit1) {
          onRelayOne();
        }
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.digit2) {
          onRelayTwo();
        }
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 26),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _stats(),
            const SizedBox(height: 14),
            const LiveViewSection(),
            const SizedBox(height: 14),
            _bento(),
            const SizedBox(height: 14),
            _todaySummary(),
            const SizedBox(height: 14),
            _relayButtons(),
            const SizedBox(height: 14),
            const SystemInfoStrip(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ stats

  Widget _stats() {
    return Obx(() {
      final cameras = Get.find<cameraController>();
      final today = DashboardStats.today(
        entries: dcontroller.entries,
        cameras: cameras,
        persons: kcontroller,
      );

      final tiles = [
        StatTile(
          label: 'موجود در پارکینگ',
          caption: 'در حال حاضر',
          value: DashboardStats.presentInParking(today),
          icon: Icons.directions_car_filled_outlined,
          accent: AppColors.primary,
        ),
        StatTile(
          label: 'ورود امروز',
          caption: 'ترددهای ورودی',
          value: today.entries,
          icon: Icons.login_rounded,
          accent: AppColors.unauthorized,
        ),
        StatTile(
          label: 'خروج امروز',
          caption: 'ترددهای خروجی',
          value: today.exits,
          icon: Icons.logout_rounded,
          accent: AppColors.warning,
        ),
      ];

      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 760;
          if (!wide) {
            return Column(
              children: [
                for (var i = 0; i < tiles.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  tiles[i],
                ],
              ],
            );
          }
          return Row(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: tiles[i]),
              ],
            ],
          );
        },
      );
    });
  }

  // ------------------------------------------------------------------ bento

  Widget _bento() {
    return Obx(() {
      final cameras = Get.find<cameraController>();
      final days = DashboardStats.lastDays(
        entries: dcontroller.entries,
        cameras: cameras,
        persons: kcontroller,
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final columns = constraints.maxWidth >= 1180
              ? 3
              : constraints.maxWidth >= 720
                  ? 2
                  : 1;

          final chart = BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(
                  title: 'گزارش ورود و خروج ۷ روز گذشته',
                  subtitle: 'تفکیک مجاز و غیر مجاز',
                  icon: Icons.stacked_bar_chart_rounded,
                ),
                const SizedBox(height: 14),
                WeeklyTrafficChart(days: days),
              ],
            ),
          );

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

          final detections = BentoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CardHeader(
                  title: 'لیست ترددها',
                  subtitle: 'آخرین رویدادهای ثبت شده',
                  icon: Icons.list_alt_rounded,
                ),
                const SizedBox(height: 12),
                dataBaseEntries(
                  dcontroller: dcontroller,
                  mController: widget.mController,
                  kcontroller: kcontroller,
                ),
              ],
            ),
          );

          final items = <BentoItem>[
            BentoItem(child: chart, span: columns >= 3 ? 2 : columns),
            BentoItem(child: storage, span: columns >= 3 ? 1 : columns),
            BentoItem(child: memory, span: columns >= 3 ? 1 : columns),
            BentoItem(child: detections, span: columns >= 3 ? 3 : columns),
          ];

          return BentoGrid(items: items, columns: columns);
        },
      );
    });
  }

  // --------------------------------------------------------------- summary

  Widget _todaySummary() {
    return Obx(() {
      return BentoCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const CardHeader(
              title: 'آمار امروز',
              subtitle: 'خلاصه پلاک های ثبت شده',
              icon: Icons.insights_rounded,
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _summaryTile(
                  'تعداد کل پلاک های امروز',
                  dcontroller.todayCount.value.toString(),
                ),
                _summaryTile(
                  'پلاک های مجاز امروز',
                  dcontroller.todayallowd.length.toString(),
                  color: AppColors.primary,
                ),
                _summaryTile(
                  'پلاک های غیر مجاز امروز',
                  dcontroller.todayunallowed.length.toString(),
                  color: AppColors.unauthorized,
                ),
                _summaryTile(
                  'پلاک های سالم امروز',
                  dcontroller.goodPlate.value.toString(),
                ),
                _summaryTile(
                  'پلاک های مخدوش امروز',
                  dcontroller.badPlate.value.toString(),
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 8,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    await showAmarDialog(
                        context, dcontroller.todayallowd, kcontroller);
                  },
                  icon: const Icon(Icons.verified_outlined, size: 16),
                  label: const Text('لیست پلاک های مجاز امروز'),
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await showAmarDialog(
                        context, dcontroller.todayunallowed, kcontroller);
                  },
                  icon: const Icon(Icons.gpp_bad_outlined, size: 16),
                  label: const Text('لیست پلاک های غیر مجاز امروز'),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }

  Widget _summaryTile(String title, String value, {Color? color}) {
    return Container(
      width: 220,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString().toPersianDigit(),
            style: AppTheme.numeric(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------------- relay

  Widget _relayButtons() {
    return Obx(() {
      final scontroller = Get.find<settingController>();
      if (scontroller.settings.isEmpty) return const SizedBox.shrink();
      final s = scontroller.settings.last;
      if (!((s.isRfid ?? false) && (s.rfconnect ?? false))) {
        return const SizedBox.shrink();
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton.icon(
            onPressed: onRelayOne,
            icon: const Icon(Icons.sensor_door_outlined, size: 16),
            label: const Text('درب یک'),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
            onPressed: onRelayTwo,
            icon: const Icon(Icons.sensor_door_outlined, size: 16),
            label: const Text('درب دو'),
          ),
        ],
      );
    });
  }
}
