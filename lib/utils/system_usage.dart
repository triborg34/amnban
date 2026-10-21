/// A single "used vs. free" measurement used by the dashboard donuts.
class SystemUsage {
  const SystemUsage({required this.used, required this.total});

  /// Amount currently in use.
  final double used;

  /// Total amount available.
  final double total;

  /// Used fraction in the 0..1 range.
  double get ratio {
    if (total <= 0) return 0;
    final value = used / total;
    return value.clamp(0.0, 1.0);
  }

  /// Free amount.
  double get free => (total - used).clamp(0, double.infinity);
}

/// Human readable byte size, e.g. `۱۲.۴ مگابایت`.
String formatBytes(double bytes, {String Function(String)? convertDigits}) {
  const units = ['بایت', 'کیلوبایت', 'مگابایت', 'گیگابایت', 'ترابایت'];
  var value = bytes;
  var unit = 0;
  while (value >= 1024 && unit < units.length - 1) {
    value /= 1024;
    unit++;
  }
  final text = value >= 100 || unit == 0
      ? value.toStringAsFixed(0)
      : value.toStringAsFixed(1);
  final digits = convertDigits?.call(text) ?? text;
  return '$digits ${units[unit]}';
}
