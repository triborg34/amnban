import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/dashboard_stats.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/dashboard_charts.dart';
import 'package:amnban/widgets/data_base_entries.dart';
import 'package:amnban/widgets/extended_table.dart';
import 'package:amnban/widgets/amar_dialog.dart';
import 'package:amnban/widgets/stat_card.dart';
import 'package:amnban/widgets/system_info_card.dart';
import 'package:amnban/widgets/video_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

/// Dashboard — mirrors the DIESPI reference layout:
/// stat strip → live camera grid → traffic chart → usage donuts → system
/// information.
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _statStrip(),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'آخرین تردد ها',
              icon: Icons.videocam_outlined,
              child: VideoBox(mController: widget.mController),
            ),
            const SizedBox(height: 16),
            _sectionCard(
              title: 'لیست ترددها',
              icon: Icons.list_alt_outlined,
              child: dataBaseEntries(
                dcontroller: dcontroller,
                mController: widget.mController,
                kcontroller: kcontroller,
              ),
            ),
            const SizedBox(height: 16),
            _liveEntries(),
            const SizedBox(height: 16),
            _trafficChart(),
            const SizedBox(height: 16),
            const SystemUsagePanel(),
            const SizedBox(height: 16),
            _todaySummary(),
            const SizedBox(height: 16),
            const SystemInfoCard(),
            const SizedBox(height: 16),
            _relayButtons(),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ stats

  Widget _statStrip() {
    return Obx(() {
      final cameras = Get.find<cameraController>();
      final today = DashboardStats.today(
        entries: dcontroller.entries,
        cameras: cameras,
        persons: kcontroller,
      );

      return LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= 640;
          final cards = [
            StatCard(
              label: 'موجود در پارکینگ',
              value: DashboardStats.presentInParking(today)
                  .toString()
                  .toPersianDigit(),
              icon: Icons.directions_car_filled_outlined,
              accent: AppColors.primary,
            ),
            StatCard(
              label: 'خروج روزانه',
              value: today.exits.toString().toPersianDigit(),
              icon: Icons.logout,
              accent: AppColors.warning,
            ),
            StatCard(
              label: 'ورود روزانه',
              value: today.entries.toString().toPersianDigit(),
              icon: Icons.login,
              accent: AppColors.chartTeal,
            ),
          ];

          if (!wide) {
            return Column(
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(height: 12),
                  cards[i],
                ],
              ],
            );
          }

          return Row(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: cards[i]),
              ],
            ],
          );
        },
      );
    });
  }

  // ----------------------------------------------------------- camera grid

  Widget _sectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSectionTitle(title: title, icon: icon),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // --------------------------------------------------------- live entries

  Widget _liveEntries() {
    return Obx(() {
      if (dcontroller.entries.isEmpty) {
        return const SizedBox.shrink();
      }
      return Visibility(
        visible: widget.mController.isSelected.value,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExtendedTable(
              index: dcontroller.selectedIndex.value,
              dcontroller: dcontroller,
              kcontroller: kcontroller,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    });
  }

  // ---------------------------------------------------------------- charts

  Widget _trafficChart() {
    return Obx(() {
      final cameras = Get.find<cameraController>();
      final days = DashboardStats.lastDays(
        entries: dcontroller.entries,
        cameras: cameras,
        persons: kcontroller,
      );

      return _sectionCard(
        title: 'گزارش ورود و خروج ۷ روز گذشته',
        icon: Icons.bar_chart_outlined,
        child: WeeklyTrafficChart(days: days),
      );
    });
  }

  // --------------------------------------------------------------- summary

  Widget _todaySummary() {
    return Obx(() {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const AppSectionTitle(
              title: 'آمار امروز',
              icon: Icons.insights_outlined,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _summaryTile(
                  'تعداد کل پلاک های امروز',
                  dcontroller.todayCount.value.toString(),
                ),
                _summaryTile(
                  'تعداد کل پلاک های مجاز امروز',
                  dcontroller.todayallowd.length.toString(),
                  color: AppColors.success,
                ),
                _summaryTile(
                  'تعداد کل پلاک های غیر مجاز امروز',
                  dcontroller.todayunallowed.length.toString(),
                  color: AppColors.unauthorized,
                ),
                _summaryTile(
                  'تعداد کل پلاک های سالم امروز',
                  dcontroller.goodPlate.value.toString(),
                ),
                _summaryTile(
                  'تعداد کل پلاک های مخدوش امروز',
                  dcontroller.badPlate.value.toString(),
                  color: AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: 12),
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
      width: 210,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(10),
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
            style: TextStyle(
              fontSize: 17,
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
