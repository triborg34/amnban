import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/cameraClass.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/controller.dart';
import '../utils/dashboard_stats.dart';
import '../utils/stream.dart';
import 'app_card.dart';
import 'iran_plate.dart';
import 'status_chip.dart';
import 'CemraFeed.dart';

/// Card for a single camera — live frame, label and the latest detection.
class CameraGridCard extends StatelessWidget {
  const CameraGridCard({
    super.key,
    required this.camera,
    required this.index,
    required this.kcontroller,
    this.onExpand,
  });

  final CameraClass camera;
  final int index;
  final knowPersonController kcontroller;
  final void Function(CameraClass camera)? onExpand;

  @override
  Widget build(BuildContext context) {
    final isEntry = (camera.gate ?? 'entre') == 'entre';

    return BentoCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: isEntry ? AppColors.primary : AppColors.warning,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  camera.name?.trim().isNotEmpty == true
                      ? camera.name!.trim()
                      : 'دوربین ${index + 1}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => onExpand?.call(camera),
                icon: const Icon(Icons.open_in_full_rounded, size: 16),
                tooltip: 'بزرگنمایی',
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 8),
          _preview(),
          const SizedBox(height: 10),
          _footer(),
        ],
      ),
    );
  }

  Widget _preview() {
    final streamUrl = cameraStreamUrl(index, camera);
    final hasStream = (camera.rtspUrl ?? '').isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.surfaceHigh),
            if (hasStream)
              CameraFeed(key: ValueKey(streamUrl), streamUrl: streamUrl)
            else
              const Center(
                child: Icon(Icons.videocam_off_outlined,
                    size: 26, color: AppColors.textMuted),
              ),
            PositionedDirectional(
              top: 8,
              start: 8,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.62),
                  borderRadius: BorderRadius.circular(7),
                ),
                child: Text(
                  camera.ip ?? '-',
                  style: const TextStyle(
                    fontFamily: 'arial',
                    fontSize: 10.5,
                    color: Colors.white70,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _footer() {
    return Obx(() {
      final dcontroller = Get.find<databaseController>();
      final latest =
          DashboardStats.latestForCamera(dcontroller.entries, camera.path);
      final status = latest == null
          ? DetectionStatus.unrecognized
          : statusForEntry(latest, kcontroller);

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Text(
              latest?.eTime ?? '-',
              style: AppTheme.numeric(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(width: 10),
            StatusChip(
              status: status,
              dense: true,
              label: latest == null ? 'بدون تردد' : null,
            ),
            const Spacer(),
            if (latest == null)
              const Text(
                '-',
                style: TextStyle(fontSize: 11, color: AppColors.textMuted),
              )
            else
              FittedBox(
                fit: BoxFit.scaleDown,
                child: EntryPlate(
                  entry: latest,
                  height: 28,
                  showIranLabel: false,
                ),
              ),
          ],
        ),
      );
    });
  }
}

/// Responsive grid of [CameraGridCard]s.
class CameraGrid extends StatelessWidget {
  const CameraGrid({
    super.key,
    required this.cameras,
    required this.kcontroller,
    this.onExpand,
  });

  final List<CameraClass> cameras;
  final knowPersonController kcontroller;
  final void Function(CameraClass camera)? onExpand;

  @override
  Widget build(BuildContext context) {
    if (cameras.isEmpty) {
      return const BentoCard(
        child: AppEmptyState(
          message: 'دوربینی ثبت نشده است',
          icon: Icons.videocam_off_outlined,
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = width >= 1100
            ? 3
            : width >= 680
                ? 2
                : 1;
        final cardWidth = (width - (columns - 1) * 14) / columns;

        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (int index = 0; index < cameras.length; index++)
              SizedBox(
                width: cardWidth,
                child: CameraGridCard(
                  camera: cameras[index],
                  index: index,
                  kcontroller: kcontroller,
                  onExpand: onExpand,
                ),
              ),
          ],
        );
      },
    );
  }
}
