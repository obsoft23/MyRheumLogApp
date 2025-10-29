// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:myrheumlogapp/view/homepage/home.dart';
import 'package:myrheumlogapp/view/onboarding/onboard.dart';
import 'package:myrheumlogapp/view/splash/splashscreen.dart';
import 'package:myrheumlogapp/view/tab_pages/home_tab/health_home.dart';
import 'package:myrheumlogapp/view/tab_pages/plan_tab/plan_home.dart';
import 'package:myrheumlogapp/view/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    //
    //
    Get.put(OnboardingController(GetStorage()));
    Get.put(HomeController());
    Get.put(QuickLogController());
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      themeMode: ThemeMode.system,
      home: HomePage(),
    );
  }
}
