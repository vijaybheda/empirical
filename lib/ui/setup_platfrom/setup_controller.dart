// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_strings.dart';

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

  bool isSetupFieldsValidate() {
    if (banner1TextController.value.text.trim().isEmpty) {
      AppSnackBar.getCustomSnackBar(AppStrings.banner1Blank, AppStrings.error,
          isSuccess: false);
      return false;
    }
    if (banner2TextController.value.text.trim().isEmpty) {
      AppSnackBar.getCustomSnackBar(AppStrings.banner2Blank, AppStrings.error,
          isSuccess: false);
      return false;
    }
    if (banner3TextController.value.text.trim().isEmpty) {
      AppSnackBar.getCustomSnackBar(AppStrings.serverUrlBlank, AppStrings.error,
          isSuccess: false);
      return false;
    }
    return true;
  }
}
