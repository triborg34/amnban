/// Builds a PocketBase file URL, returning null when parts are missing so
/// callers render a placeholder instead of requesting `.../null/null`.
String? pbFileUrl(String host, String collection, String? id, String? file) {
  if (id == null || id.isEmpty || file == null || file.isEmpty) return null;
  return 'http://$host:8090/api/files/$collection/$id/$file';
}

/// Stable Hero tag for a detection.
///
/// Never falls back to the list index: an index based tag changes when the
/// list is re-ordered, which makes Flutter drop the flight and shows a blank
/// frame. Returns `null` when the record has no id (a duplicate tag would
/// break the whole route).
String? detectionHeroTag(String? id) {
  if (id == null || id.isEmpty) return null;
  return 'hero_$id';
}
