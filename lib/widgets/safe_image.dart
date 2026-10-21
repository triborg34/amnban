import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Single place for network images so we never show a red error box or crash
/// on a null/empty id, missing filename, or failed download.
///
/// Uses `cached_network_image` so the (many) plate / car thumbnails are
/// fetched only once and kept in the disk cache.
class SafeNetImage extends StatelessWidget {
  const SafeNetImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.fill,
    this.borderRadius = 5,
  });

  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    Widget placeholder(IconData icon) => _PlaceholderBox(
          width: width,
          height: height,
          icon: icon,
        );

    if (url == null || url!.isEmpty || url!.endsWith('/null')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: placeholder(Icons.image_not_supported_outlined),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: width,
        height: height,
        fit: fit,
        // Avoid decoding a huge original when we only show a thumbnail.
        memCacheWidth: width == null ? null : (width! * 2).toInt(),
        placeholder: (context, _) => _PlaceholderBox(
          width: width,
          height: height,
          shimmer: true,
        ),
        errorWidget: (context, _, __) =>
            placeholder(Icons.broken_image_outlined),
      ),
    );
  }
}

/// Grey placeholder with a soft pulse — a lightweight "shimmer".
class _PlaceholderBox extends StatefulWidget {
  const _PlaceholderBox({
    this.width,
    this.height,
    this.icon,
    this.shimmer = false,
  });

  final double? width;
  final double? height;
  final IconData? icon;
  final bool shimmer;

  @override
  State<_PlaceholderBox> createState() => _PlaceholderBoxState();
}

class _PlaceholderBoxState extends State<_PlaceholderBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void initState() {
    super.initState();
    if (widget.shimmer) _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.width,
      height: widget.height,
      color: AppColors.surfaceMuted,
      child: widget.shimmer
          ? AnimatedBuilder(
              animation: _controller,
              builder: (context, child) => Opacity(
                opacity: 0.45 + (_controller.value * 0.35),
                child: child,
              ),
              child: const Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : Center(
              child: Icon(
                widget.icon,
                color: AppColors.textMuted,
                size: 22,
              ),
            ),
    );
  }
}

/// Builds a PocketBase file URL, returning null when parts are missing so
/// callers render a placeholder instead of requesting `.../null/null`.
String? pbFileUrl(String host, String collection, String? id, String? file) {
  if (id == null || id.isEmpty || file == null || file.isEmpty) return null;
  return 'http://$host:8090/api/files/$collection/$id/$file';
}
