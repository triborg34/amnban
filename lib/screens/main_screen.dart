import 'package:amnban/screens/camera_screen.dart';
import 'package:amnban/screens/home_sceen.dart';
import 'package:amnban/screens/person_screen.dart';
import 'package:amnban/screens/reportscreen.dart';
import 'package:amnban/screens/setting_screen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/app_logo.dart';
import 'package:amnban/widgets/app_sidebar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Application shell.
///
/// Wide screens show the dark-teal sidebar as a fixed panel on the right,
/// phones use the very same widget inside the navigation drawer.
class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final mcontroller = Get.find<mainPageConroller>();
  late final Worker _navWorker;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const double _sidebarWidth = 248;
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
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: Drawer(
        backgroundColor: AppColors.sidebar,
        child: AppSidebar(
          showCloseButton: true,
          onNavigate: () {
            final navigator = Navigator.of(context);
            if (navigator.canPop()) navigator.pop();
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final wide = constraints.maxWidth >= _wideBreakpoint;

          final content = Column(
            children: [
              _topBar(wide),
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

          return Row(
            textDirection: TextDirection.rtl,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // First child of an RTL row is rendered on the right.
              if (wide)
                SizedBox(
                  width: _sidebarWidth,
                  child: AppSidebar(),
                ),
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }

  Widget _topBar(bool wide) {
    final labels = tabsFor(role);

    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          if (!wide) ...[
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openDrawer(),
              icon: const Icon(Icons.menu, size: 20),
              tooltip: 'منو',
            ),
            const SizedBox(width: 4),
          ],
          Expanded(
            child: Obx(() {
              final index = mcontroller.navitaionIndex.value;
              final title = (index >= 0 && index < labels.length)
                  ? labels[index]
                  : '';
              return Row(
                children: [
                  const DiespiEmblem(size: 26),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
          _userChip(),
        ],
      ),
    );
  }

  Widget _userChip() {
    final label = role == 'ناظر' ? 'ناظر سیستم' : 'مدیر سیستم';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.person, size: 15, color: Colors.white),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
