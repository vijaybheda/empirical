// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/upload_inspections.dart';
import 'package:pverify/ui/login_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/user_logout.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class FooterContentView extends StatelessWidget {
  final void Function()? onDownloadTap;
  final void Function()? onBackTap;

  final ApplicationDao dao = ApplicationDao();
  final AppStorage appStorage = AppStorage.instance;
  bool hasLeftButton = true;
  final String? leftText;

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  FooterContentView({
    super.key,
    this.onDownloadTap,
    this.onBackTap,
    this.hasLeftButton = true,
    this.leftText,
  });

  @override
  Widget build(BuildContext context) {
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.only(
            left: 15,
            right: 15,
          ),
          height: 120.h,
          color: AppColors.primary,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  child: hasLeftButton
                      ? GestureDetector(
                          onTap: () {
                            if (onBackTap != null) {
                              onBackTap!();
                            } else {
                              Get.back();
                            }
                          },
                          child: Text(
                            leftText ?? AppStrings.back,
                            style: Get.textTheme.titleLarge!.copyWith(
                                color: AppColors.textFieldText_Color,
                                fontSize: 35.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        )
                      : const Offstage(),
                ),
              ),
              Expanded(
                flex: 4,
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getDaysMessage(),
                      style: Get.textTheme.titleLarge!.copyWith(
                          color: getMessageColor(),
                          fontSize: 40.sp,
                          fontWeight: FontWeight.bold),
                    ),
                    SizedBox(
                      width: 20.w,
                    ),
                    GestureDetector(
                      onTap: () async {
                        debugPrint('Download button tap.');
                        if (onDownloadTap != null) {
                          onDownloadTap!();
                        } else {
                          UploadInspections().onDownloadTap();

                          /// below code can be use before app update, when this function return callback then consider user can update app
                          /*UploadInspections().onDownloadTap(onUpdateAppCallback: () {
                            debugPrint('onUpdateAppCallback');
                          });*/
                        }
                      },
                      child: Image.asset(
                        AppImages.ic_download,
                        width: 80.w,
                        height: 80.h,
                        color: getMessageColor(),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: GestureDetector(
                  onTap: () {
                    UserLogoutDialog.showLogoutConfirmation(context,
                        onYesTap: () async {
                      await appLogoutAction();
                    });
                  },
                  child: Text(
                    AppStrings.logOut,
                    style: Get.textTheme.titleLarge!.copyWith(
                        color: AppColors.textFieldText_Color,
                        fontSize: 35.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          height: bottomPadding,
          color: AppColors.primary,
        )
      ],
    );
  }

  String getDaysMessage() {
    int remainDays = Utils().checkCacheDays();
    return 'Data $remainDays days old';
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
