import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/services/network_request_service/cache_download_service.dart';
import 'package:pverify/ui/dashboard_screen.dart';
import 'package:pverify/utils/app_storage.dart';

class CacheDownloadController extends GetxController {
  final ApplicationDao dao = ApplicationDao();

  final AppStorage appStorage = AppStorage.instance;

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      int deletePartnerResponse = await deletePartnerItemSKUForUpdateCache();
      if (deletePartnerResponse == -1) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        // show message that, deleting Partner ItemSKU failed please try again
        Get.back();
        // Helly change this message UI
        Get.snackbar(
            'Error', 'Deleting Partner ItemSKU failed please try again');
        return;
      }
      File? zipDownloaded = await downloadZipFile();
      if (zipDownloaded == null) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        // show message that, failed to download zip file
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to download zip file');
        return;
      }
      bool processCsv = await processCsvAndInsertToDatabase();
      if (!processCsv) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert csv data to database');
        return;
      }

      bool jsonDownloadResponse = await downloadJSONFile();
      if (!jsonDownloadResponse) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to download json file');
        return;
      }
      bool allUsersResponse = await downloadAllUsers();
      if (!allUsersResponse) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to download all users');
        return;
      } else {
        appStorage.write(StorageKey.kIsCSVDownloaded1, true);
        Get.snackbar('Success', 'Cache updated successfully');
        Get.offAll(() => const DashboardScreen());
      }
    });
  }

  String getLanguage() {
    String language = ui.window.locale.languageCode;
    return language;
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
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert item group');
        return false;
      }

      //TODO: implement below methods to add csv files

      // dao.csvImportItemSKU();
      // dao.csvImportAgency();
      // dao.csvImportGrade();
      // dao.csvImportGradeCommodity();
      // dao.csvImportGradeCommodityDetail();
      // dao.csvImportSpecfication();
      // dao.csvImportMaterialSpecification();
      // dao.csvImportSpecificationSupplier();
      // dao.csvImportSpecificationGradeTolerance();
      // dao.csvImportSpecificationAnalytical();
      // dao.csvImportSpecficationPackagingFinishedGoods();
      // dao.csvImportSpecificationType();
      // dao.csvImportCommodity();
      // dao.csvImportCommodityKeywords();
      // dao.csvImportPOHeader();
      // dao.csvImportPODetail();
      // dao.csvImportSpecificationSupplierGtins();
      // dao.csvImportCommodityCTE();

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<File?> downloadZipFile() async {
    String language = getLanguage();
    String requestUrl =
        "${ApiUrls.serverUrl}${ApiUrls.OFFLINE_CSV_DATA_REQUEST}?lang=$language";

    Map<String, dynamic> headerMap = appStorage.getHeaderMap();

    try {
      File? file = await CacheDownloadService.instance
          .downloadZip(requestUrl, headerMap);
      return file;
    } catch (e) {
      log('Error in downloadZipFile');
      log(e.toString());
      return null;
    }
  }

  Future<bool> downloadJSONFile() async {
    String language = getLanguage();
    String requestUrl =
        "${ApiUrls.serverUrl}${ApiUrls.OFFLINE_JSON_DATA_REQUEST}?lang=$language";

    Map<String, dynamic> headerMap = appStorage.getHeaderMap();

    try {
      return await CacheDownloadService.instance
          .downloadJSON(requestUrl, headerMap);
    } catch (e) {
      log('Error in downloadZipFile');
      log(e.toString());
      return false;
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
      log('Error in downloadZipFile');
      log(e.toString());
      return false;
    }
  }
}
