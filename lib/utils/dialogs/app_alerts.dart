// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/adaptive_alert.dart';
import 'package:pverify/utils/theme/colors.dart';

class AppAlertDialog {
  static void validateAlerts(
      BuildContext context, String title, String message) {
    AdaptiveAlert.customAlert(context,
        title: Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
              fontSize: 25.sp,
              fontWeight: FontWeight.normal,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        actions: [
          TextButton(
              onPressed: () {
                navigator?.pop();
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

  static void textfiAlert(
    BuildContext context,
    String title,
    String message, {
    required Function(String? value)? onYesTap,
    double? windowWidth,
    bool? isMultiLine = false,
    String? value = '',
  }) {
    String textFieldValue = value ?? "";
    AdaptiveAlert.customAlertWithTextField(context,
        title: Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        content: SizedBox(
          width: windowWidth,
          child: TextFormField(
            style: GoogleFonts.poppins(
                fontSize: 30.sp,
                fontWeight: FontWeight.normal,
                textStyle: TextStyle(color: AppColors.white)),
            maxLines: isMultiLine == true ? null : 1,
            cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
            initialValue: value,
            decoration: InputDecoration(
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.hintColor),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              hintText: '',
              hintStyle: GoogleFonts.poppins(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.normal,
                  textStyle: TextStyle(color: AppColors.hintColor)),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 5),
            ),
            onChanged: (value) {
              textFieldValue = value;
            },
          ),
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
          TextButton(
              onPressed: () {
                Get.back();
                if (onYesTap != null) {
                  onYesTap(textFieldValue);
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

  static void confirmationAlert(
      BuildContext context, String title, String message,
      {required Function()? onYesTap, Function()? onNOTap}) {
    AdaptiveAlert.customAlert(context,
        title: Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        content: Text(
          message,
          style: GoogleFonts.poppins(
              fontSize: 25.sp,
              fontWeight: FontWeight.normal,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        actions: [
          TextButton(
              onPressed: onNOTap ??
                  () {
                    Get.back();
                  },
              child: Text(
                AppStrings.cancel,
                style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.primary)),
              )),
          TextButton(
              onPressed: () {
                Get.back();
                if (onYesTap != null) {
                  onYesTap();
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
