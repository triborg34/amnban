import 'dart:async';

import 'package:amnban/screens/camera_screen.dart';
import 'package:amnban/screens/home_sceen.dart';
import 'package:amnban/screens/person_screen.dart';
import 'package:amnban/screens/reportscreen.dart';
import 'package:amnban/screens/setting_screen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/app_logo.dart';
import 'package:amnban/widgets/nav_rail.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';
import 'package:shamsi_date/shamsi_date.dart';

/// Application shell.
///
/// Wide screens show a floating navigation rail, phones a bottom navigation
/// bar. Both drive the very same GetX tab index as before.
class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final mcontroller = Get.find<mainPageConroller>();
  late final Worker _navWorker;

  static const double _wideBreakpoint = 1000;

  int _homeIndex() => tabsFor(role).length - 1;

  List<Widget> _pagesFor(String currentRole) {
    if (currentRole == "ناظر") {
      return [
        PersonScreen(),
        Reportscreen(),
        HomeSceen(mController: mcontroller),
      ];
    }
    return [
      SettingScreen(),
      PersonScreen(),
      CameraScreen(),
      Reportscreen(),
      HomeSceen(mController: mcontroller),
    ];
  }

  @override
  void initState() {
    super.initState();
    final videoCtrl = Get.find<videoFeedController>();
    // If the app launches on a non-Home tab (deep link / restored index),
    // don't start every MJPEG stream in the background.
    if (mcontroller.navitaionIndex.value != _homeIndex()) {
      videoCtrl.pauseAll();
    }
    _navWorker = ever<int>(mcontroller.navitaionIndex, (idx) {
      final home = _homeIndex();
      if (idx == home) {
        videoCtrl.resumeAll();
      } else {
        videoCtrl.pauseAll();
      }
    });
  }

  @override
  void dispose() {
    _navWorker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _wideBreakpoint;

          final content = Column(
            children: [
              _header(),
              Expanded(
                child: Obx(() {
                  final pages = _pagesFor(role);
                  var idx = mcontroller.navitaionIndex.value;
                  if (idx < 0 || idx >= pages.length) idx = pages.length - 1;
                  // IndexedStack keeps each tab's scroll/form state alive
                  // instead of recreating the whole screen on every switch.
                  return IndexedStack(index: idx, children: pages);
                }),
              ),
            ],
          );

          if (!wide) {
            return Column(
              children: [
                Expanded(child: content),
                const AppBottomNav(),
              ],
            );
          }

          return Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First child of an RTL row is rendered on the right.
              const AppNavRail(),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  // ------------------------------------------------------------------ header

  Widget _header() {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
      decoration: const BoxDecoration(
        color: AppColors.background,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Flexible(child: CompanyLogo()),
              const SizedBox(width: 10),
              Expanded(
                child: Obx(() {
                  final labels = tabsFor(role);
                  final index = mcontroller.navitaionIndex.value;
                  final title = (index >= 0 && index < labels.length)
                      ? labels[index]
                      : '';
                  return Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  );
                }),
              ),
              const SizedBox(width: 8),
              const Flexible(child: _JalaliClock()),
            ],
          ),
          const SizedBox(height: 10),
          const GradientDivider(height: 1.2),
        ],
      ),
    );
  }
}

/// Current Jalali date + time shown on the opposite side of the header.
class _JalaliClock extends StatefulWidget {
  const _JalaliClock();

  @override
  State<_JalaliClock> createState() => _JalaliClockState();
}

class _JalaliClockState extends State<_JalaliClock> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final jalali = Jalali.fromDateTime(_now);
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: AlignmentDirectional.centerEnd,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.schedule_outlined,
              size: 14,
              color: AppColors.primary,
            ),
            const SizedBox(width: 8),
            Text(
              '${jalali.year}/${jalali.month}/${jalali.day}'.toPersianDigit(),
              textDirection: TextDirection.ltr,
              style: AppTheme.numeric(
                fontSize: 11.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              '$hh:$mm:$ss'.toPersianDigit(),
              textDirection: TextDirection.ltr,
              style: AppTheme.numeric(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
