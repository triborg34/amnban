import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Green hexagonal "D" emblem used in the sidebar, login card and app bar.
class DiespiEmblem extends StatelessWidget {
  const DiespiEmblem({super.key, this.size = 48});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _HexagonPainter(),
        child: Center(
          child: Transform(
            // Slight italic skew, mirroring the reference logo.
            alignment: Alignment.center,
            transform: Matrix4.skewX(-0.18),
            child: Text(
              'D',
              style: TextStyle(
                fontFamily: AppThemeFont.family,
                fontSize: size * 0.62,
                fontWeight: FontWeight.w700,
                height: 1,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// "DIESPI" word mark with the two "I" letters in the brand green.
class DiespiWordmark extends StatelessWidget {
  const DiespiWordmark({super.key, this.fontSize = 26});

  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final base = TextStyle(
      fontFamily: 'arial',
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1.1,
      letterSpacing: 1.5,
      fontStyle: FontStyle.italic,
    );

    return Directionality(
      // Latin word mark — always left to right, even in the RTL app.
      textDirection: TextDirection.ltr,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text('D', style: base.copyWith(color: const Color(0xFF1B1B1B))),
          Text('I', style: base.copyWith(color: AppColors.primary)),
          Text('E', style: base.copyWith(color: const Color(0xFF1B1B1B))),
          Text('S', style: base.copyWith(color: const Color(0xFF1B1B1B))),
          Text('P', style: base.copyWith(color: const Color(0xFF1B1B1B))),
          Text('I', style: base.copyWith(color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _HexagonPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;
    const inset = 0.22;

    path.moveTo(0, h / 2);
    path.lineTo(w * inset, 0);
    path.lineTo(w * (1 - inset), 0);
    path.lineTo(w, h / 2);
    path.lineTo(w * (1 - inset), h);
    path.lineTo(w * inset, h);
    path.close();

    canvas.drawPath(path, Paint()..color = AppColors.primary);

    // Subtle inner highlight so the emblem does not look flat.
    final glow = Paint()
      ..color = Colors.white.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1, w * 0.02);
    canvas.drawPath(path, glow);
  }

  @override
  bool shouldRepaint(covariant _HexagonPainter oldDelegate) => false;
}

/// Font family constants (kept in one place so widgets do not hardcode them).
class AppThemeFont {
  const AppThemeFont._();

  static const String family = 'Vazir';
}
