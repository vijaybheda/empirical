import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/alert.dart';
import 'package:pverify/utils/theme/colors.dart';

class UpdateDataAlert {
  static void showUpdateDataDialog(
    BuildContext context, {
    String? message,
    Function()? onOkPressed,
  }) {
    return customAlert(context,
        title: Text(
          AppStrings.alert,
          style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        content: Text(
          message ?? AppStrings.updateDataConfirmation,
          style: GoogleFonts.poppins(
              fontSize: 25.sp,
              fontWeight: FontWeight.normal,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        actions: [
          InkWell(
              onTap: () {
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
          InkWell(
              onTap: () {
                Get.back();
                if (onOkPressed != null) {
                  onOkPressed();
                }
              },
              child: Text(
                AppStrings.ok,
                style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.primary)),
              )),
        ]);
  }
}
