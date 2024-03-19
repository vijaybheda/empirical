import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pverify/utils/images.dart';

Widget buildWifiIcon(int level) {
  String wifiImage;
  if (level >= -50) {
    wifiImage =  AppImages.ic_Wifi_bar_3;
  } else if (level >= -60) {
    wifiImage = AppImages.ic_Wifi_bar_3;
  } else if (level >= -70) {
    wifiImage = AppImages.ic_Wifi_bar_2;
  } else if (level >= -80) {
    wifiImage = AppImages.ic_Wifi_bar_1;
  } else {
    wifiImage = AppImages.ic_Wifi_off;
  }

  return Image.asset(wifiImage,width: 70.w,height: 70.h,);
}
