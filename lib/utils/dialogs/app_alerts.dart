// ignore_for_file: prefer_const_constructors, unused_local_variable

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/adaptive_alert.dart';
import 'package:pverify/utils/theme/colors.dart';

class AppAlertDialog {
  static void validateAlerts(
      BuildContext context, String title, String message) {
    AdaptiveAlert.customAlert(context,
        title: Text(
          title,
          style: Get.textTheme.titleLarge!.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
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
                AppStrings.ok,
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primary,
                ),
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
          style: Get.textTheme.titleLarge!.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        content: SizedBox(
          width: windowWidth,
          child: TextFormField(
            style: Get.textTheme.titleLarge!
                .copyWith(fontSize: 30.sp, fontWeight: FontWeight.normal),
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
              hintStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 30.sp,
                fontWeight: FontWeight.normal,
                color: AppColors.hintColor,
              ),
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
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primary,
                ),
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
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primary,
                ),
              )),
        ]);
  }

  static void confirmationAlert(
      BuildContext context, String title, String message,
      {required Function()? onYesTap, Function()? onNOTap}) {
    AdaptiveAlert.customAlert(context,
        title: Text(
          title,
          style: Get.textTheme.titleLarge!.copyWith(
            fontSize: 28.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          message,
          style: Get.textTheme.titleLarge!.copyWith(
            fontSize: 25.sp,
            fontWeight: FontWeight.normal,
          ),
        ),
        actions: [
          TextButton(
              onPressed: onNOTap ??
                  () {
                    Get.back();
                  },
              child: Text(
                AppStrings.cancel,
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primary,
                ),
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
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 26.sp,
                  fontWeight: FontWeight.normal,
                  color: AppColors.primary,
                ),
              )),
        ]);
  }

  static void customAlert(BuildContext context, Widget content,
      List<Widget> actions, Widget title) {
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
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              backgroundColor: Theme.of(context).colorScheme.background,
              title: title,
              content: content,
              actions: actions,
            ),
          );
  }

  static void showSeverityItemDialog({
    required BuildContext context,
    required Widget titleWidget,
    required String title,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(0),
          ),
          insetPadding: EdgeInsets.zero,
          titlePadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.zero,
          buttonPadding: EdgeInsets.zero,
          iconPadding: EdgeInsets.zero,
          title: Container(
            color: AppColors.defectOrange,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  titleWidget,
                  SizedBox(width: 10),
                  Text(title, style: Get.textTheme.titleMedium),
                ],
              ),
            ),
          ),
          content: null,
          actions: [
            TextButton(
              onPressed: () {
                Get.back();
              },
              child: const Text(
                AppStrings.ok,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
