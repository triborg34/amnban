import 'dart:convert';

import 'package:http/http.dart' as http;

import 'consts.dart';
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

  /// Reads RAM and disk usage percentages from the backend.
  static Future<Map<String, double>?> backendUsage() async {
    try {
      final response = await http
          .get(Uri.parse('http://$url:$port/system/utils'))
          .timeout(const Duration(seconds: 8));
      if (response.statusCode != 200) return null;
      final decoded = jsonDecode(response.body);
      if (decoded is! Map) return null;
      final ram = _number(decoded['ram']);
      final disk = _number(decoded['disk']);
      if (ram == null || disk == null) return null;
      return {
        'ram': ram.clamp(0, 100).toDouble(),
        'disk': disk.clamp(0, 100).toDouble()
      };
    } catch (_) {
      return null;
    }
  }

  static double? _number(Object? value) {
    final parsed = value is num ? value.toDouble() : double.tryParse('$value');
    return parsed != null && parsed.isFinite ? parsed : null;
  }
}
