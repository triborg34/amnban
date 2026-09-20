import 'package:flutter/foundation.dart';

/// Central place for safe parsing + lightweight logging.
///
/// All `fromJson` parsing goes through these helpers so an unexpected
/// int/double/string from PocketBase can never crash the app with a
/// `type 'int' is not a subtype of type 'double?'` style error.
String? asString(dynamic v) => v == null ? null : v.toString();

int? asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is double) return v.toInt();
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

double? asDouble(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

bool? asBool(dynamic v) {
  if (v == null) return null;
  if (v is bool) return v;
  final s = v.toString().toLowerCase();
  if (s == 'true' || s == '1') return true;
  if (s == 'false' || s == '0') return false;
  return null;
}

/// PocketBase filter strings are built with string interpolation in several
/// places. A `"` inside a plate number would break the query (and could be
/// used for filter injection), so always escape through here.
String pbEscape(String input) =>
    input.replaceAll(r'\', r'\\').replaceAll('"', r'\"');

/// Best-effort debug logging. Deliberately cheap and never called in the
/// high-frequency live-detection path more than once per failure.
void appLog(String message, [Object? error]) {
  if (kDebugMode) {
    // ignore: avoid_print
    print('[amnban] $message${error == null ? '' : ' — $error'}');
  }
}
