import 'dart:convert';

import 'package:amnban/models/databaseEntry.dart';

import 'package:amnban/screens/main_screen.dart';
import 'package:amnban/screens/splashScreen.dart';
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';
import 'dart:html' as html;

import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_web_notification_platform/flutter_web_notification_platform.dart';

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

final PlatformNotification platformNotification = PlatformNotificationWeb();
void onRelayOne() async {
  Uri uri = Uri.parse("http://${url}:${port}/utils/iprelay");

  await http.post(uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ip': Get.find<settingController>().settings.last.rfidip!,
        'port': Get.find<settingController>().settings.last.rfidport.toString(),
        'username': "admin",
        'password': "admin",
        'relay_number': "1"
      }));
}

void onRelayTwo() async {
  Uri uri = Uri.parse("http://${url}:${port}/utils/iprelay");

  await http.post(uri,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        'ip': Get.find<settingController>().settings.last.rfidip!,
        'port': Get.find<settingController>().settings.last.rfidport.toString(),
        'username': "admin",
        'password': "admin",
        'relay_number': "2"
      }));
}

void notifPlay(databaseClass entry) {
  if (Get.find<knowPersonController>()
      .knowPerson
      .where(
        (element) => element.plateNumber == entry.plateNum,
      )
      .isNotEmpty) {
    if (Get.find<knowPersonController>()
            .knowPerson
            .where(
              (element) => element.plateNumber == entry.plateNum,
            )
            .first
            .role !=
        "مجاز") {
      Get.find<databaseController>().todayunallowed.add(entry);
      if (Get.find<settingController>().isNotif.value) {
        platformNotification.sendNotification(
            'ورود غیر مجاز', 'پلاک\n${entry.plateNum}');
      }
    } else {
      Get.find<databaseController>().todayallowd.add(entry);
      if (Get.find<settingController>().isNotif.value) {
        platformNotification.sendNotification(
            'ورود  مجاز', 'پلاک\n${entry.plateNum}');
      }
    }
  }
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

void getBackup(String sourceCollectionName) async {

  final sourcePb = pb;
  final records = await sourcePb.collection(sourceCollectionName).getFullList();

  print('✅ Fetched ${records.length} records.');

  final cleanedRecords = records.map((record) {
    final data = record.toJson();
    data.remove('id');
    data.remove('created');
    data.remove('updated');
    data.remove('collectionId');
    data.remove('collectionName');
    return data;
  }).toList();

  final jsonString = jsonEncode(cleanedRecords);

  // Web: trigger download using HTML anchor element
  html.AnchorElement(href: 'data:application/json;charset=utf-8,$jsonString')
    ..setAttribute(
        'download', 'backup_${DateTime.now().millisecondsSinceEpoch}.json')
    ..click();
  print('💾 Backup file downloaded.');
}

void restoreBackup(String targetCollectionName) async {


  // Create a file input element and trigger the picker
  final fileUploadInput = html.FileUploadInputElement()..accept = '.json';
  fileUploadInput.click();

  fileUploadInput.onChange.listen((event) async {
    final file = fileUploadInput.files?.first;
    if (file == null) return;

    final reader = html.FileReader();
    reader.readAsText(file);
    reader.onLoadEnd.listen((_) async {
      final jsonString = reader.result as String;
      final List<dynamic> recordsData = jsonDecode(jsonString);
      print('📥 Loaded ${recordsData.length} records from file.');

      // Connect to target PocketBase
      final targetPb = pb;
      try {


        int success = 0;
        int fail = 0;
        for (final data in recordsData) {
          try {
            await targetPb.collection(targetCollectionName).create(body: data);
            success++;
          } catch (e) {
            fail++;
            print('❌ Failed to create record: $e');
          }
        }
        print('🎉 Restore complete: $success succeeded, $fail failed.');
      } catch (error) {
        print('🚨 Authentication error: $error');
      }
    });
  });
}
