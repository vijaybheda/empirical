import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/theme/magic_number.dart';

class AppSnackBar {
  static void getCustomSnackBar(
    String message,
    String? title, {
    bool isSuccess = true,
    int duration = 3,
    void Function()? onMainButtonPress,
    void Function(SnackbarStatus?)? snackbarStatus,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.rawSnackbar(
      snackbarStatus: snackbarStatus,
      mainButton: onMainButtonPress != null
          ? TextButton(
              onPressed: onMainButtonPress,
              child: Text(
                "Undo",
                style: Get.textTheme.bodySmall
                    ?.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.normal,
                      color: AppColors.textColor,
                    )
                    .copyWith(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            )
          : null,
      borderRadius: 8,
      titleText: Padding(
        padding: const EdgeInsets.only(left: 18.0),
        child: Text(
          message,
          style: Get.textTheme.bodySmall
              ?.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontStyle: FontStyle.normal,
                color: AppColors.textColor,
              )
              .copyWith(fontWeight: FontWeight.w600, color: AppColors.black),
        ),
      ),
      messageText: Padding(
        padding: const EdgeInsets.only(left: 18.0),
        child: Text(
          title ?? "",
          style: Get.textTheme.labelLarge?.copyWith(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
            color: Colors.grey,
          ),
        ),
      ),
      backgroundColor: AppColors.white,
      icon: SizedBox(
        height: 60 * magicNumber,
        width: 4 * magicNumber,
        child: Wrap(
          direction: Axis.vertical,
          alignment: WrapAlignment.center,
          children: [
            Container(
              margin: const EdgeInsets.only(left: 12, top: 12, bottom: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              height: 44 * magicNumber,
              width: 3 * magicNumber,
              decoration: BoxDecoration(
                color:
                    isSuccess ? AppColors.accentColor : AppColors.warningColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(7),
              margin: const EdgeInsets.only(left: 8),
              height: 28 * magicNumber,
              width: 28 * magicNumber,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color:
                    isSuccess ? AppColors.accentColor : AppColors.warningColor,
              ),
              // child: isSuccess
              //     ? Image.asset(AppImages.doneIcon)
              //     : Image.asset(AppImages.alertIcon),
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
      boxShadows: AppConst.shadow,
      margin: const EdgeInsets.all(16),
      duration: Duration(seconds: duration),
      snackPosition: SnackPosition.BOTTOM,
      padding: const EdgeInsets.all(0),
    );
  }

  static void error({
    String title = AppStrings.error,
    required String message,
    Color backgroundColor = Colors.red,
    Icon icon = const Icon(Icons.error),
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  static void info({
    String title = AppStrings.info,
    required String message,
    Color backgroundColor = Colors.black,
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      duration: duration,
    );
  }

  static void success({
    String title = AppStrings.success,
    required String message,
    Color backgroundColor = Colors.green,
    Icon icon = const Icon(Icons.check),
    Duration duration = const Duration(seconds: 2),
  }) {
    _showSnackbar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
    );
  }

  static void _showSnackbar({
    required String title,
    required String message,
    required Color backgroundColor,
    Icon? icon,
    required Duration duration,
  }) {
    if (Get.isSnackbarOpen) {
      Get.closeCurrentSnackbar();
    }
    Get.showSnackbar(GetSnackBar(
      title: title,
      message: message,
      backgroundColor: backgroundColor,
      icon: icon,
      duration: duration,
      key: Key(title.runtimeType.toString()),
    ));
  }
}
