import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Rounded white panel used all over the dashboard / reports screens.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color,
    this.borderColor,
    this.radius = AppTheme.cardRadius,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? color;
  final Color? borderColor;
  final double radius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final content = Container(
      margin: margin,
      padding: padding,
      decoration: AppTheme.cardDecoration(
        color: color,
        radius: radius,
        borderColor: borderColor,
      ),
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(radius),
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }
}

/// Small caption + optional trailing action used as a card header.
class AppSectionTitle extends StatelessWidget {
  const AppSectionTitle({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.dense = false,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: AppColors.primary),
          ),
          const SizedBox(width: 8),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: dense ? 13 : 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

/// Neutral label chip used for metadata (camera IP, direction, ...).
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.textSecondary,
    this.background,
    this.dense = false,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color? background;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 6 : 8,
        vertical: dense ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: background ?? AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: dense ? 10 : 11.5,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width placeholder used by empty states.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.compact = false,
  });

  final String message;
  final IconData icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: compact ? 16 : 28),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: compact ? 22 : 30, color: AppColors.textMuted),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
