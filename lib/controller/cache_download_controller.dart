import 'dart:developer';
import 'dart:io';

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/services/network_request_service/cache_download_service.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/login_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';

class CacheDownloadController extends GetxController {
  final ApplicationDao dao = ApplicationDao();

  final AppStorage appStorage = AppStorage.instance;
  final JsonFileOperations jsonFileOperations = JsonFileOperations.instance;

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      /// 1. Delete Partner ItemSKU for Update Cache
      bool deletePartnerItem = await deletePartnerItemSKU();
      if (deletePartnerItem == false) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.offAll(() => const LoginScreen());
        AppSnackBar.error(message: AppStrings.failedToDeletePartnerItemSKU);
        return;
      }

      /// 2. Download Zip File
      bool processZip = await processZipFile();
      if (!processZip) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.offAll(() => const LoginScreen());
        AppSnackBar.error(message: AppStrings.failedToDownloadZipFile);
        return;
      }

      /// 3. Download JSON file
      bool processJSON = await processJSONFile();
      if (!processJSON) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.offAll(() => const LoginScreen());
        AppSnackBar.error(message: AppStrings.failedToDownloadJSONFile);
        return;
      }

      /// 4. Download all users
      bool allUsersResponse = await downloadAllUsers();
      if (!allUsersResponse) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.offAll(() => const LoginScreen());
        AppSnackBar.error(message: AppStrings.failedToDownloadAllUsers);
        return;
      } else {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, true);
        await appStorage.setInt(
            StorageKey.kCacheDate, DateTime.now().millisecondsSinceEpoch);
        final String tag = DateTime.now().millisecondsSinceEpoch.toString();
        Get.offAll(() => Home(tag: tag));
      }
    });
  }

  Future<bool> deletePartnerItemSKU() async {
    int deletePartnerResponse = await deletePartnerItemSKUForUpdateCache();
    return deletePartnerResponse != -1;
  }

  Future<bool> processZipFile() async {
    File? zipDownloaded = await downloadZipFile();
    if (zipDownloaded == null) {
      AppSnackBar.error(message: AppStrings.failedToDownloadZipFile);
      return false;
    }
    AppSnackBar.success(message: AppStrings.csvDownloadedSuccessfully);

    bool processCsv = await processCsvAndInsertToDatabase();
    if (!processCsv) {
      AppSnackBar.error(message: AppStrings.failedToInsertCSVData);
      return false;
    }
    // show snackbar with success icon and green background
    AppSnackBar.success(
        title: AppStrings.success, message: AppStrings.csvInsertedSuccessfully);
    return true;
  }

  Future<bool> processJSONFile() async {
    File? jsonDownloaded = await downloadJSONFile();
    if (jsonDownloaded == null) {
      AppSnackBar.error(message: AppStrings.failedToDownloadJSONFile);
      return false;
    }
    AppSnackBar.success(message: AppStrings.jsonDownloadedSuccessfully);
    var allFunctions = [
      jsonFileOperations.offlineLoadSuppliersData(),
      jsonFileOperations.offlineLoadCarriersData(),
      jsonFileOperations.offlineLoadCommodityData(),
      jsonFileOperations.offlineLoadSpecificationBannerData(),
    ];
    List<bool> result = await Future.wait(allFunctions);
    if (result.contains(false)) {
      AppSnackBar.error(message: AppStrings.failedToInsertJSONData);
      return false;
    }

    AppSnackBar.success(message: AppStrings.jsonInsertedSuccessfully);
    return true;
  }

  String getLanguage() {
    String? language = Get.locale?.languageCode;
    return language ?? 'en';
  }

  Future<int> deletePartnerItemSKUForUpdateCache() async {
    try {
      return await dao.deletePartnerItemSKUForUpdateCache();
    } catch (e) {
      log('Error in delete PartnerItemSKU For Update Cache');
      log(e.toString());
      return -1;
    }
  }

  Future<bool> processCsvAndInsertToDatabase() async {
    try {
      bool itemGroup = await dao.csvImportItemGroup1();

      if (!itemGroup) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        AppSnackBar.error(message: AppStrings.failedToInsertItemGroup);
        return false;
      }

      bool itemSKU = await dao.csvImportItemSKU();

      if (!itemSKU) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        AppSnackBar.error(message: AppStrings.failedToInsertItemSKU);
        return false;
      }

      bool agency = await dao.csvImportAgency();
      if (!agency) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        AppSnackBar.error(message: AppStrings.failedToInsertAgency);
        return false;
      }

      bool grade = await dao.csvImportGrade();
      if (!grade) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        AppSnackBar.error(message: AppStrings.failedToInsertGrade);
        return false;
      }

      bool gradeCommodity = await dao.csvImportGradeCommodity();
      if (!gradeCommodity) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        AppSnackBar.error(message: AppStrings.failedToInsertGradeCommodity);
        return false;
      }

      bool gradeCommodityDetail = await dao.csvImportGradeCommodityDetail();
      if (!gradeCommodityDetail) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(
            message: AppStrings.failedToInsertGradeCommodityDetail);
        return false;
      }

      bool specification = await dao.csvImportSpecification();
      if (!specification) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(message: AppStrings.failedToInsertSpecification);
        return false;
      }

      bool materialSpecification = await dao.csvImportMaterialSpecification();
      if (!materialSpecification) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(
            message: AppStrings.failedToInsertMaterialSpecification);
        return false;
      }

      bool importSpecificationSupplier =
          await dao.csvImportSpecificationSupplier();
      if (!importSpecificationSupplier) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(
            message: AppStrings.failedToInsertSpecificationSupplier);
        return false;
      }

      bool specificationGradeTolerance =
          await dao.csvImportSpecificationGradeTolerance();
      if (!specificationGradeTolerance) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(
            message: AppStrings.failedToInsertSpecificationGradeTolerance);
        return false;
      }

      bool specificationAnalytical =
          await dao.csvImportSpecificationAnalytical();
      if (!specificationAnalytical) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        AppSnackBar.error(
            message: AppStrings.failedToInsertSpecificationAnalytical);
        return false;
      }

      bool specificationPackagingFinishedGoods =
          await dao.csvImportSpecificationPackagingFinishedGoods();
      if (!specificationPackagingFinishedGoods) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(
            message:
                AppStrings.failedToInsertSpecificationPackagingFinishedGoods);
        return false;
      }

      bool specificationType = await dao.csvImportSpecificationType();
      if (!specificationType) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(message: AppStrings.failedToInsertSpecificationType);
        return false;
      }

      bool commodity = await dao.csvImportCommodity();
      if (!commodity) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(message: AppStrings.failedToInsertCommodity);
        return false;
      }

      bool commodityKeywords = await dao.csvImportCommodityKeywords();
      if (!commodityKeywords) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(message: AppStrings.failedToInsertCommodityKeywords);
        return false;
      }

      bool poHeader = await dao.csvImportPOHeader();
      if (!poHeader) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(message: AppStrings.failedToInsertPOHeader);
        return false;
      }

      bool poDetail = await dao.csvImportPODetail();
      if (!poDetail) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(message: AppStrings.failedToInsertPODetail);
        return false;
      }

      bool specificationSupplierGtins =
          await dao.csvImportSpecificationSupplierGtins();
      if (!specificationSupplierGtins) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(
            message: AppStrings.failedToInsertSpecificationSupplierGtins);
        return false;
      }

      bool commodityCTE = await dao.csvImportCommodityCTE();
      if (!commodityCTE) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();

        AppSnackBar.error(message: AppStrings.failedToInsertCommodityCTE);
        return false;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<File?> downloadZipFile() async {
    String language = getLanguage();
    String requestUrl =
        "${ApiUrls.serverUrl}${ApiUrls.OFFLINE_CSV_DATA_REQUEST}?lang=$language";

    try {
      File? file = await CacheDownloadService.instance.downloadZip(requestUrl);
      return file;
    } catch (e) {
      log('Error in downloadZipFile');
      log(e.toString());
      return null;
    }
  }

  Future<File?> downloadJSONFile() async {
    String language = getLanguage();
    String requestUrl =
        "${ApiUrls.serverUrl}${ApiUrls.OFFLINE_JSON_DATA_REQUEST}?lang=$language";

    try {
      return await CacheDownloadService.instance.downloadJSON(requestUrl);
    } catch (e) {
      log('Error in downloadJSONFile');
      log(e.toString());
      return null;
    }
  }

  Future<bool> downloadAllUsers() async {
    String language = getLanguage();
    String requestUrl =
        "${ApiUrls.serverUrl}${ApiUrls.GET_USERS}?lang=$language";

    Map<String, dynamic> headerMap = appStorage.getHeaderMap();

    try {
      return await CacheDownloadService.instance
          .downloadAllUsers(requestUrl, headerMap);
    } catch (e) {
      log('Error in downloadAllUsers');
      log(e.toString());
      return false;
    }
  }
}
