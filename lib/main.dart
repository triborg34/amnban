import 'package:amnban/screens/splashScreen.dart';
import 'package:amnban/theme/app_theme.dart';
import 'package:amnban/utils/bindings.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/network_info.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

import 'package:responsive_sizer/responsive_sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveSizer(
      builder: (p0, p1, p2) => GetMaterialApp(
        initialBinding: MyBindings(),
        debugShowCheckedModeBanner: false,
        title: "AmnBan",
        theme: AppTheme.dark,
        darkTheme: AppTheme.dark,
        // The application is permanently dark.
        themeMode: ThemeMode.dark,
        getPages: pages,
        home: SplashScreen(),
        // The whole application is right-to-left.
        builder: (context, child) => Directionality(
          textDirection: TextDirection.rtl,
          child: child ?? const SizedBox.shrink(),
        ),
        onInit: () {
          // GetMaterialApp.onInit is not awaited before bindings' onReady,
          // so resolve synchronously with safe fallbacks. Controllers must
          // never run with a 'null' host (previously produced
          // PocketBase('http://null:8090')).
          try {
            final host = getNetworkInfo();
            final hostname = host['hostname'];
            final hostPort = host['port'];
            if (hostname is String && hostname.isNotEmpty) {
              url = hostname;
            }
            if (hostPort is String && hostPort.isNotEmpty) {
              port = hostPort;
              // port="8000";

            }
          } catch (_) {
            // Keep compiled defaults (127.0.0.1:8000).
          }
          try {
            pb = PocketBase('http://$url:8090');
          } catch (_) {}
        },
      ),
    );
  }
}
