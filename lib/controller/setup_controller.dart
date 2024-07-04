// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';

class SetupController extends GetxController {
  List<String> allDateFormats = AppStrings.allDateFormats;
  final banner1TextController = TextEditingController().obs;
  final banner2TextController = TextEditingController().obs;
  final banner3TextController = TextEditingController().obs;
  RxString selectedDateFormat = AppStrings.allDateFormats.first.obs;
  AppStorage appStorage = AppStorage.instance;

  @override
  void onInit() {
    super.onInit();
    selectedDateFormat.value = appStorage.getDateFormat() ?? 'dd-MM-yyyy';
  }

  void setSelected(String value) {
    selectedDateFormat.value = value;
    appStorage.setDateFormat(selectedDateFormat.value);
  }

  // SETUP SCREEN VALIDATION'S

  bool isSetupFieldsValidate(BuildContext context) {
    if (banner1TextController.value.text.trim().isEmpty) {
      AppAlertDialog.validateAlerts(
          context, AppStrings.error, AppStrings.banner1Blank);
      return false;
    }
    if (banner2TextController.value.text.trim().isEmpty) {
      AppAlertDialog.validateAlerts(
          context, AppStrings.error, AppStrings.banner2Blank);
      return false;
    }
    if (banner3TextController.value.text.trim().isEmpty) {
      AppAlertDialog.validateAlerts(
          context, AppStrings.error, AppStrings.serverUrlBlank);
      return false;
    }
    return true;
  }
}
