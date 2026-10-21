import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Company name — used everywhere the brand appears.
const String kCompanyName = 'امن آفرین';

/// Primary logo (`assets/mainlogo2.png`) used in the main page header and in
/// the navigation rail header.
class CompanyLogo extends StatelessWidget {
  const CompanyLogo({super.key, this.height = 30, this.showName = true});

  final double height;
  final bool showName;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: height * 0.12),
          decoration: BoxDecoration(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(height * 0.28),
            border: Border.all(color: AppColors.border),
          ),
          child: Image.asset(
            'assets/mainlogo2.png',
            height: height * 0.68,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => SizedBox(width: height * 1.6),
          ),
        ),
        if (showName) ...[
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              kCompanyName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                height: 1.2,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Small app-icon style mark (`assets/logo.png`) used on the login screen,
/// the splash state and in the app bar.
class AppMark extends StatelessWidget {
  const AppMark({super.key, this.size = 28, this.radius});

  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size * 1.55,
      decoration: BoxDecoration(
        color: AppColors.surfaceHigh,
        borderRadius: BorderRadius.circular(radius ?? size * 0.26),
        border: Border.all(color: AppColors.border),
      ),
      padding: EdgeInsets.symmetric(horizontal: size * 0.1),
      child: Image.asset(
        'assets/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
      ),
    );
  }
}

/// Standalone company name text.
class CompanyName extends StatelessWidget {
  const CompanyName({super.key, this.fontSize = 14});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Text(
      kCompanyName,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        height: 1.2,
      ),
    );
  }
}
