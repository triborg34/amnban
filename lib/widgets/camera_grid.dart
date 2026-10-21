import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/cameraClass.dart';
import '../theme/app_colors.dart';
import '../utils/consts.dart';
import '../utils/controller.dart';
import '../utils/dashboard_stats.dart';
import 'app_card.dart';
import 'iran_plate.dart';
import 'status_chip.dart';
import 'CemraFeed.dart';

/// Dashboard card for a single camera.
///
/// Shows the live feed and the latest detection of that camera in a compact
/// table (time / status / plate).
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
    return AppCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _header(),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'آخرین تردد',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 8),
          _preview(),
          const SizedBox(height: 10),
          _footer(),
        ],
      ),
    );
  }

  Widget _header() {
    final label = camera.name?.trim();
    final title = (label == null || label.isEmpty) ? 'دوربین' : label;
    return Row(
      children: [
        Expanded(
          child: Align(
            alignment: AlignmentDirectional.centerStart,
            child: InfoChip(
              label: '${title}  •  ${camera.ip ?? '-'}',
              icon: Icons.videocam_outlined,
              dense: true,
            ),
          ),
        ),
        const SizedBox(width: 6),
        InkWell(
          onTap: () => onExpand?.call(camera),
          borderRadius: BorderRadius.circular(6),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.fullscreen_outlined,
              size: 17,
              color: AppColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }

  Widget _preview() {
    final streamUrl =
        'http://$url:$port/${role == 'ناظر' ? 'rtsp_feed' : 'video_feed'}/rt${index + 1}?source=${camera.rtspUrl?.replaceAll("&", "%26") ?? ''}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 16:9 preview that scales with the card width.
          final previewHeight =
              (constraints.maxWidth * 9 / 16).clamp(140.0, 260.0).toDouble();
          return Container(
            height: previewHeight,
            color: const Color(0xFF10201F),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CameraFeed(key: ValueKey(streamUrl), streamUrl: streamUrl),
                const PositionedDirectional(
                  start: 8,
                  bottom: 8,
                  child: _LiveClock(),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _footer() {
    // The footer tracks the detection list on its own so the (heavy) live
    // feed is never rebuilt when a new detection arrives.
    return Obx(() {
      final dcontroller = Get.find<databaseController>();
      final latest =
          DashboardStats.latestForCamera(dcontroller.entries, camera.path);
      final status = latest == null
          ? DetectionStatus.unrecognized
          : statusForEntry(latest, kcontroller);

      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: const BoxDecoration(
                color: AppColors.surfaceMuted,
                border: Border(bottom: BorderSide(color: AppColors.border)),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'ساعت',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'وضعیت تردد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'پلاک',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      latest?.eTime ?? '-',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: StatusChip(
                        status: status,
                        dense: true,
                        label: latest == null ? 'بدون تردد' : null,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: latest == null
                          ? const Text(
                              '-',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            )
                          : FittedBox(
                              fit: BoxFit.scaleDown,
                              child: EntryPlate(
                                entry: latest,
                                height: 32,
                                showIranLabel: false,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}

/// Small clock rendered on top of the live feed.
///
/// It is a separate widget so the (heavy) camera feed is never rebuilt when
/// the time ticks.
class _LiveClock extends StatefulWidget {
  const _LiveClock();

  @override
  State<_LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<_LiveClock> {
  Timer? _timer;
  late DateTime _now;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hh = _now.hour.toString().padLeft(2, '0');
    final mm = _now.minute.toString().padLeft(2, '0');
    final ss = _now.second.toString().padLeft(2, '0');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$hh:$mm:$ss',
        style: const TextStyle(
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Responsive grid of [CameraGridCard]s (3 columns on desktop, 1–2 on
/// phones).
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
      return const AppCard(
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
