import 'dart:convert';

import 'package:amnban/models/databaseEntry.dart';

import 'package:amnban/screens/main_screen.dart';
import 'package:amnban/screens/splashScreen.dart';
import 'package:amnban/utils/controller.dart';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'dart:js_interop';

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

// One shared player instead of a new AudioPlayer per alarm event (each of
// which was never disposed and leaked a connection).
final AudioPlayer _alarmPlayer = AudioPlayer();

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
  final person = Get.find<knowPersonController>().personFor(entry.plateNum);
  if (person == null) return;

  final dcontroller = Get.find<databaseController>();
  if (person.role != "مجاز") {
    dcontroller.todayunallowed.add(entry);
    if (Get.find<settingController>().isNotif.value) {
      platformNotification.sendNotification(
          'ورود غیر مجاز', 'پلاک\n${entry.plateNum}');
    }
  } else {
    dcontroller.todayallowd.add(entry);
    if (Get.find<settingController>().isNotif.value) {
      platformNotification.sendNotification(
          'ورود  مجاز', 'پلاک\n${entry.plateNum}');
    }
  }
}

void alarmPlay(databaseClass entry) {
  if (!Get.find<settingController>().isAlarm.value) return;

  if (Get.find<knowPersonController>().personFor(entry.plateNum) == null) {
    _alarmPlayer.play(UrlSource('assets/alarm.mp3'));
  }

  http.post(Uri.parse('http://${url}:${port}/email?email=${email}'), body: {
    "plateNumber": entry.plateNum,
    "eDate": entry.eDate,
    "eTime": entry.eTime
  });
}

void relayAutomatic(databaseClass entry) {
  final scontroller = Get.find<settingController>();
  if (!scontroller.isRfid.value) return;
  if (Get.find<knowPersonController>().personFor(entry.plateNum) == null) {
    return;
  }
  if (scontroller.isrlOne.value) onRelayOne();
  if (scontroller.isrlTwo.value) onRelayTwo();
}

void getBackup(String sourceCollectionName) async {
  final sourcePb = pb;
  final records = await sourcePb.collection(sourceCollectionName).getFullList();

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
  final anchor = (web.document.createElement('a') as web.HTMLAnchorElement)
    ..href = 'data:application/json;charset=utf-8,$jsonString'
    ..setAttribute(
        'download', 'backup_${DateTime.now().millisecondsSinceEpoch}.json');
  anchor.click();
}

void _restoreFromJson(String jsonString, String targetCollectionName) async {
  final List<dynamic> recordsData = jsonDecode(jsonString);

  final targetPb = pb;
  const chunkSize = 20;
  for (var i = 0; i < recordsData.length; i += chunkSize) {
    final chunk = recordsData.skip(i).take(chunkSize);
    // Individual failures shouldn't abort the whole restore.
    await Future.wait(chunk.map((data) async {
      try {
        await targetPb.collection(targetCollectionName).create(body: data);
      } catch (_) {}
    }));
  }
}

void restoreBackup(String targetCollectionName) async {
  // Create a file input element and trigger the picker
  final fileUploadInput = (web.document.createElement('input') as web.HTMLInputElement)
    ..type = 'file'
    ..accept = '.json';
  fileUploadInput.click();

  fileUploadInput.addEventListener('change', ((web.Event event) {
    final files = fileUploadInput.files;
    if (files == null || files.length == 0) return;
    final file = files.item(0)!;

    final reader = web.FileReader();
    reader.readAsText(file);
    reader.addEventListener('load', ((web.Event _) {
      final jsonString = (reader.result as JSString).toDart;
      _restoreFromJson(jsonString, targetCollectionName);
    }) as web.EventListener);
  }) as web.EventListener);
}
