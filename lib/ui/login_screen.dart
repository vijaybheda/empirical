import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/utils/theme/colors.dart';

class LoginScreen extends GetView<AuthController> {
  final FocusNode fNodeEmail = FocusNode();
  final FocusNode fNodePass = FocusNode();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            color: AppColors.primaryColor,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // screen content
              ],
            ),
          ),
        ],
      ),
    );
  }
}
