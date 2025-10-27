// ignore_for_file: deprecated_member_use, unused_import

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:myrheumlogapp/view/onboarding/onboard.dart';
import 'package:myrheumlogapp/view/onboarding/onboarding_welcome.dart';
import 'package:myrheumlogapp/view/themes/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate a delay for the splash screen (e.g., loading resources)
    Future.delayed(const Duration(seconds: 3), () {
      // Navigate to the onboarding page after the delay
      Get.offAll(() => const OnboardingFirstPage());
    });
    _decideStart();
  }

  Future<void> _decideStart() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: primaryBlue,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // App logo or splash image
              SizedBox(
                height: 250,
                width: 400,
                child: SvgPicture.asset(
                  'assets/icons/splash_rheum2.svg',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 16),

              // Loading GIF below the logo
              Image.asset('assets/images/loading.gif', height: 23, width: 23),
            ],
          ),
        ),
      ),
    );
  }
}
