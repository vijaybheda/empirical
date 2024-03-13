import 'dart:developer';

import 'package:get/get.dart';
import 'package:pverify/utils/app_storage.dart';

class GlobalConfigController extends GetxController {
  AppStorage appStorage = AppStorage.instance;

  @override
  void onInit() {
    log('GlobalConfigController onInit');
    super.onInit();
  }

  GlobalConfigController();
}
