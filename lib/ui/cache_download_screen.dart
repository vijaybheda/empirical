import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/cache_download_controller.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class CacheDownloadScreen extends GetWidget<CacheDownloadController> {
  const CacheDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CacheDownloadController>(
        init: CacheDownloadController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: AppColors.blue,
            appBar: AppBar(
              leading: const Offstage(),
              leadingWidth: 0,
              title: Text(AppStrings.cacheDownload,
                  style: Get.textTheme.titleMedium
                      ?.copyWith(color: Colors.white, fontSize: 30)),
              backgroundColor: AppColors.blue,
              foregroundColor: AppColors.blue,
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  /// loading indicator
                  const Center(
                    child: SizedBox(
                      height: 25,
                      width: 25,
                      child: ProgressAdaptive(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    AppStrings.cacheDataForOffline,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 27,
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
