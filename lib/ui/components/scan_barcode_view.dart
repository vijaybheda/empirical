import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class ScanBarcodeView extends StatelessWidget {
  final Function(String barcode)? onBarcodeScanned;

  ScanBarcodeView({
    super.key,
    this.onBarcodeScanned,
  });

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.hintColor,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: Implement barcode scanning
                onBarcodeScanned?.call('1234567890');
              },
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(AppColors.white),
                padding: MaterialStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
                minimumSize: MaterialStateProperty.all(Size(.8.sw, .07.sw)),
              ),
              child: Text('Scan Barcode',
                  style: Get.textTheme.titleLarge!.copyWith(
                      color: AppColors.black,
                      fontSize: 25.sp,
                      fontWeight: FontWeight.w700)),
            ),
          )
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
