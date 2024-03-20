import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:path/path.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/services/network_request_service/cache_download_service.dart';
import 'package:pverify/ui/dashboard_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/utils.dart';

class CacheDownloadController extends GetxController {
  final ApplicationDao dao = ApplicationDao();

  final AppStorage appStorage = AppStorage.instance;

  @override
  void onInit() {
    super.onInit();
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      /// 1. Delete Partner ItemSKU for Update Cache
      bool deletePartnerItem = await deletePartnerItemSKU();
      if (deletePartnerItem == false) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar(
            'Error', 'Deleting Partner ItemSKU failed please try again');
        return;
      }

      /// 2. Download Zip File
      bool processZip = await processZipFile();
      if (!processZip) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        return;
      }

      /// 3. Download JSON file
      bool processJSON = await processJSONFile();
      if (!processJSON) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        return;
      }

      /// 4. Download all users
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
    bool processCsv = await processCsvAndInsertToDatabase();
    if (!processCsv) {
      // Helly change this message UI
      Get.snackbar('Error', 'Failed to insert csv data to database');
      return false;
    }
    return true;
  }

  Future<bool> processJSONFile() async {
    File? jsonDownloaded = await downloadJSONFile();
    if (jsonDownloaded == null) {
      // Helly change this message UI
      Get.snackbar('Error', 'Failed to download json file');
      return false;
    }
    var allFunctions = [
      offlineLoadSuppliersData(),
      offlineLoadCarriersData(),
      offlineLoadCommodityData(),
      offlineLoadSpecificationBannerData(),
    ];
    List<bool> result = await Future.wait(allFunctions);
    if (result.contains(false)) {
      // Helly change this message UI
      Get.snackbar('Error', 'Failed to insert json data to database');
      return false;
    }
    return true;
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

      bool itemSKU = await dao.csvImportItemSKU();

      if (!itemSKU) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert item SKU');
        return false;
      }

      bool agency = await dao.csvImportAgency();
      if (!agency) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert agency');
        return false;
      }

      bool grade = await dao.csvImportGrade();
      if (!grade) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert grade');
        return false;
      }

      bool gradeCommodity = await dao.csvImportGradeCommodity();
      if (!gradeCommodity) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Grade Commodity');
        return false;
      }

      bool gradeCommodityDetail = await dao.csvImportGradeCommodityDetail();
      if (!gradeCommodityDetail) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Grade Commodity Detail');
        return false;
      }

      bool specification = await dao.csvImportSpecification();
      if (!specification) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert specification');
        return false;
      }

      bool materialSpecification = await dao.csvImportMaterialSpecification();
      if (!materialSpecification) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Material Specification');
        return false;
      }

      bool importSpecificationSupplier =
          await dao.csvImportSpecificationSupplier();
      if (!importSpecificationSupplier) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert import Specification Supplier');
        return false;
      }

      bool specificationGradeTolerance =
          await dao.csvImportSpecificationGradeTolerance();
      if (!specificationGradeTolerance) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar(
            'Error', 'Failed to insert import Specification Grade Tolerance');
        return false;
      }

      bool specificationAnalytical =
          await dao.csvImportSpecificationAnalytical();
      if (!specificationAnalytical) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar(
            'Error', 'Failed to insert import Specification Analytical');
        return false;
      }

      bool specificationPackagingFinishedGoods =
          await dao.csvImportSpecificationPackagingFinishedGoods();
      if (!specificationPackagingFinishedGoods) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error',
            'Failed to insert import specification Packaging FinishedGoods');
        return false;
      }

      bool specificationType = await dao.csvImportSpecificationType();
      if (!specificationType) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert import Specification Type');
        return false;
      }

      bool commodity = await dao.csvImportCommodity();
      if (!commodity) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert import commodity');
        return false;
      }

      bool commodityKeywords = await dao.csvImportCommodityKeywords();
      if (!commodityKeywords) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Commodity Keywords');
        return false;
      }

      bool poHeader = await dao.csvImportPOHeader();
      if (!poHeader) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert PO Header');
        return false;
      }

      bool poDetail = await dao.csvImportPODetail();
      if (!poDetail) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert PO Detail');
        return false;
      }

      bool specificationSupplierGtins =
          await dao.csvImportSpecificationSupplierGtins();
      if (!specificationSupplierGtins) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
        Get.back();
        // Helly change this message UI
        Get.snackbar('Error', 'Failed to insert Specification Supplier Gtins');
        return false;
      }

      bool commodityCTE = await dao.csvImportCommodityCTE();
      if (!commodityCTE) {
        appStorage.write(StorageKey.kIsCSVDownloaded1, false);
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

  Future<File?> downloadJSONFile() async {
    String language = getLanguage();
    String requestUrl =
        "${ApiUrls.serverUrl}${ApiUrls.OFFLINE_JSON_DATA_REQUEST}?lang=$language";

    Map<String, dynamic> headerMap = appStorage.getHeaderMap();

    try {
      return await CacheDownloadService.instance
          .downloadJSON(requestUrl, headerMap);
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
      log('Error in downloadZipFile');
      log(e.toString());
      return false;
    }
  }

  Future<bool> offlineLoadSuppliersData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${AppStrings.jsonFilesCache}/");
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
    directory.createSync(recursive: true);

    String content = await File(join(
      directory.path,
      'suppliers.json',
    )).readAsString();

    List<PartnerItem>? data = parseSupplierJson(content);

    if (data != null && data.isNotEmpty) {
      await appStorage.savePartnerList(data);
    }
    return (data != null && data.isNotEmpty);
  }

  Future<bool> offlineLoadCarriersData() async {
    var storagePath = await Utils().getExternalStoragePath();
    final Directory directory =
        Directory("$storagePath${AppStrings.jsonFilesCache}/");
    if (directory.existsSync()) {
      directory.deleteSync(recursive: true);
    }
    directory.createSync(recursive: true);

    String content = await File(join(
      directory.path,
      'deliveryTo.json',
    )).readAsString();

    List<CarrierItem>? data = parseCarrierJson(content);

    if (data != null && data.isNotEmpty) {
      await appStorage.saveCarrierList(data);
    }
    return (data != null && data.isNotEmpty);
  }

  Future<bool> offlineLoadCommodityData() async {
    // TODO: implement offlineLoadCommodityData
    return true;
  }

  Future<bool> offlineLoadSpecificationBannerData() async {
    // TODO: implement offlineLoadSpecificationBannerData
    return true;
  }

  List<PartnerItem>? parseSupplierJson(String response) {
    List<PartnerItem> list = [];
    try {
      Map<String, dynamic> jsonResponse = json.decode(response);
      List<dynamic> partnersArray = jsonResponse["partners"];

      for (int i = 0; i < partnersArray.length; i++) {
        Map<String, dynamic> item = partnersArray[i];
        int id = item["id"];
        String name = item["name"];
        double redPercentage = item["redPercentage"];
        double yellowPercentage = item["yellowPercentage"];
        double orangePercentage = item["orangePercentage"];
        double greenPercentage = item["greenPercentage"];
        String recordType = item["recordType"];

        PartnerItem listItem = PartnerItem(id, name, redPercentage,
            yellowPercentage, orangePercentage, greenPercentage, recordType);
        list.add(listItem);
      }
    } catch (e) {
      print(e.toString());
      return null;
    }
    // FIXME: save to app storage
    return list;
  }

  List<CarrierItem>? parseCarrierJson(String response) {
    List<CarrierItem> list = [];

    try {
      Map<String, dynamic> jsonResponse = json.decode(response);
      List<dynamic> partnersArray = jsonResponse["partners"];

      for (int i = 0; i < partnersArray.length; i++) {
        Map<String, dynamic> item = partnersArray[i];
        int id = item["id"];
        String name = item["name"];
        double redPercentage = item["redPercentage"];
        double yellowPercentage = item["yellowPercentage"];
        double orangePercentage = item["orangePercentage"];
        double greenPercentage = item["greenPercentage"];
        String recordType = item["recordType"];

        CarrierItem listItem = CarrierItem(id, name, redPercentage,
            yellowPercentage, orangePercentage, greenPercentage, recordType);
        list.add(listItem);
      }
    } catch (e) {
      print("Error while parsing JSON: $e");
      return null;
    }

    return list;
  }
}
