// ignore_for_file: void_checks, dead_code, unused_element

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/common_widget/header/header_controller.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

Widget baseHeaderView(String title, bool isVersionShow) {
  return GetBuilder(
      id: "wifiLevel",
      init: HeaderController(),
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
              const Spacer(),
              isVersionShow
                  ? Obx(
                      () => Text(
                        controller.appVersion.value,
                        style: GoogleFonts.poppins(
                            fontSize: 40.sp,
                            fontWeight: FontWeight.bold,
                            textStyle: TextStyle(color: AppColors.white)),
                      ),
                    )
                  : Container(),
              isVersionShow ? getEnvText() : Container(),
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

Widget getEnvText() {
  String apiHost = const String.fromEnvironment('API_HOST');
  String env = '';
  if (apiHost.contains('appqa')) {
    env = ' QA';
  } else if (apiHost.contains('stage')) {
    env = ' STAGE';
  } else if (apiHost.contains('demo')) {
    env = ' DEMO';
  }

  if (env.isEmpty) {
    return const Offstage();
  }
  return Text(
    env,
    style: GoogleFonts.poppins(
        fontSize: 20.sp,
        fontWeight: FontWeight.bold,
        textStyle: TextStyle(color: AppColors.white)),
  );
}
