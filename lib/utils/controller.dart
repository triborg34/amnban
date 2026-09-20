import 'dart:async';
import 'dart:convert';

import 'package:amnban/models/cameraClass.dart';
import 'package:amnban/models/databaseEntry.dart';
import 'package:amnban/models/knowPersonClass.dart';
import 'package:amnban/models/settingClass.dart';
import 'package:amnban/models/userClass.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/safe.dart';
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
  var isLoading = false.obs;
  var error = ''.obs;

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
    if (path == null || path.isEmpty) return 'دوربین';
    return cameraNames[path] ?? 'دوربین';
  }

  void _syncNameIndex() {
    cameraNames.clear();
    for (final c in cameras) {
      if (c.path != null && c.name != null) cameraNames[c.path!] = c.name!;
    }
  }

  Future<void> Function()? _unsub;

  void startSub() {
    // PocketBase subscribe returns an unsubscribe function; keep it so we
    // never leak duplicate listeners across hot-restart / re-init.
    pb.collection('cameras').subscribe(
      '*',
      (e) {
        try {
          final record = e.record;
          if (e.action == 'create') {
            if (record == null) return;
            cameras.add(CameraClass.fromJson(record.data));
          } else if (e.action == 'delete') {
            if (record == null) return;
            cameras.removeWhere(
              (element) => element.id == record.id,
            );
          } else {
            if (record == null) return;
            int index =
                cameras.indexWhere((element) => element.id == record.id);
            if (index != -1) {
              cameras[index] = CameraClass.fromJson(record.toJson());
            }
          }
          _syncNameIndex();
        } catch (err) {
          appLog('cameras realtime event failed', err);
        }
      },
    ).then((unsub) => _unsub = unsub, onError: (err, st) {
      appLog('cameras subscribe failed', err);
    });
  }

  Future<void> fetchFirstData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';
    try {
      final mList = await pb.collection('cameras').getFullList().timeout(
            const Duration(seconds: 15),
          );
      cameras.assignAll(mList.map((json) => CameraClass.fromJson(json.data)));
      _syncNameIndex();
    } catch (e) {
      error.value = 'خطا در دریافت دوربین‌ها';
      appLog('fetch cameras failed', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void>? _loadFuture;

  /// Idempotent: safe to await from other controllers no matter whether this
  /// controller already started loading.
  Future<void> ensureLoaded() => _loadFuture ??= () async {
        await fetchFirstData();
        startSub();
      }();

  @override
  void onReady() {
    ensureLoaded().catchError((e) => appLog('camera ensureLoaded', e));
    super.onReady();
  }

  http.Client? _discoveryClient;
  StreamSubscription? _discoverySub;

  Future<void> startDiscovery() async {
    // Cancel any stream still running so repeated searches don't stack up.
    try {
      await _discoverySub?.cancel();
    } catch (_) {}
    try {
      _discoveryClient?.close();
    } catch (_) {}
    _discoverySub = null;
    _discoveryClient = null;
    searchCameras.clear();
    final uri = Uri.parse('http://$url:$port/onvif/get-stream');
    final request = http.Request('GET', uri)
      ..headers['Accept'] = 'text/event-stream';

    final client = http.Client();
    _discoveryClient = client;
    try {
      final response =
          await client.send(request).timeout(const Duration(seconds: 15));

      _discoverySub = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) {
        if (line.startsWith('data: ')) {
          final jsonStr = line.replaceFirst('data: ', '');
          try {
            final data = jsonDecode(jsonStr);
            if (data is Map<String, dynamic>) searchCameras.add(data);
          } catch (e) {
            appLog('discovery bad line', e);
          }
        }
      }, onDone: () {
        client.close();
        if (_discoveryClient == client) _discoveryClient = null;
      }, onError: (e) {
        appLog('discovery stream error', e);
        client.close();
        if (_discoveryClient == client) _discoveryClient = null;
      });
    } catch (e) {
      appLog('discovery failed', e);
      client.close();
      if (_discoveryClient == client) _discoveryClient = null;
    }
  }

  @override
  void onClose() {
    try {
      _unsub?.call();
    } catch (_) {}
    _discoverySub?.cancel();
    try {
      _discoveryClient?.close();
    } catch (_) {}
    nameController.dispose();
    ipController.dispose();
    portController.dispose();
    rtspNameController.dispose();
    rtspController.dispose();
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

class videoFeedController extends GetxController {
  final _cameras = <String, web.HTMLImageElement>{}.obs;
  final _urls = <String, String>{};
  bool _paused = false;

  void connect(String url, String viewId) {
    try {
      if (_cameras.containsKey(viewId)) return;
      final imgElement = web.HTMLImageElement()
        ..src = _paused ? '' : url
        ..id = viewId
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.objectFit = 'cover';

      _cameras[viewId] = imgElement;
      _urls[viewId] = url;
    } catch (e) {
      appLog('video connect failed', e);
    }
  }

  /// Update the stored URL when the camera's RTSP changes while paused.
  void updateUrl(String viewId, String url) {
    _urls[viewId] = url;
    if (!_paused) {
      final el = _cameras[viewId];
      if (el != null) {
        try {
          el.src = url;
        } catch (_) {}
      }
    }
  }

  web.HTMLImageElement? getElement(String viewId) => _cameras[viewId];

  void disconnect(String viewId) {
    final element = _cameras[viewId];
    if (element != null) {
      try {
        element.src = '';
        element.remove();
      } catch (_) {}
      _cameras.remove(viewId);
    }
    _urls.remove(viewId);
  }

  /// Stop all MJPEG loads without destroying the platform-view elements.
  /// Called when Home tab becomes invisible (IndexedStack keeps the widget
  /// alive, so `dispose` never fires — without this the backend keeps
  /// streaming for every camera in the background).
  void pauseAll() {
    if (_paused) return;
    _paused = true;
    for (final el in _cameras.values) {
      try {
        el.src = '';
      } catch (_) {}
    }
    appLog('video paused (${_cameras.length} streams)');
  }

  void resumeAll() {
    if (!_paused) return;
    _paused = false;
    for (final entry in _cameras.entries) {
      final url = _urls[entry.key];
      if (url == null || url.isEmpty || url.endsWith('?source=')) continue;
      try {
        entry.value.src = url;
      } catch (_) {}
    }
    appLog('video resumed (${_cameras.length} streams)');
  }

  /// 🔌 Disconnects all active camera streams
  void disconnectAll() {
    _paused = false;
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
  var searchError = ''.obs;
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
    searchError.value = '';
    isArvand.value = false;
  }

  @override
  void onClose() {
    firstTwoDigit.dispose();
    threeDigit.dispose();
    lastTwoDigit.dispose();
    arvandDigit.dispose();
    super.onClose();
  }
}

class knowPersonController extends GetxController {
  var knowPerson = <knowPersonBox>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

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

  Future<void> Function()? _unsub;

  void startSub() {
    pb.collection('registredDb').subscribe(
      '*',
      (e) {
        try {
          final record = e.record;
          if (record == null) return;
          if (e.action == 'create') {
            knowPerson.add(knowPersonBox.fromJson(record.data));
          } else if (e.action == 'delete') {
            knowPerson.removeWhere(
              (element) => element.id == record.id,
            );
          } else {
            int index =
                knowPerson.indexWhere((element) => element.id == record.id);
            if (index != -1) {
              knowPerson[index] = knowPersonBox.fromJson(record.toJson());
            }
          }
          _syncPlateIndex();
        } catch (err) {
          appLog('persons realtime event failed', err);
        }
      },
    ).then((unsub) => _unsub = unsub, onError: (err, st) {
      appLog('persons subscribe failed', err);
    });
  }

  Future<void> fetchFirstData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';
    try {
      final mList = await pb
          .collection('registredDb')
          .getFullList()
          .timeout(const Duration(seconds: 20));
      knowPerson
          .assignAll(mList.map((json) => knowPersonBox.fromJson(json.data)));
      _syncPlateIndex();
    } catch (e) {
      error.value = 'خطا در دریافت افراد';
      appLog('fetch persons failed', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void>? _loadFuture;
  Future<void> ensureLoaded() => _loadFuture ??= () async {
        await fetchFirstData();
        startSub();
      }();

  @override
  void onReady() {
    ensureLoaded().catchError((e) => appLog('persons ensureLoaded', e));
    super.onReady();
  }

  @override
  void onClose() {
    try {
      _unsub?.call();
    } catch (_) {}
    firstTwoDigit.dispose();
    threeDigit.dispose();
    lastTwoDigit.dispose();
    arvandDigits.dispose();
    name.dispose();
    lastName.dispose();
    carNmae.dispose();
    super.onClose();
  }
}

class databaseController extends GetxController with WidgetsBindingObserver {
  var entries = <databaseClass>[].obs;
  var tableContect = databaseClass().obs;
  var todayCount = 0.obs;
  var goodPlate = 0.obs;
  var badPlate = 0.obs;
  var todayunallowed = <databaseClass>[].obs;
  var todayallowd = <databaseClass>[].obs;
  var selectedIndex = (-1).obs;
  var isLoading = false.obs;
  var isLoadingMore = false.obs;
  var loadError = ''.obs;
  int inilazedPage = 1;
  final _loadedIds = <String>{};
  Future<void> Function()? _unsub;

  static bool _isGoodPlate(String? plate) => plate != null && plate.length >= 7;

  // ---- polling state ----
  static const _pollInterval = Duration(seconds: 1);
  static const _pollTimeout = Duration(seconds: 5);
  static const _pollPageSize = 50;
  String? _updatedCursor; // newest "updated" seen
  String?
      _createdCursor; // newest "created" seen (decides "is this record new?")
  bool _initialLoaded = false; // first page loaded OK
  bool _polling = false;
  bool _pollingWanted = false; // true when we're in polling mode (bad network)
  int _failures = 0;
  int _pollTick = 0;

  void _advanceUpdated(String? v) {
    if (v == null || v.isEmpty) return;
    if (_updatedCursor == null || v.compareTo(_updatedCursor!) > 0) {
      _updatedCursor = v;
    }
  }

  void _advanceCreated(String? v) {
    if (v == null || v.isEmpty) return;
    if (_createdCursor == null || v.compareTo(_createdCursor!) > 0) {
      _createdCursor = v;
    }
  }

  bool _isNewlyCreated(String? created) {
    if (_createdCursor == null) return true;
    if (created == null || created.isEmpty) return false;
    return created.compareTo(_createdCursor!) > 0;
  }

  // ---------------------------------------------------------------
  // Shared "new record" logic (used by realtime AND polling)
  // ---------------------------------------------------------------
  void _handleCreated(databaseClass entry) {
    // Deduplicate: realtime create can replay after reconnect.
    if (entry.id != null && _loadedIds.contains(entry.id)) return;
    if (entry.id != null) _loadedIds.add(entry.id!);
    entries.insert(0, entry);
    if (entries.length > 200) {
      final removed = entries.removeAt(entries.length - 1);
      if (removed.id != null) _loadedIds.remove(removed.id);
    }
    todayCount.value++;
    if (_isGoodPlate(entry.plateNum)) {
      goodPlate.value++;
    } else {
      badPlate.value++;
    }

    try {
      alarmPlay(entry);
    } catch (err) {
      appLog('alarmPlay failed', err);
    }
    try {
      relayAutomatic(entry);
    } catch (err) {
      appLog('relayAutomatic failed', err);
    }
    try {
      notifPlay(entry);
    } catch (err) {
      appLog('notifPlay failed', err);
    }
  }

  void startSub() {
    pb.collection('database').subscribe(
      '*',
      (e) {
        try {
          final record = e.record;
          if (record == null) return;
          if (e.action == 'create') {
            _handleCreated(databaseClass.fromJson(record.data));
            // final entry = databaseClass.fromJson(record.data);
            // // Deduplicate: realtime create can replay after reconnect.
            // if (entry.id != null && _loadedIds.contains(entry.id)) return;
            // if (entry.id != null) _loadedIds.add(entry.id!);
            // entries.insert(0, entry);
            // if (entries.length > 200) {
            //   final removed = entries.removeAt(entries.length - 1);
            //   if (removed.id != null) _loadedIds.remove(removed.id);
            // }
            // todayCount.value++;
            // if (_isGoodPlate(entry.plateNum)) {
            //   goodPlate.value++;
            // } else {
            //   badPlate.value++;
            // }

            // try {
            //   alarmPlay(entry);
            // } catch (err) {
            //   appLog('alarmPlay failed', err);
            // }
            // try {
            //   relayAutomatic(entry);
            // } catch (err) {
            //   appLog('relayAutomatic failed', err);
            // }
            // try {
            //   notifPlay(entry);
            // } catch (err) {
            //   appLog('notifPlay failed', err);
            // }
          } else if (e.action == 'delete') {
            entries.removeWhere(
              (element) => element.id == record.id,
            );
            _loadedIds.remove(record.id);
            if (todayCount.value > 0) todayCount.value--;
          } else {
            int index =
                entries.indexWhere((element) => element.id == record.id);
            if (index != -1) {
              entries[index] = databaseClass.fromJson(record.toJson());
            }
          }
        } catch (err) {
          appLog('database realtime event failed', err);
        }
      },
    ).then((unsub) => _unsub = unsub, onError: (err, st) {
      appLog('database subscribe failed', err);
    });
  }

  // ---------------------------------------------------------------
  // Polling (bad network)
  // ---------------------------------------------------------------
  void startPolling() {
    _pollingWanted = true;
    if (_polling) return;
    _polling = true;
    _pollLoop();
  }

  void stopPolling() {
    _pollingWanted = false;
    _polling = false;
  }

  Future<void> _pollLoop() async {
    while (_polling) {
      final started = DateTime.now();
      try {
        // keep pulling right away while full pages keep coming
        while (_polling && await fetchChanges()) {}
        if (_polling && ++_pollTick % 10 == 0) await _syncDeletes();
        _failures = 0;
      } catch (e) {
        _failures++;
        appLog('poll failed ($_failures)', e);
      }

      // 1s normally; on failures back off 1, 2, 4, 8, 15s
      final secs = _failures == 0
          ? _pollInterval.inSeconds
          : (1 << (_failures - 1).clamp(0, 4)).clamp(1, 15);
      final wait = Duration(seconds: secs) - DateTime.now().difference(started);
      if (wait > Duration.zero) await Future.delayed(wait);
    }
  }

  Future<void> _syncDeletes() async {
  if (!_initialLoaded || isLoadingMore.value || entries.isEmpty) return;

  // margin of 50 covers records created since the last check
  final size = (entries.length + 50).clamp(50, 500);
  final res = await pb
      .collection('database')
      .getList(
        page: 1,
        perPage: size,
        sort: '-created',
        fields: 'id',
        skipTotal: true,
      )
      .timeout(_pollTimeout);

  if (res.items.isEmpty) return; // safety: never wipe the list on an odd response

  final serverIds = res.items.map((r) => r.id).toSet();
  final checkable = entries.take(size - 50).toList(); // only the newest window
  final deletedIds = checkable
      .where((e) => e.id != null && !serverIds.contains(e.id))
      .map((e) => e.id!)
      .toSet();
  if (deletedIds.isEmpty) return;

  entries.removeWhere((e) => deletedIds.contains(e.id));
  _loadedIds.removeAll(deletedIds);
  if (selectedIndex.value >= entries.length) selectedIndex.value = -1;
  fetchCountData(); // recount today's totals and lists after deletes
}

  /// Fetches records changed since the last poll.
  /// Returns true if a full page came back (more may be waiting).
  Future<bool> fetchChanges() async {
    // Never poll before the first page is loaded, otherwise the cursor is
    // empty and every existing record would look "new" (alarms, relay!).
    if (!_initialLoaded || isLoadingMore.value) return false;

    final res = await pb
        .collection('database')
        .getList(
          page: 1,
          perPage: _pollPageSize,
          sort: 'updated',
          skipTotal: true,
          filter: _updatedCursor == null
              ? null
              : pb.filter('updated > {:c}', {'c': _updatedCursor}),
        )
        .timeout(_pollTimeout);

    if (res.items.isEmpty) return false;

    for (final record in res.items) {
      try {
        final data = record.data;
        final updated = data['updated'] as String?;
        final created = data['created'] as String?;
        _advanceUpdated(updated);

        final entry = databaseClass.fromJson(data);
        final id = entry.id;
        if (id == null) continue;

        final index = entries.indexWhere((el) => el.id == id);
        if (index != -1) {
          entries[index] = entry; // edited record: replace in place
        } else if (_isNewlyCreated(created)) {
          _advanceCreated(created);
          _handleCreated(entry); // brand-new record
        }
        // else: old record we never loaded was edited -> ignore
      } catch (err) {
        appLog('poll record failed', err);
      }
    }
    return res.items.length == _pollPageSize;
  }

  Future<void> fetchFirstData(int inpage, int inperpage) async {
    if (isLoadingMore.value) return;
    isLoadingMore.value = true;
    loadError.value = '';
    try {
      final mList = await pb
          .collection('database')
          .getList(
            page: inpage,
            perPage: 30,
            sort: '-created',
          )
          .timeout(const Duration(seconds: 20));
      var added = 0;
      for (final json in mList.items) {
        _advanceUpdated(json.data['updated'] as String?);
        _advanceCreated(json.data['created'] as String?);
        final entry = databaseClass.fromJson(json.data);
        if (entry.id != null && _loadedIds.contains(entry.id)) continue;
        if (entry.id != null) _loadedIds.add(entry.id!);
        entries.add(entry);
        added++;
      }
       if (inpage == 1) _initialLoaded = true;
      if (added == 0 && mList.items.isNotEmpty) {
        // Page overlapped with live inserts — nothing new, keep page index.
      }
      if (entries.isNotEmpty && tableContect.value.id == null) {
        tableContect.value = entries.first;
      }
    } catch (e) {
      loadError.value = 'خطا در دریافت رکوردها';
      appLog('fetch database page $inpage failed', e);
    } finally {
      isLoadingMore.value = false;
    }
  }

  Future<void> fetchCountData() async {
    try {
      var now = DateTime.now();
      var day = now.day.toString().padLeft(2, '0');
      var month = now.month.toString().padLeft(2, '0');
      var todayISO = "${now.year}-$month-$day";

      final kcontroller = Get.find<knowPersonController>();
      final records = await pb
          .collection('database')
          .getFullList(filter: 'eDate = "$todayISO"')
          .timeout(const Duration(seconds: 20));
      // Reset before recounting — previously this method accumulated on
      // every call (and notifPlay adds live items separately), inflating
      // all statistics.
      todayCount.value = records.length;
      goodPlate.value = 0;
      badPlate.value = 0;
      todayallowd.clear();
      todayunallowed.clear();
      final seenToday = <String>{};
      for (var data in records) {
        final plate = asString(data.data['plateNum']);
        if (_isGoodPlate(plate)) {
          goodPlate.value++;
        } else {
          badPlate.value++;
        }
        final person = kcontroller.personFor(plate);
        if (person != null) {
          final entry = databaseClass.fromJson(data.data);
          final key = entry.id ?? '${entry.plateNum}-${entry.eTime}';
          if (!seenToday.add(key)) continue;
          if (person.role == "مجاز") {
            todayallowd.add(entry);
          } else {
            todayunallowed.add(entry);
          }
        }
      }
    } catch (e) {
      appLog('fetch count failed', e);
    }
  }

  @override
  void onInit() {
      super.onInit();
     WidgetsBinding.instance.addObserver(this);
  
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Only matters in polling mode
    if (!_pollingWanted) return;
    if (state == AppLifecycleState.resumed) {
      startPolling();
    } else {
      _polling = false; // pause, but keep _pollingWanted so resume restarts it
    }
  }

  @override
  void onReady() {
    // Persons must be loaded before we classify today's records, and the two
    // database fetches are independent so they run in parallel.
    () async {
      try {
        await Get.find<knowPersonController>().ensureLoaded();
        await Future.wait([
          fetchFirstData(inilazedPage, 30),
          fetchCountData(),
        ]);
        if (Get.find<settingController>().isBadNetwork ){
startPolling();
appLog('Bad Network');
        }
        else{
startSub();
appLog('Good Network');
        }
        
        // 
      } catch (e) {
        appLog('database onReady failed', e);
      }
    }();
    super.onReady();
  }

  @override
  void onClose() {
       stopPolling();
    WidgetsBinding.instance.removeObserver(this);
    try {
      _unsub?.call();
    } catch (_) {}
    super.onClose();
  }
}

class settingController extends GetxController {
  var settings = <setting_class>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;
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

  bool isBadNetwork=false;
 
  Future<void> Function()? _unsub;

  void startSub() {
    pb.collection('setting').subscribe(
      '*',
      (e) {
        try {
          final record = e.record;
          if (record == null) return;
          if (e.action == 'create') {
            settings.add(setting_class.fromJson(record.data));
          } else if (e.action == 'delete') {
            settings.removeWhere(
              (element) => element.id == record.id,
            );
          } else {
            int index =
                settings.indexWhere((element) => element.id == record.id);
            if (index != -1) {
              settings[index] = setting_class.fromJson(record.toJson());
            }
          }
        } catch (err) {
          appLog('setting realtime event failed', err);
        }
      },
    ).then((unsub) => _unsub = unsub, onError: (err, st) {
      appLog('setting subscribe failed', err);
    });
  }

  Future<void> fetchFirstData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';
    try {
      final mList = await pb
          .collection('setting')
          .getFullList(
            sort: '-created',
          )
          .timeout(const Duration(seconds: 15));
      settings
          .assignAll(mList.map((json) => setting_class.fromJson(json.data)));
    } catch (e) {
      error.value = 'خطا در دریافت تنظیمات';
      appLog('fetch setting failed', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> firstIniliazed() async {
    if (settings.isEmpty) return;
    final s = settings.first;
    // Null-safe with sensible defaults — a malformed settings row must not
    // crash the whole app via `!` assertions.
    plateConf.value = s.plateConf ?? 0.0;
    charConf.value = s.charConf ?? 0.0;
    quality.value = (s.quality ?? 0).toDouble();
    isRfid.value = s.isRfid ?? false;
    rfipController.text = s.rfidip ?? '';
    rfportConroller.text = (s.rfidport ?? 0).toString();
    isrlOne.value = s.rl1 ?? false;
    isrlTwo.value = s.rl2 ?? false;
    rfconnect.value = s.rfconnect ?? false;
    isAlarm.value = s.alarm ?? false;
    isNotif.value = s.notif ?? false;
    isBadNetwork=s.isBadNetwork ?? false;
  }

  Future<void>? _loadFuture;
  Future<void> ensureLoaded() => _loadFuture ??= () async {
        await fetchFirstData();
        await firstIniliazed();
        startSub();
      }();

  @override
  void onReady() {
    ensureLoaded().catchError((e) => appLog('setting ensureLoaded', e));
    super.onReady();
  }

  @override
  void onClose() {
    try {
      _unsub?.call();
    } catch (_) {}
    rfipController.dispose();
    rfportConroller.dispose();
    super.onClose();
  }
}

class userController extends GetxController {
  var users = <userClass>[].obs;
  var isLoading = false.obs;
  var error = ''.obs;

  TextEditingController name = TextEditingController();
  TextEditingController lastName = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController username = TextEditingController();
  TextEditingController password = TextEditingController();
  var accsesslvl = "مدیر".obs;

  Future<void> Function()? _unsub;

  void startSub() {
    pb.collection('users').subscribe(
      '*',
      (e) {
        try {
          final record = e.record;
          if (record == null) return;
          if (e.action == 'create') {
            users.add(userClass.fromJson(record.data));
          } else if (e.action == 'delete') {
            users.removeWhere(
              (element) => element.id == record.id,
            );
          } else {
            int index = users.indexWhere((element) => element.id == record.id);
            if (index != -1) {
              users[index] = userClass.fromJson(record.toJson());
            }
          }
        } catch (err) {
          appLog('users realtime event failed', err);
        }
      },
    ).then((unsub) => _unsub = unsub, onError: (err, st) {
      appLog('users subscribe failed', err);
    });
  }

  Future<void> fetchFirstData() async {
    if (isLoading.value) return;
    isLoading.value = true;
    error.value = '';
    try {
      final mList = await pb
          .collection('users')
          .getFullList(
            sort: '-created',
          )
          .timeout(const Duration(seconds: 15));
      users.assignAll(mList.map((json) => userClass.fromJson(json.data)));
    } catch (e) {
      error.value = 'خطا در دریافت کاربران';
      appLog('fetch users failed', e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void>? _loadFuture;
  Future<void> ensureLoaded() => _loadFuture ??= () async {
        await fetchFirstData();
        startSub();
      }();

  @override
  void onReady() {
    ensureLoaded().catchError((e) => appLog('users ensureLoaded', e));
    super.onReady();
  }

  @override
  void onClose() {
    try {
      _unsub?.call();
    } catch (_) {}
    name.dispose();
    lastName.dispose();
    email.dispose();
    username.dispose();
    password.dispose();
    super.onClose();
  }
}
