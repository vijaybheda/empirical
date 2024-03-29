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
              onPressed: () async {
                // TODO: uncomment this code to enable barcode scanning

                /*String? res = await Get.to(() => SimpleBarcodeScannerPage(
                      scanType: ScanType.barcode,
                      centerTitle: true,
                      appBarTitle: 'Scan a Barcode',
                      cancelButtonText: 'Cancel',
                      isShowFlashIcon: true,
                      lineColor: AppColors.primaryColor.value.toString(),
                    ));
                if (res != null) {
                  if (onBarcodeScanned != null) {
                    onBarcodeScanned!(res);
                  }
                  'Scanned: $res'
                } else {
                'Cancelled'

                }*/

                if (onBarcodeScanned != null) {
                  // onBarcodeScanned!('(01)1233455566778(13)090818(10)912');

                  // /// Production Date= 11 > Yellow Peppers Bulk
                  // onBarcodeScanned!('(01)10012345612340(11)180322(10)01234');

                  // /// Due Date= 12 > Yellow Peppers Bulk
                  // onBarcodeScanned!('(01)10012345612340(12)180322(10)01234');
                  //
                  // /// Pack Date= 13 > Yellow Peppers Bulk
                  // onBarcodeScanned!('(01)10012345612340(13)180322(10)01234');
                  //
                  /// Date does not change represented by = 14 > Only displays GTIN# > Yellow Peppers Bulk
                  onBarcodeScanned!('(01)10012345612340(14)180322(10)01234');
                  //
                  // /// Best Used Before Date= 15 > Yellow Peppers Bulk
                  // onBarcodeScanned!('(01)10012345612340(15)180322(10)01234');
                  //
                  // /// Sell By Date= 16 > Yellow Peppers Bulk
                  // onBarcodeScanned!('(01)10012345612340(16)180322(10)01234');
                  //
                  // /// Expiration Date= 17 > Yellow Peppers Bulk
                  // onBarcodeScanned!('(01)10012345612340(17)180322(10)01234');
                  //
                  // /// Production Date= 11 > Tomato Beef STK
                  // onBarcodeScanned!('(01)10851059002829(11)240101(10)99123');
                  //
                  // /// Due Date= 12 > Tomato Beef STK
                  // onBarcodeScanned!('(01)10851059002829(12)240101(10)99123');
                  //
                  // /// Pack Date= 13 > Tomato Beef STK
                  // onBarcodeScanned!('(01)10851059002829(13)240101(10)99123');
                  //
                  // /// Date does not change represented by = 14 > Only displays GTIN# > > Tomato Beef STK
                  // onBarcodeScanned!('(01)10851059002829(14)240101(10)99123');
                  //
                  // /// Best Used Before Date= 15 > Tomato Beef STK
                  // onBarcodeScanned!('(01)10851059002829(15)240101(10)99123');
                  //
                  // /// Sell By Date= 16 > Tomato Beef STK
                  // onBarcodeScanned!('(01)10851059002829(16)240101(10)99123');
                  //
                  // /// Expiration Date= 17 > Tomato Beef STK
                  // onBarcodeScanned!('(01)10851059002829(17)240101(10)99123');
                }
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
