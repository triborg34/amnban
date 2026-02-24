import 'package:amnban/screens/splashScreen.dart';
import 'package:amnban/utils/bindings.dart';
import 'package:amnban/utils/consts.dart';
import 'package:amnban/utils/network_info.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
        theme: ThemeData(fontFamily: 'byekan'),
        getPages: pages,
        home: SplashScreen(),
        onInit: () async {

          var host = getNetworkInfo();
          url = host['hostname'];
          port=host['port'];
       
          port='8000';

        },
      ),
    );
  }
}
