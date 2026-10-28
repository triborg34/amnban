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
/// Every registered camera is rendered at the same time in a responsive grid
/// (two columns on tablet / desktop, one on phones). Tapping a tile enlarges
/// it to a full row — the other tiles stay in the grid, nothing is hidden and
/// nothing is dimmed.
class LiveViewSection extends StatefulWidget {
  const LiveViewSection({super.key});

  @override
  State<LiveViewSection> createState() => _LiveViewSectionState();
}

class _LiveViewSectionState extends State<LiveViewSection> {
  /// Id of the camera that is shown enlarged (`null` = none).
  String? _selectedCameraId;

  @override
  Widget build(BuildContext context) {
    final ccontroller = Get.find<cameraController>();
    final kcontroller = Get.find<knowPersonController>();

    return Obx(() {
      // `cameras` is the only value read here — it is the observable the
      // camera controller keeps up to date.
      final cameras = ccontroller.cameras;
      if (cameras.isEmpty) {
        return const BentoCard(
          child: AppEmptyState(
            message: 'دوربینی ثبت نشده است',
            icon: Icons.videocam_off_outlined,
          ),
        );
      }

      return BentoCard(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CardHeader(
              title: 'نمای زنده',
              subtitle: 'تصویر زنده تمام دوربین ها',
              icon: Icons.sensors_outlined,
              trailing: const _LiveBadge(),
            ),
            const SizedBox(height: 12),
            const GradientDivider(height: 1.2),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 680 ? 2 : 1;
                final gap = 12.0;
                final width = constraints.maxWidth;
                final tileWidth = (width - gap * (columns - 1)) / columns;

                // The camera order never changes: a tile is only re-sized
                // when it is selected. Re-ordering the list would move the
                // platform view of the live stream and drop the connection
                // to the backend.
                return Wrap(
                  spacing: gap,
                  runSpacing: gap,
                  children: [
                    for (final camera in cameras)
                      _LiveCameraTile(
                        key: ValueKey('live-camera-${camera.id ?? camera.path}'),
                        camera: camera,
                        kcontroller: kcontroller,
                        selected: _selectedCameraId != null &&
                            _selectedCameraId == (camera.id ?? camera.path),
                        tileWidth: tileWidth,
                        fullWidth: width,
                        onTap: () => setState(() {
                          final id = camera.id ?? camera.path;
                          _selectedCameraId =
                              _selectedCameraId == id ? null : id;
                        }),
                      ),
                  ],
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
class _LiveCameraTile extends StatelessWidget {
  const _LiveCameraTile({
    super.key,
    required this.camera,
    required this.kcontroller,
    required this.selected,
    required this.tileWidth,
    required this.fullWidth,
    required this.onTap,
  });

  final CameraClass camera;
  final knowPersonController kcontroller;
  final bool selected;
  final double tileWidth;
  final double fullWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(
        begin: tileWidth,
        end: selected ? fullWidth : tileWidth,
      ),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
      builder: (context, width, _) => SizedBox(
        width: width,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              // The same surface for every tile — selecting a camera must not
              // darken it.
              color: AppColors.surfaceHigh,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected
                    ? AppColors.primary.withValues(alpha: 0.55)
                    : AppColors.border,
              ),
              boxShadow: [
                if (selected)
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.20),
                    blurRadius: 20,
                    spreadRadius: -6,
                  ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                _label(),
                const SizedBox(height: 8),
                _frame(),
                const SizedBox(height: 8),
                _LatestDetection(
                  camera: camera,
                  kcontroller: kcontroller,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label() {
    final isEntry = (camera.gate ?? 'entre') == 'entre';
    final hasStream = (camera.rtspUrl ?? '').isNotEmpty;

    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(
            color: isEntry ? AppColors.primary : AppColors.warning,
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

  Widget _frame() {
    final hasStream = (camera.rtspUrl ?? '').isNotEmpty;
    final streamUrl = cameraStreamUrl(_indexOf(camera), camera);

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 16 / 9,
        child: hasStream
            ? CameraFeed(key: ValueKey(streamUrl), streamUrl: streamUrl)
            // No live stream — show the last detection of this camera.
            : Obx(() {
                final entries = Get.find<databaseController>().entries
                    .toList(growable: false);
                return _LastDetectionImage(
                  latest: DashboardStats.latestForCamera(
                    entries,
                    camera.path,
                  ),
                );
              }),
      ),
    );
  }

  /// Position of the camera inside the controller list (the feed URL uses it).
  int _indexOf(CameraClass item) {
    final cameras = Get.find<cameraController>().cameras;
    final index = cameras.indexWhere((c) => c.id == item.id);
    return index == -1 ? 0 : index;
  }
}

/// The "آخرین تردد" block of a camera tile.
///
/// It reads the detections straight from the controller inside an `Obx`, so
/// every poll that adds a record refreshes it — the very same observable the
/// live feed uses.
class _LatestDetection extends StatelessWidget {
  const _LatestDetection({
    required this.camera,
    required this.kcontroller,
  });

  final CameraClass camera;
  final knowPersonController kcontroller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Read the observable here (not in initState) so GetX can track it.
      // `toList` walks the RxList, which is what registers the dependency —
      // reading the field alone would not.
      final entries =
          Get.find<databaseController>().entries.toList(growable: false);
      final latest = DashboardStats.latestForCamera(entries, camera.path);

      if (latest == null) {
        return Container(
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            'هنوز ترددی برای این دوربین ثبت نشده است',
            style: TextStyle(fontSize: 10.5, color: AppColors.textMuted),
          ),
        );
      }

      final status = statusForEntry(latest, kcontroller);

      return Row(
        children: [
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: EntryPlate(entry: latest, height: 30),
            ),
          ),
          const SizedBox(width: 8),
          StatusChip(status: status, dense: true),
          const Spacer(),
          Text(
            (latest.eTime ?? '-').toString().toPersianDigit(),
            style: AppTheme.numeric(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      );
    });
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
      return Container(
        color: AppColors.surface,
        child: const Center(
          child: Icon(Icons.videocam_off_outlined,
              size: 30, color: AppColors.textMuted),
        ),
      );
    }

    return Image.network(
      url,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stack) => Container(
        color: AppColors.surface,
        child: const Center(
          child: Icon(Icons.broken_image_outlined,
              size: 28, color: AppColors.textMuted),
        ),
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
