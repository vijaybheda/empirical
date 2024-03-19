import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header.dart';
import 'package:pverify/utils/common_widget/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

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
        padding: EdgeInsets.only(left: 20, right: 20),
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
                    hintText: 'Email',
                    focusNode: controller.fNodeEmail,
                  ),
                  Divider(
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
                    hintText: AppStrings.password,
                    isPasswordField: true,
                    focusNode: controller.fNodePass,
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 70.h,
            ),
            customButton(AppStrings.login, double.infinity, 90,
                onClickAction: () {
              // validate email and password
              if (Get.find<AuthController>().isLoginFieldsValidate()) {
                // TODO: Vijay
                // User? user = await controller.loginUser(isLoginButton: true);
              }
              // change snackbar according to requirements
            }),
            SizedBox(
              height: 40.h,
            ),
            customButton(AppStrings.setup, double.infinity, 90,
                onClickAction: () => {}),
          ],
        ),
      ),
    );
  }
}
