import 'package:web/web.dart' as web;
import 'dart:js_interop';

import 'package:flutter/foundation.dart';

@JS('navigator.connection')
external JSObject? get _connection;

extension type NavigatorConnection._(JSObject _) implements JSObject {
  external String? get effectiveType;
}

Map<String, dynamic> getNetworkInfo() {
  if (!kIsWeb) return {};

  final navigator = web.window.navigator;
  final connection = _connection;

  return {
    'userAgent': navigator.userAgent,
    'platform': navigator.platform,
    'language': navigator.language,
    'onLine': navigator.onLine,
    'connectionType': connection != null
        ? (connection as NavigatorConnection).effectiveType ?? 'unknown'
        : 'unknown',
    'hostname': web.window.location.hostname,
    'port': web.window.location.port,
    'protocol': web.window.location.protocol,
  };
}
