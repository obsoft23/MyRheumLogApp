import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myrheumlogapp/view/onboarding/onboard.dart';
import 'package:myrheumlogapp/view/splash/splashscreen.dart';
import 'package:myrheumlogapp/view/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key}) {
    Get.put(OnboardingController());
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: AppTheme.light,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}
