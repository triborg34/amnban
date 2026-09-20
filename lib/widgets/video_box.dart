import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/widgets/CemraFeed.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class VideoBox extends StatelessWidget {
  const VideoBox({
    super.key,
    required this.mController,
  });

  final mainPageConroller mController;

  @override
  Widget build(BuildContext context) {
    final ccontroller = Get.find<cameraController>();
    return Obx(() {
      if (ccontroller.cameras.isEmpty) {
        return Container(
          height: 450,
          decoration: BoxDecoration(
              border: Border.all(color: purpule),
              borderRadius: BorderRadius.circular(15)),
          child: Center(
            child: ccontroller.isLoading.value
                ? const CircularProgressIndicator()
                : Text(
                    ccontroller.error.value.isNotEmpty
                        ? ccontroller.error.value
                        : "No Camera",
                    style: const TextStyle(color: Colors.white),
                  ),
          ),
        );
      }
      return GestureDetector(
        onTap: () {
          mController.videoIndex.value = (-1);
        },
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
              border: Border.all(color: purpule),
              borderRadius: BorderRadius.circular(15)),
          height: 450,
          child: SingleChildScrollView(
              child: Wrap(
            spacing: 15,
            runSpacing: 15,
            alignment: WrapAlignment.start,
            children: [
              for (int i = 0; i < ccontroller.cameras.length; i++)
                _CameraTile(
                  index: i,
                  mController: mController,
                ),
            ],
          )),
        ),
      );
    });
  }
}

/// Own widget per camera so changing the selected index only rebuilds the
/// two affected tiles — previously every CameraFeed was recreated (MJPEG
/// reconnect + flicker) on each selection.
class _CameraTile extends StatelessWidget {
  const _CameraTile({required this.index, required this.mController});

  final int index;
  final mainPageConroller mController;

  @override
  Widget build(BuildContext context) {
    final ccontroller = Get.find<cameraController>();
    return Obx(() {
      final selected = mController.videoIndex.value == index;
      final rtspUrl = index < ccontroller.cameras.length
          ? ccontroller.cameras[index].rtspUrl
          : null;
      final streamUrl =
          'http://$url:$port/${role == 'ناظر' ? 'rtsp_feed' : 'video_feed'}/rt${index + 1}?source=${rtspUrl ?? ''}';
      return InkWell(
        onTap: () {
          mController.videoIndex.value = index;
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: selected ? 500 : 225,
          height: selected ? 375 : 100,
          decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.all(
                  color: selected ? selecetpurpule : purpule),
              borderRadius: BorderRadius.circular(10)),
          // Keyed by URL so selection resizes preserve the underlying
          // platform view instead of reconnecting the stream.
          child: RepaintBoundary(
            child: CameraFeed(
              key: ValueKey(streamUrl),
              streamUrl: streamUrl,
            ),
          ),
        ),
      );
    });
  }
}
