import '../models/databaseEntry.dart';
import '../utils/controller.dart';

/// Gate direction of a camera.
///
/// The engine stores the camera `gate` as `entre` (entry) or anything else
/// (exit) — see `lib/widgets/CemraFeed.dart` / `camera_screen.dart`.
const String gateEntry = 'entre';

/// Traffic of a single day, split by direction and access status.
class DayTraffic {
  DayTraffic({
    required this.date,
    required this.entries,
    required this.exits,
    required this.entriesAllowed,
    required this.entriesDenied,
    required this.entriesUnknown,
    required this.exitsAllowed,
    required this.exitsDenied,
    required this.exitsUnknown,
  });

  final DateTime date;
  final int entries;
  final int exits;
  final int entriesAllowed;
  final int entriesDenied;
  final int entriesUnknown;
  final int exitsAllowed;
  final int exitsDenied;
  final int exitsUnknown;

  int get total => entries + exits;
}

/// Presentation-only derivations of the traffic statistics.
///
/// Everything here is computed from data the GetX controllers already hold
/// (`databaseController.entries`, `cameraController.cameras`,
/// `knowPersonController.knowPerson`) — no controller, PocketBase call or
/// polling behaviour is touched.
class DashboardStats {
  const DashboardStats._();

  /// ISO (`YYYY-MM-DD`) representation of [date].
  static String isoOf(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return "${date.year}-$m-$d";
  }

  /// The gate of the camera that produced a detection, or `null` when the
  /// camera is unknown (in that case the record is treated as an entry).
  static String? gateFor(cameraController cameras, String? rtPath) {
    if (rtPath == null || rtPath.isEmpty) return null;
    for (final c in cameras.cameras) {
      if (c.path == rtPath) return c.gate ?? gateEntry;
    }
    return null;
  }

  /// Newest detection of a given camera path (`/rt1`, `/rt2`, ...).
  static databaseClass? latestForCamera(
    List<databaseClass> entries,
    String? rtPath,
  ) {
    if (rtPath == null || rtPath.isEmpty) return null;
    for (final e in entries) {
      if (e.rtpath == rtPath) return e;
    }
    return null;
  }

  /// Traffic of the last [days] days (oldest first).
  static List<DayTraffic> lastDays({
    required List<databaseClass> entries,
    required cameraController cameras,
    required knowPersonController persons,
    int days = 7,
  }) {
    final today = DateTime.now();
    final result = <DayTraffic>[];

    for (var i = days - 1; i >= 0; i--) {
      final day = DateTime(today.year, today.month, today.day - i);
      final iso = isoOf(day);

      var entriesCount = 0;
      var exitsCount = 0;
      var eAllowed = 0;
      var eDenied = 0;
      var eUnknown = 0;
      var xAllowed = 0;
      var xDenied = 0;
      var xUnknown = 0;

      for (final e in entries) {
        if (e.eDate != iso) continue;
        final gate = gateFor(cameras, e.rtpath);
        final isExit = gate != null && gate != gateEntry;
        final person = persons.personFor(e.plateNum);

        if (isExit) {
          exitsCount++;
          if (person == null) {
            xUnknown++;
          } else if (person.role == 'مجاز') {
            xAllowed++;
          } else {
            xDenied++;
          }
        } else {
          entriesCount++;
          if (person == null) {
            eUnknown++;
          } else if (person.role == 'مجاز') {
            eAllowed++;
          } else {
            eDenied++;
          }
        }
      }

      result.add(DayTraffic(
        date: day,
        entries: entriesCount,
        exits: exitsCount,
        entriesAllowed: eAllowed,
        entriesDenied: eDenied,
        entriesUnknown: eUnknown,
        exitsAllowed: xAllowed,
        exitsDenied: xDenied,
        exitsUnknown: xUnknown,
      ));
    }

    return result;
  }

  /// Statistics of today only.
  static DayTraffic today({
    required List<databaseClass> entries,
    required cameraController cameras,
    required knowPersonController persons,
  }) {
    final all = lastDays(
      entries: entries,
      cameras: cameras,
      persons: persons,
      days: 1,
    );
    return all.first;
  }

  /// Cars currently inside the lot (entries − exits of today).
  static int presentInParking(DayTraffic today) {
    final value = today.entries - today.exits;
    return value < 0 ? 0 : value;
  }
}
