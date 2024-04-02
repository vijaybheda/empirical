import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/dialog_progress_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/purchase_order_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/utils.dart';

class CommodityIDScreenController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  CommodityIDScreenController({required this.partner, required this.carrier});

  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<CommodityItem> filteredCommodityList = <CommodityItem>[].obs;
  RxList<CommodityItem> commodityList = <CommodityItem>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 180.h;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  void assignInitialData() {
    List<CommodityItem>? _commoditiesList = appStorage.getCommodityList();
    if (_commoditiesList == null) {
      commodityList.value = [];
      filteredCommodityList.value = [];
      listAssigned.value = true;
      update(['commodityList']);
    } else {
      commodityList.value = [];
      filteredCommodityList.value = [];

      commodityList.addAll(_commoditiesList);

      commodityList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredCommodityList.addAll(_commoditiesList);
      filteredCommodityList.sort((a, b) => a.name!.compareTo(b.name!));
      listAssigned.value = true;
      update(['commodityList']);
    }
  }

  void searchAndAssignCommodity(String searchValue) {
    filteredCommodityList.clear();
    if (searchValue.isEmpty) {
      filteredCommodityList.addAll(commodityList);
    } else {
      filteredCommodityList.value = commodityList
          .where((element) => element.keywords!
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
          .toList();
    }
    update(['commodityList']);
  }

  List<String> getListOfAlphabets() {
    Set<String> uniqueAlphabets = {};

    for (CommodityItem supplier in commodityList) {
      if (supplier.name!.isNotEmpty &&
          supplier.name![0].toUpperCase().contains(RegExp(r'[A-Z0-9]'))) {
        uniqueAlphabets.add(supplier.name![0].toUpperCase());
      }
    }

    return uniqueAlphabets.toList();
  }

  void scrollToSection(String letter, int index) {
    int targetIndex = filteredCommodityList
        .indexWhere((supplier) => supplier.name!.startsWith(letter));
    if (targetIndex != -1) {
      scrollController.animateTo(
        (targetIndex * listHeight) + (index * (listHeight * .45)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  void navigateToPurchaseOrderScreen(CommodityItem commodity) {
    Get.to(() => PurchaseOrderScreen(
        partner: partner, carrier: carrier, commodity: commodity));
  }

  Future<void> onDownloadTap() async {
    if (globalConfigController.hasStableInternet.value) {
      bool hasValue = await dao.checkInspections();
      if (hasValue) {
        UpdateDataAlert.showUpdateDataDialog(Get.context!,
            onOkPressed: () async {
          await uploadAllInspections();
        }, message: AppStrings.updateDataMessage);
      } else {
        Get.to(() => const CacheDownloadScreen());
      }
    } else {
      UpdateDataAlert.showUpdateDataDialog(Get.context!,
          onOkPressed: () async {}, message: AppStrings.downloadWifiError);
    }
  }

  Future<void> uploadAllInspections() async {
    List<int> uploadCheckedList = await dao.findReadyToUploadInspectionIDs();
    if (uploadCheckedList.isNotEmpty) {
      List<int> failedList = [];

      for (int i = 0; i < uploadCheckedList.length; i++) {
        Inspection? inspection =
            await dao.findInspectionByID(uploadCheckedList[i]);

        if (inspection?.commodityId == 0) {
          uploadCheckedList.removeAt(i);
          failedList.add(uploadCheckedList[i]);
        }
      }

      final progressController = Get.put(ProgressController());

      Utils.showLinearProgressWithMessage(
          message: AppStrings.uploadMessage,
          progressController: progressController);

      int numberOfInspections = uploadCheckedList.length;
      int listIndex = 0;
      int progressDialogStatus = 0;
      while (progressDialogStatus < numberOfInspections) {
        try {
          await uploadInspection(uploadCheckedList[listIndex]);
        } catch (e) {
          AppSnackBar.error(message: AppStrings.uploadError);
          Utils.hideLoadingDialog();
        }

        progressDialogStatus = ++listIndex;

        // Update the progress bar
        progressController.updateProgress(progressDialogStatus);

        if (progressDialogStatus >= numberOfInspections) {
          await Future.delayed(const Duration(seconds: 1));
          Utils.hideLoadingDialog();
        }
      }
    } else {
      List<int> incompleteInspectionList =
          await dao.getAllIncompleteInspectionIDs();

      for (int i = 0; i < incompleteInspectionList.length; i++) {
        await dao.deleteInspection(incompleteInspectionList.elementAt(i));
      }

      Get.to(() => const CacheDownloadScreen());
    }
  }

  Future<void> uploadInspection(int inspectionId) async {
    Inspection? inspection = await dao.findInspectionByID(inspectionId);
    // TODO: Implement the below code for (WSUploadInspectionCTE, WSUploadMobileFilesCTE, WSUploadInspection, WSUploadMobileFiles)
    /*if (inspection != null) {
      QCHeaderDetails? qcHeaderDetails =
          await dao.findTempQCHeaderDetails(inspection.poNumber!);
      if (qcHeaderDetails != null &&
          qcHeaderDetails.cteType != null &&
          qcHeaderDetails.cteType != "") {
        // Start the webservice to upload the inspection
        Map<String, dynamic>? jsonObject =
            await WSUploadInspectionCTE.RequestUploadCTE(
                inspectionId, qcHeaderDetails.cteType);

        if (jsonObject != null) {
          WSUploadMobileFilesCTE.RequestUploadMobileFiles(
              null, jsonObject, inspectionId);
        }
      } else {
        // Start the webservice to upload the inspection
        Map<String, dynamic>? jsonObject =
            await WSUploadInspection.RequestUpload(inspectionId);

        if (jsonObject != null) {
          List<InspectionDefectAttachment>? attachments =
              await dao.findDefectAttachmentsByInspectionId(inspectionId);

          if (attachments != null && attachments.isNotEmpty) {
            WSUploadMobileFiles.RequestUploadMobileFiles(
                attachments, jsonObject, inspectionId);
          }
        }
      }
    }*/
  }
}
