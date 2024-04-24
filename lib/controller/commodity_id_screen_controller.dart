import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/dialog_progress_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/user_data.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/utils.dart';

class CommodityIDScreenController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final QCHeaderDetails? qcHeaderDetails;
  late final int partnerID;
  late final String partnerName;
  late final String sealNumber;
  late final String poNumber;
  late final String carrierName;
  late final int carrierID;
  late final String cteType;

  final TextEditingController searchController = TextEditingController();
  CommodityIDScreenController({
    required this.partner,
    required this.carrier,
    required this.qcHeaderDetails,
  });

  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<CommodityItem> filteredCommodityList = <CommodityItem>[].obs;
  RxList<CommodityItem> commodityList = <CommodityItem>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 130.h;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments not allowed');
    }

    partnerID = args[Consts.PARTNER_ID] ?? 0;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    cteType = args[Consts.CTEType] ?? '';
    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    UserData? currentUser = appStorage.getUserData();
    if (currentUser == null) {
      return;
    }
    int enterpriseId =
        await dao.getEnterpriseIdByUserId(currentUser.userName!.toLowerCase());

    List<CommodityItem>? commoditiesList =
        await dao.getCommodityByPartnerFromTable(partner.id!, enterpriseId,
            currentUser.supplierId!, currentUser.headquarterSupplierId!);
    appStorage.saveMainCommodityList(commoditiesList ?? []);

    if (commoditiesList == null) {
      commodityList.value = [];
      filteredCommodityList.value = [];
      listAssigned.value = true;
      update(['commodityList']);
    } else {
      commodityList.value = [];
      filteredCommodityList.value = [];

      commodityList.addAll(commoditiesList);

      commodityList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredCommodityList.addAll(commoditiesList);
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
      var items = commodityList
          .where((element) =>
              element.keywords != null &&
              element.keywords!
                  .toLowerCase()
                  .contains(searchValue.toLowerCase()))
          .toList();
      filteredCommodityList.addAll(items);
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
    Map<String, dynamic> passingData = {
      Consts.PO_NUMBER: poNumber,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodity.id,
      Consts.COMMODITY_NAME: commodity.name,
      Consts.PRODUCT_TRANSFER: qcHeaderDetails?.productTransfer ?? '',
    };
    Get.to(
        () => PurchaseOrderScreen(
            partner: partner,
            carrier: carrier,
            qcHeaderDetails: qcHeaderDetails,
            commodity: commodity),
        arguments: passingData);
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
    if (inspection != null) {
      QCHeaderDetails? qcHeaderDetails =
          await dao.findTempQCHeaderDetails(inspection.poNumber!);
      if (qcHeaderDetails != null &&
          qcHeaderDetails.cteType != null &&
          qcHeaderDetails.cteType != "") {
        // TODO: Implement the below code for (WSUploadInspectionCTE, WSUploadMobileFilesCTE)
        /*// Start the webservice to upload the inspection
        Map<String, dynamic>? jsonObject =
            await WSUploadInspectionCTE.RequestUploadCTE(
                inspectionId, qcHeaderDetails.cteType);

        if (jsonObject != null) {
          WSUploadMobileFilesCTE.RequestUploadMobileFiles(
              null, jsonObject, inspectionId);
        }*/
      } else {
        // Start the webservice to upload the inspection

        // TODO: Implement the below code for (WSUploadInspection, WSUploadMobileFiles)
        /*Map<String, dynamic>? jsonObject =
            await requestUploadInspection(inspectionId);

        if (jsonObject != null) {
          List<InspectionDefectAttachment>? attachments =
              await dao.findDefectAttachmentsByInspectionId(inspectionId);

          requestUploadMobileFiles(attachments, jsonObject, inspectionId);
        }*/
      }
    }
  }

  void clearSearch() {
    searchController.clear();
    searchAndAssignCommodity('');
    unFocus();
  }
}
