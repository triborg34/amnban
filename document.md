# AMNBAN — Full Project Document

**Project:** `amnban` — Flutter ANPR (Automatic Number Plate Recognition) frontend  
**Platform:** Web primary (`package:web` + `dart:ui_web` `HtmlElementView`), Android/iOS/Linux/macOS/Windows shells generated  
**Framework:** Flutter 3.5.4 / Dart 3.5 / GetX 4.6.6 / PocketBase 0.21.0 / http 1.2.2  
**Date of doc:** 2026-09-07  
**Repo state:** 26 commits `bc40645` → `3d83377` + uncommitted hardening (`+2135/-1180`, 30 files) — `dart analyze lib` **No issues found**

---

## Table of Contents
1. [What AMNBAN Is](#1-what-amnban-is)
2. [Tech Stack & Requirements](#2-tech-stack--requirements)
3. [Project History — Every Commit](#3-project-history--every-commit)
4. [System Architecture](#4-system-architecture)
5. [Data Models](#5-data-models)
6. [Screens & User Flow](#6-screens--user-flow)
7. [Services, API & Backend Contracts](#7-services-api--backend-contracts)
8. [Live ANPR Pipeline](#8-live-anpr-pipeline)
9. [Persian / Plate Conversion](#9-persian--plate-conversion)
10. [State Before Hardening — Audit Findings](#10-state-before-hardening--audit-findings)
11. [New Shared Helpers](#11-new-shared-helpers)
12. [Hardening — Critical Fixes](#12-hardening--critical-fixes)
13. [Hardening — Architecture / State](#13-hardening--architecture--state)
14. [Hardening — Network / Realtime Reliability](#14-hardening--network--realtime-reliability)
15. [Hardening — Live Dashboard & Video](#15-hardening--live-dashboard--video)
16. [Hardening — Lists / Images / Forms](#16-hardening--lists--images--forms)
17. [Regression Fixes (Your Bug Reports)](#17-regression-fixes-your-bug-reports)
18. [File Change Log (Hardening)](#18-file-change-log-hardening)
19. [Verification Checklist](#19-verification-checklist)
20. [Future Recommendations](#20-future-recommendations)
21. [Appendix — Commands](#21-appendix--commands)

---

## 1. What AMNBAN Is

Persian-language web dashboard for an ANPR engine:
- **Live view:** MJPEG `video_feed`/`rtsp_feed` per camera via `web.HTMLImageElement` + `ui.platformViewRegistry` (`lib/widgets/CemraFeed.dart:8`, `lib/widgets/video_box.dart:7`), `KeyboardListener` digit1/2 triggers relay open
- **Detection history:** rolling `database` list (`lib/widgets/data_base_entries.dart:11`) + expanded row (`lib/widgets/extended_table.dart:12`) + detail view (`lib/screens/details_screen.dart:16`) with plate crop, full scene, person lookup, count of same plate, PDF receipt
- **Reports:** Persian date/time + plate + Arvand filters → server-side `filter:` → `getFullList` → `ListView` + PDF `lib/screens/reportscreen.dart:497` (`pdf`/`printing`)
- **Entities:** Cameras (`cameras`), known persons/allow-list (`registredDb`), users/roles (`users`), global tuning (`setting`) — all PocketBase collections `lib/utils/controller.dart:22`
- **Hardware:** `POST /utils/iprelay` for gate relay 1/2 `lib/utils/consts.dart:42`, `POST /email?email=` alarm, `GET /onvif/get-stream` SSE discovery `lib/utils/controller.dart:128`
- **Backup/restore** of any collection as JSON `lib/utils/consts.dart:205`

Roles flow: `SplashScreen` 2s → `ModernLoginPage` (`lib/screens/loginScreen.dart:12`) → `MainScreen` tabs `lib/screens/main_screen.dart:11` `tabsFor(role)` — `مدیر` sees 5 tabs `خانه/گزارشات/دوربین/افراد/تنظیمات` (reversed list), `ناظر` sees 3 `خانه/گزارشات/افراد` (Home always last index).

---

## 2. Tech Stack & Requirements

`pubspec.yaml` deps: `get: ^4.6.6`, `http: ^1.2.2`, `pocketbase: ^0.21.0`, `persian_number_utility`, `persian_datetime_picker`, `printing: ^5.14.2`, `responsive_sizer: ^3.3.1`, `shared_preferences: ^2.5.3`, `audioplayers: ^6.1.0`, `splash_view`, `easy_image_viewer`, `web`, `flutter_web_notification_platform`.

Hard requirements: `sdk: ^3.5.4`, fonts `byekan` (default theme) + `arial`/`robots` fallback `lib/main.dart:26`, assets `assets/images/{iranFlag,arvand,ban,mainlogo2,logo}` + `assets/alarm.mp3`. Globals `url/port/pb/role/email` in `lib/utils/consts.dart:23` derived from `getNetworkInfo()` `lib/utils/network_info.dart:13` (hostname/port on web, else defaults `127.0.0.1:8000`/`8090` for PocketBase).

---

## 3. Project History — Every Commit

Derived from `git log --oneline --reverse`:

| # | Hash | Message | What happened |
|---|------|---------|---------------|
| 1 | `bc40645` | `init` | Flutter project scaffold + `lib/main.dart` 29L, `lib/models/{camera,knowPerson,database}Class`, `lib/screens/{details,home,main,report}`, `lib/utils/{bindings,consts,controller,converFunctions}`, `lib/widgets/{AlphaBetSelector,CemraFeed,arvandpelak,data_base_entries,extended_table,licance_searcher,lisancepage,pdf_printig,reportTextField,video_box}`, assets `Yekan/arial/alarm/ban` |
| 2 | `9da37a3` | `report screen complete` | `lib/screens/reportscreen.dart` 739L rebuild — Jalali pickers, time pickers, plate filter `licance_searcher`, `PlatePicked`, `server filter eDate/eTime/plateNum`, `ListView` 10-col report rows, PDF save `printing` |
| 3 | `3edb6d7` | `cameraScreen` | `lib/screens/camera_screen.dart` added — `/rt1` add dialog `lib/widgets/add_or_edit_camera.dart`, IP/port/RTSP/user/pass/gate, ONVIF discovery list, `rtspOnn/Off` widgets, discovery `GET /onvif/get-stream` |
| 4 | `591e347` | `road to person screen` | Routing toward `lib/screens/person_screen.dart` — SliverList scaffold |
| 5 | `1e6f6e7` | `add knownPerson` | `lib/models/knowPersonClass.dart` 80L, `lib/widgets/add_or_edit_person.dart` — name/lastName/carName/role/plate split (`firstTwoDigit/threeDigit/lastTwoDigit/englishAlphabet/persinalAlphabet`), Arvand toggle |
| 6 | `9c8859c` | `setting start` | `lib/models/settingClass.dart` + `lib/screens/setting_screen.dart` scaffold, `setting_box.dart`, sliders `sliders_widgets.dart` for `plateConf/charConf/quality` |
| 7 | `2da16dd` | `Setting Complete` | `lib/screens/general_setting.dart`, `lib/utils/consts.dart` RFID/relay/alarm/notif fields, `onRelayOne/Two`/`relayAutomatic`/`alarmPlay`/`notifPlay` wired |
| 8 | `508e9f9` | `Complete Ui` | UI polish across home/report/camera/person — `purpule/selecetpurpule` theme, `responsive_sizer` `w` units |
| 9 | `c848aca` | `uiComplate` | Further UI completion |
| 10 | `ba7be36` | `Complate` | Minor completes |
| 11 | `562677c` | `now its complate` | Pre-relay completeness |
| 12 | `bdbc675` | `Complate ui and relay` | `lib/utils/consts.dart` relay logic final, `lib/screens/home_sceen.dart:41` digit1/2 `KeyboardListener` + relay buttons guarded `isRfid&&rfconnect`, `lib/utils/controller.dart` `relayAutomatic/notifPlay/alarmPlay` chained on `database subscribe create` |
| 13 | `1e35acb` | `controller fixed` | `lib/utils/controller.dart` `ensureLoaded` idempotent `_loadFuture`, `onReady` async, `cameraNames/byPlate` indices introduced partly, `fetchFirstData+startSub` ordering |
| 14 | `3070aca` | `new nrc` | New NRC (likely camera/relay) tweaks |
| 15 | `334691d` | `load more function` | `lib/widgets/data_base_entries.dart` `inilazedPage+30` `fetchFirstData(page,30)` + button `بار گزاری بیشتر` |
| 16 | `aa8eca6` | `final` | Final pass before date work |
| 17 | `e8d98be` | `update info` | Info settings `isInfo/isGeneral/isUsers` toggles in `lib/screens/setting_screen.dart` |
| 18 | `23384f3` | `date and shits` | Persian date/time handling `persian_datetime_picker`, `toPersianDate/toPersianDigit` |
| 19 | `0814d4d` | `alot of changes` | Bulk changes (asset + logic) |
| 20 | `3c61872` | `update to new flutter` | Flutter upgrade (3.5 line), `web` 1.0 migration, `analysis_options.yaml` |
| 21 | `3650ce9` | `change so many things` | Many things — controller refactors, widget splits |
| 22 | `b73fb15` | `backup and restore` | `lib/utils/consts.dart:118` `getBackup/_restoreFromJson/restoreBackup` HTML anchor + `FileReader` |
| 23 | `3d02e4d` | `before ai` | Pre-AI state |
| 24 | `128da8b` | `ai emarged` | AI emerged (likely YOLO tuning fields `1404717/14040828/YOLOV5M100300` in `lib/screens/setting_screen.dart:206`) |
| 25 | `480b769` | `before z` | Before Z |
| 26 | `3d83377` | `after z` | `after z` — `_originals/` binaries added, assets recompressed (`ban.jpg 618→157k`, fonts), `details_screen 501L removed`, `home 144L removed`, `reportscreen 303L removed`, `pdf_printig 331L removed` + `receipt_pdf` 110L, `amar_dialog` 112L extracted, `licance_searcher` 16L, `lisancepage` 39L, `controller 212L`, `converFunctions 3L` — the baseline we hardened |
| 27 | *uncommitted* | *hardening* | This doc — +2135/-1180 across 30 files, `safe.dart/safe_image.dart` new, see §11–17 |

`_originals/` added in `3d83377` preserves uncompressed sources. `analysis_options.yaml` stays default `flutter_lints`. No `test` growth; `test/widget_test.dart` still stub — `flutter test` fails on web import (expected).

---

## 4. System Architecture

```
main.dart (ResponsiveSizer → GetMaterialApp initialBinding:MyBindings)
  │
MyBindings.dependencies() lib/utils/bindings.dart:6
  ├─ mainPageConroller (nav index, videoIndex, isSelected)
  ├─ videoFeedController (HTMLImageElement map, pause/resume)
  ├─ cameraController (cameras, searchCameras, name index, discovery SSE)
  ├─ knowPersonController (knowPerson, byPlate index)
  ├─ databaseController (entries, tableContect, todayCount, good/bad, allow/deny)
  ├─ reportController (plate pickers, date/time filters, selectedModel)
  ├─ settingController (settings, conf/quality/rfid/relay/alarm/notif)
  └─ userController (users)
        │
        ├─ PocketBase pb="http://$url:8090" (collections: cameras, registredDb, database, setting, users)
        ├─ http Client (SSE + iprelay + email + RTSP discovery)
        └─ SharedPreferences (remember_me username)
```

Separation goal `UI → State → Services → API` kept shallow: Widgets → `controller.dart` GetX → `consts.dart` side-effects → `pb/http`. No extra repository layer introduced (per prompt §13 — avoid over-engineering).

---

## 5. Data Models

All in `lib/models/*.dart` — nullable DTOs with `fromJson/toJson` manual maps. Hardened with `safe.dart` coercion.

- **`CameraClass` (`lib/models/cameraClass.dart:1`)** — `id,name,ip,port,gate,username,password(path+rtspUrl+rtspName+isRtsp),collectionId/Name,created/updated,maxUpdated`
- **`databaseClass` (`lib/models/databaseEntry.dart:1`)** — `id,plateNum,eDate,eTime,status/isarvand,rtpath,charPercent/platePercent,int,imgpath/scrnPath,created/updated` — each detection row, `isarvand=='arvand'` vs normal Persian plate
- **`knowPersonBox` (`lib/models/knowPersonClass.dart:1`)** — `id,plateNumber,name,carName,eDate/eTime,role مجاز/غیر مجاز,socialNumber,isArvand,firstTwoDigit/threeDigit/lastTwoDigit,englishAlphabet/persinalAlphabet` — note historical typo `persinalAlphabet` handled with fallback to `persianAlphabet` `lib/models/knowPersonClass.dart:49`
- **`setting_class` (`lib/models/settingClass.dart:1`)** — `id,plateConf/charConf double,port/isRfid/rl1/rl2/rfidip/rfidport,alarm/quality/ip/rfconnect/notif` — `double?` crash on server `int` fixed `lib/models/settingClass.dart:33` via `asDouble`
- **`userClass` (`lib/models/userClass.dart:1`)** — `id,username,password(base64),accsesslvl مدیر/ناظر,email,nickname,rememberme bool,created/updated`

---

## 6. Screens & User Flow

- **`SplashScreen` (`lib/screens/splashScreen.dart:7`)** — `SplashView duration 2s` → `Done(ModernLoginPage)` → in current hardened flow kept but auth is via `ModernLoginPage`
- **`ModernLoginPage` (`lib/screens/loginScreen.dart:12`)** — `Form` username/password, `_rememberMe` checkbox, `_checkLoginStatus()` auto-login via `SharedPreferences username + users.where(username==...).first.rememberme==true` (hardened with `mounted`/timeout/`_decodePassword` helper `lib/screens/loginScreen.dart:19`), `Enter` key listener, `Get.offAll(MainScreen)` on success (was `Get.to` stacking) `lib/screens/loginScreen.dart:80`
- **`MainScreen` (`lib/screens/main_screen.dart:11`)** — AppBar `mainlogo2.png` + `tabsFor(role)` `InkWell` per tab `AnimatedContainer 300ms`, body `IndexedStack` `lib/screens/main_screen.dart:72` (was `GetX` switch recreating screens). `Stateful+ever` pauses video off-Home `lib/screens/main_screen.dart:28`. `role` global mutable set on login `lib/screens/loginScreen.dart:70`
- **`HomeSceen` (`lib/screens/home_sceen.dart:11`)** — `KeyboardListener digit1/2 → onRelayOne/Two`, `Row[VideoBox|dataBaseEntries]` with `LayoutBuilder` narrow<900 → `Column` `lib/screens/home_sceen.dart:34`, `Obx+Visibility(isSelected)->ExtendedTable`, RFID buttons guarded `lib/screens/home_sceen.dart:98`, stats `amarWidget` per `Obx` + `barChartWidget:289` 4 bars (good/bad/allowed/denied) with `caculate` div-zero guard `lib/screens/home_sceen.dart:309`
- **`Reportscreen` (`lib/screens/reportscreen.dart:23`)** — `reportController.inilazed()` in `initState` (once per visit not per build) `lib/screens/reportscreen.dart:35`, `Row` filters: `PlatePicked`/`isArvand` 210w container ↔ `licanceSearcher` dialog, `Jalali` date 1385-1499, `TimeOfDay` 24h, `جستجو` → `searchFunction` `lib/screens/reportscreen.dart:651`, `ذخیره` → `saveToPdf:497` `pdf` `MultiPage rtl 75w`, `ریست` → `inilazed+update` `lib/screens/reportscreen.dart:243`, result `ListView.builder` 10-col row + `SafeNetImage` `lib/screens/reportscreen.dart:311`
- **`CameraScreen` (`lib/screens/camera_screen.dart:10`)** — two 300h lists: registered cameras (50/150/250w cols) + ONVIF discovered (`searchCameras`) via `GET /onvif/get-stream` SSE `lib/utils/controller.dart:128`, `AddOrEditCamera` dialog per row, `startDiscovery` button, horizontal scroll `width 1400` `lib/screens/camera_screen.dart:77`
- **`PersonScreen` (`lib/screens/person_screen.dart:12`)** — `CustomScrollView+SliverList.Builder` `lib/screens/person_screen.dart:26` (recycles vs `shrinkWrap`), 4-6w cols, Arvand vs `convertToPersianString`, edit via `add_or_edit_person`, delete `registredDb`
- **`SettingScreen` (`lib/screens/setting_screen.dart:8`)** — collapsible `isUsers/isGeneral/isInfo` sections `Obx+AnimatedCrossFade`, `UserBox` `lib/screens/user_box.dart:11` 3-12w list, `GeneralSetting` `lib/screens/general_setting.dart:7` sliders `plateConf/charConf/quality` + RFID/alarm/notif toggles + save `setting.first.id` update
- **`Detailedscreen` (`lib/screens/details_screen.dart:16`)** — `Scaffold AppBar`, `EasyImageView` full scene `scrnPath`, header `header3()` 12w 8 cols, row with `ArvandPelak/LicanceNumber`, `Hero`, `personFor`, `platePercent%`, `rec.length` tap → `showAmarDialog`, `printReceipt`
- Other: `camera_screen` ONVIF, `setting_box`, `sliders_widgets`, `futurs_of_system_row`, `amar_dialog` `lib/widgets/amar_dialog.dart:13` today allowed/denied dialog, `licance_searcher` `lib/widgets/licance_searcher.dart:8` etc.

---

## 7. Services, API & Backend Contracts

All endpoints preserved:

- **PocketBase** `pb=PocketBase('http://$url:8090')` `lib/utils/consts.dart:28` — `cameras` (`getFullList/subscribe/create/update/delete`), `registredDb`, `database` (`getList page:page perPage:30 sort:-created`, `getFullList filter:eDate="YYYY-MM-DD"`, `filter:plateNum="..."` `pbEscape`), `setting` (`sort:-created`), `users` (`where username`, `update rememberme`, `create/update`)
- **http** — `GET http://$url:$port/onvif/get-stream` `Accept:text/event-stream` `LineSplitter` `lib/utils/controller.dart:139`, `POST /utils/iprelay` JSON `{ip,port,username:admin,password:admin,relay_number:1/2}` `lib/utils/consts.dart:42`, `POST /onvif/get-rtsp` body `{ip,port,username,password}` `lib/widgets/add_or_edit_camera.dart:203`, `POST /email?email=$email` body `{plateNumber,eDate,eTime}` `lib/utils/consts.dart:155`
- **MJPEG** — `lib/widgets/video_box.dart:83` `http://$url:$port/${role=='ناظر'?'rtsp_feed':'video_feed'}/rt${i+1}?source=${rtspUrl}`
- **Files** — `http://$url:8090/api/files/{database,registredDb,setting}/$id/$file` via `pbFileUrlOf` `lib/utils/consts.dart:28` / `SafeNetImage` `lib/widgets/safe_image.dart:75`

`lib/utils/network_info.dart:13` `getNetworkInfo()` reads `window.location.hostname/port` on web else `{}`, `lib/main.dart:19` now sync with fallbacks.

---

## 8. Live ANPR Pipeline

1. Engine writes `database` record `{plateNum,eDate,eTime,isarvand,rtpath,imgpath,scrnPath,platePercent}`
2. `databaseController:313` `pb.collection('database').subscribe('*')` inserts at `0`, caps `>200` (was 30), `todayCount++`, `_isGoodPlate(plate.length>=7)` `goodPlate/badPlate`, calls `alarmPlay/relayAutomatic/notifPlay` each in `try` `lib/utils/controller.dart:313`
3. `alarmPlay` `lib/utils/consts.dart:155` checks `isAlarm`, `personFor==null` → `AudioPlayer play alarm.mp3` `catchError`, `POST /email` fire-and-forget `timeout 8s`
4. `relayAutomatic` `lib/utils/consts.dart:187` checks `isRfid`, `personFor!=null`, `isrlOne/Two → onRelayOne/Two`
5. `notifPlay` `lib/utils/consts.dart:74` checks `person.role مجاز` → `todayallowed/todayunallowed` dedup by `id`, `PlatformNotification` if `isNotif`
6. `fetchCountData:363` daily recount `eDate=todayISO`, resets counters before loop, `seenToday` dedup

---

## 9. Persian / Plate Conversion

`lib/utils/converFunctions.dart:1` — `latinLetters` regex, `labelmap/carDict alphabetP/P2/E/plateAlphabet` maps (`PuV->ع`, `Gh->ق` etc.), `convertToPersian(String, dict)` 3-char then 2-char then 1-char token loop → `[ "۱۲۳ ب ۴۵", "۶۷"]` try `result[0..7]` formatting `lib/utils/converFunctions.dart:234` fallback `["-","-"]`, `convertString` longest-key replace. Used everywhere `ArvandPelak` `12|34`, `LicanceNumber` `۱۲۳/۴۵ ب ۶۷`. Hardened callers guard `plate==null` → `'-'` `lib/widgets/lisancepage.dart:15`, `arvandpelak.dart:9` `_label()` safe substring.

---

## 10. State Before Hardening — Audit Findings

(Kept verbatim for traceability)

- **State:** `lib/utils/bindings.dart:6` `Get.put(x8)` + mixed `GetBuilder/.value` `lib/screens/reportscreen.dart:56`, `lib/utils/consts.dart:32` import-time `tabs`
- **API/Models:** unawaited `onInit` → `null` host, `safe.dart` missing type coercion crashes, typo `persinalAlphabet`
- **Nav/Auth:** unused `pages`, stacking `Get.to`, `base64` reversible, `rememberme!` crash, 2s splash ignores remembered user
- **Realtime:** 5× `subscribe` leak, SSE `jsonDecode` without `try`, `viewId=hash+timestamp` leak/flicker, `registerViewFactory` throws duplicate
- **UI:** `SingleChildScrollView>Column>Expanded>ListView` height error, `Visibility` filter keeps `itemCount`, 1400px rows overflow, raw `Image.network` no placeholder, hero tag collides, `home_sceen:48` double height, `main_screen:58` rebuilds whole body
- **Async:** `picked!/t!` cancel crash, `maybeOf!` after await, `base64.decode!`, `int.parse`, `split()[2]/substring` `RangeError`, only login has validators

---

## 11. New Shared Helpers

**`lib/utils/safe.dart:1`**
```dart
String? asString(dynamic v) => v?.toString();
int? asInt(dynamic v) { if(v is int) return v; if(v is double) return v.toInt(); ... tryParse }
double? asDouble(dynamic v) // int→double
bool? asBool(dynamic v) // bool/"true"/"1"
String pbEscape(String s) => s.replaceAll(r'\', r'\\').replaceAll('"', r'\"')
void appLog(String msg,[Object? e]) // kDebugMode print only
```

**`lib/widgets/safe_image.dart:10`** — `SafeNetImage` null guard, 20px progress, broken-icon error, `cacheWidth: width*2`; `pbFileUrl(host,collection,id,file)`.

---

## 12. Hardening — Critical Fixes

- **Init race:** `lib/main.dart:19` sync fallbacks
- **Parsing:** `lib/models/*:35` coercion + typo fallback `lib/models/knowPersonClass.dart:49`
- **Empty-list:** `lib/screens/home_sceen.dart:98` `Obx+isEmpty` guard, `lib/utils/consts.dart:42` `Get.isRegistered+isEmpty+null` guards, `lib/utils/controller.dart:452` defaults `??`
- **Unsafe `!`:** `lib/utils/controller.dart:53` `record==null` guard, `lib/utils/controller.dart:318` `asString+_isGoodPlate`, `lib/screens/loginScreen.dart:19` `_decodePassword` helper, `lib/screens/camera_screen.dart:200` `??''/false`, `lib/screens/person_screen.dart:55` etc. — 30+ removed
- **Async/timeout:** all `fetch*` `timeout 15-30s` `lib/utils/controller.dart:92`, `http.post timeout 8s` `lib/utils/consts.dart:42`, `getFullList pbEscape+timeout` `lib/screens/reportscreen.dart:312`, backup `encodeComponent` `lib/utils/consts.dart:205`
- **Disposal:** `_unsub` stored `lib/utils/controller.dart:40` `.then(onError)`, awaited `cancel/close`, all controllers dispose `TextEditingController`s `lib/utils/controller.dart:178`

---

## 13. Hardening — Architecture / State

Keep GetX. Correct usage: `GetBuilder+.value` → `Obx` `lib/screens/reportscreen.dart:58`, `Obx` in `add_or_edit_*` dropdowns `lib/widgets/add_or_edit_person.dart:155`, `ListenableBuilder+Obx` `lib/widgets/plate_picked.dart:16`. Central `tabsFor/pbFileUrlOf/videoFeedUrl` `lib/utils/consts.dart:23`. Model parsing centralized.

---

## 14. Hardening — Network / Realtime Reliability

All screens now `isLoading/isLoadingMore/loadError/searchError`. `databaseController:426` `_loadedIds` dedup, cap 200. `fetchCountData:363` reset-then-recount + `seenToday` dedup. `startDiscovery:128` awaited cancel, `jsonDecode` per line guarded. Timeouts everywhere prevent infinite spinners.

---

## 15. Hardening — Live Dashboard & Video

**Over-rebuild:** `lib/widgets/video_box.dart:7` `_CameraTile` per camera, `ValueKey(streamUrl)+RepaintBoundary`, 300ms, 2 tiles rebuild.

**IndexedStack leak:** `lib/screens/main_screen.dart:72` → `IndexedStack` preserved state but kept feeds alive offstage. Fixed `lib/utils/controller.dart:197` `_urls/_paused` + `pauseAll()`/`resumeAll()`/`updateUrl()` + `lib/screens/main_screen.dart:28` `ever(navitaionIndex)` worker + `lib/widgets/CemraFeed.dart:23` stable `viewId` + `didUpdateWidget` via `updateUrl`.

---

## 16. Hardening — Lists / Images / Forms

- `lib/widgets/data_base_entries.dart:11` single Column+ListView, pre-filter `isEntryVisible`, `SafeNetImage`, `splitPlateSafe`, delete by captured `id`, spinner
- `lib/screens/home_sceen.dart:34` `LayoutBuilder` narrow wrap, `mainAxisSize.min`
- Tables horizontal scroll `lib/screens/camera_screen.dart:77`, `SliverList` `lib/screens/person_screen.dart:26`
- `reportscreen:244` `isEntryVisible` + hero `id??index`, PDF null-safe
- `lib/screens/general_setting.dart:25` `tryParse` + guards
- `add_or_edit_camera:192` validation, status-code, RTSP split guarded, timeout, `maybeOf?.`, `mounted`, dropdown normalized
- `licance_searcher`/`plate_picked`/`person`/`user` similarly hardened — see §9 latest.

---

## 17. Regression Fixes (Your Bug Reports)

### `licance_searcher.dart:26` — `setState() or markNeedsBuild() called during build`
- **Cause:** `lib/widgets/licance_searcher.dart:24` `initState` `clear()` on shared `TextEditingController`s synchronously → `notifyListeners` → `lib/widgets/plate_picked.dart:19` `ListenableBuilder(mode: merge firstTwoDigit/threeDigit/lastTwoDigit)._handleChange.setState` during mounting of `showAdaptiveDialog` build. Rule `framework.dart:5373` forbids.
- **Fix `lib/widgets/licance_searcher.dart:22`:** 1) `super.initState()` first, 2) defer to `WidgetsBinding.instance.addPostFrameCallback`, 3) `if(!mounted) return`, 4) `if(text.isNotEmpty) clear()` to avoid notify at all. Also fixed `lib/widgets/licance_searcher.dart:90` `"${rcontroller.engishalphabet}"` → `.value` + `_submit()` extraction. Explained `State.mounted` `true` after `mount` before `dispose`; any `async`/`post-frame`/`await` must check `if(!mounted) return` before `context`/`setState`.

### Reportscreen add `ریست` next to `ذخیره`
- Added `ElevatedButton "ریست"` `lib/screens/reportscreen.dart:243` → `rcontroller.inilazed():266` (clears plate/date/time/flags/results/errors) + `update()`, safe from `onPressed` outside build.

### Tab change doesn't disconnect from engine
- **Cause:** see §15 `IndexedStack` keeps `HomeSceen` mounted, `CemraFeed.dispose→disconnect` never fires, MJPEG `src` keeps fetching.
- **Fix:** `pauseAll` blanks `src` (aborts) on leave, `resumeAll` restores on return via `ever` worker `lib/screens/main_screen.dart:28`.

### `picked!/t!` and `int.parse`
- `if(picked==null) return; if(!context.mounted) return;` `lib/screens/reportscreen.dart:97,120`, `if(t==null) return` `lib/screens/reportscreen.dart:154`, `int.tryParse` snackbar `lib/screens/general_setting.dart:25`.

---

## 18. File Change Log (Hardening)

| File | Summary |
|---|---|
| `lib/utils/safe.dart` | NEW |
| `lib/widgets/safe_image.dart` | NEW |
| `lib/main.dart:19` | Sync onInit, null-host guard |
| `lib/models/*` | Safe coercion + typo fallback |
| `lib/utils/consts.dart:23` | tabsFor/pbFileUrlOf/videoFeedUrl, guards/timeouts/dedup |
| `lib/utils/controller.dart:22` | Timeouts, try/catch, unsubscribe, dedup, pause/resume, dispose |
| `lib/screens/home_sceen.dart:34` | LayoutBuilder, guard, split Obx, div-zero |
| `lib/screens/main_screen.dart:11` | IndexedStack, ever pause/resume |
| `lib/screens/loginScreen.dart:19` | decode helper, mounted, offAll, lock |
| `lib/screens/reportscreen.dart:58` | Obx fix, guards, lock, ریست, pbEscape, hero |
| `lib/screens/details_screen.dart:1` | SafeNetImage, hero, guards |
| `lib/screens/camera_screen.dart:77` | Safe decode, delete-by-id, h-scroll |
| `lib/screens/person_screen.dart:55` | Null fallbacks, safe convert |
| `lib/screens/user_box.dart:10` | Safe decode, delete guard |
| `lib/screens/setting_screen.dart:17` | maybeOf?.size |
| `lib/screens/general_setting.dart:25` | tryParse |
| `lib/widgets/video_box.dart:7` | _CameraTile, ValueKey |
| `lib/widgets/CemraFeed.dart:8` | Stable viewId, kIsWeb, updateUrl |
| `lib/widgets/data_base_entries.dart:11` | Layout, pre-filter, SafeNetImage, splitPlateSafe |
| `lib/widgets/*` | extended_table, amar_dialog, lisancepage, arvandpelak, licance_searcher, plate_picked, add_or_edit_* — guards |

`git diff --stat HEAD` ≈ 30 files +2135/-1180.

---

## 19. Verification Checklist

- `dart analyze lib` → `No issues found`
- Nav: every tab (مدیر 5 / ناظر 3), rapid switch, IndexedStack state, back-button, dialogs
- API: success, offline/timeout (error not spinner), empty list, invalid JSON (coercion)
- ANPR: new/repeated/100+ (cap 200 dedup), missing imgpath (placeholder), short plate (no RangeError), live on/off Home (pause/resume)
- Conn: backend offline → error, back online → fetch, WS reconnect no duplicate
- UI: narrow wrap, large row, long plate, Persian, 1400px h-scroll
- Forms: picker cancel, duplicate lock, maybeOf?. if popped
- `flutter test` not runnable — web via `package:web/dart:js_interop` (pre-existing)

---

## 20. Future Recommendations

- **Auth:** `base64` → `pb.authWithPassword` + `authStore`
- **Paging:** keep server filter (`eDate/eTime/plateNum` done), page `fetchCountData`
- **Cache:** `cached_network_image` disk cache if many thumbs
- **Config:** move `8090`, `/video_feed`, `1385-1499`, `30`, `75w` to `consts` constants
- **Dedup:** extract `add_or_edit_person` mapper duplicated

---

## 21. Appendix — Commands

```bash
dart analyze lib
# web only — flutter test fails on dart:js_interop, expected
# Manual: open every screen, toggle tabs fast, backend on/off, picker cancel, 100+ plates
```

*Preserved: colors, layout, navigation, PocketBase collections, http/SSE/MJPEG protocols. Analyzer clean.*
