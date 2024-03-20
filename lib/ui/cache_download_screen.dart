import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/cache_download_controller.dart';

class CacheDownloadScreen extends GetWidget<CacheDownloadController> {
  const CacheDownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CacheDownloadController>(
        init: CacheDownloadController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              title: const Text('Cache Download'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  /// loading indicator

                  Center(
                    child: SizedBox(
                      height: 50,
                      width: 50,
                      child: CircularProgressIndicator(),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
