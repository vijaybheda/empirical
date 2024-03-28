import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/models/user.dart';
import 'package:pverify/models/user_offline.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/services/network_request_service/user_network_service.dart';
import 'package:pverify/services/permission_service.dart';
import 'package:pverify/services/secure_password.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/setup_platfrom/setup.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/constants.dart';
import 'package:pverify/utils/utils.dart';

class AuthController extends GetxController {
  User? userModel;
  final emailTextController = TextEditingController().obs;
  final passwordTextController = TextEditingController().obs;
  bool socialButtonVisible = true;
  final AppStorage appStorage = AppStorage.instance;
  final JsonFileOperations jsonFileOperations = JsonFileOperations.instance;

  int wifiLevel = 0;

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => GlobalConfigController(), fenix: true);
    final GlobalConfigController globalConfigController =
        Get.find<GlobalConfigController>();

    globalConfigController.wifiLevelStream.listen((value) {
      wifiLevel = value;
    });

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
    try {
      String mUsername = emailTextController.value.text.trim();
      String mPassword = passwordTextController.value.text;
      if (await Utils.hasInternetConnection()) {
        LoginData? userData = await UserService()
            .checkLogin(loginRequestUrl, mUsername, mPassword, isLoginButton);

        if (userData != null) {
          try {
            int userid =
                await ApplicationDao().getEnterpriseIdByUserId(mUsername);
            if (userid == 0) {
              int? _id = await ApplicationDao().createOrUpdateOfflineUser(
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
            await Utils.hideLoadingDialog();
            Utils.showErrorAlertDialog(AppStrings.invalidUsernamePassword);
          }
        }
        /*// todo remove below code
            else {
              String mUsername = emailTextController.value.text.trim();
              String mPassword = passwordTextController.value.text;
              String? userHash =
                  await ApplicationDao().getOfflineUserHash(mUsername.toLowerCase());

              if (userHash != null && userHash.isNotEmpty) {
                if (SecurePassword().validatePasswordHash(mPassword, userHash)) {
                  List<String> features = [];
                  features.add("pfg");

                  await ApplicationDao().getOfflineUserData(mUsername.toLowerCase());

                  await persistUserName();

                  if (isLoginButton) {
                    LoginData? userData = appStorage.getLoginData();
                    if ((userData?.subscriptionExpired ?? true) ||
                        userData?.status == 3) {
                      await Utils.hideLoadingDialog();
                      Utils.showInfoAlertDialog(
                          "Your account is inactive. Please contact your administrator.");
                    } else {
                      await jsonFileOperations.offlineLoadSuppliersData();
                      await jsonFileOperations.offlineLoadCarriersData();
                      await jsonFileOperations.offlineLoadCommodityData();
                      await Utils.hideLoadingDialog();
                      Get.offAll(() => const DashboardScreen());
                    }
                  } else {
                    await Utils.hideLoadingDialog();
                    Get.offAll(() => SetupScreen());
                  }
                } else {
                  await Utils.hideLoadingDialog();
                  // show error alert dialog
                  Utils.showErrorAlert(AppStrings.invalidUsernamePassword);
                }
              } else {
                await Utils.hideLoadingDialog();
                // show Info Alert Dialog
                Utils.showInfoAlertDialog(AppStrings.turnOnWifi);
              }
            }*/
      } else {
        String? userHash =
            await ApplicationDao().getOfflineUserHash(mUsername.toLowerCase());

        if (userHash != null && userHash.isNotEmpty) {
          if (SecurePassword.validatePasswordHash(mPassword, userHash)) {
            UserOffline? offlineUser = await ApplicationDao()
                .getOfflineUserData(mUsername.toLowerCase());
            await persistUserName();
            if (isLoginButton) {
              if (offlineUser != null && offlineUser.isSubscriptionExpired ||
                  offlineUser?.status == 3) {
                // show Info Alert Dialog
                await Utils.hideLoadingDialog();
                Utils.showErrorAlertDialog(
                    "Your account is inactive. Please contact your administrator.");
              } else {
                await jsonFileOperations.offlineLoadSuppliersData();
                await jsonFileOperations.offlineLoadCarriersData();
                await jsonFileOperations.offlineLoadCommodityData();
                await Utils.hideLoadingDialog();
                Get.offAll(() => Home());
              }
            } else {
              await Utils.hideLoadingDialog();
              Get.offAll(() => SetupScreen());
            }
          } else {
            await Utils.hideLoadingDialog();
            Utils.showErrorAlertDialog(AppStrings.invalidUsernamePassword);
          }
        } else {
          await Utils.hideLoadingDialog();
          // show Info Alert Dialog
          Utils.showErrorAlertDialog(AppStrings.turnOnWifi);
        }
      }

      return null;
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  String get loginRequestUrl =>
      const String.fromEnvironment('API_HOST') + ApiUrls.LOGIN_REQUEST;

  Future<void> persistUserName() async {
    LoginData? loginData = appStorage.getLoginData();
    if (loginData != null) {
      int? userId;

      try {
        User user = User(
          id: 0,
          name: loginData.userName,
          timestamp: DateTime.now().millisecondsSinceEpoch,
          language: loginData.language,
        );
        userId = await ApplicationDao().createOrUpdateUser(user);
        user = user.copyWith(id: userId);
        await appStorage.setUserData(user);
      } catch (e) {
        return;
      }
    }
  }

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

  Future<void> triggerCheckForUpdate() async {
    /// start the service to check for updates.
    // WSUpdateService updateWebservice = new WSUpdateService(appContext);
    // updateWebservice.RequestUpdateInfo();
  }

  Future<void> downloadCloudData() async {
    if (appStorage.getBool(StorageKey.kIsCSVDownloaded1) == false) {
      if (await Utils.hasInternetConnection()) {
        if (wifiLevel >= 2) {
          await appStorage.setBool(StorageKey.kIsCSVDownloaded1, true);
          await appStorage.setInt(
              StorageKey.kCacheDate, DateTime.now().millisecondsSinceEpoch);
          await appStorage.setBool(StorageKey.kIsCSVDownloaded1, true);
          Get.offAll(() => const CacheDownloadScreen());
          return;
        } else {
          Utils.showErrorAlertDialog(AppStrings.downloadWifiError);
        }
      } else {
        Utils.showErrorAlertDialog(AppStrings.betterWifiConnWarning);
      }
    } else {
      Get.offAll(() => Home());
      return;
    }
  }
}
