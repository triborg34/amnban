import 'package:amnban/screens/details_screen.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/controller.dart';
import 'package:amnban/utils/dashboard_stats.dart';
import 'package:amnban/utils/safe.dart';
import 'package:amnban/widgets/app_card.dart';
import 'package:amnban/widgets/camera_grid.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Live camera grid shown on the dashboard.
///
/// The widget keeps its original name / constructor so the existing call
/// sites keep working — only the presentation changed (responsive grid of
/// camera cards instead of the old fixed-size tiles).
class VideoBox extends StatelessWidget {
  const VideoBox({
    super.key,
    required this.mController,
  });

  final mainPageConroller mController;

  @override
  Widget build(BuildContext context) {
    final ccontroller = Get.find<cameraController>();
    final kcontroller = Get.find<knowPersonController>();
    final dcontroller = Get.find<databaseController>();

    return Obx(() {
      if (ccontroller.cameras.isEmpty) {
        return const AppCard(
          child: AppEmptyState(
            message: 'دوربینی ثبت نشده است',
            icon: Icons.videocam_off_outlined,
          ),
        );
      }

      return CameraGrid(
        cameras: ccontroller.cameras,
        kcontroller: kcontroller,
        onExpand: (camera) => _openLatest(context, camera, dcontroller, kcontroller),
      );
    });
  }

  /// Opens the detail view of the latest detection of the given camera.
  Future<void> _openLatest(
    BuildContext context,
    dynamic camera,
    databaseController dcontroller,
    knowPersonController kcontroller,
  ) async {
    final latest =
        DashboardStats.latestForCamera(dcontroller.entries, camera.path);
    if (latest == null) {
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('برای این دوربین ترددی ثبت نشده است')),
      );
      return;
    }

    final plate = latest.plateNum ?? '';
    if (plate.isEmpty) return;

    try {
      final record = await pb
          .collection('database')
          .getFullList(filter: 'plateNum="${pbEscape(plate)}"')
          .timeout(const Duration(seconds: 15));

      if (!context.mounted) return;
      Get.to(() => Detailedscreen(
            rec: record,
            kcontroller: kcontroller,
            selectedModel: latest,
            index: 0,
          ));
    } catch (e) {
      appLog('camera detail fetch failed', e);
      if (!context.mounted) return;
      ScaffoldMessenger.maybeOf(context)?.showSnackBar(
        const SnackBar(content: Text('خطا در دریافت اطلاعات تردد')),
      );
    }
  }
}
