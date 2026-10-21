/// Web implementation of the small system-info helper.
///
/// Uses the browser APIs that are available on every modern browser:
/// `navigator.hardwareConcurrency` (logical CPU cores),
/// `navigator.userAgent` (best-effort CPU model),
/// `navigator.storage.estimate()` (storage usage) and
/// `performance.memory` (JS heap usage, Chrome / Edge).
library;

import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import 'package:web/web.dart' as web;

import 'system_usage.dart';

@JS('navigator.storage')
external JSObject? get _navigatorStorage;

@JS('performance.memory')
external JSObject? get _performanceMemory;

/// Number of logical CPU cores reported by the browser.
int get cpuCoreCount {
  try {
    final value = web.window.navigator.hardwareConcurrency;
    return value > 0 ? value : 1;
  } catch (_) {
    return 1;
  }
}

/// Best-effort CPU model extracted from the user agent string.
///
/// Browsers do not expose the CPU model directly; when nothing matches we
/// fall back to a neutral label so the panel never shows a raw exception.
String get cpuModel {
  try {
    final ua = web.window.navigator.userAgent;
    final match = RegExp(
      r'(Intel\(R\)?\s?Core\(TM\)?\s?[A-Za-z0-9\- ]+)|(AMD\s[A-Za-z0-9\- ]+)|(Apple\sM[0-9]+)|(Qualcomm\s[A-Za-z0-9\- ]+)',
      caseSensitive: false,
    ).firstMatch(ua);
    if (match != null) {
      return match.group(0)!.trim();
    }
  } catch (_) {
    // fall through
  }
  return 'نامشخص';
}

/// Platform name shown next to the CPU model.
String get platformName {
  try {
    final platform = web.window.navigator.platform;
    if (platform.isNotEmpty) return platform;
  } catch (_) {
    // fall through
  }
  return 'Web';
}

/// Storage used by the origin (cache, IndexedDB, ...) versus the quota.
Future<SystemUsage?> storageUsage() async {
  try {
    final storage = _navigatorStorage;
    if (storage == null) return null;
    final estimate = storage.callMethod<JSObject?>('estimate'.toJS);
    if (estimate == null) return null;
    final usage = estimate.getProperty<JSNumber>('usage'.toJS).toDartDouble;
    final quota = estimate.getProperty<JSNumber>('quota'.toJS).toDartDouble;
    if (quota <= 0) return null;
    return SystemUsage(used: usage, total: quota);
  } catch (_) {
    return null;
  }
}

/// JS heap usage versus the heap limit (Chrome / Edge only).
SystemUsage? memoryUsage() {
  try {
    final memory = _performanceMemory;
    if (memory == null) return null;
    final used =
        memory.getProperty<JSNumber>('usedJSHeapSize'.toJS).toDartDouble;
    final total =
        memory.getProperty<JSNumber>('jsHeapSizeLimit'.toJS).toDartDouble;
    if (total <= 0) return null;
    return SystemUsage(used: used, total: total);
  } catch (_) {
    return null;
  }
}
