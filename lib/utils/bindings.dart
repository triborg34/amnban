import 'package:amnban/utils/controller.dart';
import 'package:get/get.dart';

class MyBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(mainPageConroller());
    Get.put(videoFeedController());
    Get.put(cameraController());
    Get.put(knowPersonController());
    Get.put(databaseController());
    Get.put(reportController());
    Get.put(settingController());
    Get.put(userController());
  }
}