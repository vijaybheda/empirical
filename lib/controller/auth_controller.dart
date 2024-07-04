// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/user_data.dart';
import 'package:pverify/models/user_offline.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/services/network_request_service/user_network_service.dart';
import 'package:pverify/services/permission_service.dart';
import 'package:pverify/services/secure_password.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/setup_platfrom/setup.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/constants.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class AuthController extends GetxController {
  UserData? userModel;
  final emailTextController = TextEditingController().obs;
  final passwordTextController = TextEditingController().obs;
  bool socialButtonVisible = true;
  final AppStorage appStorage = AppStorage.instance;
  final JsonFileOperations jsonFileOperations = JsonFileOperations.instance;
  final ApplicationDao dao = ApplicationDao();
  late final GlobalConfigController globalConfigController;

  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => GlobalConfigController(), fenix: true);
    globalConfigController = Get.find<GlobalConfigController>();

    SchedulerBinding.instance.addPostFrameCallback((_) async {
      // request for storage permission
      await PermissionsService.instance
          .checkAndRequestExternalStoragePermissions();
      await PermissionsService.instance
          .checkAndRequestCameraPhotosPermissions();
    });
  }

  bool isLoggedIn() {
    UserData? userData = AppStorage.instance.getUserData();

    return userData != null;
  }

  Future<void> userLogout() async {
    AppStorage appStorage = AppStorage.instance;
    await appStorage.appLogout();
  }

  // loginUser
  Future<UserData?> loginUser(
      {required bool isLoginButton, required BuildContext context}) async {
    try {
      String mUsername = emailTextController.value.text.trim();
      String mPassword = passwordTextController.value.text;
      if (await Utils.hasInternetConnection()) {
        UserData? userData = await UserService()
            .checkLogin(loginRequestUrl, mUsername, mPassword, isLoginButton);

        if (userData != null) {
          try {
            int? userid = await dao.getEnterpriseIdByUserId(mUsername);
            if (userid == null) {
              await dao.createOrUpdateOfflineUser(
                mUsername.toLowerCase(),
                userData.access1!,
                userData.enterpriseId!,
                (userData.status == 3) ? "Inactive" : "Active",
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
            AppAlertDialog.validateAlerts(
                context, AppStrings.error, AppStrings.invalidUsernamePassword);
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
                    UserData? userData = appStorage.getUserData();
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
            await dao.getOfflineUserHash(mUsername.toLowerCase());

        if (userHash != null && userHash.isNotEmpty) {
          if (SecurePassword.validatePasswordHash(mPassword, userHash)) {
            UserOffline? offlineUser =
                await dao.getOfflineUserData(mUsername.toLowerCase());
            await persistUserName();
            if (isLoginButton) {
              if (offlineUser != null && offlineUser.isSubscriptionExpired ||
                  offlineUser?.status == '3') {
                // show Info Alert Dialog
                await Utils.hideLoadingDialog();
                AppAlertDialog.validateAlerts(
                    context, AppStrings.error, AppStrings.accountInactive);
              } else {
                await jsonFileOperations.offlineLoadSuppliersData();
                await jsonFileOperations.offlineLoadDeliveredFrom();
                await jsonFileOperations.offlineLoadCarriersData();
                await jsonFileOperations.offlineLoadCommodityData();
                await Utils.hideLoadingDialog();
                final String tag =
                    DateTime.now().millisecondsSinceEpoch.toString();
                Get.offAll(() => Home(tag: tag));
              }
            } else {
              await Utils.hideLoadingDialog();
              Get.offAll(() => SetupScreen());
            }
          } else {
            await Utils.hideLoadingDialog();
            AppAlertDialog.validateAlerts(
                context, AppStrings.error, AppStrings.invalidUsernamePassword);
          }
        } else {
          await Utils.hideLoadingDialog();
          // show Info Alert Dialog
          AppAlertDialog.validateAlerts(
              context, AppStrings.error, AppStrings.turnOnWifi);
        }
      }
      return null;
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  String get loginRequestUrl => appStorage.serverUrl + ApiUrls.LOGIN_REQUEST;

  Future<void> persistUserName() async {
    UserData? userData = appStorage.getUserData();
    if (userData != null) {
      int? userId;

      try {
        userData = userData.copyWith(
          id: userData.id,
          loginTime: DateTime.now().millisecondsSinceEpoch,
        );

        userId = await dao.createOrUpdateUser(userData);
        userData = userData.copyWith(id: userId);
        await appStorage.setUserData(userData);
      } catch (e) {
        return;
      }
    }
  }

  // LOGIN SCREEN VALIDATION'S

  bool isLoginFieldsValidate(BuildContext context) {
    if (emailTextController.value.text.trim().isEmpty) {
      AppAlertDialog.validateAlerts(
          context, AppStrings.error, AppStrings.userNameBlank);
      return false;
    }
    if (validateEmail(emailTextController.value.text) == true) {
      AppAlertDialog.validateAlerts(
          context, AppStrings.error, AppStrings.invalidUsername);
      return false;
    }
    if (passwordTextController.value.text.trim().isEmpty) {
      AppAlertDialog.validateAlerts(
          context, AppStrings.error, AppStrings.passwordBlank);
      return false;
    }
    // if (checkPassword(passwordTextController.value.text) == false) {
    //   AppSnackBar.getCustomSnackBar(AppStrings.passwordValid, AppStrings.error,
    //       isSuccess: false);
    //   return false;
    // }
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
        if (globalConfigController.wifiLevel >= 2) {
          await appStorage.setBool(StorageKey.kIsCSVDownloaded1, true);
          await appStorage.setInt(
              StorageKey.kCacheDate, DateTime.now().millisecondsSinceEpoch);
          await appStorage.setBool(StorageKey.kIsCSVDownloaded1, true);
          Get.offAll(() => const CacheDownloadScreen());
          return;
        } else {
          Utils.hideLoadingDialog();
          AppAlertDialog.validateAlerts(
              Get.context!, AppStrings.error, AppStrings.downloadWifiError);
        }
      } else {
        AppAlertDialog.validateAlerts(
            Get.context!, AppStrings.error, AppStrings.betterWifiConnWarning);
      }
    } else {
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      Get.offAll(() => Home(tag: tag));
      return;
    }
  }
}
