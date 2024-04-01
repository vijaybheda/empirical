import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/adaptive_alert.dart';
import 'package:pverify/utils/theme/colors.dart';

class UserLogoutDialog {
  static void showLogoutConfirmation(
    BuildContext context, {
    required Function()? onYesTap,
  }) {
    return AdaptiveAlert.customAlert(context,
        title: Text(
          AppStrings.alert,
          style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        content: Text(
          AppStrings.logoutConfirmation,
          style: GoogleFonts.poppins(
              fontSize: 25.sp,
              fontWeight: FontWeight.normal,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        actions: [
          TextButton(
              onPressed: () {
                Get.back();
              },
              child: Text(
                AppStrings.cancel,
                style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.primary)),
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
                style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.bold,
                    textStyle: TextStyle(color: AppColors.primary)),
              )),
        ]);
  }
}
