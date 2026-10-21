import 'package:web/web.dart' as web;

/// Triggers a browser download for the given [url].
///
/// Used by the detail screen to download the camera frame / cropped plate.
void downloadUrl(String url, {String? fileName}) {
  try {
    final anchor = (web.document.createElement('a') as web.HTMLAnchorElement)
      ..href = url
      ..setAttribute('download', fileName ?? 'image.jpg');
    anchor.click();
  } catch (_) {
    // The download helper is a best-effort convenience; never break the
    // screen because of it.
  }
}
