import 'package:amnban/screens/camera_screen.dart';
import 'package:amnban/screens/home_sceen.dart';
import 'package:amnban/screens/person_screen.dart';
import 'package:amnban/screens/reportscreen.dart';
import 'package:amnban/screens/setting_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainScreen extends StatelessWidget {
  MainScreen({super.key});

  mainPageConroller mcontroller = Get.find<mainPageConroller>();

  @override
  Widget build(BuildContext context) {
    print(role);
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
                Image.network('assets/images/mainlogo2.png'),
                Spacer(),
                for (int i = 0; i < tabs.length; i++)
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
                              tabs[i],
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
        child: GetX<mainPageConroller>(
          builder: (controller) {
            if (role == "ناظر") {
              switch (controller.navitaionIndex.value) {
          
                case 0:
                  return PersonScreen();
                case 1:
                  return Reportscreen();
                case 2:
                  return HomeSceen(
                    mController: mcontroller,
                  );

                default:
                  return HomeSceen(
                    mController: mcontroller,
                  );
              }
            } else {
              switch (controller.navitaionIndex.value) {
                case 0:
                  return SettingScreen();
                case 1:
                  return PersonScreen();
                case 2:
                  return CameraScreen();
                case 3:
                  return Reportscreen();
                case 4:
                  return HomeSceen(
                    mController: mcontroller,
                  );

                default:
                  return HomeSceen(
                    mController: mcontroller,
                  );
              }
            }
          },
        ),
      ),
    );
  }
}
