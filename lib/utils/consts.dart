import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/screens/main_screen.dart';
import 'package:amnban/screens/splashScreen.dart';
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';

List<GetPage> pages = [
  GetPage(name: '/', page: () => MainScreen()),
  GetPage(name: '/splash', page: () => SplashScreen())
];

String role = '';
String email = '';
String url = '127.0.0.1';
String port = "8000";

var pb = PocketBase('http://${url}:8090');

Color purpule = Color.fromARGB(255, 56, 2, 109);
Color selecetpurpule = const Color.fromARGB(255, 109, 20, 125);
List<String> tabs = role == 'ناظر'
    ? ['خانه', "گزارشات", 'افراد'].reversed.toList()
    : ['خانه', "گزارشات", 'دوربین', 'افراد', "تنظیمات"].reversed.toList();

void onRelayOne() async {
  Uri uri = Uri.parse("http://${url}:${port}/iprelay?onOff=true&relay=1");
  await http.get(uri);
}

void onRelayTwo() async {
  Uri uri = Uri.parse("http://${url}:${port}/iprelay?onOff=true&relay=2");
  await http.get(uri);
}

void alarmPlay(databaseClass entry) {
  if (Get.find<settingController>().isAlarm.value) {
    AudioPlayer audioPlayer = AudioPlayer();
    if (Get.find<knowPersonController>()
        .knowPerson
        .where(
          (element) => element.plateNumber != entry.plateNum,
        )
        .isNotEmpty) {
      audioPlayer.play(UrlSource('assets/alarm.mp3'));
    }

    http.post(Uri.parse('http://${url}:${port}/email?email=${email}'), body: {
      "plateNumber": entry.plateNum,
      "eDate": entry.eDate,
      "eTime": entry.eTime
    });
  }
}

void relayAutomatic(databaseClass entry) {
  if (Get.find<settingController>().isRfid.value) {
    if (Get.find<knowPersonController>()
        .knowPerson
        .where(
          (element) => element.plateNumber == entry.plateNum,
        )
        .isNotEmpty) {
      if (Get.find<settingController>().isrlOne.value &&
          Get.find<settingController>().isrlTwo.value) {
        onRelayOne();
        onRelayTwo();
      } else if (Get.find<settingController>().isrlOne.value == true &&
          Get.find<settingController>().isrlTwo.value == false) {
        onRelayOne();
      } else if (Get.find<settingController>().isrlOne.value == false &&
          Get.find<settingController>().isrlTwo.value == true) {
        onRelayTwo();
      }
    }
  }
}
