import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/login_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/dialogs/user_logout.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class FooterContentView extends StatelessWidget {
  final void Function()? onDownloadTap;

  final ApplicationDao dao = ApplicationDao();
  final AppStorage appStorage = AppStorage.instance;

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  FooterContentView({super.key, this.onDownloadTap});

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      height: 120.h + (bottomPadding * .5),
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              Get.back();
            },
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
            ),
          ),
          const Spacer(),
          Text(
            getDaysMessage(),
            style: GoogleFonts.poppins(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                textStyle: TextStyle(color: getMessageColor())),
          ),
          SizedBox(
            width: 40.w,
          ),
          GestureDetector(
            onTap: () async {
              debugPrint('Download button tap.');
              if (onDownloadTap != null) {
                onDownloadTap!();
              } else {
                if (globalConfigController.hasStableInternet.value) {
                  UpdateDataAlert.showUpdateDataDialog(
                    context,
                    onOkPressed: () {
                      debugPrint('Download button tap.');
                      Get.off(() => const CacheDownloadScreen());
                    },
                    message: AppStrings.updateDataConfirmation,
                  );
                } else {
                  UpdateDataAlert.showUpdateDataDialog(context,
                      onOkPressed: () {
                    debugPrint('Download button tap.');
                  }, message: AppStrings.downloadWifiError);
                }
              }
            },
            child: Image.asset(
              AppImages.ic_download,
              width: 80.w,
              height: 80.h,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              UserLogoutDialog.showLogoutConfirmation(context,
                  onYesTap: () async {
                await appLogoutAction();
              });
            },
            child: Text(
              AppStrings.logOut,
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
            ),
          )
        ],
      ),
    );
  }

  String getDaysMessage() {
    int remainDays = Utils().checkCacheDays();
    return 'Data $remainDays days old.';
  }

  Color getMessageColor() {
    int remainDays = Utils().checkCacheDays();
    if (remainDays == 1) {
      return AppColors.white;
    } else if (remainDays < 2) {
      return AppColors.white;
    } else if (remainDays >= 2 && remainDays < 5) {
      return AppColors.yellow;
    } else if (remainDays >= 5 && remainDays < 7) {
      return AppColors.orange;
    } else {
      return AppColors.red;
    }
  }

  Future<void> appLogoutAction() async {
    int tempTrailer = await dao.deleteRowsTempTrailerTable();
    log('Deleted $tempTrailer rows from temp_trailer table.');
    int tempTrailerDetail = await dao.deleteTempTrailerTemperatureDetails();
    log('Deleted $tempTrailerDetail rows from temp_trailer_temperature_details table.');
    await appStorage.removeDataByKey(StorageKey.kFinishedGoodsItemSKUList);
    int selectedItemSku = await dao.deleteSelectedItemSKUList();
    log('Deleted $selectedItemSku rows from selected_item_sku_list table.');
    Get.offAll(() => const LoginScreen());
  }
}
