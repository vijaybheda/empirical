// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/alert.dart';

class SetupController extends GetxController {
  List dateformats = AppStrings.dateFormats;
  final banner1TextController = TextEditingController().obs;
  final banner2TextController = TextEditingController().obs;
  final banner3TextController = TextEditingController().obs;
  var selectetdDateFormat = 'mm-dd-yyyy'.obs;

  void setSelected(String value) {
    selectetdDateFormat.value = value;
  }

  @override
  void onInit() {
    super.onInit();
  }

  // SETUP SCREEN VALIDATION'S

  bool isSetupFieldsValidate(BuildContext context) {
    if (banner1TextController.value.text.trim().isEmpty) {
      validateAlerts(context, AppStrings.error, AppStrings.banner1Blank);
      return false;
    }
    if (banner2TextController.value.text.trim().isEmpty) {
      validateAlerts(context, AppStrings.error, AppStrings.banner2Blank);
      return false;
    }
    if (banner3TextController.value.text.trim().isEmpty) {
      validateAlerts(context, AppStrings.error, AppStrings.serverUrlBlank);
      return false;
    }
    return true;
  }
}
