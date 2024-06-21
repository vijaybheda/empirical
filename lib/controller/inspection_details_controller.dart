import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/defect_categories.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/models/specification_grade_tolerance.dart';
import 'package:pverify/models/specification_packaging_gtin.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/defects/defects_screen.dart';
import 'package:pverify/ui/overridden_result/overridden_result_screen.dart';
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';
import 'package:pverify/ui/trailer_temp/trailertemp_class.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class InspectionDetailsController extends GetxController {
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  final ApplicationDao dao = ApplicationDao();

  final AppStorage _appStorage = AppStorage.instance;

  QualityControlItem? qualityControlItem;

  Inspection? inspection;

  RxList<SpecificationByItemSKU> specificationList =
      <SpecificationByItemSKU>[].obs;

  // SpecificationByItemSKU? selectedSpecification;
  String? selectedSpecification;
  RxList<String> specificationArray = <String>[].obs;

  RxList<SpecificationPackagingGTIN> specificationPackagingGTINList =
      <SpecificationPackagingGTIN>[].obs;

  // SpecificationPackagingGTIN? selectedSpecificationPackagingGTIN;
  String? selectedSpecificationPackagingGTIN;
  RxList<String> specificationPackagingGTINArray = <String>[].obs;

  TextEditingController qtyRejectedController = TextEditingController();

  int serverInspectionID = -1;
  int typeDefect = 1;
  int typeQuallity = 2;
  int typeTrailer = 3;
  int selectedType = 0;
  int varietyId = 0;
  int? commodityID;
  int? partnerID;
  int? carrierID;
  int? gradeId;
  int? gradeCommodityDetailId;
  int? sampleSizeByCount;
  int? itemSkuId;

  String partnerName = "";
  String carrierName = "";
  String commodityName = "";
  String varietyName = "";
  String varietySize = "";
  String inspectionResult = "";
  String specificationNameVal = "";
  String inspectionResultText = "";
  String commodityText = "";
  String varietyText = "";
  String textspecificationText = "";
  String? lotNo;
  String? itemSku;
  String? packDate;
  String? lotSize;
  String? itemUniqueId;
  String? poNumber;
  String? sealNumber;
  String? gtin;
  String? callerActivity;
  String? itemSkuName;
  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;

  bool partialCompleted = false;
  bool completed = false;
  bool isMyInspectionScreen = false;
  bool qualityComplete = false;
  bool defectComplete = false;
  RxBool isShowSaveButton = false.obs;
  bool isPartialComplete = false, isComplete = false;
  RxBool isShowDefectButton = false.obs;
  RxBool isShowTrailerButton = false.obs;
  RxBool isShowQualityButton = false.obs;
  RxBool rejectionLayout = false.obs;
  RxBool approvalLayout = false.obs;
  RxBool gtinSpinnerEnabled = false.obs;
  RxBool textspecification = false.obs;
  RxBool specificationSpinner = false.obs;
  RxBool listAssigned = false.obs;
  Color inspectionTextColor = AppColors.white;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }
    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID];
    carrierName = args[Consts.CARRIER_NAME];
    carrierID = args[Consts.CARRIER_ID];
    commodityName = args[Consts.COMMODITY_NAME] ?? '';
    commodityID = args[Consts.COMMODITY_ID];
    varietyName = args[Consts.VARIETY_NAME] ?? "";
    varietySize = args[Consts.VARIETY_SIZE] ?? "";
    varietyId = args[Consts.VARIETY_ID] ?? 0;
    completed = args[Consts.COMPLETED] ?? false;
    gradeId = args[Consts.GRADE_ID];
    gradeCommodityDetailId = args[Consts.GRADE_COMMODITY_DETAIL_ID] ?? -1;
    inspectionResult = args[Consts.INSPECTION_RESULT] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    specificationNumber = args[Consts.SPECIFICATION_NUMBER];
    specificationVersion = args[Consts.SPECIFICATION_VERSION];
    specificationName = args[Consts.SPECIFICATION_NAME];
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME];
    gtin = args[Consts.GTIN] ?? '';
    lotNo = args[Consts.LOT_NO] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    itemSku = args[Consts.ITEM_SKU] ?? '';
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    packDate = args[Consts.PACK_DATE] ?? '';
    lotSize = args[Consts.LOT_SIZE] ?? '';
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
    sampleSizeByCount = args[Consts.SAMPLE_SIZE_BY_COUNT] ?? 0;
    partialCompleted = args[Consts.PARTIAL_COMPLETED] ?? false;
    qualityComplete = args[Consts.QUALITY_COMPLETED] ?? false;
    isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    fetchInspectionDetails(serverInspectionID);
    rejectionLayout.value = false;
    listAssigned.value = true;

    super.onInit();
  }

  // Fetching the Inspection Details
  Future<void> fetchInspectionDetails(int id) async {
    inspection = await dao.findInspectionByID(id);
    if (inspection != null) {
      inspectionResult = inspection?.result ?? "";
      specificationName = inspection?.specificationName;
      specificationNumber = inspection?.specificationNumber;
      specificationVersion = inspection?.specificationVersion;
      specificationTypeName = inspection?.specificationTypeName;
      sampleSizeByCount = inspection?.sampleSizeByCount;

      qualityControlItem = await dao.findQualityControlDetails(id);
    }

    if (serverInspectionID < 0) {
      isShowDefectButton.value = true;
      isShowTrailerButton.value = true;
      isShowQualityButton.value = true;
    } else {
      var isQctisComplete = await dao.isQCTIsComplete(serverInspectionID);
      if (isQctisComplete) {
        isShowQualityButton.value = true;

        qualityComplete = true;
        areAllInspectionsComplete();
      } else {
        isShowQualityButton.value = false;
      }
      var isISTIsComplete = await dao.isISTIsComplete(serverInspectionID);
      if (isISTIsComplete) {
        isShowDefectButton.value = true;
        areAllInspectionsComplete();
      } else {
        isShowDefectButton.value = false;
      }
      if (inspectionResult.isNotEmpty) {
        if (inspectionResult == 'RJ' || inspectionResult == 'Reject') {
          rejectionLayout.value = true;
          inspectionTextColor = AppColors.red;
          inspectionResultText = "Reject";
          if (qualityControlItem != null) {
            approvalLayout.value = true;
            qtyRejectedController.text =
                qualityControlItem!.qtyRejected.toString();
          }
        } else if (inspectionResult == 'AC' || inspectionResult == 'Accept') {
          inspectionTextColor = AppColors.primary;
          inspectionResultText = "Accept";
        } else if (inspectionResult == 'A-') {
          inspectionTextColor = AppColors.orange;
          inspectionResultText = "A-";
        } else if (inspectionResult == 'AW' ||
            inspectionResult == 'Accept with Condition') {
          inspectionTextColor = AppColors.primary;
          inspectionResultText = 'Accept with Condition';
        }
        isShowSaveButton.value = true;
      }
    }
    _handleCallerActivity();
    _handleGtinActivity();
  }

  void _handleGtinActivity() async {
    if (callerActivity == "GTIN") {
      textspecification.value = true;
      specificationSpinner.value = false;

      textspecificationText = specificationName!;

      if (!(specificationTypeName?.toLowerCase() ==
              "Finished Goods Produce".toLowerCase() ||
          specificationTypeName?.toLowerCase() ==
              "Raw Produce".toLowerCase())) {
        isShowDefectButton.value = false;
      } else {
        isShowDefectButton.value = true;
      }
      isShowTrailerButton.value = true;
      // qualityButton.enabled = true;
    } else {
      textspecification.value = false;
      specificationSpinner.value = true;
    }
  }

  void _handleCallerActivity() async {
    if (callerActivity!.isNotEmpty) {
      //bool isOnline = globalConfigController.hasStableInternet.value;

      if (callerActivity == 'TrendingReportActivity') {
        if (!itemSku!.isNotEmpty) {
          //if (!isOnline) {
          _appStorage.specificationByItemSKUList =
              await dao.getSpecificationByItemSKUFromTable(
            partnerID!,
            itemSku!,
            itemSku!,
          );

          if (_appStorage.specificationByItemSKUList!.isNotEmpty) {
            setSpecificationSpinner();
            //}
          }
        }
      } else if (callerActivity == 'QCDetailsShortForm') {
        if (itemSku!.isNotEmpty) {
          //if (!isOnline) {
          _appStorage.specificationByItemSKUList =
              await dao.getSpecificationByItemSKUFromTable(
            partnerID!,
            itemSku!,
            itemSku!,
          );

          if (_appStorage.specificationByItemSKUList!.isNotEmpty) {
            setSpecificationSpinner();
          }

          Future.delayed(const Duration(milliseconds: 500), () {
            AppAlertDialog.confirmationAlert(
                Get.context!, AppStrings.alert, "Calculate results?",
                onYesTap: () {
              calculateButtonClick(Get.context!);
            });
          });
          //}
        }
      } else if (callerActivity == 'GTIN') {
        // Do nothing
      } else {
        setSpecificationSpinner();
      }
    } else {
      setSpecificationSpinner();
    }
  }

  Future<void> onSpinnerChange(String value) async {
    selectedSpecification = value;
    int position = specificationArray.indexOf(value);
    enableWhenSelectedSpecificationName(position);
    await Utils().offlineLoadCommodityVarietyDocuments(
        specificationNumber!, specificationVersion!);
    update();
  }

  Future<void> setSpecificationSpinner() async {
    // bool isOnline = globalConfigController.hasStableInternet.value;
    specificationList.value = _appStorage.specificationByItemSKUList ?? [];

    if (specificationList.isNotEmpty) {
      specificationArray.clear();
      specificationArray.add('Select Specification');
      for (var spec in specificationList) {
        specificationArray.add(
            '${spec.specificationNumber}-${spec.specificationVersion} : ${spec.specificationName}');
      }

      if (specificationArray.length == 2) {
        selectedSpecification = specificationArray[1];
        enableWhenSelectedSpecificationName(1);

        // if (!isOnline) {
        await Utils().offlineLoadCommodityVarietyDocuments(
            specificationNumber ?? '', specificationVersion ?? '');
        // }
      }

      if (!completed &&
          (specificationName == null || specificationName!.isEmpty)) {
        AppAlertDialog.confirmationAlert(
          Get.context!,
          AppStrings.alert,
          'Please select a specification.',
          onYesTap: () {
            Get.back();
          },
        );
      }
      // ignore: unnecessary_null_comparison
      if (specificationArray != null || specificationArray.isEmpty) {
        updateSpecificationSpinner();
      }
    }
    update();
  }

  void updateSpecificationSpinner() async {
    if (specificationArray.isNotEmpty) {
      final List<DropdownMenuItem<String>> dropDownItems = specificationArray
          .map((spec) => DropdownMenuItem<String>(
                value: spec,
                child: Text(spec),
              ))
          .toList();

      if ((specificationName != null &&
              (completed ||
                  partialCompleted ||
                  qualityComplete ||
                  defectComplete)) ||
          (specificationName != null && gtin != null)) {
        int spinnerPosition = specificationArray.indexOf(
            '$specificationNumber-$specificationVersion : $specificationName');
        enableWhenSelectedSpecificationName(spinnerPosition);
        selectedSpecification = specificationArray[spinnerPosition];
      }

      DropdownButtonFormField<String>(
        value: selectedSpecification!.isEmpty ? null : selectedSpecification,
        items: dropDownItems,
        onChanged: (value) async {
          int position = specificationArray.indexOf(value!);
          enableWhenSelectedSpecificationName(position);

          // if (!isOnline) {
          await Utils().offlineLoadCommodityVarietyDocuments(
              specificationNumber!, specificationVersion!);
          // }
        },
      );
      int position = specificationArray.indexOf('Select Specification');
      enableWhenSelectedSpecificationName(position);

      // if (!isOnline) {
      await Utils().offlineLoadCommodityVarietyDocuments(
          specificationNumber!, specificationVersion!);
      // }
    }
  }

  void enableWhenSelectedSpecificationName(int position) {
    gtinSpinnerEnabled.value = true;
    if (position > 0) {
      SpecificationByItemSKU specificationByItemSKU =
          specificationList[position - 1];
      commodityID = specificationByItemSKU.commodityId;
      commodityName = specificationByItemSKU.commodityName!;
      varietyName = specificationByItemSKU.itemGroup1Name ?? "";
      varietyId = specificationByItemSKU.itemGroup1Id ?? 0;
      gradeId = specificationByItemSKU.gradeId;

      if (commodityName.isEmpty) {
        commodityText = "";
      } else {
        commodityText = commodityName;
      }

      varietyText = varietyName;

      specificationNumber = specificationByItemSKU.specificationNumber;
      specificationVersion = specificationByItemSKU.specificationVersion;
      specificationName = specificationByItemSKU.specificationName;
      specificationTypeName = specificationByItemSKU.specificationTypeName;
      sampleSizeByCount = specificationByItemSKU.sampleSizeByCount;

      debugPrint("specification name = $specificationTypeName");

      if (serverInspectionID < 0) {
        // we're creating a new inspection

        if (!completed && !partialCompleted) {
          // createNewInspection(item_Sku, item_Sku_Id, lot_No, pack_Date, specificationNumber,
          //     specificationVersion, specificationName, specificationTypeName,
          //     sampleSizeByCount);
        }
      } else {
        // dao.updateInspection(serverInspectionID, commodityID, commodityName, varietyId, varietyName,
        //     gradeId, specificationNumber,
        //     specificationVersion, specificationName, specificationTypeName,
        //     sampleSizeByCount);
      }

      if (!(specificationTypeName
                  ?.toLowerCase()
                  .contains("Finished Goods Produce".toLowerCase()) ??
              false) &&
          !(specificationTypeName
                  ?.toLowerCase()
                  .contains("Raw Produce".toLowerCase()) ??
              false)) {
        isShowDefectButton.value = false;
      } else {
        isShowDefectButton.value = true;
      }
      isShowTrailerButton.value = true;
      isShowQualityButton.value = true;
    }
  }

  void areAllInspectionsComplete() {
    if (defectComplete && qualityComplete) {
      isShowDefectButton.value = true;
    } else if (serverInspectionID > 0 && qualityComplete) {
      if (inspection != null) {
        specificationTypeName = inspection!.specificationTypeName;
      }
      if (specificationTypeName!.isNotEmpty &&
          (specificationTypeName?.toLowerCase() !=
                  'Finished Goods Produce'.toLowerCase() &&
              specificationTypeName?.toLowerCase() !=
                  'Raw Produce'.toLowerCase())) {
        isShowDefectButton.value = true;
      }
    }
  }

  // QC Header Button OnClick Event
  void onQcHeaderButtonClick() {
    Map<String, dynamic> passingData = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PO_NUMBER: poNumber,
      "callerActivity": "QualityControlHeaderActivity",
    };
    Get.to(() => const QualityControlHeader(), arguments: passingData);
  }

  // Calculate Result Button OnClick Event
  void onCalculateResultButtonClick() async {
    bool isOnline = globalConfigController.hasStableInternet.value;
    if (isOnline) {
      // Make web service call
      // For example:
      // WSSpecificationGradeTolerance specificationWebservice = WSSpecificationGradeTolerance();
      // specificationWebservice.RequestSpecificationGradeTolerance(specificationNumber, specificationVersion);
    } else {
      // Load data from table
    }
    _appStorage.specificationGradeToleranceList =
        await dao.getSpecificationGradeTolerance(
      specificationNumber!,
      specificationVersion!,
    );
    // calculateResult22();
  }

  Future<void> setComplete(bool complete) async {
    if (serverInspectionID > -1) {
      await dao.updateInspectionComplete(serverInspectionID, complete);
    }
  }

  void onSaveButtonClick() async {
    var isSuccess = await saveFieldsToDB();
    if (isSuccess) {
      setComplete(true);

      await dao.updateItemSKUInspectionComplete(serverInspectionID, true);

      Utils.setInspectionUploadStatus(
          inspection!.inspectionId!, Consts.INSPECTION_UPLOAD_READY);

      if (isMyInspectionScreen) {
        final String uniqueTag =
            DateTime.now().millisecondsSinceEpoch.toString();
        Get.offAll(() => Home(tag: uniqueTag));
      } else {
        callNextItemQCDetails();
      }
    }
  }

  Future<bool> saveFieldsToDB() async {
    bool hasErrors = false;

    if (approvalLayout.isTrue) {
      String tempQty = qtyRejectedController.text;

      if (tempQty.isEmpty || tempQty == "") {
        hasErrors = true;
        qtyRejectedController.text = 'Quantity rejected is required';
      } else if (qualityControlItem != null &&
          (int.tryParse(tempQty)! > qualityControlItem!.qtyShipped! ||
              int.tryParse(tempQty)! < 0)) {
        hasErrors = true;
        qtyRejectedController.text = 'Invalid quantity rejected';
      } else {
        if (tempQty.isNotEmpty && tempQty != "") {
          int qtyRejected = int.tryParse(tempQty)!;
          int qtyReceived = 0;
          if (qualityControlItem != null) {
            qtyReceived = qualityControlItem!.qtyShipped! - qtyRejected;
          }

          dao.updateQuantityRejected(
              serverInspectionID, qtyRejected, qtyReceived);
        }
      }
    }

    return !hasErrors;
  }

  Future<void> callNextItemQCDetails() async {
    lotNo = lotNo;
    itemSku = itemSku;
    itemSkuId = itemSkuId;
    itemUniqueId = itemUniqueId;

    for (int j = 0; j < _appStorage.selectedItemSKUList.length; j++) {
      if (_appStorage.selectedItemSKUList[j].uniqueItemId == itemUniqueId) {
        _appStorage.selectedItemSKUList[j].lotNo = lotNo;
        _appStorage.selectedItemSKUList[j].sku = itemSku;
        _appStorage.selectedItemSKUList[j].id = itemSkuId;
        break;
      }
    }

    PartnerItemSKUInspections? partnerItemSKU =
        await dao.findPartnerItemSKU(partnerID!, itemSku!, itemUniqueId);
    isComplete = false;
    isPartialComplete = false;

    if (partnerItemSKU != null) {
      isComplete =
          await dao.isInspectionComplete(partnerID!, itemSku!, itemUniqueId);
      if (!isComplete) {
        isPartialComplete = await dao.isInspectionPartialComplete(
            partnerID!, itemSku!, itemUniqueId!);
      }
    }
    bool isItemAvailable = false;

    for (int i = 0; i < _appStorage.tempSelectedItemSKUList.length; i++) {
      if (!isPartialComplete && !isComplete) {
        isItemAvailable = true;
        lotNo = _appStorage.tempSelectedItemSKUList[i].lotNo;
        itemSku = _appStorage.tempSelectedItemSKUList[i].sku;
        itemSkuId = _appStorage.tempSelectedItemSKUList[i].id;
        itemUniqueId = _appStorage.tempSelectedItemSKUList[i].uniqueItemId;

        bool isOnline = globalConfigController.hasStableInternet.value;
        if (isOnline) {
          // WSSpecificationByItemSKU webservice = WSSpecificationByItemSKU(context);
          // webservice.RequestSpecificationByItemSKU(partnerID, _appStorage.selectedItemSKUList[i].sku);
        } else {
          _appStorage.specificationByItemSKUList =
              await dao.getSpecificationByItemSKUFromTable(
            partnerID!,
            _appStorage.selectedItemSKUList[i].sku!,
            _appStorage.selectedItemSKUList[i].sku!,
          );

          if (_appStorage.specificationByItemSKUList != null &&
              _appStorage.specificationByItemSKUList!.isNotEmpty) {
            Map<String, dynamic> passingData = {
              Consts.SERVER_INSPECTION_ID: -1,
              Consts.SPECIFICATION_NUMBER: specificationNumber,
              Consts.SPECIFICATION_VERSION: specificationVersion,
              Consts.SPECIFICATION_NAME: specificationName,
              Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
              Consts.SEAL_NUMBER: sealNumber,
              Consts.PARTNER_NAME: partnerName,
              Consts.PARTNER_ID: partnerID,
              Consts.CARRIER_NAME: carrierName,
              Consts.CARRIER_ID: carrierID,
              Consts.ITEM_SKU: itemSku,
              Consts.ITEM_UNIQUE_ID: itemUniqueId,
              Consts.ITEM_SKU_ID: itemSkuId,
              Consts.COMPLETED: false,
              Consts.PARTIAL_COMPLETED: false,
              Consts.COMMODITY_ID: commodityID,
              Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
              Consts.ITEM_SKU_NAME: itemSkuName,
            };

            final String uniqueTag =
                DateTime.now().millisecondsSinceEpoch.toString();
            Get.to(() => QCDetailsShortFormScreen(tag: uniqueTag),
                arguments: passingData);
          } else {
            AppAlertDialog.confirmationAlert(
              Get.context!,
              AppStrings.alert,
              'No specification available for $itemSku',
              onYesTap: () {
                Get.back();
              },
            );
          }
        }
        break;
      } else {
        _appStorage.tempSelectedItemSKUList.removeAt(i);
        i--;
        isComplete = false;
        isPartialComplete = false;
      }
    }
    if (!isItemAvailable) {
      callPurchaseOrderDetailsActivity();
    }
  }

  void callPurchaseOrderDetailsActivity() {
    Map<String, dynamic> passingData = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.PO_NUMBER: poNumber,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.ITEM_SKU: itemSku,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.LOT_NO: lotNo,
      Consts.GTIN: gtin,
      Consts.PACK_DATE: packDate,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VARIETY_NAME: varietyName,
      Consts.VARIETY_ID: varietyId,
      Consts.GRADE_ID: gradeId,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SPECIFICATION_NAME: specificationName,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.ITEM_UNIQUE_ID: itemUniqueId,
      Consts.ITEM_SKU_NAME: itemSkuName,
      Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
    };

    final String uniqueTag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.to(() => QCDetailsShortFormScreen(tag: uniqueTag),
        arguments: passingData);
  }

  // Defect Button OnClick event
  void onDefectButtonClick() {
    startDefectsActivity();
  }

  void startDefectsActivity() {
    Map<String, dynamic> bundle = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.COMPLETED: completed,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VARIETY_NAME: varietyName,
      Consts.VARIETY_SIZE: varietySize,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.PO_NUMBER: poNumber,
      Consts.VARIETY_ID: varietyId,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SAMPLE_SIZE_BY_COUNT: sampleSizeByCount,
      Consts.SPECIFICATION_NAME: selectedSpecification,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.INSPECTION_RESULT: inspectionResult,
      Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
      Consts.ITEM_SKU: itemSku,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.LOT_NO: lotNo,
      Consts.GTIN: gtin,
      Consts.PACK_DATE: packDate,
    };

    final String uniqueTag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.to(
      () => DefectsScreen(tag: uniqueTag),
      arguments: bundle,
    );
  }

  // Trailer Button OnClick event
  void onTrailerButtonClick() {
    startTrailerTemperatureActivity();
  }

  void startTrailerTemperatureActivity() {
    Map<String, dynamic> passingData = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.COMPLETED: completed,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VARIETY_NAME: varietyName,
      Consts.VARIETY_SIZE: varietySize,
      Consts.VARIETY_ID: varietyId,
      Consts.INSPECTION_RESULT: inspectionResult,
    };

    Get.to(() => TrailerTemp(), arguments: passingData);
  }

  // Quality Control Button OnClick event
  void onQualityControllDetailsButtonClick() {
    startQCDetailForm();
  }

  void startQCDetailForm() {
    _appStorage.resumeFromSpecificationAttributes = false;

    Map<String, dynamic> bundle = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.COMPLETED: completed,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VARIETY_NAME: varietyName,
      Consts.VARIETY_SIZE: varietySize,
      Consts.VARIETY_ID: varietyId,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.PO_NUMBER: poNumber,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SPECIFICATION_NAME: selectedSpecification,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.INSPECTION_RESULT: inspectionResult,
      Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
      Consts.ITEM_SKU: itemSku,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.LOT_NO: lotNo,
      Consts.GTIN: gtin,
      Consts.PACK_DATE: packDate,
      Consts.LOT_SIZE: lotSize,
    };

    final String uniqueTag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.to(
      () => QCDetailsShortFormScreen(tag: uniqueTag),
      arguments: bundle,
    );
  }

  // Edit Inspection Button OnClick event
  void onEditInspectionButtonClick() async {
    Map<String, dynamic> bundle = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.COMPLETED: completed,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VARIETY_NAME: varietyName,
      Consts.VARIETY_ID: varietyId,
      Consts.INSPECTION_RESULT: inspectionResult,
      Consts.ITEM_SKU: itemSku,
    };

    var getData =
        await Get.to(() => const OverriddenResultScreen(), arguments: bundle);
    if (getData != null) {
      int inspectionId = getData;

      if (inspectionId == -1) {
        if (serverInspectionID > -1) {
          inspectionId = serverInspectionID;
        } else if (_appStorage.currentInspection != null) {
          inspectionId = _appStorage.currentInspection!.inspectionId!;
        }
      }

      OverriddenResult? overriddenResult =
          await dao.getOverriddenResult(inspectionId);
      String? result = overriddenResult?.overriddenResult;

      if (result == "RJ" || result == "Reject") {
        inspectionResult = "Reject";
        inspectionResultText = "Reject";
        inspectionTextColor = AppColors.red;
        approvalLayout.value = true;
        setResult("RJ");
        qualityControlItem = await dao.findQualityControlDetails(inspectionId);
        if (qualityControlItem != null) {
          qtyRejectedController.text =
              qualityControlItem!.qtyRejected.toString();
        }
      } else if (result == "AC" || result == "Accept") {
        inspectionResult = "Accept";
        inspectionResultText = "Accept";
        inspectionTextColor = AppColors.primary;
        approvalLayout.value = false;
        setResult("AC");
      } else if (result == "A-") {
        inspectionResult = "A-";
        inspectionResultText = "A-";
        inspectionTextColor = AppColors.yellow;
        approvalLayout.value = false;
        setResult("A-");
      } else if (result == AppStrings.acceptCondition || result == "AW") {
        inspectionResult = AppStrings.acceptCondition;
        inspectionResultText = "AW";
        inspectionTextColor = AppColors.primary;
        approvalLayout.value = false;
        setResult("AW");
      }

      update();
    }
  }

  List<FinishedGoodsItemSKU> get selectedItemSKUList =>
      _appStorage.selectedItemSKUList;

  // Calculate Button OnClick event
  Future<void> calculateButtonClick(BuildContext context) async {
    _appStorage.specificationGradeToleranceList =
        await dao.getSpecificationGradeTolerance(
            specificationNumber!, specificationVersion!);
    await calculateResult();
  }

  // Calculate Inspection Result
  Future<String> calculateResult() async {
    String result = "";
    String rejectReason = "";
    int totalQualityDefectId = 0;
    int totalConditionDefectId = 0;

    try {
      if (inspection != null && inspection?.inspectionId != null) {
        await dao
            .deleteRejectionDetailByInspectionId(inspection!.inspectionId!);

        QCHeaderDetails? qcHeaderDetails =
            await dao.findTempQCHeaderDetails(inspection!.poNumber!);

        if (qcHeaderDetails != null && qcHeaderDetails.truckTempOk == 'N') {
          result = 'RJ';

          inspectionTextColor = AppColors.red;
          inspectionResultText = AppStrings.reject;
          approvalLayout.value = true;

          QualityControlItem? qualityControlItems =
              await dao.findQualityControlDetails(inspection!.inspectionId!);

          if (qualityControlItems != null) {
            await dao.updateQuantityRejected(
                inspection!.inspectionId!, qualityControlItems.qtyShipped!, 0);
          }

          await dao.updateInspectionResult(inspection!.inspectionId!, result);
          await dao.updateOverriddenResult(inspection!.inspectionId!, result);

          await dao.updateInspectionComplete(inspection!.inspectionId!, true);
          await dao.updateItemSKUInspectionComplete(
              inspection!.inspectionId!, true);

          Utils.setInspectionUploadStatus(
              inspection!.inspectionId!, Consts.INSPECTION_UPLOAD_READY);

          await dao.createOrUpdateResultReasonDetails(
              inspection!.inspectionId!, result, "Truck Temp Ok = No", "");
          setResult('RJ');

          inspectionTextColor = AppColors.red;
          inspectionResultText = AppStrings.reject;
          approvalLayout.value = true;

          isShowSaveButton.value = true;
          rejectionLayout.value = true;

          if (qualityControlItems != null) {
            if (qualityControlItems.qtyRejected == 0) {
              qtyRejectedController.text =
                  qualityControlItems.qtyShipped.toString();
            } else {
              qtyRejectedController.text =
                  qualityControlItems.qtyRejected.toString();
            }
          } else {
            qtyRejectedController.text =
                qualityControlItems!.qtyShipped.toString();
          }
        }

        if (result != "RJ") {
          List<String> rejectReasonArray = [];
          List<String> defectNameReasonArray = [];
          _appStorage.specificationAnalyticalList =
              await dao.getSpecificationAnalyticalFromDB(
                  specificationNumber!, specificationVersion!);
          log("HERE IS SPECIFICATION TYPE NAME $specificationTypeName");
          if ((!(specificationTypeName?.toLowerCase() ==
                  ("Finished Goods Produce".toLowerCase())) &&
              !(specificationTypeName?.toLowerCase() ==
                  ("Raw Produce".toLowerCase())))) {
            if (_appStorage.specificationAnalyticalList != null) {
              for (var item
                  in (_appStorage.specificationAnalyticalList ?? [])) {
                SpecificationAnalyticalRequest? dbobj =
                    await dao.findSpecAnalyticalObj(
                        inspection!.inspectionId!, item.analyticalID);
                if (dbobj != null &&
                    (dbobj.comply == 'N' || dbobj.comply == 'No')) {
                  if (dbobj.inspectionResult != null &&
                      (dbobj.inspectionResult == 'No' ||
                          dbobj.inspectionResult == 'N')) {
                    // Do nothing
                  } else {
                    result = "RJ";
                    rejectReason += "${dbobj.analyticalName} = N";
                    rejectReasonArray.add("${dbobj.analyticalName} = N");

                    await dao.createOrUpdateResultReasonDetails(
                        inspection!.inspectionId!,
                        result,
                        "${dbobj.analyticalName} = N",
                        dbobj.comment!);

                    await dao.createIsPictureReqSpecAttribute(
                      inspection!.inspectionId!,
                      result,
                      "${dbobj.analyticalName} = N",
                      dbobj.isPictureRequired!,
                      // dbobj.comment ?? '',
                    );
                    break;
                  }
                }
              }
              if (result == "") {
                result = "AC";
                inspectionTextColor = AppColors.primary;
                inspectionResultText = 'Accept';
                approvalLayout.value = false;
              }
              isShowSaveButton.value = true;
              rejectionLayout.value = true;
            }

            if (result == "A-" || result == "AC") {
              QualityControlItem? qualityControlItems = await dao
                  .findQualityControlDetails(inspection!.inspectionId!);

              await dao.updateQuantityRejected(inspection!.inspectionId!, 0,
                  qualityControlItems!.qtyShipped!);
            }

            await dao.updateInspectionResult(inspection!.inspectionId!, result);

            await dao.createOrUpdateInspectionSpecification(
              inspection!.inspectionId!,
              specificationNumber,
              specificationVersion,
              specificationName,
            );

            await dao.updateInspectionComplete(inspection!.inspectionId!, true);

            await dao.updateItemSKUInspectionComplete(
                inspection!.inspectionId!, true);

            Utils.setInspectionUploadStatus(
                inspection!.inspectionId!, Consts.INSPECTION_UPLOAD_READY);
            update();
          }
          //
          else if (_appStorage.specificationGradeToleranceList != null &&
              (_appStorage.specificationGradeToleranceList ?? []).isNotEmpty) {
            int totalSampleSize = 0;

            List<InspectionSample> samples =
                await dao.findInspectionSamples(inspection!.inspectionId!);
            if (samples.isNotEmpty) {
              for (int a = 0; a < samples.length; a++) {
                totalSampleSize += samples[a].setSize!;
                debugPrint('line no 964 : Total sample size: $totalSampleSize');
              }
            }
            if (_appStorage.defectCategoriesList != null) {
              for (DefectCategories defectCategory
                  in _appStorage.defectCategoriesList ?? []) {
                if (defectCategory.name == "Quality" &&
                    (defectCategory.defectList != null)) {
                  for (DefectItem defectItem
                      in defectCategory.defectList ?? []) {
                    if (defectItem.name?.contains("Total Quality") ?? false) {
                      totalQualityDefectId = defectItem.id ?? 0;
                      break;
                    }
                  }
                } else if (defectCategory.name == "Condition" &&
                    (defectCategory.defectList != null)) {
                  for (DefectItem defectItem
                      in defectCategory.defectList ?? []) {
                    if (defectItem.name?.contains("Total Condition") ?? false) {
                      totalConditionDefectId = defectItem.id ?? 0;
                      break;
                    }
                  }
                }
              }
            }

            for (int n = 0;
                n < _appStorage.specificationGradeToleranceList!.length;
                n++) {
              SpecificationGradeTolerance gradeTolerance =
                  _appStorage.specificationGradeToleranceList!.elementAt(n);

              int specTolerancePercentage =
                  gradeTolerance.specTolerancePercentage ?? 0;
              int? defectID = gradeTolerance.defectID;
              int severityDefectID = gradeTolerance.severityDefectID ?? 0;
              String tempSeverityDefectName = "";
              String defectName = gradeTolerance.defectName ?? '';

              if (_appStorage.severityDefectsList != null) {
                for (int m = 0;
                    m < _appStorage.severityDefectsList!.length;
                    m++) {
                  // ignore: unnecessary_null_comparison
                  if ((severityDefectID != null) &&
                      severityDefectID ==
                          _appStorage.severityDefectsList!.elementAt(m).id) {
                    tempSeverityDefectName =
                        _appStorage.severityDefectsList!.elementAt(m).name ??
                            '';
                    break;
                  }
                }
              }

              int totalcount = 0;
              // int totalSampleSize = 0;
              int totalSize = 0;
              int totalColor = 0;
              bool iscalculated = false;
              int totalQualitycount = 0;
              int totalQualityInjury = 0;
              int totalQualityDamage = 0;
              int totalQualitySeriousDamage = 0;
              int totalQualityVerySeriousDamage = 0;
              int totalQualityDecay = 0;

              int totalConditionCount = 0;
              int totalConditionInjury = 0;
              int totalConditionDamage = 0;
              int totalConditionSeriousDamage = 0;
              int totalConditionVerySeriousDamage = 0;
              int totalConditionDecay = 0;
              String defectNameResult = "";

              int totalSeverityInjury = 0;
              int totalSeverityDamage = 0;
              int totalSeveritySeriousDamage = 0;
              int totalSeverityVerySeriousDamage = 0;
              int totalSeverityDecay = 0;

              if (samples.isNotEmpty) {
                for (int f = 0; f < samples.length; f++) {
                  List<InspectionDefect> defectList = await dao
                      .findInspectionDefects(samples.elementAt(f).sampleId!);
                  String? sizeDefectName;
                  String? colorDefectName;

                  if (defectList.isNotEmpty) {
                    if (defectID == null || defectID == 0) {
                      for (int k = 0; k < defectList.length; k++) {
                        if (defectList.elementAt(k).defectCategory ==
                                "quality" ||
                            (defectList.elementAt(k).defectCategory ==
                                "condition")) {
                          if (defectList.elementAt(k).verySeriousDamageCnt! >
                              0) {
                            if (tempSeverityDefectName ==
                                "Very Serious Damage") {
                              totalcount +=
                                  defectList.elementAt(k).verySeriousDamageCnt!;
                              totalSeverityVerySeriousDamage +=
                                  defectList.elementAt(k).verySeriousDamageCnt!;
                              iscalculated = true;
                            }
                          }
                          if (defectList.elementAt(k).seriousDamageCnt! > 0) {
                            if (tempSeverityDefectName == "Serious Damage") {
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt!) {
                                totalcount +=
                                    (defectList.elementAt(k).seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!);
                                totalSeveritySeriousDamage +=
                                    defectList.elementAt(k).seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                                iscalculated = true;
                              }
                            }
                          }
                          if (defectList.elementAt(k).damageCnt! > 0) {
                            if (tempSeverityDefectName == "Damage") {
                              if (defectList.elementAt(k).damageCnt! >
                                  defectList.elementAt(k).seriousDamageCnt!) {
                                totalcount += defectList
                                        .elementAt(k)
                                        .damageCnt! -
                                    defectList.elementAt(k).seriousDamageCnt!;
                                totalSeverityDamage += defectList
                                        .elementAt(k)
                                        .damageCnt! -
                                    defectList.elementAt(k).seriousDamageCnt!;
                                iscalculated = true;
                              }
                            }
                          }
                          if (defectList.elementAt(k).injuryCnt! > 0) {
                            if (tempSeverityDefectName == "Injury") {
                              if (defectList.elementAt(k).injuryCnt! >
                                  defectList.elementAt(k).damageCnt!) {
                                totalcount +=
                                    defectList.elementAt(k).injuryCnt! -
                                        defectList.elementAt(k).damageCnt!;
                                totalSeverityInjury +=
                                    defectList.elementAt(k).injuryCnt! -
                                        defectList.elementAt(k).damageCnt!;
                                iscalculated = true;
                              }
                            }
                          }
                          if (defectList.elementAt(k).decayCnt! > 0) {
                            if (tempSeverityDefectName == "Decay") {
                              totalcount += defectList.elementAt(k).decayCnt!;
                              totalSeverityDecay +=
                                  defectList.elementAt(k).decayCnt!;

                              iscalculated = true;
                            }
                          }

                          if (tempSeverityDefectName == "") {
                            if (defectList.elementAt(k).verySeriousDamageCnt! >
                                0) {
                              totalcount +=
                                  defectList.elementAt(k).verySeriousDamageCnt!;
                            }
                            if (defectList.elementAt(k).seriousDamageCnt! > 0) {
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt!) {
                                totalcount +=
                                    (defectList.elementAt(k).seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!);
                              }
                            }
                            if (defectList.elementAt(k).damageCnt! > 0) {
                              if (defectList.elementAt(k).damageCnt! >
                                  defectList.elementAt(k).seriousDamageCnt!) {
                                totalcount += defectList
                                        .elementAt(k)
                                        .damageCnt! -
                                    defectList.elementAt(k).seriousDamageCnt!;
                              }
                            }
                            if (defectList.elementAt(k).injuryCnt! > 0) {
                              if (defectList.elementAt(k).injuryCnt! >
                                  defectList.elementAt(k).damageCnt!) {
                                totalcount +=
                                    defectList.elementAt(k).injuryCnt! -
                                        defectList.elementAt(k).damageCnt!;
                              }
                            }
                            if (defectList.elementAt(k).decayCnt! > 0) {
                              totalcount += defectList.elementAt(k).decayCnt!;
                            }
                            iscalculated = true;
                          }
                        }
                      }
//---------------------------------------------------------------------------------------------------------------------------------
                      if (result != "RJ" &&
                          tempSeverityDefectName == "Very Serious Damage") {
                        double vsdpercent = totalSeverityVerySeriousDamage *
                            100 /
                            totalSampleSize;
                        if (vsdpercent > specTolerancePercentage) {
                          result = "RJ";
                          //rejectReason += "Total Severity VSD % exceeds tolerance";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              result,
                              "Total Severity VSD % exceeds tolerance",
                              "");
                          break;
                        } else if ((vsdpercent > specTolerancePercentage / 2) &&
                            (vsdpercent <= specTolerancePercentage)) {
                          result = "A-";
                        }
                      }

                      if (tempSeverityDefectName == "Very Serious Damage") {
                        double vsdpercent = totalSeverityVerySeriousDamage *
                            100 /
                            totalSampleSize;
                        if (vsdpercent > specTolerancePercentage) {
                          if (rejectReason != "") {
                            rejectReason += ", ";
                          }
                          rejectReasonArray
                              .add("Total Severity VSD % exceeds tolerance");

                          rejectReason +=
                              "Total Severity VSD % exceeds tolerance";

                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              "RJ",
                              rejectReason,
                              "");
                        }
                      }

                      if (result != "RJ" &&
                          tempSeverityDefectName == "Serious Damage") {
                        double sdpercent =
                            totalSeveritySeriousDamage * 100 / totalSampleSize;
                        if (sdpercent > specTolerancePercentage) {
                          result = "RJ";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              result,
                              " Total Severity SD % exceeds tolerance",
                              "");
                        } else if ((sdpercent > specTolerancePercentage / 2) &&
                            (sdpercent <= specTolerancePercentage)) {
                          result = "A-";
                        }
                      }

                      if (tempSeverityDefectName == "Serious Damage") {
                        double sdpercent =
                            totalSeveritySeriousDamage * 100 / totalSampleSize;
                        if (sdpercent > specTolerancePercentage) {
                          if (rejectReason != "") {
                            rejectReason += ", ";
                          }
                          rejectReasonArray
                              .add("Total Severity SD % exceeds tolerance");

                          rejectReason +=
                              " Total Severity SD % exceeds tolerance";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              "RJ",
                              rejectReason,
                              "");
                        }
                      }

                      if (result != "RJ" &&
                          tempSeverityDefectName == "Damage") {
                        double dpercent =
                            totalSeverityDamage * 100 / totalSampleSize;
                        if (dpercent > specTolerancePercentage) {
                          result = "RJ";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              result,
                              " Total Severity Damage % exceeds tolerance",
                              "");
                        } else if ((dpercent > specTolerancePercentage / 2) &&
                            (dpercent <= specTolerancePercentage)) {
                          result = "A-";
                        }
                      }

                      if (tempSeverityDefectName == "Damage") {
                        double dpercent =
                            totalSeverityDamage * 100 / totalSampleSize;
                        if (dpercent > specTolerancePercentage) {
                          if (rejectReason != "") {
                            rejectReason += ", ";
                          }
                          rejectReasonArray
                              .add("Total Severity Damage % exceeds tolerance");

                          rejectReason +=
                              " Total Severity Damage % exceeds tolerance";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              "RJ",
                              rejectReason,
                              "");
                        }
                      }

                      if (result != "RJ" &&
                          tempSeverityDefectName == "Injury") {
                        double ipercent =
                            totalSeverityInjury * 100 / totalSampleSize;
                        if (ipercent > specTolerancePercentage) {
                          result = "RJ";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              result,
                              " Total Severity Injury % exceeds tolerance",
                              "");
                          break;
                        } else if ((ipercent > specTolerancePercentage / 2) &&
                            (ipercent <= specTolerancePercentage)) {
                          result = "A-";
                        }
                      }

                      if (tempSeverityDefectName == "Injury") {
                        double ipercent =
                            totalSeverityInjury * 100 / totalSampleSize;
                        if (ipercent > specTolerancePercentage) {
                          if (rejectReason != "") {
                            rejectReason += ", ";
                          }
                          rejectReasonArray
                              .add("Total Severity Injury % exceeds tolerance");

                          rejectReason +=
                              "Total Severity Injury % exceeds tolerance";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              "RJ",
                              rejectReason,
                              "");
                        }
                      }

                      if (result != "RJ" && tempSeverityDefectName == "Decay") {
                        double depercent =
                            totalSeverityDecay * 100 / totalSampleSize;
                        if (depercent > specTolerancePercentage) {
                          result = "RJ";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              result,
                              " Total Severity Decay % exceeds tolerance",
                              "");
                        } else if ((depercent > specTolerancePercentage / 2) &&
                            (depercent <= specTolerancePercentage)) {
                          result = "A-";
                        }
                      }

                      if (tempSeverityDefectName == "Decay") {
                        double depercent =
                            totalSeverityDecay * 100 / totalSampleSize;
                        if (depercent > specTolerancePercentage) {
                          if (rejectReason != "") {
                            rejectReason += ", ";
                          }
                          rejectReasonArray
                              .add("Total Severity Decay % exceeds tolerance");

                          rejectReason +=
                              " Total Severity Decay % exceeds tolerance";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              "RJ",
                              rejectReason,
                              "");
                        }
                      }

                      if (result != "RJ" && tempSeverityDefectName == "") {
                        double qualpercentage =
                            (totalcount * 100) / totalSampleSize;
                        if (qualpercentage > specTolerancePercentage) {
                          result = "RJ";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              result,
                              "Total Severity % exceeds tolerance",
                              "");
                        } else if ((qualpercentage >
                                specTolerancePercentage / 2) &&
                            (qualpercentage <= specTolerancePercentage)) {
                          result = "A-";
                        }
                      }

                      if (tempSeverityDefectName == "") {
                        double qualpercentage =
                            (totalcount * 100) / totalSampleSize;
                        if (qualpercentage > specTolerancePercentage) {
                          if (rejectReason != "") {
                            rejectReason += ", ";
                          }
                          rejectReasonArray
                              .add("Total Severity % exceeds tolerance");

                          rejectReason += "Total Severity % exceeds tolerance";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection!.inspectionId!,
                              "RJ",
                              rejectReason,
                              "");
                        }
                      }
                      //------------------------------------------------------------------------------------------------------------------------------------
                    } else {
                      for (int k = 0; k < defectList.length; k++) {
                        if (defectList.elementAt(k).defectCategory ==
                                "quality" ||
                            defectList.elementAt(k).defectCategory ==
                                "condition") {
                          if (defectID == defectList.elementAt(k).defectId) {
                            defectNameResult =
                                defectList.elementAt(k).spinnerSelection!;

                            if (tempSeverityDefectName ==
                                "Very Serious Damage") {
                              if (defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt! >
                                  0) {
                                iscalculated = true;
                                totalcount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;

                                if (defectList.elementAt(k).defectCategory ==
                                    "quality") {
                                  totalQualitycount += defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt!;
                                  totalQualityVerySeriousDamage += defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt!;
                                } else if (defectList
                                        .elementAt(k)
                                        .defectCategory ==
                                    "condition") {
                                  totalConditionCount += defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt!;
                                  totalConditionVerySeriousDamage += defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt!;
                                }

                                if (result != "RJ") {
                                  double vsdpercent =
                                      totalQualityVerySeriousDamage *
                                          100 /
                                          totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        result,
                                        "$defectNameResult - Quality (VSD)  % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else if ((vsdpercent >
                                          specTolerancePercentage / 2) &&
                                      (vsdpercent <= specTolerancePercentage)) {
                                    result = "A-";
                                  }
                                }

                                double vsdpercent1 =
                                    totalQualityVerySeriousDamage *
                                        100 /
                                        totalSampleSize;
                                debugPrint("$vsdpercent1");
                                if (result != "RJ") {
                                  double vsdpercent =
                                      totalConditionVerySeriousDamage *
                                          100 /
                                          totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        result,
                                        "$defectNameResult - Condition (VSD)  % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else if ((vsdpercent >
                                          specTolerancePercentage / 2) &&
                                      (vsdpercent <= specTolerancePercentage)) {
                                    result = "A-";
                                  }
                                }

                                double vsdpercent2 =
                                    totalConditionVerySeriousDamage *
                                        100 /
                                        totalSampleSize;
                                debugPrint("$vsdpercent2");
                              }
                            }
                            if (tempSeverityDefectName == "Serious Damage") {
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  0) {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  totalcount += (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!);
                                  iscalculated = true;

                                  if (defectList.elementAt(k).defectCategory ==
                                      "quality") {
                                    totalQualitycount += defectList
                                            .elementAt(k)
                                            .seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                                    totalQualitySeriousDamage += defectList
                                            .elementAt(k)
                                            .seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                                  } else if (defectList
                                          .elementAt(k)
                                          .defectCategory ==
                                      "condition") {
                                    totalConditionCount += defectList
                                            .elementAt(k)
                                            .seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                                    totalConditionSeriousDamage += defectList
                                            .elementAt(k)
                                            .seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                                  }

                                  if (result != "RJ") {
                                    double vsdpercent =
                                        totalQualitySeriousDamage *
                                            100 /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection!.inspectionId!,
                                          result,
                                          "$defectNameResult - Quality (SD)  % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }

                                  double vsdpercent3 =
                                      totalQualitySeriousDamage *
                                          100 /
                                          totalSampleSize;
                                  debugPrint("$vsdpercent3");
                                  if (result != "RJ") {
                                    double vsdpercent =
                                        totalConditionSeriousDamage *
                                            100 /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection!.inspectionId!,
                                          result,
                                          "$defectNameResult - Condition (SD)  % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }
                                  double vsdpercent4 =
                                      totalConditionSeriousDamage *
                                          100 /
                                          totalSampleSize;
                                  debugPrint("$vsdpercent4");
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Damage") {
                              if (defectList.elementAt(k).damageCnt! > 0) {
                                if (defectList.elementAt(k).damageCnt! >
                                    defectList.elementAt(k).seriousDamageCnt!) {
                                  totalcount +=
                                      (defectList.elementAt(k).damageCnt! -
                                          defectList
                                              .elementAt(k)
                                              .seriousDamageCnt!);
                                  iscalculated = true;
                                  if (defectList.elementAt(k).defectCategory ==
                                      "quality") {
                                    totalQualitycount +=
                                        defectList.elementAt(k).damageCnt! -
                                            defectList
                                                .elementAt(k)
                                                .seriousDamageCnt!;
                                    totalQualityDamage +=
                                        defectList.elementAt(k).damageCnt! -
                                            defectList
                                                .elementAt(k)
                                                .seriousDamageCnt!;
                                  } else if (defectList
                                          .elementAt(k)
                                          .defectCategory ==
                                      "condition") {
                                    totalConditionCount +=
                                        defectList.elementAt(k).damageCnt! -
                                            defectList
                                                .elementAt(k)
                                                .seriousDamageCnt!;
                                    totalConditionDamage +=
                                        defectList.elementAt(k).damageCnt! -
                                            defectList
                                                .elementAt(k)
                                                .seriousDamageCnt!;
                                  }
                                }
                              }
                              if (result != "RJ") {
                                double vsdpercent =
                                    totalQualityDamage * 100 / totalSampleSize;
                                if (vsdpercent > specTolerancePercentage) {
                                  result = "RJ";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "$defectNameResult - Quality (Damage)  % exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                } else if ((vsdpercent >
                                        specTolerancePercentage / 2) &&
                                    (vsdpercent <= specTolerancePercentage)) {
                                  result = "A-";
                                }
                              }

                              double vsdpercent5 =
                                  totalQualityDamage * 100 / totalSampleSize;
                              debugPrint("$vsdpercent5");
                              if (result != "RJ") {
                                double vsdpercent = totalConditionDamage *
                                    100 /
                                    totalSampleSize;
                                if (vsdpercent > specTolerancePercentage) {
                                  result = "RJ";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "$defectNameResult - Condition (Damage)  % exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                } else if ((vsdpercent >
                                        specTolerancePercentage / 2) &&
                                    (vsdpercent <= specTolerancePercentage)) {
                                  result = "A-";
                                }
                              }

                              double vsdpercent6 =
                                  totalConditionDamage * 100 / totalSampleSize;
                              debugPrint("$vsdpercent6");
                            }
                            if (tempSeverityDefectName == "Injury") {
                              if (defectList.elementAt(k).injuryCnt! > 0) {
                                if (defectList.elementAt(k).injuryCnt! >
                                    defectList.elementAt(k).damageCnt!) {
                                  totalcount +=
                                      (defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!);
                                  iscalculated = true;
                                  if (defectList.elementAt(k).defectCategory ==
                                      "quality") {
                                    totalQualitycount +=
                                        defectList.elementAt(k).injuryCnt! -
                                            defectList.elementAt(k).damageCnt!;
                                    totalQualityInjury +=
                                        defectList.elementAt(k).injuryCnt! -
                                            defectList.elementAt(k).damageCnt!;
                                  } else if (defectList
                                          .elementAt(k)
                                          .defectCategory ==
                                      "condition") {
                                    totalConditionCount +=
                                        defectList.elementAt(k).injuryCnt! -
                                            defectList.elementAt(k).damageCnt!;
                                    totalConditionInjury +=
                                        defectList.elementAt(k).injuryCnt! -
                                            defectList.elementAt(k).damageCnt!;
                                  }

                                  if (result != "RJ") {
                                    double vsdpercent = totalQualityInjury *
                                        100 /
                                        totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection!.inspectionId!,
                                          result,
                                          "$defectNameResult - Quality (Injury)  % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }
                                  double vsdpercent7 = totalQualityInjury *
                                      100 /
                                      totalSampleSize;
                                  debugPrint("$vsdpercent7");
                                  if (result != "RJ") {
                                    double vsdpercent = totalConditionInjury *
                                        100 /
                                        totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection!.inspectionId!,
                                          result,
                                          "$defectNameResult - Condition (Injury)  % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }

                                  double vsdpercent8 = totalConditionInjury *
                                      100 /
                                      totalSampleSize;
                                  debugPrint("$vsdpercent8");
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Decay") {
                              if (defectList.elementAt(k).decayCnt! > 0) {
                                totalcount += defectList.elementAt(k).decayCnt!;
                                iscalculated = true;
                                if (defectList.elementAt(k).defectCategory ==
                                    "quality") {
                                  totalQualitycount +=
                                      defectList.elementAt(k).decayCnt!;
                                  totalQualityDecay +=
                                      defectList.elementAt(k).decayCnt!;
                                } else if (defectList
                                        .elementAt(k)
                                        .defectCategory ==
                                    "condition") {
                                  totalConditionCount +=
                                      defectList.elementAt(k).decayCnt!;
                                  totalConditionDecay +=
                                      defectList.elementAt(k).decayCnt!;
                                }

                                if (result != "RJ") {
                                  double vsdpercent =
                                      totalQualityDecay * 100 / totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        result,
                                        "$defectNameResult - Quality (Decay)  % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else if ((vsdpercent >
                                          specTolerancePercentage / 2) &&
                                      (vsdpercent <= specTolerancePercentage)) {
                                    result = "A-";
                                  }
                                }
                                double vsdpercent9 =
                                    totalQualityDecay * 100 / totalSampleSize;
                                debugPrint("$vsdpercent9");
                                if (result != "RJ") {
                                  double vsdpercent = totalConditionDecay *
                                      100 /
                                      totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        result,
                                        "$defectNameResult - Condition (Decay)  % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else if ((vsdpercent >
                                          specTolerancePercentage / 2) &&
                                      (vsdpercent <= specTolerancePercentage)) {
                                    result = "A-";
                                  }
                                }
                                double vsdpercent10 =
                                    totalConditionDecay * 100 / totalSampleSize;
                                debugPrint("$vsdpercent10");
                              }
                            }
                            if (tempSeverityDefectName == "") {
                              if (defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt! >
                                  0) {
                                totalcount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                              }
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  0) {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  totalcount += (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).damageCnt! > 0) {
                                if (defectList.elementAt(k).damageCnt! >
                                    defectList.elementAt(k).seriousDamageCnt!) {
                                  totalcount +=
                                      (defectList.elementAt(k).damageCnt! -
                                          defectList
                                              .elementAt(k)
                                              .seriousDamageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).injuryCnt! > 0) {
                                if (defectList.elementAt(k).injuryCnt! >
                                    defectList.elementAt(k).damageCnt!) {
                                  totalcount +=
                                      (defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).decayCnt! > 0) {
                                totalcount += defectList.elementAt(k).decayCnt!;
                              }
                              iscalculated = true;

                              if (result != "RJ") {
                                double qualpercentage =
                                    (totalcount * 100) / totalSampleSize;
                                if (qualpercentage > specTolerancePercentage) {
                                  result = "RJ";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "$defectNameResult Total Defects % exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                } else if ((qualpercentage >
                                        specTolerancePercentage / 2) &&
                                    (qualpercentage <=
                                        specTolerancePercentage)) {
                                  result = "A-";
                                }
                              }

                              double qualpercentage =
                                  (totalcount * 100) / totalSampleSize;
                              debugPrint("$qualpercentage");
                            }
                          } else if (defectName == "Total Quality (%)" &&
                              (defectList.elementAt(k).defectCategory ==
                                  "quality")) {
                            if (tempSeverityDefectName ==
                                "Very Serious Damage") {
                              if (defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt! >
                                  0) {
                                totalQualitycount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                totalQualityVerySeriousDamage += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                if (result != "RJ") {
                                  double vsdpercent =
                                      totalQualityVerySeriousDamage *
                                          100 /
                                          totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        result,
                                        "Total Quality - (VSD) " +
                                            " % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else if ((vsdpercent >
                                          specTolerancePercentage / 2) &&
                                      (vsdpercent <= specTolerancePercentage)) {
                                    result = "A-";
                                  }
                                }

                                double vsdpercent11 =
                                    totalQualityVerySeriousDamage *
                                        100 /
                                        totalSampleSize;
                                if (vsdpercent11 > specTolerancePercentage) {
                                  if (rejectReason != "") {
                                    rejectReason += ", ";
                                  }

                                  rejectReasonArray.add(
                                      "Total Quality - (VSD) " +
                                          " % exceeds tolerance");

                                  rejectReason += "Total Quality - (VSD) " +
                                      " % exceeds tolerance";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      "RJ",
                                      rejectReason,
                                      defectList.elementAt(k).comment ?? "");
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Serious Damage") {
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  0) {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  totalQualitycount += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!;
                                  totalQualitySeriousDamage += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!;

                                  if (result != "RJ") {
                                    double vsdpercent =
                                        totalQualitySeriousDamage *
                                            100 /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection!.inspectionId!,
                                              result,
                                              "Total Quality - (SD) " +
                                                  " % exceeds tolerance",
                                              defectList.elementAt(k).comment ??
                                                  "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }
                                  double vsdpercent12 =
                                      totalQualitySeriousDamage *
                                          100 /
                                          totalSampleSize;
                                  if (vsdpercent12 > specTolerancePercentage) {
                                    if (rejectReason != "") {
                                      rejectReason += ", ";
                                    }
                                    rejectReasonArray.add(
                                        "Total Quality - (SD) " +
                                            " % exceeds tolerance");

                                    rejectReason += "Total Quality - (SD) " +
                                        " % exceeds tolerance";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        "RJ",
                                        rejectReason,
                                        defectList.elementAt(k).comment ?? "");
                                  }
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Damage") {
                              if (defectList.elementAt(k).damageCnt! > 0) {
                                if (defectList.elementAt(k).damageCnt! >
                                    defectList.elementAt(k).seriousDamageCnt!) {
                                  totalQualitycount += defectList
                                          .elementAt(k)
                                          .damageCnt! -
                                      defectList.elementAt(k).seriousDamageCnt!;
                                  totalQualityDamage += defectList
                                          .elementAt(k)
                                          .damageCnt! -
                                      defectList.elementAt(k).seriousDamageCnt!;

                                  if (result != "RJ") {
                                    double vsdpercent = totalQualityDamage *
                                        100 /
                                        totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection!.inspectionId!,
                                              result,
                                              "Total Quality - (Damage) " +
                                                  " % exceeds tolerance",
                                              defectList.elementAt(k).comment ??
                                                  "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }

                                  double vsdpercent13 = totalQualityDamage *
                                      100 /
                                      totalSampleSize;
                                  if (vsdpercent13 > specTolerancePercentage) {
                                    if (rejectReason != "") {
                                      rejectReason += ", ";
                                    }
                                    rejectReasonArray.add(
                                        "Total Quality - (Damage) " +
                                            " % exceeds tolerance");

                                    rejectReason +=
                                        "Total Quality - (Damage) " +
                                            " % exceeds tolerance";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        "RJ",
                                        rejectReason,
                                        defectList.elementAt(k).comment ?? "");
                                  }
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Injury") {
                              if (defectList.elementAt(k).injuryCnt! > 0) {
                                if (defectList.elementAt(k).injuryCnt! >
                                    defectList.elementAt(k).damageCnt!) {
                                  totalQualitycount +=
                                      defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                  totalQualityInjury +=
                                      defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                  if (result != "RJ") {
                                    double vsdpercent = totalQualityInjury *
                                        100 /
                                        totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection!.inspectionId!,
                                              result,
                                              "Total Quality - (Injury) " +
                                                  " % exceeds tolerance",
                                              defectList.elementAt(k).comment ??
                                                  "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }

                                  double vsdpercent14 = totalQualityInjury *
                                      100 /
                                      totalSampleSize;
                                  if (vsdpercent14 > specTolerancePercentage) {
                                    if (rejectReason != "") {
                                      rejectReason += ", ";
                                    }
                                    rejectReasonArray.add(
                                        "Total Quality - (Injury) " +
                                            " % exceeds tolerance");

                                    rejectReason +=
                                        "Total Quality - (Injury) " +
                                            " % exceeds tolerance";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        "RJ",
                                        rejectReason,
                                        defectList.elementAt(k).comment ?? "");
                                  }
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Decay") {
                              if (defectList.elementAt(k).decayCnt! > 0) {
                                totalQualitycount +=
                                    defectList.elementAt(k).decayCnt!;
                                totalQualityDecay +=
                                    defectList.elementAt(k).decayCnt!;

                                if (result != "RJ") {
                                  double vsdpercent =
                                      totalQualityDecay * 100 / totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        result,
                                        "Total Quality - (Decay) " +
                                            " % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else if ((vsdpercent >
                                          specTolerancePercentage / 2) &&
                                      (vsdpercent <= specTolerancePercentage)) {
                                    result = "A-";
                                  }
                                }
                                double vsdpercent15 =
                                    totalQualityDecay * 100 / totalSampleSize;
                                if (vsdpercent15 > specTolerancePercentage) {
                                  if (rejectReason != "") {
                                    rejectReason += ", ";
                                  }
                                  rejectReasonArray.add(
                                      "Total Quality - (Decay) " +
                                          " % exceeds tolerance");

                                  rejectReason += "Total Quality - (Decay) " +
                                      " % exceeds tolerance";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      "RJ",
                                      rejectReason,
                                      defectList.elementAt(k).comment ?? "");
                                }
                              }
                            }
                            if (tempSeverityDefectName == "") {
                              if (defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt! >
                                  0) {
                                totalQualitycount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                              }
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  0) {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  totalQualitycount += (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).damageCnt! > 0) {
                                if (defectList.elementAt(k).damageCnt! >
                                    defectList.elementAt(k).seriousDamageCnt!) {
                                  totalQualitycount += defectList
                                          .elementAt(k)
                                          .damageCnt! -
                                      defectList.elementAt(k).seriousDamageCnt!;
                                }
                              }
                              if (defectList.elementAt(k).injuryCnt! > 0) {
                                if (defectList.elementAt(k).injuryCnt! >
                                    defectList.elementAt(k).damageCnt!) {
                                  totalQualitycount +=
                                      defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                }
                              }
                              if (defectList.elementAt(k).decayCnt! > 0) {
                                totalQualitycount +=
                                    defectList.elementAt(k).decayCnt!;
                              }
                              if (result != "RJ") {
                                double totalqualitypercent =
                                    totalQualitycount * 100 / totalSampleSize;
                                if (totalqualitypercent >
                                    specTolerancePercentage) {
                                  result = "RJ";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "Total Quality" + "% exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                } else if ((totalqualitypercent >
                                        specTolerancePercentage / 2) &&
                                    (totalqualitypercent <=
                                        specTolerancePercentage)) {
                                  result = "A-";
                                }
                              }
                              double totalqualitypercent1 =
                                  totalQualitycount * 100 / totalSampleSize;
                              if (totalqualitypercent1 >
                                  specTolerancePercentage) {
                                if (rejectReason != "") {
                                  rejectReason += ", ";
                                }
                                rejectReasonArray.add(
                                    "Total Quality" + "% exceeds tolerance");

                                rejectReason +=
                                    "Total Quality" + "% exceeds tolerance";
                                await dao.createOrUpdateResultReasonDetails(
                                    inspection!.inspectionId!,
                                    result,
                                    rejectReason,
                                    defectList.elementAt(k).comment ?? "");
                              }
                            }
                            iscalculated = true;
                          } else if (defectList.elementAt(k).defectCategory ==
                                  "condition" &&
                              defectName == "Total Condition (%)") {
                            if (tempSeverityDefectName ==
                                "Very Serious Damage") {
                              if (defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt! >
                                  0) {
                                totalConditionCount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                totalConditionVerySeriousDamage += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                if (result != "RJ") {
                                  double vsdpercent =
                                      totalConditionVerySeriousDamage *
                                          100 /
                                          totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        result,
                                        "Total Condition - (VSD) " +
                                            " % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else if ((vsdpercent >
                                          specTolerancePercentage / 2) &&
                                      (vsdpercent <= specTolerancePercentage)) {
                                    result = "A-";
                                  }
                                }
                                double vsdpercentT =
                                    totalConditionVerySeriousDamage *
                                        100 /
                                        totalSampleSize;
                                if (vsdpercentT > specTolerancePercentage) {
                                  if (rejectReason != "") {
                                    rejectReason += ", ";
                                  }
                                  rejectReasonArray.add(
                                      "Total Condition - (VSD) " +
                                          "% exceeds tolerance");

                                  rejectReason += "Total Condition - (VSD) " +
                                      " % exceeds tolerance";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      "RJ",
                                      rejectReason,
                                      defectList.elementAt(k).comment ?? "");
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Serious Damage") {
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  0) {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  totalConditionCount += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!;
                                  totalConditionSeriousDamage += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!;

                                  if (result != "RJ") {
                                    double vsdpercent =
                                        totalConditionSeriousDamage *
                                            100 /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection!.inspectionId!,
                                              result,
                                              "Total Condition - (SD) " +
                                                  " % exceeds tolerance",
                                              defectList.elementAt(k).comment ??
                                                  "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }
                                  double vsdpercentTT =
                                      totalConditionSeriousDamage *
                                          100 /
                                          totalSampleSize;
                                  if (vsdpercentTT > specTolerancePercentage) {
                                    if (rejectReason != "") {
                                      rejectReason += ", ";
                                    }
                                    rejectReasonArray.add(
                                        "Total Condition - (SD) " +
                                            "% exceeds tolerance");

                                    rejectReason += "Total Condition - (SD) " +
                                        " % exceeds tolerance";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        "RJ",
                                        rejectReason,
                                        defectList.elementAt(k).comment ?? "");
                                  }
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Damage") {
                              if (defectList.elementAt(k).damageCnt! > 0) {
                                if (defectList.elementAt(k).damageCnt! >
                                    defectList.elementAt(k).seriousDamageCnt!) {
                                  totalConditionCount += defectList
                                          .elementAt(k)
                                          .damageCnt! -
                                      defectList.elementAt(k).seriousDamageCnt!;
                                  totalConditionDamage += defectList
                                          .elementAt(k)
                                          .damageCnt! -
                                      defectList.elementAt(k).seriousDamageCnt!;
                                  if (result != "RJ") {
                                    double vsdpercent = totalConditionDamage *
                                        100 /
                                        totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection!.inspectionId!,
                                              result,
                                              "Total Condition - (Damage) " +
                                                  " % exceeds tolerance",
                                              defectList.elementAt(k).comment ??
                                                  "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }
                                  double vsdpercentTB = totalConditionDamage *
                                      100 /
                                      totalSampleSize;
                                  if (vsdpercentTB > specTolerancePercentage) {
                                    if (rejectReason != "") {
                                      rejectReason += ", ";
                                    }
                                    rejectReasonArray.add(
                                        "Total Condition - (Damage) " +
                                            "% exceeds tolerance");

                                    rejectReason +=
                                        "Total Condition - (Damage) " +
                                            " % exceeds tolerance";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        "RJ",
                                        rejectReason,
                                        defectList.elementAt(k).comment ?? "");
                                  }
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Injury") {
                              if (defectList.elementAt(k).injuryCnt! > 0) {
                                if (defectList.elementAt(k).injuryCnt! >
                                    defectList.elementAt(k).damageCnt!) {
                                  totalConditionCount +=
                                      defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                  totalConditionInjury +=
                                      defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;

                                  if (result != "RJ") {
                                    double vsdpercent = totalConditionInjury *
                                        100 /
                                        totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection!.inspectionId!,
                                              result,
                                              "Total Condition - (Injury) " +
                                                  " % exceeds tolerance",
                                              defectList.elementAt(k).comment ??
                                                  "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }
                                  double vsdpercentTA = totalConditionInjury *
                                      100 /
                                      totalSampleSize;
                                  if (vsdpercentTA > specTolerancePercentage) {
                                    if (rejectReason != "") {
                                      rejectReason += ", ";
                                    }
                                    rejectReasonArray.add(
                                        "Total Condition - (Injury) " +
                                            "% exceeds tolerance");

                                    rejectReason +=
                                        "Total Condition - (Injury) " +
                                            " % exceeds tolerance";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        "RJ",
                                        rejectReason,
                                        defectList.elementAt(k).comment ?? "");
                                  }
                                }
                              }
                            }
                            if (tempSeverityDefectName == "Decay") {
                              if (defectList.elementAt(k).decayCnt! > 0) {
                                totalConditionCount +=
                                    defectList.elementAt(k).decayCnt!;
                                totalConditionDecay +=
                                    defectList.elementAt(k).decayCnt!;
                                if (result != "RJ") {
                                  double vsdpercent = totalConditionDecay *
                                      100 /
                                      totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection!.inspectionId!,
                                        result,
                                        "Total Condition - (Decay) " +
                                            " % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else if ((vsdpercent >
                                          specTolerancePercentage / 2) &&
                                      (vsdpercent <= specTolerancePercentage)) {
                                    result = "A-";
                                  }
                                }
                                double vsdpercentAB =
                                    totalConditionDecay * 100 / totalSampleSize;
                                if (vsdpercentAB > specTolerancePercentage) {
                                  if (rejectReason != "") {
                                    rejectReason += ", ";
                                  }
                                  rejectReasonArray.add(
                                      "Total Condition - (Decay) " +
                                          "% exceeds tolerance");

                                  rejectReason += "Total Condition - (Decay) " +
                                      " % exceeds tolerance";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      "RJ",
                                      rejectReason,
                                      defectList.elementAt(k).comment ?? "");
                                }
                              }
                              iscalculated = true;
                            }
                            if (tempSeverityDefectName == "") {
                              if (defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt! >
                                  0) {
                                totalConditionCount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                              }
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  0) {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  totalConditionCount += (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).damageCnt! > 0) {
                                if (defectList.elementAt(k).damageCnt! >
                                    defectList.elementAt(k).seriousDamageCnt!) {
                                  totalConditionCount += defectList
                                          .elementAt(k)
                                          .damageCnt! -
                                      defectList.elementAt(k).seriousDamageCnt!;
                                }
                              }
                              if (defectList.elementAt(k).injuryCnt! > 0) {
                                if (defectList.elementAt(k).injuryCnt! >
                                    defectList.elementAt(k).damageCnt!) {
                                  totalConditionCount +=
                                      defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                }
                              }
                              if (defectList.elementAt(k).decayCnt! > 0) {
                                totalConditionCount +=
                                    defectList.elementAt(k).decayCnt!;
                              }
                              if (result != "RJ") {
                                double vsdpercent =
                                    totalConditionCount * 100 / totalSampleSize;
                                if (vsdpercent > specTolerancePercentage) {
                                  result = "RJ";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "Total Condition " +
                                          "% exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                } else if ((vsdpercent >
                                        specTolerancePercentage / 2) &&
                                    (vsdpercent <= specTolerancePercentage)) {
                                  result = "A-";
                                }
                              }

                              double vsdpercentAC =
                                  totalConditionCount * 100 / totalSampleSize;
                              if (vsdpercentAC > specTolerancePercentage) {
                                if (rejectReason != "") {
                                  rejectReason += ", ";
                                }
                                rejectReasonArray.add(
                                    "Total Condition " + "% exceeds tolerance");

                                rejectReason +=
                                    "Total Condition " + "% exceeds tolerance";
                                await dao.createOrUpdateResultReasonDetails(
                                    inspection!.inspectionId!,
                                    "RJ",
                                    rejectReason,
                                    defectList.elementAt(k).comment ?? "");
                              }

                              iscalculated = true;
                            }
                          }
                        } else if (defectList.elementAt(k).defectCategory ==
                            "size") {
                          if (defectList.elementAt(k).defectId == defectID) {
                            sizeDefectName =
                                defectList.elementAt(k).spinnerSelection;

                            int totalSizecount = 0;
                            if (tempSeverityDefectName ==
                                "Very Serious Damage") {
                              totalSizecount +=
                                  defectList.elementAt(k).verySeriousDamageCnt!;
                              totalSize +=
                                  defectList.elementAt(k).verySeriousDamageCnt!;
                            }
                            if (tempSeverityDefectName == "Serious Damage") {
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt!) {
                                totalSizecount +=
                                    defectList.elementAt(k).seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                                totalSize +=
                                    defectList.elementAt(k).seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                              }
                            }
                            if (tempSeverityDefectName == "Damage") {
                              if (defectList.elementAt(k).damageCnt! >
                                  defectList.elementAt(k).seriousDamageCnt!) {
                                totalSizecount += defectList
                                        .elementAt(k)
                                        .damageCnt! -
                                    defectList.elementAt(k).seriousDamageCnt!;
                                totalSize += defectList
                                        .elementAt(k)
                                        .damageCnt! -
                                    defectList.elementAt(k).seriousDamageCnt!;
                              }
                            }
                            if (tempSeverityDefectName == "Injury") {
                              if (defectList.elementAt(k).injuryCnt! >
                                  defectList.elementAt(k).damageCnt!) {
                                totalSizecount +=
                                    defectList.elementAt(k).injuryCnt! -
                                        defectList.elementAt(k).damageCnt!;
                                totalSize +=
                                    defectList.elementAt(k).injuryCnt! -
                                        defectList.elementAt(k).damageCnt!;
                              }
                            }
                            if (tempSeverityDefectName == "Decay") {
                              totalSizecount +=
                                  defectList.elementAt(k).decayCnt!;
                              totalSize += defectList.elementAt(k).decayCnt!;
                            }

                            if (tempSeverityDefectName == "") {
                              if (defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt! >
                                  0) {
                                totalSizecount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                totalSize += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                              }
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  0) {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  totalSizecount += (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!);
                                  totalSize += (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).damageCnt! > 0) {
                                if (defectList.elementAt(k).damageCnt! >
                                    defectList.elementAt(k).seriousDamageCnt!) {
                                  totalSizecount +=
                                      (defectList.elementAt(k).damageCnt! -
                                          defectList
                                              .elementAt(k)
                                              .seriousDamageCnt!);
                                  totalSize +=
                                      (defectList.elementAt(k).damageCnt! -
                                          defectList
                                              .elementAt(k)
                                              .seriousDamageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).injuryCnt! > 0) {
                                if (defectList.elementAt(k).injuryCnt! >
                                    defectList.elementAt(k).damageCnt!) {
                                  totalSizecount +=
                                      (defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!);
                                  totalSize +=
                                      (defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).decayCnt! > 0) {
                                totalSizecount +=
                                    defectList.elementAt(k).decayCnt!;
                                totalSize += defectList.elementAt(k).decayCnt!;
                              }
                            }
                            iscalculated = true;
                            if (result != "RJ") {
                              double sizepercent =
                                  (totalSizecount * 100) / totalSampleSize;

                              if (sizepercent > specTolerancePercentage) {
                                result = "RJ";
                                if (sizeDefectName != null &&
                                    sizeDefectName != "") {
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "$sizeDefectName : Size % exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                } else {
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "Size % exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                }
                              } else if ((sizepercent >
                                      specTolerancePercentage / 2) &&
                                  (sizepercent <= specTolerancePercentage)) {
                                result = "A-";
                              }
                            }

                            double sizepercent1 =
                                (totalSizecount * 100) / totalSampleSize;
                            if (sizepercent1 > specTolerancePercentage) {
                              if (sizeDefectName != null &&
                                  sizeDefectName != "") {
                                if (rejectReason != "") {
                                  rejectReason += ", ";
                                }
                                // rejectReasonArray.add(sizeDefectName + " : Size % exceeds tolerance");

                                rejectReason +=
                                    "$sizeDefectName : Size % exceeds tolerance";
                                await dao.createOrUpdateResultReasonDetails(
                                    inspection!.inspectionId!,
                                    "RJ",
                                    rejectReason,
                                    defectList.elementAt(k).comment ?? "");
                              } else {
                                if (rejectReason != "") {
                                  rejectReason += ", ";
                                }

                                rejectReasonArray
                                    .add("Size % exceeds tolerance");

                                rejectReason += "Size % exceeds tolerance";
                                await dao.createOrUpdateResultReasonDetails(
                                    inspection!.inspectionId!,
                                    "RJ",
                                    rejectReason,
                                    defectList.elementAt(k).comment ?? "");
                              }
                            }
                          }
                        } else if (defectList.elementAt(k).defectCategory ==
                            "color") {
                          if (defectList.elementAt(k).defectId == defectID) {
                            colorDefectName =
                                defectList.elementAt(k).spinnerSelection;

                            int colorcount = 0;

                            if (tempSeverityDefectName ==
                                "Very Serious Damage") {
                              colorcount +=
                                  defectList.elementAt(k).verySeriousDamageCnt!;
                              totalColor +=
                                  defectList.elementAt(k).verySeriousDamageCnt!;
                            }
                            if (tempSeverityDefectName == "Serious Damage") {
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt!) {
                                colorcount +=
                                    defectList.elementAt(k).seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                                totalColor +=
                                    defectList.elementAt(k).seriousDamageCnt! -
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                              }
                            }
                            if (tempSeverityDefectName == "Damage") {
                              if (defectList.elementAt(k).damageCnt! >
                                  defectList.elementAt(k).seriousDamageCnt!) {
                                colorcount += defectList
                                        .elementAt(k)
                                        .damageCnt! -
                                    defectList.elementAt(k).seriousDamageCnt!;
                                totalColor += defectList
                                        .elementAt(k)
                                        .damageCnt! -
                                    defectList.elementAt(k).seriousDamageCnt!;
                              }
                            }
                            if (tempSeverityDefectName == "Injury") {
                              if (defectList.elementAt(k).injuryCnt! >
                                  defectList.elementAt(k).damageCnt!) {
                                colorcount +=
                                    defectList.elementAt(k).injuryCnt! -
                                        defectList.elementAt(k).damageCnt!;
                                totalColor +=
                                    defectList.elementAt(k).injuryCnt! -
                                        defectList.elementAt(k).damageCnt!;
                              }
                            }
                            if (tempSeverityDefectName == "Decay") {
                              colorcount += defectList.elementAt(k).decayCnt!;
                              totalColor += defectList.elementAt(k).decayCnt!;
                            }
                            if (tempSeverityDefectName == "") {
                              if (defectList
                                      .elementAt(k)
                                      .verySeriousDamageCnt! >
                                  0) {
                                colorcount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                totalColor += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                              }
                              if (defectList.elementAt(k).seriousDamageCnt! >
                                  0) {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  colorcount += (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!);
                                  totalColor += (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).damageCnt! > 0) {
                                if (defectList.elementAt(k).damageCnt! >
                                    defectList.elementAt(k).seriousDamageCnt!) {
                                  colorcount +=
                                      (defectList.elementAt(k).damageCnt! -
                                          defectList
                                              .elementAt(k)
                                              .seriousDamageCnt!);
                                  totalColor +=
                                      (defectList.elementAt(k).damageCnt! -
                                          defectList
                                              .elementAt(k)
                                              .seriousDamageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).injuryCnt! > 0) {
                                if (defectList.elementAt(k).injuryCnt! >
                                    defectList.elementAt(k).damageCnt!) {
                                  colorcount +=
                                      (defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!);
                                  totalColor +=
                                      (defectList.elementAt(k).injuryCnt! -
                                          defectList.elementAt(k).damageCnt!);
                                }
                              }
                              if (defectList.elementAt(k).decayCnt! > 0) {
                                colorcount += defectList.elementAt(k).decayCnt!;
                                totalColor += defectList.elementAt(k).decayCnt!;
                              }
                            }
                            iscalculated = true;
                            if (result != "RJ") {
                              double colorpercent =
                                  (colorcount * 100) / totalSampleSize;

                              if (colorpercent > specTolerancePercentage) {
                                result = "RJ";

                                if (colorDefectName != null &&
                                    colorDefectName != "") {
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "$colorDefectName : Color % exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                } else {
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection!.inspectionId!,
                                      result,
                                      "Color % exceeds tolerance",
                                      defectList.elementAt(k).comment ?? "");
                                }
                              } else if ((colorpercent >
                                      specTolerancePercentage / 2) &&
                                  (colorpercent <= specTolerancePercentage)) {
                                result = "A-";
                              }
                            }
                            double colorpercent1 =
                                (colorcount * 100) / totalSampleSize;
                            if (colorpercent1 > specTolerancePercentage) {
                              if (colorDefectName != null &&
                                  colorDefectName != "") {
                                if (rejectReason != "") {
                                  rejectReason += ", ";
                                }
                                //rejectReasonArray.add(colorDefectName + " : Color % exceeds tolerance");

                                rejectReason +=
                                    "$colorDefectName : Color % exceeds tolerance";
                                await dao.createOrUpdateResultReasonDetails(
                                    inspection!.inspectionId!,
                                    "RJ",
                                    rejectReason,
                                    defectList.elementAt(k).comment ?? "");
                              } else {
                                if (rejectReason != "") {
                                  rejectReason += ", ";
                                }
                                //rejectReasonArray.add("Color % exceeds tolerance");

                                rejectReason += "Color % exceeds tolerance";
                                await dao.createOrUpdateResultReasonDetails(
                                    inspection!.inspectionId!,
                                    "RJ",
                                    rejectReason,
                                    defectList.elementAt(k).comment ?? "");
                              }
                            }
                          }
                        }
                      }
                    }

                    for (int k = 0; k < defectList.length; k++) {
                      if (defectList.elementAt(k).spinnerSelection != null) {
                        defectNameReasonArray
                            .add(defectList.elementAt(k).spinnerSelection!);
                      }
                    }
                  }
                }
                if (result != "RJ" && iscalculated) {
                  if (defectID != null &&
                      totalQualitycount > 0 &&
                      defectID == totalQualityDefectId &&
                      tempSeverityDefectName == "") {
                    double qualpercentage =
                        (totalQualitycount * 100) / totalSampleSize;
                    if (qualpercentage > specTolerancePercentage) {
                      result = "RJ";
                      if (rejectReason != "") {
                        rejectReason += ", ";
                      }
                      rejectReasonArray
                          .add("Total Quality Defects % exceeds tolerance");

                      rejectReason +=
                          "Total Quality Defects % exceeds tolerance";
                      await dao.createOrUpdateResultReasonDetails(
                          inspection!.inspectionId!, result, rejectReason, "");
                    } else if ((qualpercentage > specTolerancePercentage / 2) &&
                        (qualpercentage <= specTolerancePercentage)) {
                      result = "A-";
                    }
                  } else if (defectID != null &&
                      totalConditionCount > 0 &&
                      defectID == totalConditionDefectId &&
                      tempSeverityDefectName == "") {
                    double condPercentage =
                        (totalConditionCount * 100) / totalSampleSize;
                    if (condPercentage > specTolerancePercentage) {
                      result = "RJ";
                      if (rejectReason != "") {
                        rejectReason += ", ";
                      }
                      rejectReasonArray
                          .add("Total Condition Defects % exceeds tolerance");

                      rejectReason +=
                          "Total Condition Defects % exceeds tolerance";
                      await dao.createOrUpdateResultReasonDetails(
                          inspection!.inspectionId!, result, rejectReason, "");
                      break;
                    } else if ((condPercentage > specTolerancePercentage / 2) &&
                        (condPercentage <= specTolerancePercentage)) {
                      result = "A-";
                      setResult('A-');
                    }
                  } else if (defectID != null &&
                      totalSize > 0 &&
                      tempSeverityDefectName == "" &&
                      result != "RJ") {
                    double sizePer = (totalSize * 100) / totalSampleSize;
                    if (sizePer > specTolerancePercentage) {
                      result = "RJ";
                      if (rejectReason != "") {
                        rejectReason += ", ";
                      }
                      rejectReasonArray.add("Total Size % exceeds tolerance");
                      rejectReason += "Total Size % exceeds tolerance";
                      dao.createOrUpdateResultReasonDetails(
                          inspection!.inspectionId!, result, rejectReason, "");
                      break;
                    } else if (sizePer > specTolerancePercentage / 2 &&
                        sizePer <= specTolerancePercentage) {
                      result = "A-";
                    }
                  } else if (defectID != null &&
                      totalColor > 0 &&
                      tempSeverityDefectName == "" &&
                      result != "RJ") {
                    double sizePer = (totalColor * 100) / totalSampleSize;
                    if (sizePer > specTolerancePercentage) {
                      result = "RJ";
                      if (rejectReason != "") {
                        rejectReason += ", ";
                      }
                      rejectReasonArray.add("Total Color % exceeds tolerance");
                      rejectReason += "Total Color % exceeds tolerance";
                      dao.createOrUpdateResultReasonDetails(
                          inspection!.inspectionId!, result, rejectReason, "");
                      break;
                    } else if (sizePer > specTolerancePercentage / 2 &&
                        sizePer <= specTolerancePercentage) {
                      result = "A-";
                    }
                  }

                  if (result != "RJ") {
                    if (defectID != null &&
                        totalQualityDefectId != 0 &&
                        defectID == totalQualityDefectId) {
                      double qualpercentage = 0;
                      if (tempSeverityDefectName == "Very Serious Damage") {
                        qualpercentage = (totalQualityVerySeriousDamage * 100) /
                            totalSampleSize;
                      } else if (tempSeverityDefectName == "Serious Damage") {
                        qualpercentage =
                            (totalQualitySeriousDamage * 100) / totalSampleSize;
                      } else if (tempSeverityDefectName == "Damage") {
                        qualpercentage =
                            (totalQualityDamage * 100) / totalSampleSize;
                      } else if (tempSeverityDefectName == "Injury") {
                        qualpercentage =
                            (totalQualityInjury * 100) / totalSampleSize;
                      } else if (tempSeverityDefectName == "Decay") {
                        qualpercentage =
                            (totalQualityDecay * 100) / totalSampleSize;
                      }

                      if (qualpercentage > specTolerancePercentage) {
                        result = "RJ";
                        if (rejectReason != "") {
                          rejectReason += ", ";
                        }
                        rejectReasonArray
                            .add("Total Quality Defects % exceeds tolerance");

                        rejectReason +=
                            " Total Quality Defects % exceeds tolerance";

                        await dao.createOrUpdateResultReasonDetails(
                            inspection!.inspectionId!,
                            result,
                            rejectReason,
                            "");
                        break;
                      } else if ((qualpercentage >
                              specTolerancePercentage / 2) &&
                          (qualpercentage <= specTolerancePercentage)) {
                        result = "A-";
                      }
                    } else if (defectID != null &&
                        totalConditionDefectId != 0 &&
                        defectID == totalConditionDefectId) {
                      double condpercentage = 0;
                      if (tempSeverityDefectName == "Very Serious Damage") {
                        condpercentage =
                            (totalConditionVerySeriousDamage * 100) /
                                totalSampleSize;
                      } else if (tempSeverityDefectName == "Serious Damage") {
                        condpercentage = (totalConditionSeriousDamage * 100) /
                            totalSampleSize;
                      } else if (tempSeverityDefectName == "Damage") {
                        condpercentage =
                            (totalConditionDamage * 100) / totalSampleSize;
                      } else if (tempSeverityDefectName == "Injury") {
                        condpercentage =
                            (totalConditionInjury * 100) / totalSampleSize;
                      } else if (tempSeverityDefectName == "Decay") {
                        condpercentage =
                            (totalConditionDecay * 100) / totalSampleSize;
                      }

                      if (condpercentage > specTolerancePercentage) {
                        result = "RJ";
                        if (rejectReason != "") {
                          rejectReason += ", ";
                        }
                        rejectReasonArray
                            .add("Total Condition Defects % exceeds tolerance");

                        rejectReason +=
                            " Total Condition Defects % exceeds tolerance";
                        await dao.createOrUpdateResultReasonDetails(
                            inspection!.inspectionId!,
                            result,
                            rejectReason,
                            "");
                        break;
                      } else if ((condpercentage >
                              specTolerancePercentage / 2) &&
                          (condpercentage <= specTolerancePercentage)) {
                        result = "A-";
                      }
                    }
                  }

                  double calpercentage = (totalcount * 100) / totalSampleSize;
                  if (result != "RJ" && totalcount > 0) {
                    if (calpercentage > specTolerancePercentage) {
                      List<String> exceptions = [
                        "Manager Approval",
                        "Approval",
                        "Manager Rejection"
                      ];
                      debugPrint("$exceptions");
                      result = "RJ";
                      inspectionResultText = 'Reject';
                      inspectionTextColor = AppColors.red;
                      setResult('RJ');
                      approvalLayout.value = true;

                      if (rejectReason != "") {
                        rejectReason += ", ";
                      }
                      rejectReasonArray
                          .add("Defects Severity % exceeds tolerance");

                      rejectReason += "Defects Severity % exceeds tolerance";
                      await dao.createOrUpdateResultReasonDetails(
                          inspection!.inspectionId!, result, rejectReason, "");
                    } else if ((calpercentage > specTolerancePercentage / 2) &&
                        (calpercentage <= specTolerancePercentage)) {
                      result = "A-";
                      inspectionResultText = 'Accept';
                      inspectionTextColor = AppColors.primary;
                      approvalLayout.value = false;
                      setResult('A-');
                    }

                    if (result != "RJ" &&
                        result != "A-" &&
                        (calpercentage >= 0 &&
                            calpercentage < (specTolerancePercentage / 2))) {
                      result = "AC";
                      inspectionResultText = 'Accept';
                      inspectionTextColor = AppColors.primary;
                      approvalLayout.value = false;
                      setResult('AC');
                    }
                  }
                } else if (!iscalculated && result == "") {
                  result = "AC";
                  inspectionResultText = 'Accept';
                  inspectionTextColor = AppColors.primary;
                  setResult('AC');
                }
              }
            }

            // if (result != "RJ") {
            //   if (_appStorage.specificationAnalyticalList != null) {
            //     for (SpecificationAnalytical item
            //         in _appStorage.specificationAnalyticalList ?? []) {
            //       SpecificationAnalyticalRequest? dbobj;
            //
            //       dbobj = await dao.findSpecAnalyticalObj(
            //           inspection!.inspectionId!, item.analyticalID!);
            //
            //       if (dbobj != null && dbobj.comply == "N") {
            //         if (dbobj.inspectionResult != null &&
            //             (dbobj.inspectionResult == "No" ||
            //                 dbobj.inspectionResult == "N")) {
            //         } else {
            //           List<String> exceptions = [
            //             "Manager Approval",
            //             "Approval",
            //             "Manager Rejection"
            //           ];
            //           debugPrint("$exceptions");
            //           result = "RJ";
            //           inspectionResultText = 'Reject';
            //           inspectionTextColor = AppColors.red;
            //           rejectionLayout.value = true;
            //           setResult('RJ');
            //           await dao.createOrUpdateResultReasonDetails(
            //               inspection!.inspectionId!,
            //               result,
            //               "${dbobj.analyticalName ?? ""} = N",
            //               dbobj.comment ?? "");
            //           break;
            //         }
            //       }
            //     }
            //     if (result == "") {
            //       result = "AC";
            //       inspectionResultText = 'Accept';
            //       inspectionTextColor = AppColors.primary;
            //       setResult('AC');
            //     }
            //   }
            // }

            rejectionLayout.value = true;
            isShowSaveButton.value = true;

            if (_appStorage.specificationAnalyticalList != null) {
              for (SpecificationAnalytical item
                  in _appStorage.specificationAnalyticalList!) {
                SpecificationAnalyticalRequest? dbobj =
                    await dao.findSpecAnalyticalObj(
                        inspection!.inspectionId!, item.analyticalID!);

                if (dbobj != null &&
                    (dbobj.comply == "N" || dbobj.comply == "No")) {
                  if (dbobj.inspectionResult != null &&
                      (dbobj.inspectionResult == "No" ||
                          dbobj.inspectionResult == "N")) {
                  } else {
                    if (rejectReason.isNotEmpty) {
                      rejectReason += ", ";
                    }
                    rejectReasonArray.add("${dbobj.analyticalName} = N");

                    rejectReason += "${dbobj.analyticalName} = N";
                    await dao.createOrUpdateResultReasonDetails(
                        inspection!.inspectionId!,
                        "RJ",
                        rejectReason,
                        dbobj.comment ?? '');
                    result = "RJ";
                    inspectionResultText = AppStrings.reject;
                    inspectionTextColor = AppColors.red;
                    setResult('RJ');
                    approvalLayout.value = true;
                  }
                }
              }
              if (result.isEmpty || result == "AC") {
                result = "AC";
                inspectionResultText = 'Accept';
                inspectionTextColor = AppColors.primary;
                setResult('AC');
                approvalLayout.value = false;
              } else if (result == "RJ") {
                inspectionResultText = AppStrings.reject;
                inspectionTextColor = AppColors.red;
                setResult('RJ');
                approvalLayout.value = true;
              } else if (result == "A-") {
                result = "A-";
                inspectionResultText = 'A-';
                inspectionTextColor = AppColors.primary;
                approvalLayout.value = false;
                setResult('A-');
              }
            }

            defectNameReasonArray = defectNameReasonArray.toSet().toList();

            String defectNameString = defectNameReasonArray.join(", ");

            if (defectNameString.isNotEmpty) {
              rejectReasonArray.add(defectNameString);
            }
            rejectReasonArray = rejectReasonArray.toSet().toList();

            String listString = rejectReasonArray.join("\n \u25BA ");
            listString = "\u25BA $listString";
            await dao.updateInspectionResultReason(
                inspection!.inspectionId!, listString);
            await dao.updateQuantityRejected(
                inspection!.inspectionId!, qualityControlItem!.qtyShipped!, 0);

            OverriddenResult? overriddenResult =
                await dao.getOverriddenResult(inspection!.inspectionId!);

            if ((result == "A-" || result == "AC") &&
                overriddenResult == null) {
              QualityControlItem? qualityControlItems = await dao
                  .findQualityControlDetails(inspection!.inspectionId!);
              await dao.updateQuantityRejected(inspection!.inspectionId!, 0,
                  qualityControlItems!.qtyShipped!);
            } else {
              await dao.updateQuantityRejected(inspection!.inspectionId!,
                  qualityControlItem!.qtyShipped!, 0);

              if (qualityControlItem != null) {
                if (qualityControlItem!.qtyRejected == 0) {
                  qtyRejectedController.text =
                      qualityControlItem!.qtyShipped.toString();
                } else {
                  qtyRejectedController.text =
                      qualityControlItem!.qtyRejected.toString();
                }
              } else {
                qtyRejectedController.text =
                    qualityControlItem!.qtyShipped.toString();
              }
            }

            await dao.updateInspectionResult(inspection!.inspectionId!, result);
            await dao.createOrUpdateInspectionSpecification(
                inspection!.inspectionId!,
                specificationNumber,
                specificationVersion,
                specificationName);

            await dao.updateInspectionComplete(inspection!.inspectionId!, true);
            await dao.updateItemSKUInspectionComplete(
                inspection!.inspectionId!, true);
            Utils.setInspectionUploadStatus(
                inspection!.inspectionId!, Consts.INSPECTION_UPLOAD_READY);

            update();
          }

          //
          else {
            AppAlertDialog.validateAlerts(Get.context!, AppStrings.alert,
                AppStrings.noGradeTolarenceDataFound);
          }
        }
        update();
      }

      return result;
    } catch (e) {
      debugPrint("Calculate Result Catch $e");
    }
    return result;
  }

  Future<void> setResult(String result) async {
    inspectionResult = result;

    if (serverInspectionID > -1) {
      if (result == 'A-' || result == 'AC') {
        QualityControlItem? qualityControlItems =
            await dao.findQualityControlDetails(inspection!.inspectionId!);
        await dao.updateQuantityRejected(
            inspection!.inspectionId!, 0, qualityControlItems!.qtyShipped!);
      }
      await dao.updateInspectionResult(serverInspectionID, result);
      await dao.createOrUpdateInspectionSpecification(serverInspectionID,
          specificationNumber, specificationVersion, specificationName);
    } else if (_appStorage.currentInspection != null) {
      _appStorage.currentInspection!.result = result;
      if (result == 'A-' || result == 'AC') {
        QualityControlItem? qualityControlItems =
            await dao.findQualityControlDetails(inspection!.inspectionId!);
        await dao.updateQuantityRejected(
            inspection!.inspectionId!, 0, qualityControlItems!.qtyShipped!);
      }
      await dao.updateInspectionResult(
          _appStorage.currentInspection!.inspectionId!, result);
      await dao.createOrUpdateInspectionSpecification(
          _appStorage.currentInspection!.inspectionId!,
          specificationNumber,
          specificationVersion,
          specificationName);
    }
  }
}
