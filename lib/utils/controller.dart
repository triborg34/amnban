import 'dart:convert';

import 'package:amnban/models/cameraClass.dart';
import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/models/knowPersonClass.dart';
import 'package:amnban/utils/consts.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

class mainPageConroller extends GetxController {
  var navitaionIndex = 2.obs;
  var videoIndex = (-1).obs;

  var isSelected = false.obs;
}

class cameraController extends GetxController {
  var cameras = <CameraClass>[].obs;
  var searchCameras = <Map<String, dynamic>>[].obs;

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
    final uri = Uri.parse('http://127.0.0.1:8000/onvif/get-stream');
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

  var pickerPlate = ''.obs;

  var firstDate = ''.obs;
  var lastDate = ''.obs;
  var fistTime = ''.obs;
  var lastTime = ''.obs;
  var isDate = false.obs;
  var isTime = false.obs;
  var isCompleted = false.obs;

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

  void startSub() {
    pb.collection('cameras').subscribe(
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
    final mList = await pb.collection('cameras').getFullList();
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
  var selectedIndex = (-1).obs;

  void startSub() {
    pb.collection('database').subscribe(
      '*',
      (e) {
        if (e.action == 'create') {
          entries.add(databaseClass.fromJson(e.record!.data));
        } else if (e.action == 'delete') {
          entries.removeWhere(
            (element) => element.id == e.record!.id,
          );
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

  fetchFirstData() async {
    final mList = await pb.collection('database').getFullList(
          sort: '-created',
        );
    for (var json in mList) {
      entries.add(databaseClass.fromJson(json.data));
    }
    tableContect.value = entries.first;
  }

  @override
  void onReady() async {
    await fetchFirstData();
    startSub();
    super.onReady();
  }
}
