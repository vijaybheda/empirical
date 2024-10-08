import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:pverify/controller/dialog_progress_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_defect_attachment.dart';
import 'package:pverify/models/my_inspection_48hour_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/network_request_service/ws_upload_inspection.dart';
import 'package:pverify/services/network_request_service/ws_upload_mobile_files.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class HomeController extends GetxController {
  final ApplicationDao dao = ApplicationDao();
  final AppStorage appStorage = AppStorage.instance;

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  PageController pageController = PageController();

  RxMap<int, String> failedInspections = <int, String>{}.obs;

  Object uploadToken = Object();

  List<String> bannerImages = [AppImages.img_banner, AppImages.img_banner];
  List<MyInspection48HourItem> itemsList = <MyInspection48HourItem>[].obs;
  List<MyInspection48HourItem> selectedIDsInspection =
      <MyInspection48HourItem>[].obs;
  List expandContents = [].obs;
  RxList<int> uploadCheckedList = <int>[].obs;
  RxList<MyInspection48HourItem> myInsp48HourList =
      <MyInspection48HourItem>[].obs;

  RxInt bannersCurrentPage = 0.obs;
  RxInt progressDialogStatus = 0.obs;

  RxString sortType = ''.obs;

  RxBool completeAllCheckbox = false.obs;
  RxBool progressLayoutVisible = false.obs;
  RxBool isInspectionFailed = false.obs;

  @override
  void onInit() {
    super.onInit();
    int days = Utils().checkCacheDays();
    if (days >= 7) {
      if (globalConfigController.hasStableInternet.value) {
        Future.delayed(const Duration(seconds: 1)).then((value) =>
            UpdateDataAlert.showUpdateDataDialog(Get.context!, onOkPressed: () {
              Get.off(() => const CacheDownloadScreen());
            }, message: AppStrings().getDayMessage(days)));
      } else {
        Future.delayed(const Duration(seconds: 1)).then((value) =>
            UpdateDataAlert.showUpdateDataDialog(Get.context!, onOkPressed: () {
              Get.off(() => const CacheDownloadScreen());
            }, message: AppStrings().getDayMessage1(days)));
      }
    }
    uploadCheckedList.value = [];
    getInspectionListOnInit();
    inAppUpdateInit();
    // simulateEvents();
    // clearAnyDownloadedInspectionData();
  }

  Future<void> getInspectionListOnInit() async {
    bool isOnline = globalConfigController.hasStableInternet.value;

    if (isOnline) {
      itemsList = await getAllInspectionData();

      if (itemsList.isNotEmpty) {
        appStorage.myInsp48HourList ??= itemsList;
        myInsp48HourList.assignAll(itemsList);
      } else {
        myInsp48HourList.value = [];
      }
    } else {
      itemsList = await getAllInspectionData();
      if (itemsList.isNotEmpty) {
        myInsp48HourList.assignAll(itemsList);
      }
    }
    appStorage.selectedItemSKUList.clear();
    update(['inspectionsList']);
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

  void selectInspectionForDownload(int id, bool isSelectAll) {
    if (isSelectAll) {
      List<MyInspection48HourItem> selectedItems =
          itemsList.where((item) => item.uploadStatus == 1).toList();
      if (selectedIDsInspection.length == selectedItems.length) {
        selectedIDsInspection.clear();
        uploadCheckedList.clear();
      } else {
        selectedIDsInspection.clear();
        selectedIDsInspection.addAll(selectedItems);
        uploadCheckedList.clear();
        uploadCheckedList
            .addAll(selectedItems.map((item) => item.inspectionId!));
      }
      completeAllCheckbox.value = selectedIDsInspection.length ==
          itemsList.where((item) => item.uploadStatus == 1).length;
    } else {
      MyInspection48HourItem selectedItem =
          itemsList.firstWhere((item) => item.inspectionId == id);
      if (selectedIDsInspection.contains(selectedItem)) {
        selectedIDsInspection.remove(selectedItem);
        uploadCheckedList.remove(selectedItem.inspectionId);
      } else {
        selectedIDsInspection.add(selectedItem);
        uploadCheckedList.add(selectedItem.inspectionId!);
      }
      completeAllCheckbox.value = selectedIDsInspection.length ==
          itemsList.where((item) => item.uploadStatus == 1).length;
    }
  }

  void sortArrayItem() {
    if (sortType.value == 'asc') {
      sortType.value = 'dsc';
      myInsp48HourList
          .sort((a, b) => b.inspectionId!.compareTo(a.inspectionId!));
    } else {
      sortType.value = 'asc';
      myInsp48HourList
          .sort((a, b) => a.inspectionId!.compareTo(b.inspectionId!));
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
      Consts.VARIETY_SIZE: '1',
      Consts.COMPLETED: selectedItem.complete == "1",
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
    log("HERE IS PASSED DATA $passingData");
    // Navigate to the details screen
    if (selectedItem.cteType != null && selectedItem.cteType!.isNotEmpty) {
      //todo add navigation for CTE flow.
    } else {
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      Get.to(() => QCDetailsShortFormScreen(tag: tag), arguments: passingData);
    }
  }

  Future<void> uploadAllInspections() async {
    List<int> uploadList = await dao.findReadyToUploadInspectionIDs();

    if (completeAllCheckbox.isTrue) {
      uploadCheckedList.clear();
      uploadCheckedList.addAll(uploadList);
    }

    if (uploadCheckedList.isEmpty) {
      Utils.noInspectionAlert(title: AppStrings.noInspectionToUpload);
      return;
    } else {
      List<int> failedList = [];
      for (int i = 0; i < uploadCheckedList.length; i++) {
        Inspection? inspection =
            await dao.findInspectionByID(uploadCheckedList[i]);
        if (inspection?.commodityId == 0) {
          uploadCheckedList.removeAt(i);
          failedList.add(uploadCheckedList[i]);

          i--;
        }
      }
    }

    final progressController = Get.put(ProgressController());
    Utils.showLinearProgressWithMessage(
      message: AppStrings.uploadMessage,
      progressController: progressController,
      totalInspection: uploadCheckedList.length,
    );

    int numberOfInspections = uploadCheckedList.length;
    int listIndex = 0;
    progressDialogStatus.value = 0;

    while (progressDialogStatus.value < numberOfInspections) {
      try {
        await uploadInspection(uploadCheckedList[listIndex]);
      } catch (e) {
        AppSnackBar.error(message: AppStrings.uploadError);
        Utils.hideLoadingDialog();
        break;
      }
      listIndex++;
      progressDialogStatus.value++;
      // Update the progress bar
      progressController.updateProgress(progressDialogStatus.value.toDouble());

      if (progressDialogStatus.value >= numberOfInspections) {
        await Future.delayed(const Duration(seconds: 1));
        Utils.hideLoadingDialog();
      }
    }
    String failedInspection = '';

    for (int j = 0; j < failedInspections.length; j++) {
      failedInspection += '${failedInspections[j]}\n';
    }

    if (failedInspection.isNotEmpty) {
      AppSnackBar.error(
          message:
              "ID - \n$failedInspection\nMissing Grading Standard; please contact Service@Share-ify.com");
    }
  }

  Future<void> uploadInspection(int inspectionId) async {
    Inspection? inspection = await dao.findInspectionByID(inspectionId);
    if (inspection != null) {
      QCHeaderDetails? qcHeaderDetails =
          await dao.findTempQCHeaderDetails(inspection.poNumber!);
      if (qcHeaderDetails != null &&
          qcHeaderDetails.cteType != null &&
          qcHeaderDetails.cteType != "") {
        // TODO: Implement CTE flow
      } else {
        Map<String, dynamic>? jsonObject =
            await WSUploadInspection().requestUpload(inspectionId);

        if (jsonObject.isNotEmpty) {
          List<InspectionDefectAttachment>? attachments =
              await dao.findDefectAttachmentsByInspectionId(inspectionId);

          var isApiCallSuccess = await WSUploadMobileFiles(
            inspectionId,
            attachments ?? [],
            jsonObject,
          ).requestUploadMobileFiles(
            attachments ?? [],
            jsonObject,
            inspectionId,
          );
          if (isApiCallSuccess) {
            Future.delayed(Duration.zero, () {
              getInspectionListOnInit();
              update(['inspectionsList']);
            });
          }
        }
      }
    }
  }

  Future<void> onUploadAllInspectionButtonClick(BuildContext context) async {
    bool isOnline = globalConfigController.hasStableInternet.value;
    if (isOnline) {
      int wifiLevel = globalConfigController.wifiLevel.value;

      if (wifiLevel < 2) {
        AppAlertDialog.confirmationAlert(
          context,
          AppStrings.alert,
          "Please go to your hotspot to upload",
          onYesTap: () {
            int wifiLevel2 = globalConfigController.wifiLevel.value;
            if (wifiLevel2 >= 2) {
              AppAlertDialog.confirmationAlert(
                context,
                AppStrings.alert,
                AppStrings.inspectionUploadMessage,
                onYesTap: () {
                  isInspectionFailed.value = false;
                  uploadAllInspections();
                },
              );
            }
          },
        );
      } else {
        AppAlertDialog.confirmationAlert(
          context,
          AppStrings.alert,
          AppStrings.inspectionUploadMessage,
          onYesTap: () {
            isInspectionFailed.value = false;
            uploadAllInspections();
          },
        );
      }
    } else {
      AppAlertDialog.confirmationAlert(
        context,
        AppStrings.alert,
        AppStrings.turnWifiMessage,
        onYesTap: () {
          Get.back();
        },
      );
    }
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

  void inAppUpdateInit() {
    Timer(const Duration(seconds: 1), () {
      inAppUpdate();
    });
  }

  Future<void> inAppUpdate() async {
    final newVersion = NewVersionPlus(
        iOSAppStoreCountry: "IN",
        iOSId: "com.trt.verify",
        androidId: "com.trt.verify");

    try {
      final status = await newVersion.getVersionStatus();
      //For Demo Purpose
      /*  final status = VersionStatus(
        localVersion: "1.0.0",
        storeVersion: "1.0.1",
        appStoreLink: "www.java.com",
      ); */
      if (status != null) {
        debugPrint(status.releaseNotes);
        debugPrint("**AppStore Link ${status.appStoreLink}");
        debugPrint(status.localVersion);
        debugPrint(status.storeVersion);
        debugPrint(status.canUpdate.toString());
        if (status.canUpdate) {
          newVersion.showUpdateDialog(
            dismissButtonText: AppStrings.cancel,
            context: Get.context!,
            versionStatus: status,
            dialogText: "New version is available, please upgrade this app.",
          );
        }
      }
    } on SocketException catch (_) {
      AppSnackBar.error(message: "Please check your internet connection");
    } catch (error) {
      log("HEREEE IS ${error.toString()}");
      // AppSnackBar.error(message: error.toString());
    }
  }
}
