import 'package:amnban/screens/camera_screen.dart';
import 'package:amnban/screens/home_sceen.dart';
import 'package:amnban/screens/person_screen.dart';
import 'package:amnban/screens/reportscreen.dart';
import 'package:amnban/screens/setting_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatefulWidget {
  MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final mcontroller = Get.find<mainPageConroller>();
  late final Worker _navWorker;

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
    final tabLabels = tabsFor(role);
    return Scaffold(
      backgroundColor: Colors.black,
      extendBody: false,
      appBar: PreferredSize(
          preferredSize: Size(MediaQuery.of(context).size.width, 50),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            height: 50,
            color: purpule,
            child: Row(
              children: [
                Image.asset('assets/images/mainlogo2.png'),
                Spacer(),
                for (int i = 0; i < tabLabels.length; i++)
                  InkWell(
                      onTap: () {
                        mcontroller.navitaionIndex.value = i;
                      },
                      child: Obx(
                        () => AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          color: mcontroller.navitaionIndex.value == i
                              ? selecetpurpule
                              : purpule,
                          width: 100,
                          child: Center(
                            child: Text(
                              tabLabels[i],
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ))
              ],
            ),
          )),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        // IndexedStack keeps each tab's scroll/form state alive instead of
        // recreating the whole screen on every tab switch.
        child: Obx(() {
          final pages = _pagesFor(role);
          var idx = mcontroller.navitaionIndex.value;
          if (idx < 0 || idx >= pages.length) idx = pages.length - 1;
          return IndexedStack(index: idx, children: pages);
        }),
      ),
    );
  }
}
