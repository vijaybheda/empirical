// ignore_for_file: prefer_final_fields, unused_field, non_constant_identifier_names, unnecessary_this, unrelated_type_equality_checks

import 'dart:developer';
import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/my_inspection_48hour_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/utils.dart';

class HomeController extends GetxController {
  PageController pageController = PageController();

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  List<String> bannerImages = [
    AppImages.img_banner,
    AppImages.img_banner,
  ];

  List<Map<String, String>> listOfInspection = [
    {
      "ID": "1",
      "PO": "ee",
      "Item": "6443101",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organicfsdfsfdsfsd",
      "Status": "Done"
    },
    {
      "ID": "2",
      "PO": "ee",
      "Item": "6443102",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organicfsdfsfdsfsd",
      "Status": "Done"
    },
    {
      "ID": "3",
      "PO": "ee",
      "Item": "6443108",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
    {
      "ID": "4",
      "PO": "ee",
      "Item": "6443104",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
    {
      "ID": "5",
      "PO": "ee",
      "Item": "6443103",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
  ].obs;
  final ApplicationDao dao = ApplicationDao();
  List<MyInspection48HourItem> itemsList = <MyInspection48HourItem>[].obs;
  var bannersCurrentPage = 0.obs;
  List selectedIDsInspection = [].obs;
  List expandContents = [].obs;
  var sortType = ''.obs;

  var progressLayoutVisible = false.obs;
  var isInspectionFailed = false.obs;
  var progressDialogStatus = 0.obs;
  Object uploadToken = Object();

  RxBool completeAllChecked = false.obs;
  RxMap<int, String> failedInspections = <int, String>{}.obs;
  RxList<Long> uploadCheckedList = <Long>[].obs;
  final AppStorage appStorage = AppStorage.instance;

  RxList<MyInspection48HourItem> myInsp48HourList =
      <MyInspection48HourItem>[].obs;

  @override
  void onInit() {
    // Get.put(() => InspectionController(), permanent: true);
    super.onInit();
    int days = Utils().checkCacheDays();
    if (days >= 7) {
      if (globalConfigController.hasStableInternet.value) {
        Future.delayed(const Duration(seconds: 1)).then((value) =>
            UpdateDataAlert.showUpdateDataDialog(Get.context!, onOkPressed: () {
              debugPrint('Ok button tap.');
              Get.off(() => const CacheDownloadScreen());
            }, message: AppStrings().getDayMessage(days)));
      } else {
        Future.delayed(const Duration(seconds: 1)).then((value) =>
            UpdateDataAlert.showUpdateDataDialog(Get.context!, onOkPressed: () {
              debugPrint('Ok button tap.');
              Get.off(() => const CacheDownloadScreen());
            }, message: AppStrings().getDayMessage1(days)));
      }
    }

    getInspectionListOnInit();
    // simulateEvents();
    // clearAnyDownloadedInspectionData();
  }

  Future<void> getInspectionListOnInit() async {
    bool isOnline = await Utils.isOnline();

    if (isOnline) {
      itemsList = await getAllInspectionData();
      if (itemsList.isNotEmpty) {
        appStorage.myInsp48HourList!.assignAll(itemsList);
        myInsp48HourList.assignAll(itemsList);
        log("$itemsList");
        update(['inspectionsList']);
      }
    } else {
      itemsList = await getAllInspectionData();
      if (itemsList.isNotEmpty) {
        myInsp48HourList.assignAll(itemsList);
      }
    }
    appStorage.selectedItemSKUList.clear();
  }

  void simulateEvents() {
    handleCompletedInspectionsWebServiceCall(true);
    handleUploadMobileFilesWebServiceCall(false);
    handleOfflineZipWebServiceCall(true);
  }

  Future<void> handleCompletedInspectionsWebServiceCall(bool success) async {
    progressLayoutVisible.value = false;
    if (success) {
      itemsList = await getAllInspectionData();
      if (itemsList.isNotEmpty) {
        myInsp48HourList.assignAll(itemsList);
      }
    }
  }

  Future<void> handleOfflineZipWebServiceCall(bool success) async {
    if (success) {
      await importAllCSVFiles();
      log(" 🟢 offline csv files downloaded");
    }
  }

  Future<void> handleUploadMobileFilesWebServiceCall(bool success) async {
    if (success) {
      //todo  Handle successful upload
    } else {
      isInspectionFailed.value = true;
      if (appStorage.uploadResponseData != null) {
        if (appStorage.uploadResponseData!.getValidationErrors != null &&
            appStorage.uploadResponseData!.getValidationErrors!.isNotEmpty) {
          failedInspections[appStorage.uploadResponseData!.localInspectionID!] =
              appStorage.uploadResponseData!.validationErrors!;
        } else {
          failedInspections[appStorage.uploadResponseData!.localInspectionID!] =
              appStorage.uploadResponseData!.errorMessage!;
        }
      }
    }
  }

  // Clear out any downloaded inspection data
  Future<void> clearAnyDownloadedInspectionData() async {
    appStorage.downloadedInspection = null;
    if (await Utils.isOnline() == false) {
      itemsList = await getAllInspectionData();
      if (itemsList.isNotEmpty) {
        myInsp48HourList.assignAll(itemsList);
      }
    } else {
      itemsList = await getAllInspectionData();
      if (itemsList.isNotEmpty) {
        myInsp48HourList.assignAll(itemsList);
      }
      progressLayoutVisible.value = false;
    }

    if (Consts.IS_EXIT) {
      Get.back();
    }
  }

  Future<List<MyInspection48HourItem>> getAllInspectionData() async {
    // Load local inspection
    List<MyInspection48HourItem> inspections = await getLocalInspectionData();
    // Combine pfg, local pfg always at the top and
    // downloaded pfg always at the bottom
    inspections.insertAll(inspections.length, create48HourInspectionsData());

    return inspections;
  }

  Future<List<MyInspection48HourItem>> getLocalInspectionData() {
    return dao.getAllLocalInspections();
  }

  List<MyInspection48HourItem> create48HourInspectionsData() {
    if (appStorage.myInsp48HourList != null) {
      List<MyInspection48HourItem> list = appStorage.myInsp48HourList!;

      list.sort();
      return list;
    } else {
      log(" 🟠 create48HourInspectionsData is empty");
      return [];
    }
  }

  // Import All CSV files
  Future<void> importAllCSVFiles() async {
    try {
      await dao.csvImportItemGroup1();
      await dao.csvImportItemSKU();
      await dao.csvImportAgency();
      await dao.csvImportGrade();
      await dao.csvImportGradeCommodity();
      await dao.csvImportGradeCommodityDetail();
      await dao.csvImportSpecification();
      await dao.csvImportMaterialSpecification();
      await dao.csvImportSpecificationSupplier();
      await dao.csvImportSpecificationGradeTolerance();
      await dao.csvImportSpecificationAnalytical();
      await dao.csvImportSpecificationPackagingFinishedGoods();
      await dao.csvImportSpecificationType();
      await dao.csvImportCommodity();
      await dao.csvImportCommodityKeywords();
      await dao.csvImportPOHeader();
      await dao.csvImportPODetail();
      await dao.csvImportSpecificationSupplierGtins();
      await dao.csvImportCommodityCTE();
    } catch (e) {
      log(" 🔴 IMPORT ALL CSV FILES ERROR ${e.toString()}");
    }
  }

  selectInspectionForDownload(String id, bool isSelectAll) {
    if (isSelectAll) {
      if (selectedIDsInspection.length != listOfInspection.length) {
        selectedIDsInspection.clear();
        List list1 = listOfInspection.map((array) => array['ID']).toList();
        selectedIDsInspection.addAll(list1);
      } else {
        selectedIDsInspection.clear();
      }
    } else {
      if (selectedIDsInspection.contains(id)) {
        selectedIDsInspection.remove(id);
      } else {
        selectedIDsInspection.add(id);
      }
    }
  }

  sortArray_Item() {
    if (sortType == 'asc') {
      sortType.value = 'dsc';
      listOfInspection
          .sort((b, a) => a['Item'].toString().compareTo(b['Item'].toString()));
    } else {
      sortType.value = 'asc';
      listOfInspection
          .sort((a, b) => a['Item'].toString().compareTo(b['Item'].toString()));
    }
    update(['inspectionsList']);
  }
}
