import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header.dart';
import 'package:pverify/utils/common_widget/text_field/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: AuthController(),
      builder: (authController) {
        authController.emailTextController.value.text =
            'nirali.talavia@gmail.com';
        authController.passwordTextController.value.text = 'Niralishah@1234';
        return Scaffold(
          backgroundColor: AppColors.grey2,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: 150.h,
            backgroundColor: AppColors.primary,
            title: baseHeaderView(AppStrings.login, true),
          ),
          body: Container(
            width: ResponsiveHelper.getDeviceWidth(context),
            padding: const EdgeInsets.only(left: 20, right: 20),
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
                        controller: authController.emailTextController.value,
                        onTap: () {},
                        errorText: '',
                        onEditingCompleted: () {},
                        onChanged: (value) {},
                        keyboardType: TextInputType.emailAddress,
                        hintText: AppStrings.username,
                      ),
                      Divider(
                        height: 2,
                        color: AppColors.textFieldText_Color,
                      ),
                      BoxTextField(
                        isMulti: false,
                        controller: authController.passwordTextController.value,
                        onTap: () {},
                        errorText: '',
                        onEditingCompleted: () {},
                        onChanged: (value) {},
                        keyboardType: TextInputType.name,
                        hintText: AppStrings.password,
                        isPasswordField: true,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 70.h,
                ),
                customButton(
                  AppColors.primary,
                  AppStrings.logIn.toUpperCase(),
                  double.infinity,
                  90,
                  onClickAction: () async {
                    await doLoginAction(authController, isLoginButton: true);
                  },
                ),
                SizedBox(
                  height: 40.h,
                ),
                customButton(
                  AppColors.primary,
                  AppStrings.setup.toUpperCase(),
                  double.infinity,
                  90,
                  onClickAction: () async {
                    await doLoginAction(authController, isLoginButton: false);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> doLoginAction(
    AuthController authController, {
    required bool isLoginButton,
  }) async {
    if (authController.isLoginFieldsValidate()) {
      try {
        Utils.showLoadingDialog();
        LoginData? loginData =
            await authController.loginUser(isLoginButton: isLoginButton);
        if (loginData != null) {
          if (loginData.subscriptionExpired ?? false) {
            // dismissible info dialog
            Utils.hideLoadingDialog();
            Get.snackbar(
              AppStrings.error,
              "User is not active.",
              backgroundColor: AppColors.red,
              colorText: AppColors.white,
            );
          } else if (loginData.status == 3) {
            // "Account is not active." dialog
            Utils.hideLoadingDialog();
            Get.snackbar(
              AppStrings.error,
              "Account is not active.",
              backgroundColor: AppColors.red,
              colorText: AppColors.white,
            );
          } else {
            await authController.persistUserName();

            // TODO: unnecessary
            // await authController.jsonFileOperations.offlineLoadSuppliersData();
            // await authController.jsonFileOperations.offlineLoadCarriersData();
            // await authController.jsonFileOperations.offlineLoadCommodityData();

            await authController.downloadCloudData();
          }
        } else {
          // Utils.hideLoadingDialog();
        }
      } catch (e) {
        print(e);
        Utils.hideLoadingDialog();
      }
    }
  }
}
