import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/services/network_request_service/cache_download_service.dart';
import 'package:pverify/ui/dashboard_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/theme/colors.dart';

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
        Get.back();
        // Helly change this message UI
        Get.snackbar(
            'Error', 'Deleting Partner ItemSKU failed please try again');
        return;
      }

      /// 2. Download Zip File
      bool processZip = await processZipFile();
      if (!processZip) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        return;
      }

      /// 3. Download JSON file
      bool processJSON = await processJSONFile();
      if (!processJSON) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        return;
      }

      /// 4. Download all users
      bool allUsersResponse = await downloadAllUsers();
      if (!allUsersResponse) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to download all users');
        return;
      } else {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, true);
        Get.showSnackbar(GetSnackBar(
          title: 'Success',
          message: 'Cache updated successfully',
          backgroundColor: AppColors.primaryColor,
          icon: const Icon(Icons.check),
          duration: const Duration(seconds: 1),
          key: const Key('cacheUpdated'),
        ));
        Get.offAll(() => const DashboardScreen());
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
      // Helly change this message UI
      Get.snackbar('Error', 'Failed to download zip file');
      return false;
    }
    Get.showSnackbar(GetSnackBar(
      title: 'Success',
      message: 'CSV files downloaded successfully',
      backgroundColor: AppColors.primaryColor,
      icon: const Icon(Icons.check),
      duration: const Duration(seconds: 1),
      key: const Key('csvDownloaded'),
    ));
    bool processCsv = await processCsvAndInsertToDatabase();
    if (!processCsv) {
      // Helly change this message UI
      Get.snackbar('Error', 'Failed to insert csv data to database');
      return false;
    }
    // show snackbar with success icon and green background
    Get.showSnackbar(GetSnackBar(
      title: 'Success',
      message: 'CSV files data added successfully',
      backgroundColor: AppColors.primaryColor,
      icon: const Icon(Icons.check),
      duration: const Duration(seconds: 1),
      key: const Key('csvInserted'),
    ));

    return true;
  }

  Future<bool> processJSONFile() async {
    File? jsonDownloaded = await downloadJSONFile();
    if (jsonDownloaded == null) {
      // Helly change this message UI
      Get.snackbar('Error', 'Failed to download json file');
      return false;
    }
    Get.showSnackbar(GetSnackBar(
      title: 'Success',
      message: 'JSON file downloaded successfully.',
      backgroundColor: AppColors.primaryColor,
      icon: const Icon(Icons.check),
      duration: const Duration(seconds: 1),
      key: const Key('jsonDownloaded'),
    ));
    var allFunctions = [
      jsonFileOperations.offlineLoadSuppliersData(),
      jsonFileOperations.offlineLoadCarriersData(),
      jsonFileOperations.offlineLoadCommodityData(),
      jsonFileOperations.offlineLoadSpecificationBannerData(),
    ];
    List<bool> result = await Future.wait(allFunctions);
    if (result.contains(false)) {
      // Helly change this message UI
      Get.snackbar('Error', 'Failed to insert json data to database');
      return false;
    }

    Get.showSnackbar(GetSnackBar(
      title: 'Success',
      message: 'JSON file data saved to device storage.',
      backgroundColor: AppColors.primaryColor,
      icon: const Icon(Icons.check),
      duration: const Duration(seconds: 1),
      key: const Key('jsonInserted'),
    ));
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
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert item group');
        return false;
      }

      bool itemSKU = await dao.csvImportItemSKU();

      if (!itemSKU) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert item SKU');
        return false;
      }

      bool agency = await dao.csvImportAgency();
      if (!agency) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert agency');
        return false;
      }

      bool grade = await dao.csvImportGrade();
      if (!grade) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert grade');
        return false;
      }

      bool gradeCommodity = await dao.csvImportGradeCommodity();
      if (!gradeCommodity) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Grade Commodity');
        return false;
      }

      bool gradeCommodityDetail = await dao.csvImportGradeCommodityDetail();
      if (!gradeCommodityDetail) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Grade Commodity Detail');
        return false;
      }

      bool specification = await dao.csvImportSpecification();
      if (!specification) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert specification');
        return false;
      }

      bool materialSpecification = await dao.csvImportMaterialSpecification();
      if (!materialSpecification) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Material Specification');
        return false;
      }

      bool importSpecificationSupplier =
          await dao.csvImportSpecificationSupplier();
      if (!importSpecificationSupplier) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert import Specification Supplier');
        return false;
      }

      bool specificationGradeTolerance =
          await dao.csvImportSpecificationGradeTolerance();
      if (!specificationGradeTolerance) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar(
            'Error', 'Failed to insert import Specification Grade Tolerance');
        return false;
      }

      bool specificationAnalytical =
          await dao.csvImportSpecificationAnalytical();
      if (!specificationAnalytical) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar(
            'Error', 'Failed to insert import Specification Analytical');
        return false;
      }

      bool specificationPackagingFinishedGoods =
          await dao.csvImportSpecificationPackagingFinishedGoods();
      if (!specificationPackagingFinishedGoods) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error',
            'Failed to insert import specification Packaging FinishedGoods');
        return false;
      }

      bool specificationType = await dao.csvImportSpecificationType();
      if (!specificationType) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert import Specification Type');
        return false;
      }

      bool commodity = await dao.csvImportCommodity();
      if (!commodity) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert import commodity');
        return false;
      }

      bool commodityKeywords = await dao.csvImportCommodityKeywords();
      if (!commodityKeywords) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Commodity Keywords');
        return false;
      }

      bool poHeader = await dao.csvImportPOHeader();
      if (!poHeader) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert PO Header');
        return false;
      }

      bool poDetail = await dao.csvImportPODetail();
      if (!poDetail) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert PO Detail');
        return false;
      }

      bool specificationSupplierGtins =
          await dao.csvImportSpecificationSupplierGtins();
      if (!specificationSupplierGtins) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Specification Supplier Gtins');
        return false;
      }

      bool commodityCTE = await dao.csvImportCommodityCTE();
      if (!commodityCTE) {
        await appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Commodity CTE');
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
        "${const String.fromEnvironment('API_HOST')}${ApiUrls.OFFLINE_CSV_DATA_REQUEST}?lang=$language";

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
        "${const String.fromEnvironment('API_HOST')}${ApiUrls.OFFLINE_JSON_DATA_REQUEST}?lang=$language";

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
        "${const String.fromEnvironment('API_HOST')}${ApiUrls.GET_USERS}?lang=$language";

    Map<String, dynamic> headerMap = appStorage.getHeaderMap();

    try {
      return await CacheDownloadService.instance
          .downloadAllUsers(requestUrl, headerMap);
    } catch (e) {
      log('Error in downloadZipFile');
      log(e.toString());
      return false;
    }
  }
}
