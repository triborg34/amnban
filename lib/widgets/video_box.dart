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
    return Obx(() => Get.find<cameraController>().cameras.length == 0
        ? Expanded(
            child: Container(
            height: 450,
            child: Center(
              child: Text(
                "No Camera",
                style: TextStyle(color: Colors.white),
              ),
            ),
            decoration: BoxDecoration(
                border: Border.all(color: purpule),
                borderRadius: BorderRadius.circular(15)),
          ))
        : Expanded(
            child: GestureDetector(
            onTap: () {
              mController.videoIndex.value = (-1);
            },
            child: Container(
              padding: EdgeInsets.all(15),
              child: SingleChildScrollView(
                  child: Wrap(
                spacing: 15,
                alignment: WrapAlignment.start,
                children: [
                  for (int i = 0;
                      i < Get.find<cameraController>().cameras.length;
                      i++)
                    Obx(
                      () => InkWell(
                        onTap: () {
                          mController.videoIndex.value = i;
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 500),
                          margin:
                              EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                          width: mController.videoIndex.value == i ? 500 : 225,
                          height: mController.videoIndex.value == i ? 375 : 100,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(
                                  color: mController.videoIndex.value == i
                                      ? selecetpurpule
                                      : purpule),
                              borderRadius: BorderRadius.circular(10)),
                          child: Stack(
                            children: [
                              role == 'ناظر'
                                  ? CameraFeed(
                                      streamUrl:
                                          'http://${url}:5000/rtsp_feed/rt${i + 1}?source=${Get.find<cameraController>().cameras[i].rtspUrl}')
                                  : CameraFeed(
                                      streamUrl:
                                          'http://${url}:5000/video_feed/rt${i + 1}?source=${Get.find<cameraController>().cameras[i].rtspUrl}'),
                              GestureDetector(
                                onTap: () => mController.videoIndex.value = i,
                                child: Container(
                                  color: Colors.transparent,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              )),
              decoration: BoxDecoration(
                  border: Border.all(color: purpule),
                  borderRadius: BorderRadius.circular(15)),
              height: 450,
            ),
          )));
  }
}
