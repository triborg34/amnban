import 'package:amnban/screens/main_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pocketbase/pocketbase.dart';

List<GetPage> pages = [GetPage(name: '/', page: () => MainScreen())];
var pb = PocketBase('http://127.0.0.1:8090');
Color purpule = Color.fromARGB(255, 56, 2, 109);
Color selecetpurpule=const Color.fromARGB(255, 109, 20, 125);
List<String> tabs=['خانه',"گزارشات","تنظیمات","درباره"].reversed.toList();