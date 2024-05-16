import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/adaptive_alert.dart';
import 'package:pverify/utils/theme/colors.dart';

class UpdateDataAlert {
  static void showUpdateDataDialog(
    BuildContext context, {
    String? message,
    Function()? onOkPressed,
  }) {
    return AdaptiveAlert.customAlert(context,
        title: Text(
          AppStrings.alert,
          style: Get.textTheme.titleLarge!.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: Text(
          message ?? AppStrings.updateDataConfirmation,
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
              onPressed: () {
                Get.back();
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: Text(
                AppStrings.ok,
                style: Get.textTheme.titleLarge!.copyWith(
                  color: AppColors.primary,
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                ),
              )),
        ]);
  }
}
