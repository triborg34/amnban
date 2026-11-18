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
  static final Set<String> _registered = <String>{};

  @override
  void initState() {
    super.initState();
    if (!kIsWeb) return;
    if (!_registered.contains(viewId)) {
      ui.platformViewRegistry.registerViewFactory(viewId, (int _) {
        // Never throws: connect() always returns an element.
        return controller.connect(widget.streamUrl, viewId);
      });
      _registered.add(viewId);
    }
    try {
      controller.connect(widget.streamUrl, viewId);
    } catch (e) {
      appLog('camera connect failed', e);
      widget.onError?.call();
    }
  }


  @override
  void didUpdateWidget(covariant CameraFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (kIsWeb && oldWidget.streamUrl != widget.streamUrl) {
      controller.updateUrl(viewId, widget.streamUrl);
    }
  }

  @override
  // void dispose() {
  //   // NOTE: do not disconnect here when the tile is only being resized —
  //   // the ValueKey above keeps this State alive across selection changes,
  //   // so dispose only runs when the camera is truly removed.
  //   try {
  //     controller.disconnect(viewId);
  //   } catch (_) {}
  //   super.dispose();
  // }

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
