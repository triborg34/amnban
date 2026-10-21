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
import '../utils/detection_meta.dart';
import '../utils/stream.dart';
import 'app_card.dart';
import 'iran_plate.dart';
import 'status_chip.dart';
import 'CemraFeed.dart';

/// LIVE VIEW section of the main page.
///
/// Every registered camera is shown at the same time in a responsive grid
/// (two columns on tablet / desktop, one on phones). Tapping a tile enlarges
/// it to the full row — tapping it again returns it to the grid.
class LiveViewSection extends StatefulWidget {
  const LiveViewSection({super.key});

  @override
  State<LiveViewSection> createState() => _LiveViewSectionState();
}

class _LiveViewSectionState extends State<LiveViewSection> {
  /// Index of the enlarged camera (`null` = none).
  int? _expanded;

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

      final expanded = (_expanded != null && _expanded! < cameras.length)
          ? _expanded
          : null;

      return BentoCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              title: 'نمای زنده',
              subtitle: 'تصویر زنده تمام دوربین ها',
              icon: Icons.sensors_outlined,
              trailing: _LiveBadge(),
            ),
            const SizedBox(height: 12),
            const GradientDivider(height: 1.2),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 680 ? 2 : 1;
                final gap = 12.0;
                final tileWidth =
                    (constraints.maxWidth - gap * (columns - 1)) / columns;

                // The enlarged camera is moved to the front so it occupies the
                // whole first row of the grid.
                final ordered = <int>[
                  if (expanded != null) expanded,
                  for (var i = 0; i < cameras.length; i++)
                    if (i != expanded) i,
                ];

                return AnimatedSize(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOutCubic,
                  alignment: Alignment.topCenter,
                  child: Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: [
                      for (final index in ordered)
                        SizedBox(
                          width: index == expanded
                              ? constraints.maxWidth
                              : tileWidth,
                          child: _CameraLiveTile(
                            camera: cameras[index],
                            index: index,
                            expanded: index == expanded,
                            latest: DashboardStats.latestForCamera(
                              dcontroller.entries,
                              cameras[index].path,
                            ),
                            kcontroller: kcontroller,
                            onTap: () => setState(() {
                              _expanded = _expanded == index ? null : index;
                            }),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
    });
  }
}

/// A single camera tile of the LIVE VIEW grid.
class _CameraLiveTile extends StatelessWidget {
  const _CameraLiveTile({
    required this.camera,
    required this.index,
    required this.expanded,
    required this.latest,
    required this.kcontroller,
    required this.onTap,
  });

  final CameraClass camera;
  final int index;
  final bool expanded;
  final databaseClass? latest;
  final knowPersonController kcontroller;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasStream = (camera.rtspUrl ?? '').isNotEmpty;

    return AnimatedScale(
      scale: expanded ? 1.0 : 1.0,
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOutCubic,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 240),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh.withValues(alpha: expanded ? 0.9 : 0.45),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: expanded
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : AppColors.border,
            ),
            boxShadow: [
              if (expanded)
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 20,
                  spreadRadius: -6,
                ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _label(hasStream),
              const SizedBox(height: 8),
              _frame(hasStream),
              const SizedBox(height: 8),
              _latestPlate(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(bool hasStream) {
    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: (camera.gate ?? 'entre') == 'entre'
                ? AppColors.primary
                : AppColors.warning,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            '${DetectionMeta.cameraDirection(camera)}  •  ${camera.ip ?? '-'}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        if (hasStream)
          const _LiveBadge()
        else
          const _DetectionBadge(),
      ],
    );
  }

  Widget _frame(bool hasStream) {
    final streamUrl = cameraStreamUrl(index, camera);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: AppColors.background),
            if (hasStream)
              CameraFeed(key: ValueKey(streamUrl), streamUrl: streamUrl)
            else
              _LastDetectionImage(latest: latest),
            const PositionedDirectional(
              bottom: 8,
              start: 8,
              child: _ClockOverlay(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _latestPlate() {
    if (latest == null) {
      return Container(
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'هنوز ترددی ثبت نشده است',
          style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
        ),
      );
    }

    return Row(
      children: [
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: EntryPlate(entry: latest!, height: 30),
          ),
        ),
        const SizedBox(width: 8),
        StatusChip(
          status: statusForEntry(latest!, kcontroller),
          dense: true,
        ),
        const Spacer(),
        Text(
          (latest!.eTime ?? '-').toString().toPersianDigit(),
          style: AppTheme.numeric(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
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
            size: 30, color: AppColors.textMuted),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const Center(
        child: Icon(Icons.broken_image_outlined,
            size: 28, color: AppColors.textMuted),
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.62),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.45)),
      ),
      child: const Text(
        'آخرین تشخیص',
        style: TextStyle(
          fontSize: 10,
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
