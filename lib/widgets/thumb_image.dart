import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Thumbnail / picture loader built on the plain [NetworkImage] provider.
///
/// * `cacheWidth` keeps the decoded bitmap small (cheap to decode and shared
///   between every row that shows the same picture),
/// * `gaplessPlayback: true` keeps the previous frame visible while the next
///   one loads, so a scrolling list never shows a black hole,
/// * the placeholder is always the solid card colour — never transparent.
class ThumbImage extends StatelessWidget { 
  const ThumbImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.cacheWidth = 240,
    this.borderRadius = 8,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;

  /// Decode width of the cached bitmap.
  final int cacheWidth;

  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    if (url == null || url!.isEmpty || url!.endsWith('/null')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: _fallback(Icons.image_not_supported_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        cacheWidth: cacheWidth,
        gaplessPlayback: true,
        filterQuality: FilterQuality.low,
        frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
          if (wasSynchronouslyLoaded) return child;
          // `wasSynchronouslyLoaded` is only true for a memory-cache hit, so
          // the real "still loading" signal is the missing frame.
          if (frame == null) {
            // Keep the dark surface until the first frame is ready.
            return Container(
              width: width,
              height: height,
              color: AppColors.surface,
            );
          }
          return child;
        },
        errorBuilder: (context, error, stackTrace) =>
            _fallback(Icons.broken_image_outlined),
      ),
    );
  }

  Widget _fallback(IconData icon) {
    return Container(
      width: width,
      height: height,
      color: AppColors.surface,
      alignment: Alignment.center,
      child: Icon(icon, size: 20, color: AppColors.textMuted),
    );
  }
}
