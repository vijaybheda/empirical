import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/my_inspection_48hour_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class HomeController extends GetxController {
  PageController pageController = PageController();

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  List<String> bannerImages = [
    AppImages.img_banner,
    AppImages.img_banner,
  ];

  final ApplicationDao dao = ApplicationDao();
  List<MyInspection48HourItem> itemsList = <MyInspection48HourItem>[].obs;
  var bannersCurrentPage = 0.obs;
  List<MyInspection48HourItem> selectedIDsInspection =
      <MyInspection48HourItem>[].obs;

  List expandContents = [].obs;
  RxString sortType = ''.obs;

  var progressLayoutVisible = false.obs;
  var isInspectionFailed = false.obs;
  var progressDialogStatus = 0.obs;
  Object uploadToken = Object();

  RxBool completeAllChecked = false.obs;
  RxMap<int, String> failedInspections = <int, String>{}.obs;
  RxList<int> uploadCheckedList = <int>[].obs;
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

  /* Future<void> getInspectionListOnInit() async {
    // bool isOnline = await Utils.isOnline();
    bool isOnline = globalConfigController.hasStableInternet.value;

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
  } */

  Future<void> getInspectionListOnInit() async {
    bool isOnline = globalConfigController.hasStableInternet.value;

    if (isOnline) {
      itemsList = await getAllInspectionData();
      if (itemsList.isNotEmpty) {
        appStorage.myInsp48HourList ??= itemsList;
        myInsp48HourList.assignAll(itemsList);
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
    bool isOnline = globalConfigController.hasStableInternet.value;
    if (!isOnline) {
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

      list.sort((a, b) => a.date!.compareTo(b.date!));
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

  void selectInspectionForDownload(int id, bool isSelectAll) {
    if (isSelectAll) {
      List<MyInspection48HourItem> selectedItems =
          itemsList.where((item) => item.uploadStatus == 1).toList();
      if (selectedItems.length != selectedIDsInspection.length) {
        selectedIDsInspection.clear();
        selectedIDsInspection.addAll(selectedItems);
      } else {
        selectedIDsInspection.clear();
      }
    } else {
      MyInspection48HourItem selectedItem =
          itemsList.firstWhere((item) => item.id == id);
      if (selectedIDsInspection.contains(selectedItem)) {
        selectedIDsInspection.remove(selectedItem);
      } else {
        selectedIDsInspection.add(selectedItem);
      }
    }
  }

  void sortArrayItem() {
    if (sortType.value == 'asc') {
      sortType.value = 'dsc';
      myInsp48HourList.sort((a, b) => b.id!.compareTo(a.id!));
    } else {
      sortType.value = 'asc';
      myInsp48HourList.sort((a, b) => a.id!.compareTo(b.id!));
    }
    update(['inspectionsList']);
  }

  Color getResultTextColor(String? result) {
    if (result == null) {
      return Colors.transparent;
    } else if (result == "RJ") {
      return AppColors.notificationOff;
    } else {
      return AppColors.primary;
    }
  }

  void onItemTap(int position) {
    MyInspection48HourItem selectedItem = myInsp48HourList[position];

    Map<String, dynamic> passingData = {
      Consts.SERVER_INSPECTION_ID: selectedItem.inspectionId,
      Consts.PARTNER_NAME: selectedItem.partnerName,
      Consts.PARTNER_ID: selectedItem.partnerId,
      Consts.CARRIER_NAME: selectedItem.carrierName ?? "",
      Consts.CARRIER_ID: selectedItem.carrierId,
      Consts.COMMODITY_NAME: selectedItem.commodityName,
      Consts.COMMODITY_ID: selectedItem.commodityId,
      Consts.VARIETY_NAME: selectedItem.varietyName,
      Consts.VARIETY_ID: selectedItem.varietyId,
      'VARIETY_SIZE': '1',
      // todo discuss this Completed with Nirali shah
      // 'COMPLETED': selectedItem.isCompleted,
      Consts.GRADE_ID: selectedItem.gradeId,
      Consts.INSPECTION_RESULT: selectedItem.inspectionResult ?? "",
      Consts.SPECIFICATION_NAME: selectedItem.specificationName,
      Consts.SPECIFICATION_NUMBER: selectedItem.specificationNumber,
      Consts.SPECIFICATION_VERSION: selectedItem.specificationVersion,
      Consts.SPECIFICATION_TYPE_NAME: selectedItem.specificationTypeName,
      Consts.LOT_NO: selectedItem.lotNo,
      Consts.PACK_DATE: selectedItem.packDate,
      Consts.IS_MY_INSPECTION_SCREEN: true,
      Consts.SAMPLE_SIZE_BY_COUNT: selectedItem.sampleSizeByCount,
      Consts.ITEM_SKU: selectedItem.itemSKU,
      Consts.ITEM_SKU_ID: selectedItem.itemSKUId,
      Consts.PO_NUMBER: selectedItem.poNumber,
      Consts.CTEType: selectedItem.cteType,
      Consts.ITEM_SKU_NAME: selectedItem.itemSkuName,
      Consts.CALLER_ACTIVITY: "TrendingReportActivity",
    };

    // Navigate to the details screen
    if (selectedItem.cteType != null && selectedItem.cteType!.isNotEmpty) {
      //todo add navigation for CTE flow.
    } else {
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      Get.to(QCDetailsShortFormScreen(tag: tag), arguments: passingData);
    }
  }
}
