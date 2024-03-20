import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/user.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/constants.dart';

class AuthController extends GetxController {
  bool isLoading = false;
  User? userModel;
  final emailTextController = TextEditingController().obs;
  final passwordTextController = TextEditingController().obs;
  bool socialButtonVisible = true;
  AppStorage appStorage = AppStorage.instance;

  bool isLoggedIn() {
    User? userData = AppStorage.instance.getUserData();

    return userData != null;
  }

  Future<void> userLogout() async {
    AppStorage appStorage = AppStorage.instance;
    await appStorage.appLogout();
  }

  // loginUser
  /*Future<User?> loginUser({required bool isLoginButton}) async {
    isLoading = true;

    // unfocus
    fNodeEmail.unfocus();
    fNodePass.unfocus();

    if (await Utils.hasInternetConnection()) {
      String mUsername = emailTextController.text.trim();
      String mPassword = passwordTextController.text;
      // TODO: Vijay show loading indicator
      Map<String, dynamic>? userData =
          await UserService().checkLogin(mUsername, mPassword, isLoginButton);

      if (userData != null) {
        try {
          var status = userData['status'];
          var access = userData['access1'];

          String userId = userData["userName"];
          var gtinScanning = userData["gtinScanning"];
          var headquarterSupplierId = userData["headquarterSupplierId"];
          var supplierId = userData["supplierId"];
          var features = userData["features"];
          var isSubscriptionExpired = userData["subscriptionExpired"];
          var systemLabels = userData["systemLabels"];
          var language = userData["language"];
          var enterpriseId = userData["enterpriseId"];

          int userid =
              await ApplicationDao().getEnterpriseIdByUserId(mUsername);
          if (userid == 0) {
            if (status == 3) {
              ApplicationDao().createOrUpdateOfflineUser(
                  mUsername.toLowerCase(),
                  access,
                  enterpriseId,
                  "Inactive",
                  isSubscriptionExpired,
                  supplierId,
                  headquarterSupplierId,
                  gtinScanning);
            } else {
              ApplicationDao().createOrUpdateOfflineUser(
                  mUsername.toLowerCase(),
                  access,
                  enterpriseId,
                  "Active",
                  isSubscriptionExpired,
                  supplierId,
                  headquarterSupplierId,
                  gtinScanning);
            }
          }
        } catch (e) {}
      }
    } else {
      String mUsername = emailTextController.text.trim();
      String mPassword = passwordTextController.text;
      String? userHash =
          await ApplicationDao().getOfflineUserHash(mUsername.toLowerCase());

      if (userHash != null && userHash.isNotEmpty) {
        if (SecurePassword().validatePasswordHash(mPassword, userHash)) {
          AppInfo.setUsername(mUsername.toLowerCase());
          AppInfo.setPassword(mPassword);

          List<String> features = [];
          features.add("pfg");

          // TODO: Need usernames from /user/users WS

          ApplicationDao().getOfflineUserData(mUsername.toLowerCase());

          persistUserName();

          if (isLoginButton) {
            if (AppInfo.user.isSubscriptionExpired() ||
                AppInfo.user.getStatus() == 3) {
              Utils.showInfoAlertDialog(
                  "Your account is inactive. Please contact your administrator.");
            } else {
              CacheUtil.offlineLoadSuppliers();
              CacheUtil.offlineLoadCarriers();
              CacheUtil.offlineLoadCommodity(context);

              Get.offAll(() => TrendingReport());
            }
          } else {
            Get.to(() => SetupScreen());
          }
        } else {
          // show error alert dialog
          Utils.showErrorAlert("0");
        }
      } else {
        // alert dialog for "Please go to your hotspot and turn WiFi on - need to update data with first login."
        // show Info Alert Dialog
        Utils.showInfoAlertDialog(
            "Please go to your hotspot and turn WiFi on - need to update data with first login.");
      }
    }

    isLoading = false;

    return null;
  }

  Future<void> persistUserName() async {
    if (AppInfo.user != null) {
      int? userId;

      try {
        userId = await ApplicationDao().createOrUpdateUser(AppInfo.user);
        AppInfo.user.setId(userId);
      } catch (e) {
        return;
      }
    }
  }*/

  // LOGIN SCREEN VALIDATION'S

  bool isLoginFieldsValidate() {
    if (emailTextController.value.text.trim().isEmpty) {
      AppSnackBar.getCustomSnackBar(AppStrings.userNameBlank, AppStrings.error,
          isSuccess: false);
      return false;
    }
    if (validateEmail(emailTextController.value.text) == true) {
      AppSnackBar.getCustomSnackBar(
          AppStrings.invalidUsername, AppStrings.error,
          isSuccess: false);
      return false;
    }
    if (passwordTextController.value.text.trim().isEmpty) {
      AppSnackBar.getCustomSnackBar(AppStrings.passwordBlank, AppStrings.error,
          isSuccess: false);
      return false;
    }
    if (checkPassword(passwordTextController.value.text) == false) {
      AppSnackBar.getCustomSnackBar(AppStrings.passwordValid, AppStrings.error,
          isSuccess: false);
      return false;
    }
    return true;
  }
}
