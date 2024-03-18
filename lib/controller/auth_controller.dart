// ignore_for_file: unrelated_type_equality_checks

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/user_model.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/constants.dart';
import 'package:pverify/utils/strings.dart';

class AuthController extends GetxController {
  bool isLoading = false;

  UserModel? userModel;
  final emailTextController = TextEditingController().obs;
  final passwordTextController = TextEditingController().obs;

  bool socialButtonVisible = true;
  AppStorage appStorage = AppStorage.instance;

  bool isLoggedIn() {
    UserModel? userData = AppStorage.instance.getUserData();

    return userData != null;
  }

  Future<void> userLogout() async {
    //get user data
    AppStorage appStorage = AppStorage.instance;
    // UserModel? userData = appStorage.getUserData();
    //user data remove
    await appStorage.appLogout();
  }

  bool isLoginFieldsValidate() {
    if (Get.find<AuthController>().emailTextController.value.text.isEmpty) {
      AppSnackBar.getCustomSnackBar(Appstrings.UserName_Blank, Appstrings.Error,
          isSuccess: false);
      return false;
    }
    if (validateEmail(
            Get.find<AuthController>().emailTextController.value.text) ==
        true) {
      AppSnackBar.getCustomSnackBar(Appstrings.UserName_Valid, Appstrings.Error,
          isSuccess: false);
      return false;
    }
    if (Get.find<AuthController>().passwordTextController.value.text.isEmpty) {
      AppSnackBar.getCustomSnackBar(Appstrings.Password_Blank, Appstrings.Error,
          isSuccess: false);
      return false;
    }
    if (checkPassword(
            Get.find<AuthController>().passwordTextController.value.text) ==
        false) {
      AppSnackBar.getCustomSnackBar(Appstrings.Password_Valid, Appstrings.Error,
          isSuccess: false);
      return false;
    }
    return true;
  }
}
