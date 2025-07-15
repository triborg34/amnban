
import 'dart:html' as html;
import 'dart:js' as js;

import 'package:flutter/foundation.dart';


 

// Method 3: Get network connection info (limited)
Map<String, dynamic> getNetworkInfo() {
  if (!kIsWeb) return {};

  final navigator = html.window.navigator;
  final connection = js.context['navigator']['connection'];

  return {
    'userAgent': navigator.userAgent,
    'platform': navigator.platform,
    'language': navigator.language,
    'onLine': navigator.onLine,
    'connectionType': connection?['effectiveType'] ?? 'unknown',
    'hostname': html.window.location.hostname,
    'port': html.window.location.port,
    'protocol': html.window.location.protocol,
  };
}
