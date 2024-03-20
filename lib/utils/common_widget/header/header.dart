// ignore_for_file: void_checks, dead_code, unused_element

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/common_widget/header/wifi_controller.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

Widget baseHeaderView(String title, bool isVersionShow) {
  return GetBuilder(
      id: "wifiLevel",
      init: WifiController(),
      builder: (controller) {
        return Container(
          color: AppColors.primary,
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
              Text(
                title,
                style: GoogleFonts.poppins(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    textStyle: TextStyle(color: AppColors.white)),
              ),
              Spacer(),
              isVersionShow
                  ? Text(
                      '10.19.7',
                      style: GoogleFonts.poppins(
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold,
                          textStyle: TextStyle(color: AppColors.white)),
                    )
                  : Container(),
              SizedBox(
                width: 40.w,
              ),
              Obx(
                () => Image.asset(
                  controller.wifiImage1.value,
                  width: 70.w,
                  height: 70.w,
                ),
              ),
            ],
          ),
        );
      });
}

Widget _buildWifiIcon(int level) {
  String wifiImage;
  if (level <= -50 && level >= -60) {
    wifiImage = AppImages.ic_Wifi_bar_3;
  } else if (level <= -61 && level >= -70) {
    wifiImage = AppImages.ic_Wifi_bar_3;
  } else if (level <= -71 && level >= -80) {
    wifiImage = AppImages.ic_Wifi_bar_2;
  } else if (level <= -81 && level >= -90) {
    wifiImage = AppImages.ic_Wifi_bar_1;
  } else if (level <= -91) {
    wifiImage = AppImages.ic_Wifi_off;
  } else {
    wifiImage = AppImages.ic_Wifi_off;
  }

  return Image.asset(
    wifiImage,
    width: 70.w,
    height: 70.w,
  );
}
