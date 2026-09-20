import 'dart:convert';

import 'package:amnban/models/databaseEntry.dart';

import 'package:amnban/screens/main_screen.dart';
import 'package:amnban/screens/splashScreen.dart';
import 'package:amnban/utils/safe.dart';
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

/// Centralised backend addresses. [url]/[port] are still the mutable globals
/// (many widgets read them) but new code should go through these helpers so
/// host/port handling lives in one place.
String get pbHost => url;
String pbFileUrlOf(String collection, String? id, String? file) {
  if (id == null || id.isEmpty || file == null || file.isEmpty) return '';
  return 'http://$url:8090/api/files/$collection/$id/$file';
}

// String videoFeedUrl(int cameraIndex, String? rtspUrl, {required bool isRfid}) {
//   final src = rtspUrl ?? '';
//   final feed = isRfid ? 'rtsp_feed' : 'video_feed';
//   return 'http://$url:$port/$feed/rt${cameraIndex + 1}?source=$src';
// }

/// Tabs depend on the logged-in role, but the old global list was computed
/// once at import time (always the admin list). Compute per build instead.
List<String> tabsFor(String currentRole) => currentRole == 'ناظر'
    ? ['خانه', "گزارشات", 'افراد'].reversed.toList()
    : ['خانه', "گزارشات", 'دوربین', 'افراد', "تنظیمات"].reversed.toList();

var pb = PocketBase('http://${url}:8090');

Color purpule = Color.fromARGB(255, 56, 2, 109);
Color selecetpurpule = const Color.fromARGB(255, 109, 20, 125);
// Kept for backwards compatibility — prefer tabsFor(role) which reflects the
// current login instead of the import-time value.
List<String> tabs = ['خانه', "گزارشات", 'دوربین', 'افراد', "تنظیمات"].reversed.toList();

final PlatformNotification platformNotification = PlatformNotificationWeb();

// One shared player instead of a new AudioPlayer per alarm event (each of
// which was never disposed and leaked a connection).
final AudioPlayer _alarmPlayer = AudioPlayer();

Future<void> onRelayOne() async {
  try {
    if (!Get.isRegistered<settingController>()) return;
    final settings = Get.find<settingController>().settings;
    if (settings.isEmpty) return;
    final s = settings.last;
    if (s.rfidip == null || s.rfidport == null) return;
    Uri uri = Uri.parse("http://$url:$port/utils/iprelay");

    await http
        .post(uri,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'ip': s.rfidip!,
              'port': s.rfidport.toString(),
              'username': "admin",
              'password': "admin",
              'relay_number': "1"
            }))
        .timeout(const Duration(seconds: 8));
  } catch (e) {
    appLog('onRelayOne failed', e);
  }
}

Future<void> onRelayTwo() async {
  try {
    if (!Get.isRegistered<settingController>()) return;
    final settings = Get.find<settingController>().settings;
    if (settings.isEmpty) return;
    final s = settings.last;
    if (s.rfidip == null || s.rfidport == null) return;
    Uri uri = Uri.parse("http://$url:$port/utils/iprelay");

    await http
        .post(uri,
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{
              'ip': s.rfidip!,
              'port': s.rfidport.toString(),
              'username': "admin",
              'password': "admin",
              'relay_number': "2"
            }))
        .timeout(const Duration(seconds: 8));
  } catch (e) {
    appLog('onRelayTwo failed', e);
  }
}

void notifPlay(databaseClass entry) {
  try {
    if (!Get.isRegistered<knowPersonController>() ||
        !Get.isRegistered<databaseController>() ||
        !Get.isRegistered<settingController>()) {
      return;
    }
    final person = Get.find<knowPersonController>().personFor(entry.plateNum);
    if (person == null) return;

    final dcontroller = Get.find<databaseController>();
    // Guard against double-counting the same record (realtime replay +
    // fetchCountData both feed these lists).
    bool alreadyCounted(List<databaseClass> list) => entry.id != null &&
        list.any((e) => e.id != null && e.id == entry.id);
    if (person.role != "مجاز") {
      if (!alreadyCounted(dcontroller.todayunallowed)) {
        dcontroller.todayunallowed.add(entry);
      }
      if (Get.find<settingController>().isNotif.value) {
        platformNotification.sendNotification(
            'ورود غیر مجاز', 'پلاک\n${entry.plateNum}');
      }
    } else {
      if (!alreadyCounted(dcontroller.todayallowd)) {
        dcontroller.todayallowd.add(entry);
      }
      if (Get.find<settingController>().isNotif.value) {
        platformNotification.sendNotification(
            'ورود  مجاز', 'پلاک\n${entry.plateNum}');
      }
    }
  } catch (e) {
    appLog('notifPlay failed', e);
  }
}

void alarmPlay(databaseClass entry) {
  try {
    if (!Get.isRegistered<settingController>() ||
        !Get.isRegistered<knowPersonController>()) {
      return;
    }
    if (!Get.find<settingController>().isAlarm.value) return;

    if (Get.find<knowPersonController>().personFor(entry.plateNum) == null) {
      _alarmPlayer.play(UrlSource('assets/alarm.mp3')).catchError((e) {
        appLog('alarm sound failed', e);
      });
    }

    if (email.isEmpty) return;
    // Fire-and-forget with error handling — must never crash live updates.
    http
        .post(Uri.parse('http://$url:$port/email?email=$email'), body: {
          "plateNumber": entry.plateNum ?? '',
          "eDate": entry.eDate ?? '',
          "eTime": entry.eTime ?? ''
        })
        .timeout(const Duration(seconds: 8))
        .then((_) {})
        .catchError((e) {
          appLog('alarm email failed', e);
        });
  } catch (e) {
    appLog('alarmPlay failed', e);
  }
}

void relayAutomatic(databaseClass entry) {
  try {
    if (!Get.isRegistered<settingController>() ||
        !Get.isRegistered<knowPersonController>()) {
      return;
    }
    final scontroller = Get.find<settingController>();
    if (!scontroller.isRfid.value) return;
    if (Get.find<knowPersonController>().personFor(entry.plateNum) == null) {
      return;
    }
    if (scontroller.isrlOne.value) onRelayOne();
    if (scontroller.isrlTwo.value) onRelayTwo();
  } catch (e) {
    appLog('relayAutomatic failed', e);
  }
}

Future<void> getBackup(String sourceCollectionName) async {
  try {
    final sourcePb = pb;
    final records = await sourcePb
        .collection(sourceCollectionName)
        .getFullList()
        .timeout(const Duration(seconds: 30));

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
      ..href =
          'data:application/json;charset=utf-8,${Uri.encodeComponent(jsonString)}'
      ..setAttribute(
          'download', 'backup_${DateTime.now().millisecondsSinceEpoch}.json');
    anchor.click();
  } catch (e) {
    appLog('getBackup failed', e);
  }
}

Future<void> _restoreFromJson(String jsonString, String targetCollectionName) async {
  List<dynamic> recordsData;
  try {
    final decoded = jsonDecode(jsonString);
    if (decoded is! List) {
      appLog('_restoreFromJson: expected a JSON list');
      return;
    }
    recordsData = decoded;
  } catch (e) {
    appLog('_restoreFromJson: invalid JSON', e);
    return;
  }

  final targetPb = pb;
  const chunkSize = 20;
  for (var i = 0; i < recordsData.length; i += chunkSize) {
    final chunk = recordsData.skip(i).take(chunkSize);
    // Individual failures shouldn't abort the whole restore.
    await Future.wait(chunk.map((data) async {
      try {
        if (data is Map) {
          await targetPb
              .collection(targetCollectionName)
              .create(body: Map<String, dynamic>.from(data))
              .timeout(const Duration(seconds: 15));
        }
      } catch (e) {
        appLog('restore record failed', e);
      }
    }));
  }
}

Future<void> restoreBackup(String targetCollectionName) async {
  // Create a file input element and trigger the picker
  final fileUploadInput = (web.document.createElement('input') as web.HTMLInputElement)
    ..type = 'file'
    ..accept = '.json';
  fileUploadInput.click();

  fileUploadInput.addEventListener('change', ((web.Event event) {
    try {
      final files = fileUploadInput.files;
      if (files == null || files.length == 0) return;
      final file = files.item(0);
      if (file == null) return;

      final reader = web.FileReader();
      reader.readAsText(file);
      reader.addEventListener('load', ((web.Event _) {
        try {
          final result = reader.result;
          if (result == null) return;
          final jsonString = (result as JSString).toDart;
          _restoreFromJson(jsonString, targetCollectionName);
        } catch (e) {
          appLog('restore read failed', e);
        }
      }) as web.EventListener);
    } catch (e) {
      appLog('restore picker failed', e);
    }
  }) as web.EventListener);
}
