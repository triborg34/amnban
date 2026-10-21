/// A single "used vs. free" measurement used by the dashboard donuts.
library;

import 'safe_math.dart';

class SystemUsage {
  const SystemUsage({required this.used, required this.total});

  /// Amount currently in use.
  final double used;

  /// Total amount available.
  final double total;

  /// Used fraction in the 0..1 range.
  double get ratio => safeRatio(used, total).clamp(0.0, 1.0);

  /// Free amount.
  double get free {
    if (!total.isFinite) return 0;
    final value = total - used;
    return value.isFinite && value > 0 ? value : 0;
  }
}

/// Human readable byte size, e.g. `۱۲.۴ مگابایت`.
String formatBytes(double bytes, {String Function(String)? convertDigits}) {
  const units = ['بایت', 'کیلوبایت', 'مگابایت', 'گیگابایت', 'ترابایت'];

  if (!bytes.isFinite || bytes <= 0) {
    return 'نامشخص';
  }

  var value = bytes;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
    if (!value.isFinite) return 'نامشخص';
  }
  final text = value >= 100 || unit == 0
      ? safeFixed(value, digits: 0)
      : safeFixed(value, digits: 1);
  final digits = convertDigits?.call(text) ?? text;
  return '$digits ${units[unit]}';
}
