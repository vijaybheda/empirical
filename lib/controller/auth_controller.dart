import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/models/user.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/user_network_service.dart';
import 'package:pverify/services/permission_service.dart';
import 'package:pverify/services/secure_password.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/dashboard_screen.dart';
import 'package:pverify/ui/setup_platfrom/setup.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/constants.dart';
import 'package:pverify/utils/utils.dart';

class AuthController extends GetxController {
  bool isLoading = false;
  User? userModel;
  final emailTextController = TextEditingController().obs;
  final passwordTextController = TextEditingController().obs;
  bool socialButtonVisible = true;
  AppStorage appStorage = AppStorage.instance;

  int wifiLevel = 0;

  @override
  void onInit() {
    super.onInit();
    Utils.checkWifiLevel().then((value) {
      wifiLevel = value;
    });
    // FIXME: change below logic
    // if (isLoggedIn()) {
    //   Get.offAll(() => const DashboardScreen());
    // }

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // request for storage permission
      await PermissionsService.instance
          .checkAndRequestExternalStoragePermissions();
      await PermissionsService.instance
          .checkAndRequestCameraPhotosPermissions();
    });
  }

  bool isLoggedIn() {
    User? userData = AppStorage.instance.getUserData();

    return userData != null;
  }

  Future<void> userLogout() async {
    AppStorage appStorage = AppStorage.instance;
    await appStorage.appLogout();
  }

  // loginUser
  Future<LoginData?> loginUser({required bool isLoginButton}) async {
    isLoading = true;

    if (await Utils.hasInternetConnection()) {
      String mUsername = emailTextController.value.text.trim();
      String mPassword = passwordTextController.value.text;
      // TODO: Vijay show loading indicator
      LoginData? userData =
          await UserService().checkLogin(mUsername, mPassword, isLoginButton);

      if (userData != null) {
        try {
          int userid =
              await ApplicationDao().getEnterpriseIdByUserId(mUsername);
          if (userid == 0) {
            int? id = await ApplicationDao().createOrUpdateOfflineUser(
              mUsername.toLowerCase(),
              userData.access1!,
              userData.enterpriseId!,
              userData.status == 3 ? "Inactive" : "Active",
              userData.subscriptionExpired ?? false,
              userData.supplierId!,
              userData.headquarterSupplierId!,
              userData.gtinScanning!,
            );

            return userData;
          } else {
            return userData;
          }
        } catch (e) {
          Utils.showErrorAlert("0");
        }
      } else {
        String mUsername = emailTextController.value.text.trim();
        String mPassword = passwordTextController.value.text;
        String? userHash =
            await ApplicationDao().getOfflineUserHash(mUsername.toLowerCase());

        if (userHash != null && userHash.isNotEmpty) {
          if (SecurePassword().validatePasswordHash(mPassword, userHash)) {
            List<String> features = [];
            features.add("pfg");

            ApplicationDao().getOfflineUserData(mUsername.toLowerCase());

            persistUserName();

            if (isLoginButton) {
              LoginData? userData = appStorage.getLoginData();
              if ((userData?.subscriptionExpired ?? true) ||
                  userData?.status == 3) {
                Utils.showInfoAlertDialog(
                    "Your account is inactive. Please contact your administrator.");
              } else {
                // TODO: add below logic
                // CacheUtil.offlineLoadSuppliers();
                // CacheUtil.offlineLoadCarriers();
                // CacheUtil.offlineLoadCommodity(context);

                Get.offAll(() => const DashboardScreen());
              }
            } else {
              Get.offAll(() => SetupScreen());
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
    }

    isLoading = false;

    return null;
  }

  Future<void> persistUserName() async {
    LoginData? loginData = appStorage.getLoginData();
    if (loginData != null) {
      int? userId;

      try {
        userId = await ApplicationDao().createOrUpdateUser(loginData);
        loginData = loginData.copyWith(id: userId);
        await appStorage.setLoginData(loginData);
      } catch (e) {
        return;
      }
    }
  }

  // LOGIN SCREEN VALIDATION'S

  bool isLoginFieldsValidate() {
    if (emailTextController.value.text.isEmpty) {
      AppSnackBar.getCustomSnackBar(AppStrings.userNameBlank, AppStrings.error,
          isSuccess: false);
      return false;
    }
    if (validateEmail(emailTextController.value.text) == true) {
      AppSnackBar.getCustomSnackBar(AppStrings.userNameValid, AppStrings.error,
          isSuccess: false);
      return false;
    }
    if (passwordTextController.value.text.isEmpty) {
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

  Future<void> triggerCheckForUpdate() async {
    /// start the service to check for updates.
    // WSUpdateService updateWebservice = new WSUpdateService(appContext);
    // updateWebservice.RequestUpdateInfo();
  }

  Future<void> downloadCloudData() async {
    if (appStorage.getBool(StorageKey.kIsCSVDownloaded1) == false) {
      if (await Utils.hasInternetConnection()) {
        if (wifiLevel >= 2) {
          appStorage.setBool(StorageKey.kIsCSVDownloaded1, true);
          appStorage.setInt(
              StorageKey.kCacheDate, DateTime.now().millisecondsSinceEpoch);
          Get.to(() => const CacheDownloadScreen());
        } else {
          Utils.showInfoAlertDialog(AppStrings.downloadWifiError);
        }
      } else {
        Utils.showInfoAlertDialog(AppStrings.betterWifiConnWarning);
      }
      await appStorage.setBool("isCSVDownloaded1", true);
    } else {
      Get.offAll(() => const DashboardScreen());
    }
  }
}
