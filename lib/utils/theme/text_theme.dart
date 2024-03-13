import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/theme/colors.dart';

class AppFontStyle {
  /// Font size 24
  static final TextStyle? displayLarge = Get.textTheme.displayLarge?.copyWith(
    fontSize: 26,
    color: AppColors.textColor,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
  );

  /// Font size 22
  static final TextStyle? titleLarge = Get.textTheme.titleLarge?.copyWith(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    fontStyle: FontStyle.normal,
    color: AppColors.white,
  );

  /// Font size 20
  static final TextStyle? bodyLarge = Get.textTheme.bodyLarge?.copyWith(
    fontSize: 22,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    color: AppColors.textColor,
  );

  /// Font size 14
  static final TextStyle? bodyMedium = Get.textTheme.bodyMedium?.copyWith(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontStyle: FontStyle.normal,
    color: AppColors.white,
  );

  /// Font size 12
  static final TextStyle? bodySmall = Get.textTheme.bodySmall?.copyWith(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: AppColors.textColor,
  );

  /// Font size 10
  static final TextStyle? labelLarge = Get.textTheme.labelLarge?.copyWith(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontStyle: FontStyle.normal,
    color: AppColors.textColor,
  );
}
