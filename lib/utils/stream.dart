import '../models/cameraClass.dart';
import 'consts.dart';

/// MJPEG feed URL of a camera.
///
/// Mirrors the URL scheme the app has always used: the feed index is the
/// position of the camera in the list (`/rt1`, `/rt2`, ...) and the source is
/// the camera RTSP URL.
String cameraStreamUrl(int index, CameraClass camera) {
  final source = (camera.rtspUrl ?? '').replaceAll('&', '%26');
  final feed = role == 'ناظر' ? 'rtsp_feed' : 'video_feed';
  return 'http://$url:$port/$feed/rt${index + 1}?source=$source';
}
