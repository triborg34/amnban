
import 'package:amnban/utils/controller.dart';
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
  late final String viewId;

  @override
  void initState() {
    super.initState();
    viewId = 'camera-feed-${widget.streamUrl.hashCode}-${DateTime.now().millisecondsSinceEpoch}';

    controller.connect(widget.streamUrl, viewId);

    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(
      viewId,
      (int viewId) => controller.getElement(this.viewId)!,
    );
  }

  @override
  void dispose() {
    controller.disconnect(viewId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(

      child: ClipRRect(borderRadius: BorderRadius.circular(15),child: HtmlElementView(viewType: viewId)),
    );
  }
}
