import 'package:flutter/material.dart';

import '../models/databaseEntry.dart';
import '../theme/app_colors.dart';
import '../utils/controller.dart';

/// Detection / access status of a plate.
enum DetectionStatus {
  /// مجاز — the plate is on the allow list.
  allowed,

  /// غیر مجاز — known person, but not permitted.
  unauthorized,

  /// بدون مالک — the plate is unknown and therefore denied.
  denied,

  /// خروج — leaving the parking.
  exit,

  /// پلاک ناشناخته — the plate could not be read.
  unrecognized,
}

/// Human readable Persian label for [status].
String statusLabel(DetectionStatus status) {
  switch (status) {
    case DetectionStatus.allowed:
      return 'مجاز';
    case DetectionStatus.unauthorized:
      return 'غیر مجاز';
    case DetectionStatus.denied:
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
    case DetectionStatus.unauthorized:
      return (fg: AppColors.unauthorized, bg: AppColors.unauthorizedSoft);
    case DetectionStatus.denied:
      return (fg: AppColors.danger, bg: AppColors.dangerSoft);
    case DetectionStatus.exit:
      return (fg: AppColors.warning, bg: AppColors.warningSoft);
    case DetectionStatus.unrecognized:
      return (fg: AppColors.warning, bg: AppColors.warningSoft);
  }
}

/// Derives the status of a detection from the allow-list.
///
/// * known person with `مجاز` role  → allowed (green-cyan)
/// * known person, other role         → unauthorized (violet)
/// * unknown plate                    → denied (red)
DetectionStatus statusForEntry(
  databaseClass entry,
  knowPersonController kcontroller,
) {
  final person = kcontroller.personFor(entry.plateNum);
  if (person == null) return DetectionStatus.denied;
  if (person.role == 'مجاز') return DetectionStatus.allowed;
  return DetectionStatus.unauthorized;
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
        horizontal: dense ? 7 : 9,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: colors.bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.fg.withValues(alpha: 0.40)),
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
              fontWeight: FontWeight.w600,
              color: colors.fg,
            ),
          ),
        ],
      ),
    );
  }
}
