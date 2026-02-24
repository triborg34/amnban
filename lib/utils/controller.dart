import 'dart:convert';

import 'package:amnban/models/cameraClass.dart';
import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/models/knowPersonClass.dart';
import 'package:amnban/models/settingClass.dart';
import 'package:amnban/models/userClass.dart';
import 'package:amnban/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class mainPageConroller extends GetxController {
  var navitaionIndex = 4.obs;
  var videoIndex = (-1).obs;

  var isSelected = false.obs;
}

class cameraController extends GetxController {
  var cameras = <CameraClass>[].obs;
  var searchCameras = <Map<String, dynamic>>[].obs;

  var isRtspEnabled = false.obs;
  var gateWayc = 'entre'.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController rtspNameController = TextEditingController();
  TextEditingController rtspController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  void startSub() {
    pb.collection('cameras').subscribe(
      '*',
      (e) {
        if (e.action == 'create') {
          cameras.add(CameraClass.fromJson(e.record!.data));
        } else if (e.action == 'delete') {
          cameras.removeWhere(
            (element) => element.id == e.record!.id,
          );
        } else {
          int index =
              cameras.indexWhere((element) => element.id == e.record!.id);
          if (index != -1) {
            cameras[index] = CameraClass.fromJson(e.record!.toJson());
          }
        }
      },
    );
  }

  fetchFirstData() async {
    final mList = await pb.collection('cameras').getFullList();
    for (var json in mList) {
      cameras.add(CameraClass.fromJson(json.data));
    }
  }

  @override
  void onReady() async {
    await fetchFirstData();
    startSub();
    super.onReady();
  }

  void startDiscovery() async {
    searchCameras.clear();
    final uri = Uri.parse('http://${url}:${port}/onvif/get-stream');
    final request = http.Request('GET', uri)
      ..headers['Accept'] = 'text/event-stream';

    final client = http.Client();
    final response = await client.send(request);

    response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .listen((line) {
      if (line.startsWith('data: ')) {
        final jsonStr = line.replaceFirst('data: ', '');
        final data = jsonDecode(jsonStr);
        searchCameras.add(data);
      }
    });
  }
}

class videoFeedController extends GetxController {
  final _cameras = <String, html.ImageElement>{}.obs;

  void connect(String url, String viewId) {
    final imgElement = html.ImageElement()
      ..src = url
      ..id = viewId
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    _cameras[viewId] = imgElement;
  }

  html.ImageElement? getElement(String viewId) => _cameras[viewId];

  void disconnect(String viewId) {
    print(viewId);
    final element = _cameras[viewId];
    if (element != null) {
      element.src = '';
      element.remove();
      _cameras.remove(viewId);
    }
  }

  /// 🔌 Disconnects all active camera streams
  void disconnectAll() {
    final keys = _cameras.keys.toList(); // Avoid concurrent modification
    for (final viewId in keys) {
      disconnect(viewId);
    }
  }

  @override
  void onClose() {
    disconnectAll();
    super.onClose();
  }
}

class reportController extends GetxController {
  var engishalphabet = ''.obs;
  var persianalhpabet = ''.obs;
  var selectedModel = <databaseClass>[].obs;
  TextEditingController firstTwoDigit = TextEditingController();
  TextEditingController threeDigit = TextEditingController();
  TextEditingController lastTwoDigit = TextEditingController();
  TextEditingController arvandDigit = TextEditingController();

  var pickerPlate = ''.obs;

  var firstDate = ''.obs;
  var lastDate = ''.obs;
  var fistTime = ''.obs;
  var lastTime = ''.obs;
  var isDate = false.obs;
  var isTime = false.obs;
  var isCompleted = false.obs;
  var isLoading = false.obs;
  var isArvand = false.obs;

  inilazed() {
    engishalphabet = ''.obs;
    persianalhpabet = ''.obs;
    selectedModel.clear();
    firstTwoDigit = TextEditingController();
    threeDigit = TextEditingController();
    lastTwoDigit = TextEditingController();

    pickerPlate = ''.obs;

    firstDate = ''.obs;
    lastDate = ''.obs;
    fistTime = ''.obs;
    lastTime = ''.obs;
    isDate = false.obs;
    isTime = false.obs;
    isCompleted = false.obs;
  }
}

class knowPersonController extends GetxController {
  var knowPerson = <knowPersonBox>[].obs;

  var engishAlphabet = ''.obs;
  var persianAlhpabet = ''.obs;
  var isArvand = false.obs;

  TextEditingController firstTwoDigit = TextEditingController();
  TextEditingController threeDigit = TextEditingController();
  TextEditingController lastTwoDigit = TextEditingController();

  TextEditingController arvandDigits = TextEditingController();

  TextEditingController name = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController carNmae = TextEditingController();
  var role = 'مجاز'.obs;

  void startSub() {
    pb.collection('registredDb').subscribe(
      '*',
      (e) {
        if (e.action == 'create') {
          knowPerson.add(knowPersonBox.fromJson(e.record!.data));
        } else if (e.action == 'delete') {
          knowPerson.removeWhere(
            (element) => element.id == e.record!.id,
          );
        } else {
          int index =
              knowPerson.indexWhere((element) => element.id == e.record!.id);
          if (index != -1) {
            knowPerson[index] = knowPersonBox.fromJson(e.record!.toJson());
          }
        }
      },
    );
  }

  fetchFirstData() async {
    final mList = await pb.collection('registredDb').getFullList();
    for (var json in mList) {
      knowPerson.add(knowPersonBox.fromJson(json.data));
    }
  }

  @override
  void onReady() async {
    await fetchFirstData();
    startSub();
    super.onReady();
  }
}

class databaseController extends GetxController {
  var entries = <databaseClass>[].obs;
  var tableContect = databaseClass().obs;
  var todayCount = 0.obs;
  var goodPlate = 0.obs;
  var badPlate = 0.obs;
  var todayunallowed = <databaseClass>[];
  var todayallowd = <databaseClass>[];
  var selectedIndex = (-1).obs;
  int inilazedPage = 1;
  var knowPersone = Get.find<knowPersonController>().knowPerson;

  void startSub() {
    pb.collection('database').subscribe(
      '*',
      (e) {
        if (e.action == 'create') {
          entries.insert(0, databaseClass.fromJson(e.record!.data));
          if (entries.length > 30) {
            entries.removeAt(entries.length - 1);
          }
          todayCount.value++;
          if (e.record!.data['plateNum'].length >= 7) {
            goodPlate.value++;
          } else {
            badPlate.value++;
          }

          alarmPlay(entries.first);
          relayAutomatic(
            entries.first,
          );
          notifPlay(entries.first);
        } else if (e.action == 'delete') {
          entries.removeWhere(
            (element) => element.id == e.record!.id,
          );
          todayCount.value--;
        } else {
          int index =
              entries.indexWhere((element) => element.id == e.record!.id);
          if (index != -1) {
            entries[index] = databaseClass.fromJson(e.record!.toJson());
          }
        }
      },
    );
  }

  fetchFirstData(int inpage, int inperpage) async {
    final mList = await pb.collection('database').getList(
          page: inpage,
          perPage: 30,
          sort: '-created',
        );
    for (var json in mList.items) {
      entries.add(databaseClass.fromJson(json.data));
    }
    tableContect.value = entries.first;
  }

  fetchCountData() async {
    var day =
        DateTime.now().day < 10 ? "0${DateTime.now().day}" : DateTime.now().day;
    var month = DateTime.now().month < 10
        ? "0${DateTime.now().month}"
        : DateTime.now().month;
    var todayISO = "${DateTime.now().year}-${month}-${day}";

    final records = await pb
        .collection('database')
        .getFullList(filter: 'eDate = "${todayISO}"');
    todayCount.value = records.length;
    for (var data in records) {
      if (data.data['plateNum'].length >= 7) {
        goodPlate.value++;
      } else {
        badPlate.value++;
      }
    }
    for (var data in records) {
      for (var k in knowPersone) {
        if (data.data['plateNum'] == k.plateNumber) {
          if (k.role == "مجاز") {
            todayallowd.add(databaseClass.fromJson(data.data));
          } else {
            todayunallowed.add(databaseClass.fromJson(data.data));
          }
        }
      }
    }
  }

  @override
  void onReady() async {
    await fetchFirstData(inilazedPage, 30);
    await fetchCountData();
    startSub();
    super.onReady();
  }
}

class settingController extends GetxController {
  var settings = <setting_class>[].obs;
  var plateConf = 0.0.obs;
  var charConf = 0.0.obs;
  var quality = 0.0.obs;

  var isRfid = false.obs;
  TextEditingController rfipController = TextEditingController();
  TextEditingController rfportConroller = TextEditingController();
  var isrlOne = false.obs;
  var isrlTwo = false.obs;
  var rfconnect = false.obs;

  var isAlarm = false.obs;
  var isNotif = false.obs;

  var isUsers = false.obs;
  var isGeneral = false.obs;
  var isInfo = false.obs;
  void startSub() {
    pb.collection('setting').subscribe(
      '*',
      (e) {
        if (e.action == 'create') {
          settings.add(setting_class.fromJson(e.record!.data));
        } else if (e.action == 'delete') {
          settings.removeWhere(
            (element) => element.id == e.record!.id,
          );
        } else {
          int index =
              settings.indexWhere((element) => element.id == e.record!.id);
          if (index != -1) {
            settings[index] = setting_class.fromJson(e.record!.toJson());
          }
        }
      },
    );
  }

  fetchFirstData() async {
    final mList = await pb.collection('setting').getFullList(
          sort: '-created',
        );
    for (var json in mList) {
      settings.add(setting_class.fromJson(json.data));
    }
  }

  firstIniliazed() async {
    plateConf.value = settings.first.plateConf!;
    charConf.value = settings.first.charConf!;
    quality.value = settings.first.quality!.toDouble();
    isRfid.value = settings.first.isRfid!;
    rfipController.text = settings.first.rfidip!;
    rfportConroller.text = settings.first.rfidport!.toString();
    isrlOne.value = settings.first.rl1!;
    isrlTwo.value = settings.first.rl2!;
    rfconnect.value = settings.first.rfconnect!;
    isAlarm.value = settings.first.alarm!;
    isNotif.value = settings.first.notif!;
  }

  @override
  void onReady() async {
    await fetchFirstData();
    await firstIniliazed();
    // await checkForConnect();
    startSub();
    super.onReady();
  }

  // checkForConnect() async {
  //   if (isRfid.value && rfconnect.value) {
  //     Uri uri = Uri.parse(
  //         'http://${url}:${port}/iprelay?ip=${rfipController.text}&port=${rfportConroller.text}');

  //     await http.post(
  //       uri,
  //       body: {"isconnect": true},
  //     );
  //   }
  // }
}

class userController extends GetxController {
  var users = <userClass>[].obs;

  TextEditingController name = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  var accsesslvl = "مدیر".obs;

  void startSub() {
    pb.collection('users').subscribe(
      '*',
      (e) {
        if (e.action == 'create') {
          users.add(userClass.fromJson(e.record!.data));
        } else if (e.action == 'delete') {
          users.removeWhere(
            (element) => element.id == e.record!.id,
          );
        } else {
          int index = users.indexWhere((element) => element.id == e.record!.id);
          if (index != -1) {
            users[index] = userClass.fromJson(e.record!.toJson());
          }
        }
      },
    );
  }

  fetchFirstData() async {
    final mList = await pb.collection('users').getFullList(
          sort: '-created',
        );
    for (var json in mList) {
      users.add(userClass.fromJson(json.data));
    }
  }

  @override
  void onReady() async {
    await fetchFirstData();
    startSub();
    super.onReady();
  }
}
