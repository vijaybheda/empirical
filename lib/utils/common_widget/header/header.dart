// ignore_for_file: void_checks, dead_code, unused_element, non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/utils/common_widget/header/header_controller.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

Widget baseHeaderView(String title, bool isVersionShow) {
  var headerController = Get.put(HeaderController());

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
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 38.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              isVersionShow
                  ? Obx(
                      () => Text(
                        headerController.appVersion.value,
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
              Obx(
                () => Image.asset(
                  headerController.wifiImage1.value,
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
  String apiHost = ApiUrls.serverUrl;
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
    style: Get.textTheme.titleLarge!.copyWith(
      fontSize: 20.sp,
      fontWeight: FontWeight.bold,
    ),
  );
}
