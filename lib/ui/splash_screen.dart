import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/splash_screen_controller.dart';
import 'package:pverify/utils/theme/colors.dart';

class SplashScreen extends GetWidget<SplashScreenController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SplashScreenController>(
      init: SplashScreenController(),
      builder: (controller) {
        return Scaffold(
            body: Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
          ),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                ],
              ),
              SizedBox(
                height: 15,
              ),
            ],
          ),
        ));
      },
    );
  }
}
