import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/alert.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class FooterContentView extends StatelessWidget {
  final void Function()? onDownloadTap;

  const FooterContentView({super.key, this.onDownloadTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      height: 120.h,
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
            ),
          ),
          const Spacer(),
          Text(
            AppStrings.data0DaysOld,
            style: GoogleFonts.poppins(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                textStyle: TextStyle(color: AppColors.white)),
          ),
          SizedBox(
            width: 40.w,
          ),
          InkWell(
            onTap: () {
              debugPrint('Download button tap.');
              if (onDownloadTap != null) {
                onDownloadTap!();
              }
            },
            child: Image.asset(
              AppImages.ic_download,
              width: 80.w,
              height: 80.h,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              showLogoutConfirmation(context);
            },
            child: Text(
              AppStrings.logOut,
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
            ),
          )
        ],
      ),
    );
  }

  void showLogoutConfirmation(BuildContext context) {
    return customAlert(context,
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
              },
              child: Text(
                AppStrings.yes,
                style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.primary)),
              )),
        ]);
  }
}
