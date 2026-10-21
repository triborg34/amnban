import 'package:flutter/material.dart';

import '../models/databaseEntry.dart';
import '../theme/app_colors.dart';
import '../utils/controller.dart';

/// Detection / access status of a plate, mirrored from the DIESPI reference.
enum DetectionStatus {
  allowed,
  denied,
  unknown,
  exit,
  unrecognized,
}

/// Human readable Persian label for [status].
String statusLabel(DetectionStatus status) {
  switch (status) {
    case DetectionStatus.allowed:
      return 'مجاز';
    case DetectionStatus.denied:
      return 'غیر مجاز';
    case DetectionStatus.unknown:
      return 'بدون مالک';
    case DetectionStatus.exit:
      return 'خروج';
    case DetectionStatus.unrecognized:
      return 'پلاک ناشناخته';
  }
}

/// Colour pair (foreground / background) for [status].
({Color fg, Color bg}) statusColors(DetectionStatus status) {
  switch (status) {
    case DetectionStatus.allowed:
      return (fg: AppColors.success, bg: AppColors.successSoft);
    case DetectionStatus.denied:
      return (fg: AppColors.unauthorized, bg: AppColors.unauthorizedSoft);
    case DetectionStatus.unknown:
    case DetectionStatus.unrecognized:
      return (fg: AppColors.warning, bg: AppColors.warningSoft);
    case DetectionStatus.exit:
      return (fg: AppColors.warning, bg: AppColors.warningSoft);
  }
}

/// Derives the status of a detection from the allow-list.
///
/// * known person with `مجاز` role  → allowed
/// * known person with another role → denied (purple)
/// * unknown plate                   → unknown / بدون مالک (orange)
DetectionStatus statusForEntry(
  databaseClass entry,
  knowPersonController kcontroller,
) {
  final person = kcontroller.personFor(entry.plateNum);
  if (person == null) return DetectionStatus.unknown;
  if (person.role == 'مجاز') return DetectionStatus.allowed;
  return DetectionStatus.denied;
}

/// Small coloured pill used for detection status.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.status,
    this.label,
    this.dense = false,
    this.icon,
  });

  final DetectionStatus status;
  final String? label;
  final bool dense;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = statusColors(status);
    final text = label ?? statusLabel(status);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 9,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.fg.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: colors.fg),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: dense ? 10 : 11.5,
              fontWeight: FontWeight.w500,
              color: colors.fg,
            ),
          ),
        ],
      ),
    );
  }
}
