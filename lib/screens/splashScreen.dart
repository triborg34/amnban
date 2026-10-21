import 'dart:async';

import 'package:amnban/screens/loginScreen.dart';
import 'package:amnban/theme/app_colors.dart';
import 'package:amnban/widgets/app_logo.dart';

import 'package:flutter/material.dart';

/// Splash screen — shows the DIESPI emblem for two seconds and then hands
/// over to the login page (same behaviour as the previous `SplashView`).
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
      backgroundColor: AppColors.loginBackground,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const DiespiEmblem(size: 110),
            const SizedBox(height: 18),
            const DiespiWordmark(fontSize: 28),
            const SizedBox(height: 10),
            const Text(
              'سامانه پایش خودکار پلاک',
              style: TextStyle(fontSize: 12.5, color: Colors.white70),
            ),
            const SizedBox(height: 26),
            const SizedBox(
              width: 160,
              child: LinearProgressIndicator(
                minHeight: 3,
                color: AppColors.primary,
                backgroundColor: Colors.white24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
