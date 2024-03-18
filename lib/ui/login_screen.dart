// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last, unnecessary_new, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_typedefs/rx_typedefs.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/utils/Common%20Widget/Buttons.dart';
import 'package:pverify/utils/Common%20Widget/Header.dart';
import 'package:pverify/utils/Common%20Widget/textFields.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/strings.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/theme/text_theme.dart';

class LoginScreen extends GetView<AuthController> {
  final FocusNode fNodeEmail = FocusNode();
  final FocusNode fNodePass = FocusNode();
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.grey2,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 150.h,
        backgroundColor: AppColors.primary,
        title: baseHeaderView(),
      ),
      body: Container(
        width: ResponsiveHelper.getDeviceWidth(context),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 50.h,
            ),
            Image.asset(
              fit: BoxFit.contain,
              AppImages.appLogo,
              width: 220.w,
              height: 220.h,
            ),
            SizedBox(
              height: 50.h,
            ),
            Container(
              width: (ResponsiveHelper.getDeviceWidth(context)).w,
              height: 220.h,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: [
                  BoxTextField(
                    isMulti: false,
                    controller:
                        Get.find<AuthController>().emailTextController.value,
                    onTap: () {
                      print('on Tap');
                    },
                    errorText: '',
                    onEditingCompleted: () {
                      print(
                          Get.find<AuthController>().emailTextController.value);
                    },
                    onChanged: (value) {},
                    keyboardType: TextInputType.emailAddress,
                    hintText: Appstrings.UserName,
                  ),
                  new Divider(
                    height: 2,
                    color: AppColors.textFieldText_Color,
                  ),
                  BoxTextField(
                    isMulti: false,
                    controller:
                        Get.find<AuthController>().passwordTextController.value,
                    onTap: () {
                      print('on Tap');
                    },
                    errorText: '',
                    onEditingCompleted: () {
                      print(Get.find<AuthController>()
                          .passwordTextController
                          .value);
                    },
                    onChanged: (value) {
                      print(value);
                    },
                    keyboardType: TextInputType.name,
                    hintText: Appstrings.Password,
                    isPasswordField: true,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 70.h,
            ),
            customButton(Appstrings.LOGIN, double.infinity, 90,
                onClickAction: () => {
                      if (AuthController().isLoginFieldsValidate() == true)
                        {print("All field are validate.")}
                    }),
            SizedBox(
              height: 40.h,
            ),
            customButton(Appstrings.SETUP, double.infinity, 90,
                onClickAction: () => {}),
          ],
        ),
        padding: EdgeInsets.only(left: 20, right: 20),
      ),
    );
  }
}
