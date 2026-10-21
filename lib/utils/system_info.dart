import 'system_info_io.dart' if (dart.library.js_interop) 'system_info_web.dart'
    as impl;
import 'system_usage.dart';

export 'system_usage.dart';

/// Thin facade over the platform specific system-info helpers.
///
/// The values are only used for the small "system information" / "usage"
/// cards at the bottom of the dashboard — no controller or networking is
/// involved.
class SystemInfo {
  const SystemInfo._();

  /// Moment the dashboard was loaded — used for the "uptime" caption.
  static final DateTime startedAt = DateTime.now();

  /// How long the dashboard has been running.
  static Duration get uptime => DateTime.now().difference(startedAt);

  /// Number of logical CPU cores.
  static int get cpuCoreCount => impl.cpuCoreCount;

  /// CPU model (best effort).
  static String get cpuModel => impl.cpuModel;

  /// Platform / operating system name.
  static String get platformName => impl.platformName;

  /// Storage used by the origin versus the available quota.
  static Future<SystemUsage?> storageUsage() => impl.storageUsage();

  /// Heap usage versus the heap limit.
  static SystemUsage? memoryUsage() => impl.memoryUsage();
}
