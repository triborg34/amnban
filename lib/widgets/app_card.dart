import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

/// Bento card — layered dark surface with a hairline border.
///
/// The [glass] variant adds a blurred backdrop so the card floats above the
/// content behind it (used by the reports filter panel).
class BentoCard extends StatelessWidget {
  const BentoCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.glass = false,
    this.glow = false,
    this.color,
    this.radius = AppTheme.cardRadius,
    this.borderColor,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final bool glass;
  final bool glow;
  final Color? color;
  final double radius;
  final Color? borderColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(radius);

    Widget content = Container(
      margin: margin,
      padding: padding,
      decoration: _decoration(),
      child: child,
    );

    if (glass) {
      content = ClipRRect(
        borderRadius: borderRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            margin: margin,
            padding: padding,
            decoration: BoxDecoration(
              color: AppColors.surface.withValues(alpha: 0.55),
              borderRadius: borderRadius,
              border: Border.all(
                color: borderColor ?? AppColors.border,
              ),
            ),
            child: child,
          ),
        ),
      );
    }

    if (onTap == null) return content;

    return Material(
      color: Colors.transparent,
      borderRadius: borderRadius,
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: content),
    );
  }

  /// Layered background: a barely-visible gradient over the dark surface plus
  /// a hairline border — depth without heavy shadows.
  BoxDecoration _decoration() {
    final base = color ?? AppColors.surface;
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Color.lerp(base, AppColors.surfaceHigh, 0.45)!,
          base,
        ],
      ),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor ?? AppColors.border),
      boxShadow: [
        if (glow)
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.16),
            blurRadius: 22,
            spreadRadius: -6,
          )
        else
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.30),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
      ],
    );
  }
}

/// Header of a card: small caption + optional trailing widget.
class CardHeader extends StatelessWidget {
  const CardHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.accent = AppColors.primary,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final Color accent;

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
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(width: 9),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13.5,
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

/// Thin gradient hairline used between sections.
class GradientDivider extends StatelessWidget {
  const GradientDivider({
    super.key,
    this.height = 1.5,
    this.vertical = false,
    this.color = AppColors.primary,
  });

  final double height;
  final bool vertical;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: [
        Colors.transparent,
        color.withValues(alpha: 0.55),
        Colors.transparent,
      ],
      begin: vertical ? Alignment.topCenter : Alignment.centerLeft,
      end: vertical ? Alignment.bottomCenter : Alignment.centerRight,
    );

    if (vertical) {
      return Container(
        width: height,
        decoration: BoxDecoration(gradient: gradient),
      );
    }

    return Container(
      height: height,
      decoration: BoxDecoration(gradient: gradient),
    );
  }
}

/// One cell of a [BentoGrid].
class BentoItem {
  const BentoItem({
    required this.child,
    this.span = 1,
    this.height,
  });

  final Widget child;

  /// How many grid columns the cell occupies.
  final int span;
  final double? height;
}

/// Asymmetric grid — cells can span one or more columns.
class BentoGrid extends StatelessWidget {
  const BentoGrid({
    super.key,
    required this.items,
    this.columns = 3,
    this.spacing = 14,
  });

  final List<BentoItem> items;
  final int columns;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final unit = (width - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(
                width: unit * item.span + spacing * (item.span - 1),
                height: item.height,
                child: item.child,
              ),
          ],
        );
      },
    );
  }
}

/// Neutral metadata chip (camera IP, direction, ...).
class InfoChip extends StatelessWidget {
  const InfoChip({
    super.key,
    required this.label,
    this.icon,
    this.color = AppColors.textSecondary,
    this.background,
    this.dense = false,
    this.mono = false,
  });

  final String label;
  final IconData? icon;
  final Color color;
  final Color? background;
  final bool dense;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 9,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background ?? AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: dense ? 11 : 13, color: color),
            const SizedBox(width: 5),
          ],
          Text(
            label,
            style: (mono
                    ? AppTheme.numeric(fontSize: dense ? 10.5 : 11.5)
                    : const TextStyle(fontSize: 11.5))
                .copyWith(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

/// Empty / placeholder state.
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
