/// Native (dart:io) implementation of the small system-info helper.
///
/// Only compiled for non-web targets — the web build picks
/// `system_info_web.dart` through the conditional import in
/// `system_info.dart`.
library;

import 'dart:io';

import 'system_usage.dart';

/// Number of logical CPU cores of the host machine.
int get cpuCoreCount {
  try {
    return Platform.numberOfProcessors;
  } catch (_) {
    return 1;
  }
}

/// Best-effort CPU model. The Dart VM does not expose it, so we report the
/// operating system instead of an empty value.
String get cpuModel {
  try {
    return Platform.operatingSystemVersion;
  } catch (_) {
    return 'نامشخص';
  }
}

/// Platform name shown next to the CPU model.
String get platformName {
  try {
    return Platform.operatingSystem;
  } catch (_) {
    return 'Native';
  }
}

/// Native builds have no portable storage/quota API — the panel falls back
/// to the placeholder values.
Future<SystemUsage?> storageUsage() async => null;

/// Native builds have no portable heap API — the panel falls back to the
/// placeholder values.
SystemUsage? memoryUsage() => null;
