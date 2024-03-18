// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last, unnecessary_new, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/utils/Common%20Widget/Buttons.dart';
import 'package:pverify/utils/Common%20Widget/Header.dart';
import 'package:pverify/utils/Common%20Widget/text_fields.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sampleColorTheme,
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
            Image.asset(
              AppImages.appLogo,
              width: 130.w,
              height: 130.w,
            ),
            SizedBox(
              height: 40.h,
            ),
            Container(
              width: (ResponsiveHelper.getDeviceWidth(context)).w,
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10.0)),
              child: Column(
                children: [
                  BoxTextField(
                    isMulti: false,
                    controller: controller.emailTextController,
                    onTap: () {
                      print('on Tap');
                    },
                    errorText: '',
                    suffix: Container(),
                    prefix: Container(),
                    onEditingCompleted: () {
                      print('Complete Change');
                    },
                    onChanged: (value) {
                      print(value);
                    },
                    keyboardType: TextInputType.emailAddress,
                    hintText: 'Email',
                    focusNode: controller.fNodeEmail,
                  ),
                  new Divider(
                    height: 2,
                    color: AppColors.loginTextField_UnderlineColor,
                  ),
                  BoxTextField(
                    isMulti: false,
                    controller: controller.passwordTextController,
                    onTap: () {
                      print('on Tap');
                    },
                    errorText: '',
                    suffix: Container(),
                    prefix: Container(),
                    onEditingCompleted: () {
                      print('Complete Change');
                    },
                    onChanged: (value) {
                      print(value);
                    },
                    keyboardType: TextInputType.name,
                    hintText: 'Password',
                    isPasswordField: true,
                    focusNode: controller.fNodePass,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 70.h,
            ),
            customButton('LOG IN', double.infinity, 90,
                onbuttonTap: {print('LOG IN Button Tapped')}),
            SizedBox(
              height: 40.h,
            ),
            customButton('SETUP', double.infinity, 90,
                onbuttonTap: {print('Setup Button Tapped')})
          ],
        ),
        padding: EdgeInsets.only(left: 20, right: 20),
      ),
    );
  }
}
