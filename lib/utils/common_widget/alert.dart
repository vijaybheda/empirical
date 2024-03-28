// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

void customAlert(
  context, {
  required Text title,
  required Text content,
  required List<Widget> actions,
}) {
  Platform.isIOS || Platform.isMacOS
      ? showCupertinoDialog<String>(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => Theme(
            data: ThemeData.dark(),
            child: CupertinoAlertDialog(
              title: title,
              content: content,
              actions: actions,
            ),
          ),
        )
      : showDialog(
          barrierDismissible: false,
          context: context,
          builder: (BuildContext context) => AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(5))),
            backgroundColor: Theme.of(context).colorScheme.background,
            title: title,
            content: content,
            actions: actions,
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
        TextButton(
            onPressed: () {
              navigator?.pop();
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
            onPressed: () {
              navigator?.pop();
            },
            child: Text(
              AppStrings.yes,
              style: GoogleFonts.poppins(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  textStyle: TextStyle(color: AppColors.primary)),
            ))
      ]);
}
