import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class DrawerHeaderContentView extends StatelessWidget {
  final String title;
  final String? message;
  final bool isVersionShow;

  DrawerHeaderContentView({
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
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            iconSize: 24,
            icon: Icon(
              Icons.menu_outlined,
              color: AppColors.white,
            ),
            onPressed: () {
              Scaffold.of(context).isDrawerOpen
                  ? Scaffold.of(context).openEndDrawer()
                  : Scaffold.of(context).openDrawer();
            },
          ),
          Expanded(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 15.w,
                ),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.poppins(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w600,
                        textStyle: TextStyle(color: AppColors.white)),
                  ),
                ),
                message != null
                    ? Expanded(
                        child: Text(
                          message ?? '',
                          style: GoogleFonts.poppins(
                              fontSize: 38.sp,
                              fontWeight: FontWeight.w600,
                              textStyle: TextStyle(color: AppColors.white)),
                        ),
                      )
                    : const Offstage(),
                // const Spacer(),
                isVersionShow
                    ? Obx(
                        () => Text(
                          globalConfigController.appVersion.value,
                          style: GoogleFonts.poppins(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                              textStyle: TextStyle(color: AppColors.white)),
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
          ),
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
