import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/cache_download_controller.dart';
import 'package:pverify/utils/app_strings.dart';

class CacheDownloadScreen extends GetWidget<CacheDownloadController> {
  const CacheDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CacheDownloadController>(
        init: CacheDownloadController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Get.theme.colorScheme.background,
            appBar: AppBar(
              leading: const Offstage(),
              title: const Text('Cache Download'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  /// loading indicator
                  const Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator.adaptive(),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    AppStrings.cacheDataForOffline,
                    textAlign: TextAlign.center,
                    style: Get.textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          );
        });
  }
}
