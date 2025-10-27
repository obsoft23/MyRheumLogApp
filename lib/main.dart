import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:myrheumlogapp/view/splash/splashscreen.dart';
import 'package:myrheumlogapp/view/themes/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
