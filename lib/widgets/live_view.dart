import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:persian_number_utility/persian_number_utility.dart';

import '../models/cameraClass.dart';
import '../models/databaseEntry.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../utils/consts.dart';
import '../utils/controller.dart';
import '../utils/dashboard_stats.dart';
import '../utils/stream.dart';
import 'app_card.dart';
import 'iran_plate.dart';
import 'status_chip.dart';
import 'CemraFeed.dart';

/// LIVE VIEW section of the main page.
///
/// Shows the selected camera as a large 16:9 frame with a pulsing LIVE badge,
/// the camera label and a timestamp overlay, the most recent plate detected
/// by that camera and a horizontal strip of the other cameras.
class LiveViewSection extends StatefulWidget {
  const LiveViewSection({super.key});

  @override
  State<LiveViewSection> createState() => _LiveViewSectionState();
}

class _LiveViewSectionState extends State<LiveViewSection> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final ccontroller = Get.find<cameraController>();
    final dcontroller = Get.find<databaseController>();
    final kcontroller = Get.find<knowPersonController>();

    return Obx(() {
      final cameras = ccontroller.cameras;
      if (cameras.isEmpty) {
        return const BentoCard(
          child: AppEmptyState(
            message: 'دوربینی ثبت نشده است',
            icon: Icons.videocam_off_outlined,
          ),
        );
      }

      if (_selected >= cameras.length) _selected = 0;
      final camera = cameras[_selected];
      final latest = DashboardStats.latestForCamera(
        dcontroller.entries,
        camera.path,
      );

      return BentoCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              title: 'نمای زنده',
              subtitle: 'آخرین تصویر دریافتی از دوربین‌ها',
              icon: Icons.sensors_outlined,
              trailing: _LiveBadge(),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 860;
                final frame = _LiveFrame(
                  camera: camera,
                  index: _selected,
                  latest: latest,
                );

                final strip = _CameraStrip(
                  cameras: cameras,
                  selected: _selected,
                  onSelect: (index) => setState(() => _selected = index),
                );

                if (!wide) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      frame,
                      const SizedBox(height: 12),
                      strip,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: frame),
                    const SizedBox(width: 12),
                    Expanded(flex: 1, child: strip),
                  ],
                );
              },
            ),
            const SizedBox(height: 12),
            const GradientDivider(height: 1.2),
            const SizedBox(height: 12),
            _latestPlate(latest, kcontroller),
          ],
        ),
      );
    });
  }

  Widget _latestPlate(
      databaseClass? latest, knowPersonController kcontroller) {
    if (latest == null) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: const Text(
          'هنوز ترددی برای این دوربین ثبت نشده است',
          style: TextStyle(fontSize: 11.5, color: AppColors.textMuted),
        ),
      );
    }

    final status = statusForEntry(latest, kcontroller);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text(
            'آخرین تردد',
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: EntryPlate(entry: latest, height: 38),
          ),
          const SizedBox(width: 12),
          StatusChip(status: status, dense: true),
          const Spacer(),
          Text(
            (latest.eTime ?? '-').toString().toPersianDigit(),
            style: AppTheme.numeric(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// The large 16:9 frame.
class _LiveFrame extends StatelessWidget {
  const _LiveFrame({
    required this.camera,
    required this.index,
    required this.latest,
  });

  final CameraClass camera;
  final int index;
  final databaseClass? latest;

  @override
  Widget build(BuildContext context) {
    final hasStream = (camera.rtspUrl ?? '').isNotEmpty;
    final streamUrl = cameraStreamUrl(index, camera);

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.surfaceHigh),
            if (hasStream)
              CameraFeed(key: ValueKey(streamUrl), streamUrl: streamUrl)
            else
              _LastDetectionImage(latest: latest),
            // Top row: camera label + LIVE badge.
            PositionedDirectional(
              top: 10,
              start: 10,
              child: _CameraLabel(camera: camera),
            ),
            const PositionedDirectional(
              top: 10,
              end: 10,
              child: _LiveBadge(),
            ),
            // Bottom: timestamp overlay.
            const PositionedDirectional(
              bottom: 10,
              start: 10,
              child: _ClockOverlay(),
            ),
            if (!hasStream)
              const PositionedDirectional(
                bottom: 10,
                end: 10,
                child: _DetectionBadge(),
              ),
          ],
        ),
      ),
    );
  }
}

/// Fallback frame when a camera has no live stream.
class _LastDetectionImage extends StatelessWidget {
  const _LastDetectionImage({required this.latest});

  final databaseClass? latest;

  @override
  Widget build(BuildContext context) {
    final url = latest == null
        ? ''
        : pbFileUrlOf('database', latest!.id, latest!.scrnPath);

    if (url.isEmpty) {
      return const Center(
        child: Icon(Icons.videocam_off_outlined,
            size: 34, color: AppColors.textMuted),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined,
            size: 30, color: AppColors.textMuted),
      ),
    );
  }
}

/// Entry / exit label with the camera IP.
class _CameraLabel extends StatelessWidget {
  const _CameraLabel({required this.camera});

  final CameraClass camera;

  @override
  Widget build(BuildContext context) {
    final isEntry = (camera.gate ?? 'entre') == 'entre';
    final color = isEntry ? AppColors.primary : AppColors.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            isEntry ? 'ورود' : 'خروج',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            camera.ip ?? '-',
            style: const TextStyle(
              fontFamily: 'arial',
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pulsing red LIVE badge.
class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: Tween<double>(begin: 0.35, end: 1).animate(_controller),
            child: Container(
              width: 7,
              height: 7,
              decoration: const BoxDecoration(
                color: AppColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'LIVE',
            style: TextStyle(
              fontFamily: 'arial',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// "آخرین تشخیص" badge shown when there is no live stream.
class _DetectionBadge extends StatelessWidget {
  const _DetectionBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
      ),
      child: const Text(
        'آخرین تشخیص',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Live timestamp overlay.
class _ClockOverlay extends StatefulWidget {
  const _ClockOverlay();

  @override
  State<_ClockOverlay> createState() => _ClockOverlayState();
}

class _ClockOverlayState extends State<_ClockOverlay> {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(7),
      ),
      child: Text(
        '$hh:$mm:$ss',
        style: const TextStyle(
          fontFamily: 'arial',
          fontSize: 11,
          color: Colors.white,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
    );
  }
}

/// Horizontal strip of the other cameras.
class _CameraStrip extends StatelessWidget {
  const _CameraStrip({
    required this.cameras,
    required this.selected,
    required this.onSelect,
  });

  final List<CameraClass> cameras;
  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 92,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cameras.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final camera = cameras[index];
          final isEntry = (camera.gate ?? 'entre') == 'entre';
          final active = index == selected;

          return InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onSelect(index),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 132,
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.primary.withValues(alpha: 0.10)
                    : AppColors.surfaceHigh,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.55)
                      : AppColors.border,
                ),
                boxShadow: [
                  if (active)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.22),
                      blurRadius: 16,
                      spreadRadius: -5,
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isEntry
                              ? AppColors.primary
                              : AppColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isEntry ? 'ورود' : 'خروج',
                        style: const TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    camera.name?.trim().isNotEmpty == true
                        ? camera.name!.trim()
                        : 'دوربین ${index + 1}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    camera.ip ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTheme.numeric(
                      fontSize: 10,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
