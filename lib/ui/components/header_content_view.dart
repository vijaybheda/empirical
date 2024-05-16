import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class HeaderContentView extends StatelessWidget {
  final String title;
  final String? message;
  final bool isVersionShow;

  HeaderContentView({
    super.key,
    this.title = AppStrings.appName,
    this.message,
    this.isVersionShow = false,
  });

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Image.asset(
            AppImages.appLogo,
            width: 90.w,
            height: 90.h,
          ),
          SizedBox(
            width: 15.w,
          ),
          Expanded(
            child: Text(
              title,
              style: Get.textTheme.titleLarge!.copyWith(
                fontSize: 38.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          message != null
              ? Expanded(
                  child: Text(
                    message ?? '',
                    style: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                )
              : const Offstage(),
          // const Spacer(),
          isVersionShow
              ? Obx(
                  () => Text(
                    globalConfigController.appVersion.value,
                    style: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Container(),
          // isVersionShow ? getEnvText() : Container(),
          SizedBox(
            width: 40.w,
          ),
          StreamBuilder(
              stream: globalConfigController.wifiLevelStream,
              builder: (_, __) {
                return Image.asset(
                  getWifiImagePath(),
                  width: 70.w,
                  height: 70.w,
                );
              })
        ],
      ),
    );
  }

  String getWifiImagePath() {
    int wifiLevel = globalConfigController.wifiLevel.value;

    if (wifiLevel == 0) {
      return AppImages.ic_Wifi_off;
    } else if (wifiLevel == 1) {
      return AppImages.ic_Wifi_bar_1;
    } else if (wifiLevel == 2) {
      return AppImages.ic_Wifi_bar_2;
    } else if (wifiLevel == 3) {
      return AppImages.ic_Wifi_bar_3;
    } else if (wifiLevel == 4) {
      return AppImages.ic_Wifi_bar_4;
    } else {
      return AppImages.ic_Wifi_bar_4;
    }
  }
}
