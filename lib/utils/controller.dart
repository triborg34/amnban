import 'dart:async';
import 'dart:convert';

import 'package:amnban/models/cameraClass.dart';
import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/models/knowPersonClass.dart';
import 'package:amnban/models/settingClass.dart';
import 'package:amnban/models/userClass.dart';
import 'package:amnban/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:web/web.dart' as web;
import 'package:http/http.dart' as http;

class mainPageConroller extends GetxController {
  var navitaionIndex = 4.obs;
  var videoIndex = (-1).obs;

  var isSelected = false.obs;
}

class cameraController extends GetxController {
  var cameras = <CameraClass>[].obs;
  var searchCameras = <Map<String, dynamic>>[].obs;

  /// path -> camera name, kept in sync with [cameras] so table rows can do a
  /// single O(1) lookup instead of firstWhere-per-row.
  final cameraNames = <String, String>{}.obs;

  var isRtspEnabled = false.obs;
  var gateWayc = 'entre'.obs;
  TextEditingController nameController = TextEditingController();
  TextEditingController ipController = TextEditingController();
  TextEditingController portController = TextEditingController();
  TextEditingController rtspNameController = TextEditingController();
  TextEditingController rtspController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  String cameraNameFor(String? path) {
    if (cameras.isEmpty) return 'No Camera';
    if (path == null) return 'دوربین';
    return cameraNames[path] ?? 'دوربین';
  }

  void _syncNameIndex() {
    cameraNames.clear();
    for (final c in cameras) {
      if (c.path != null && c.name != null) cameraNames[c.path!] = c.name!;
    }
  }

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
        _syncNameIndex();
      },
    );
  }

  fetchFirstData() async {
    final mList = await pb.collection('cameras').getFullList();
    cameras.assignAll(mList.map((json) => CameraClass.fromJson(json.data)));
    _syncNameIndex();
  }

  Future<void>? _loadFuture;
  /// Idempotent: safe to await from other controllers no matter whether this
  /// controller already started loading.
  Future<void> ensureLoaded() =>
      _loadFuture ??= () async {
        await fetchFirstData();
        startSub();
      }();

  @override
  void onReady() async {
    ensureLoaded();
    super.onReady();
  }

  http.Client? _discoveryClient;
  StreamSubscription? _discoverySub;

  void startDiscovery() async {
    // Cancel any stream still running so repeated searches don't stack up.
    _discoverySub?.cancel();
    _discoveryClient?.close();
    searchCameras.clear();
    final uri = Uri.parse('http://${url}:${port}/onvif/get-stream');
    final request = http.Request('GET', uri)
      ..headers['Accept'] = 'text/event-stream';

    final client = http.Client();
    _discoveryClient = client;
    try {
      final response = await client.send(request);

      _discoverySub = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.replaceFirst('data: ', '');
          final data = jsonDecode(jsonStr);
          searchCameras.add(data);
        }
      }, onDone: () {
        client.close();
        if (_discoveryClient == client) _discoveryClient = null;
      }, onError: (_) {
        client.close();
        if (_discoveryClient == client) _discoveryClient = null;
      });
    } catch (_) {
      client.close();
      if (_discoveryClient == client) _discoveryClient = null;
    }
  }

  @override
  void onClose() {
    _discoverySub?.cancel();
    _discoveryClient?.close();
    super.onClose();
  }
}

class videoFeedController extends GetxController {
  final _cameras = <String, web.HTMLImageElement>{}.obs;

  void connect(String url, String viewId) {
    final imgElement = web.HTMLImageElement()
      ..src = url
      ..id = viewId
      ..style.width = '100%'
      ..style.height = '100%'
      ..style.objectFit = 'cover';

    _cameras[viewId] = imgElement;
  }

  web.HTMLImageElement? getElement(String viewId) => _cameras[viewId];

  void disconnect(String viewId) {
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
    engishalphabet.value = '';
    persianalhpabet.value = '';
    selectedModel.clear();
    firstTwoDigit.clear();
    threeDigit.clear();
    lastTwoDigit.clear();
    arvandDigit.clear();

    pickerPlate.value = '';

    firstDate.value = '';
    lastDate.value = '';
    fistTime.value = '';
    lastTime.value = '';
    isDate.value = false;
    isTime.value = false;
    isCompleted.value = false;
    isLoading.value = false;
    isArvand.value = false;
  }
}

class knowPersonController extends GetxController {
  var knowPerson = <knowPersonBox>[].obs;

  /// plateNumber -> person, kept in sync with [knowPerson] so every table
  /// cell is a single O(1) lookup instead of where()+indexWhere() scans.
  final byPlate = <String, knowPersonBox>{}.obs;

  knowPersonBox? personFor(String? plateNumber) =>
      plateNumber == null ? null : byPlate[plateNumber];

  void _syncPlateIndex() {
    byPlate.clear();
    for (final p in knowPerson) {
      if (p.plateNumber != null) byPlate[p.plateNumber!] = p;
    }
  }

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
        _syncPlateIndex();
      },
    );
  }

  fetchFirstData() async {
    final mList = await pb.collection('registredDb').getFullList();
    knowPerson
        .assignAll(mList.map((json) => knowPersonBox.fromJson(json.data)));
    _syncPlateIndex();
  }

  Future<void>? _loadFuture;
  Future<void> ensureLoaded() =>
      _loadFuture ??= () async {
        await fetchFirstData();
        startSub();
      }();

  @override
  void onReady() async {
    ensureLoaded();
    super.onReady();
  }
}

class databaseController extends GetxController {
  var entries = <databaseClass>[].obs;
  var tableContect = databaseClass().obs;
  var todayCount = 0.obs;
  var goodPlate = 0.obs;
  var badPlate = 0.obs;
  var todayunallowed = <databaseClass>[].obs;
  var todayallowd = <databaseClass>[].obs;
  var selectedIndex = (-1).obs;
  int inilazedPage = 1;

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

  Future<void> fetchFirstData(int inpage, int inperpage) async {
    final mList = await pb.collection('database').getList(
          page: inpage,
          perPage: 30,
          sort: '-created',
        );
    // addAll (not per-item add) so a page load triggers a single rebuild.
    entries.addAll(mList.items.map((json) => databaseClass.fromJson(json.data)));
    if (entries.isNotEmpty && tableContect.value.id == null) {
      tableContect.value = entries.first;
    }
  }

  Future<void> fetchCountData() async {
    var now = DateTime.now();
    var day = now.day.toString().padLeft(2, '0');
    var month = now.month.toString().padLeft(2, '0');
    var todayISO = "${now.year}-$month-$day";

    final kcontroller = Get.find<knowPersonController>();
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
      final person = kcontroller.personFor(data.data['plateNum']);
      if (person != null) {
        if (person.role == "مجاز") {
          todayallowd.add(databaseClass.fromJson(data.data));
        } else {
          todayunallowed.add(databaseClass.fromJson(data.data));
        }
      }
    }
  }

  @override
  void onReady() async {
    // Persons must be loaded before we classify today's records, and the two
    // database fetches are independent so they run in parallel.
    await Get.find<knowPersonController>().ensureLoaded();
    await Future.wait([
      fetchFirstData(inilazedPage, 30),
      fetchCountData(),
    ]);
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
    settings.assignAll(mList.map((json) => setting_class.fromJson(json.data)));
  }

  firstIniliazed() async {
    if (settings.isEmpty) return;
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

  Future<void>? _loadFuture;
  Future<void> ensureLoaded() =>
      _loadFuture ??= () async {
        await fetchFirstData();
        await firstIniliazed();
        startSub();
      }();

  @override
  void onReady() async {
    ensureLoaded();
    super.onReady();
  }
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
    users.assignAll(mList.map((json) => userClass.fromJson(json.data)));
  }

  Future<void>? _loadFuture;
  Future<void> ensureLoaded() =>
      _loadFuture ??= () async {
        await fetchFirstData();
        startSub();
      }();

  @override
  void onReady() async {
    ensureLoaded();
    super.onReady();
  }
}
