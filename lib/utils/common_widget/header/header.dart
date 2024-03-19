import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/common_widget/header/wifi_controller.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';


Widget baseHeaderView(String title, bool isVersionShow) {

  //final WifiController wifiController = Get.put(WifiController());

  return GetBuilder(
    id: "wifiLevel",
    init: WifiController(),
    builder: (wifiController) {
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
             _buildWifiIcon(wifiController.wifiLevel.value),
          ],
        ),
      );
    }
  );
}

Widget _buildWifiIcon(int level) {
  String wifiImage;
  if (level >= 4) {
    wifiImage =  AppImages.ic_Wifi_bar_3;
  } else if (level == 3) {
    wifiImage = AppImages.ic_Wifi_bar_3;
  } else if (level == 2) {
    wifiImage = AppImages.ic_Wifi_bar_2;
  } else if (level == 1) {
    wifiImage = AppImages.ic_Wifi_bar_1;
  } else if (level <= 0){
    wifiImage = AppImages.ic_Wifi_off;
  }
  else{
    wifiImage = AppImages.ic_Wifi;
  }

  return Image.asset(wifiImage,width: 70.w,height: 70.w,);
}
