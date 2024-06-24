import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/models/user_data.dart';
import 'package:pverify/services/custom_exception/custom_exception.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/setup_platfrom/setup.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
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
        if (kDebugMode) {
          authController.emailTextController.value.text =
              'nirali.talavia@yahoo.com';
          authController.passwordTextController.value.text = 'P@ssword1234';

          // authController.emailTextController.value.text =
          //     'nirali.talavia@gmail.com';
          // authController.passwordTextController.value.text = 'Niralishah@1234';
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: 150.h,
            backgroundColor: Theme.of(context).primaryColor,
            title:
                HeaderContentView(title: AppStrings.login, isVersionShow: true),
          ),
          body: AutofillGroup(
            child: Container(
              width: ResponsiveHelper.getDeviceWidth(context),
              padding: EdgeInsets.only(left: 30.w, right: 30.w),
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
                        BoxTextFieldLogin(
                          isMulti: false,
                          controller: authController.emailTextController.value,
                          onTap: () {},
                          errorText: '',
                          onEditingCompleted: () {
                            FocusScope.of(context).unfocus();
                          },
                          onChanged: (value) {},
                          keyboardType: TextInputType.emailAddress,
                          hintText: AppStrings.username,
                        ),
                        Divider(
                          height: 2,
                          color: AppColors.textFieldText_Color,
                        ),
                        BoxTextFieldLogin(
                          isMulti: false,
                          controller:
                              authController.passwordTextController.value,
                          onTap: () {},
                          errorText: '',
                          onEditingCompleted: () {
                            FocusScope.of(context).unfocus();
                          },
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
                    backgroundColor: Theme.of(context).primaryColor,
                    title: AppStrings.logIn.toUpperCase(),
                    width: double.infinity,
                    height: 90,
                    fontStyle: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    onClickAction: () async {
                      TextInput.finishAutofillContext();
                      await doLoginAction(authController,
                          isLoginButton: true, context: context);
                    },
                  ),
                  SizedBox(
                    height: 40.h,
                  ),
                  customButton(
                    backgroundColor: Theme.of(context).primaryColor,
                    title: AppStrings.setup.toUpperCase(),
                    width: double.infinity,
                    height: 90,
                    fontStyle: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                    onClickAction: () async {
                      await doLoginAction(authController,
                          isLoginButton: false, context: context);
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> doLoginAction(AuthController authController,
      {required bool isLoginButton, required BuildContext context}) async {
    if (authController.isLoginFieldsValidate(context)) {
      try {
        Utils.showLoadingDialog();
        UserData? userData = await authController.loginUser(
            isLoginButton: isLoginButton, context: context);
        if (userData != null) {
          if (!isLoginButton) {
            Utils.hideLoadingDialog();
            await Get.to(() => SetupScreen(), arguments: userData);
            return;
          }
          if (userData.subscriptionExpired ?? false) {
            // dismissible info dialog
            Utils.hideLoadingDialog();

            AppAlertDialog.validateAlerts(
                Get.context!, AppStrings.error, AppStrings.subscriptionExpired);
          } else if (userData.status == 3) {
            Utils.hideLoadingDialog();

            AppAlertDialog.validateAlerts(
                Get.context!, AppStrings.error, AppStrings.accountNotActive);
          } else {
            await authController.persistUserName();

            // unnecessary
            await authController.jsonFileOperations.offlineLoadSuppliersData();
            await authController.jsonFileOperations.offlineLoadDeliveredFrom();
            await authController.jsonFileOperations.offlineLoadCarriersData();
            await authController.jsonFileOperations.offlineLoadCommodityData();

            await authController.downloadCloudData();
          }
        } else {
          // Utils.hideLoadingDialog();
        }
      } catch (e) {
        Utils.hideLoadingDialog();
        debugPrint('doLoginAction ${e.toString()}');
        if (e is CustomException) {
          // info alert dialog
          AppAlertDialog.validateAlerts(
              Get.context!, AppStrings.error, e.message);
        }
      }
    }
  }
}
