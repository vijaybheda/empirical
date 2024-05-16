import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/adaptive_alert.dart';
import 'package:pverify/utils/theme/colors.dart';

class UserLogoutDialog {
  static void showLogoutConfirmation(
    BuildContext context, {
    required Function()? onYesTap,
  }) {
    return AdaptiveAlert.customAlert(
      context,
      title: Text(
        AppStrings.alert,
        style: Get.textTheme.titleLarge!
            .copyWith(fontSize: 28.sp, fontWeight: FontWeight.w500),
      ),
      content: Text(
        AppStrings.logoutConfirmation,
        style: Get.textTheme.titleLarge!.copyWith(
          fontSize: 25.sp,
          fontWeight: FontWeight.normal,
        ),
      ),
      actions: [
        TextButton(
            onPressed: () {
              Get.back();
            },
            child: Text(
              AppStrings.cancel,
              style: Get.textTheme.titleLarge!.copyWith(
                color: AppColors.primary,
                fontSize: 26.sp,
                fontWeight: FontWeight.normal,
              ),
            )),
        SizedBox(
          width: 10.w,
        ),
        TextButton(
          onPressed: () async {
            Get.back();
            if (onYesTap != null) {
              onYesTap();
            }
          },
          child: Text(
            AppStrings.yes,
            style: Get.textTheme.titleLarge!.copyWith(
              color: AppColors.primary,
              fontSize: 26.sp,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }
}
