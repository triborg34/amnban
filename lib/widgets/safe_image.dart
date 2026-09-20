import 'package:flutter/material.dart';

/// Single place for network images so we never show a red error box or crash
/// on a null/empty id, missing filename, or failed download.
///
/// Keeps the existing visual style (same fit/size) and only adds:
/// - null/empty URL guard
/// - loading placeholder (grey box + progress)
/// - error placeholder (broken-image icon)
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
    Widget placeholder(IconData icon) => Container(
          width: width,
          height: height,
          color: Colors.white10,
          child: Center(
            child: Icon(icon, color: Colors.white38, size: 24),
          ),
        );

    if (url == null || url!.isEmpty || url!.endsWith('/null')) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: placeholder(Icons.image_not_supported_outlined),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        // Avoid decoding a huge original when we only show a thumbnail.
        cacheWidth: width == null ? null : (width! * 2).toInt(),
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: width,
            height: height,
            color: Colors.white10,
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => placeholder(Icons.broken_image_outlined),
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
