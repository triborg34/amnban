import 'dart:async';

import 'package:amnban/screens/loginScreen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/widgets/app_logo.dart';

import 'package:flutter/material.dart';

/// Splash screen — shows the "امن آفرین" app mark for two seconds and then
/// hands over to the login page.
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const ModernLoginPage()),
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.12),
                    blurRadius: 36,
                    spreadRadius: -12,
                  ),
                ],
              ),
              child: const AppMark(size: 44),
            ),
            const SizedBox(height: 20),
            const CompanyName(fontSize: 20),
            const SizedBox(height: 8),
            const Text(
              'سامانه پایش خودکار پلاک',
              style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.primary,
                backgroundColor: AppColors.surfaceHigh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
