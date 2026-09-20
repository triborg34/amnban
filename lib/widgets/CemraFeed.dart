import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/safe.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:ui_web' as ui;

class CameraFeed extends StatefulWidget {
  final String streamUrl;
  final VoidCallback? onError; // Callback when stream fails
  final VoidCallback? onLoad;

  const CameraFeed({super.key, required this.streamUrl,this.onError,this.onLoad});

  @override
  State<CameraFeed> createState() => _CameraFeedState();
}

class _CameraFeedState extends State<CameraFeed> {
  final videoFeedController controller = Get.find();
  // Stable per-URL id: the old timestamp id created a new platform view on
  // every rebuild (leaking factories + reconnecting MJPEG each time).
  late final String viewId =
      'camera-feed-${widget.streamUrl.hashCode}';

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;
    try {
      controller.connect(widget.streamUrl, viewId);
      // Registering the same viewType twice throws — ignore on re-mount
      // since the element is already cached in the controller.
      try {
        // ignore: undefined_prefixed_name
        ui.platformViewRegistry.registerViewFactory(
          viewId,
          (int viewId) =>
              controller.getElement(this.viewId) ??
              (throw StateError('missing camera element')),
        );
      } catch (e) {
        // Already registered from a previous mount — reuse it.
        appLog('camera factory reuse', e);
      }
    } catch (e) {
      appLog('camera connect failed', e);
      widget.onError?.call();
    }
  }

  @override
  void didUpdateWidget(covariant CameraFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streamUrl != widget.streamUrl) {
      try {
        // Keep the same viewId / platform-view; just swap the underlying
        // image source (honours the controller's paused state).
        final el = controller.getElement(viewId);
        if (el != null) {
          controller.updateUrl(viewId, widget.streamUrl);
        } else {
          controller.disconnect(viewId);
          controller.connect(widget.streamUrl, viewId);
        }
      } catch (e) {
        appLog('camera reconnect failed', e);
      }
    }
  }

  @override
  void dispose() {
    // NOTE: do not disconnect here when the tile is only being resized —
    // the ValueKey above keeps this State alive across selection changes,
    // so dispose only runs when the camera is truly removed.
    try {
      controller.disconnect(viewId);
    } catch (_) {}
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Icon(Icons.videocam_off, color: Colors.white38),
        ),
      );
    }
    if (widget.streamUrl.isEmpty || widget.streamUrl.endsWith('?source=')) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white10,
          borderRadius: BorderRadius.circular(15),
        ),
        child: const Center(
          child: Text('No Stream', style: TextStyle(color: Colors.white38)),
        ),
      );
    }
    return SizedBox(
      child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: HtmlElementView(viewType: viewId)),
    );
  }
}
