import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/cache_download_controller.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';

class CacheDownloadScreen extends GetWidget<CacheDownloadController> {
  const CacheDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: GetBuilder<CacheDownloadController>(
          init: CacheDownloadController(),
          builder: (controller) {
            return Scaffold(
              backgroundColor: Get.theme.colorScheme.background,
              appBar: null,
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
                        fontSize: 27,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
    );
  }
}
