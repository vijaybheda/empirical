import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/result_rejection_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/purchase_order/purchase_order_details_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/theme/colors.dart';

class OverriddenResultScreenController extends GetxController {
  final ApplicationDao dao = ApplicationDao();
  final AppStorage appStorage = AppStorage.instance;
  ResultRejectionDetail? resultRejectionDetail;
  List<String> newResultList = AppStrings.newResultList;

  final Rx<TextEditingController> ovverRiddenCommentTextController =
      TextEditingController().obs;
  final Rx<TextEditingController> gtyRejectController =
      TextEditingController().obs;

  QualityControlItem? qualityControlItems;

  int? carrierId;
  int? partnerId;
  int? commodityId;
  int? varietyId;
  int? gradeId;
  int? itemSkuId;
  int? inspectionID;
  RxInt qtyShipped = 0.obs;
  RxInt qtyRejected = 0.obs;

  String? itemSkuName;
  String? partnerName;
  String? commodityName;
  String? itemSku;
  String? lotNo;
  String? gtin;
  String? packDate;
  String? varietyName;
  String? specificationNumber;
  String? specificationVersion;
  String? selectedSpecification;
  String? specificationTypeName;
  String? itemUniqueId;
  String? lotSize;
  String? poNumber;
  String? productTransfer;
  String? callerActivity;
  String carrierName = "";

  RxString newResultAccept = AppStrings.accept.obs;
  RxString newResultA = AppStrings.a_minus.obs;
  RxString newResultProtection = AppStrings.acceptCondition.obs;
  RxString newResultReject = AppStrings.reject.obs;
  RxString finalInspectionResult = ''.obs;
  RxString txtRejectionDetails = ''.obs;
  RxString txtDefectComment = ''.obs;
  String myInspectionResult = '';
  RxBool layoutQtyRejectedVisibility = false.obs;
  RxBool rejectionDetailsVisibility = false.obs;
  RxBool defectCommentsVisibility = false.obs;

  Color finalInspectionResultColor = AppColors.white;

  @override
  void onInit() {
    Map<String, dynamic> passingData = Get.arguments as Map<String, dynamic>;
    inspectionID = passingData[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = passingData[Consts.PARTNER_NAME];
    commodityName = passingData[Consts.COMMODITY_NAME];
    itemSku = passingData[Consts.ITEM_SKU];
    myInspectionResult = passingData[Consts.INSPECTION_RESULT];
    partnerId = passingData[Consts.PARTNER_ID];
    carrierName = passingData[Consts.CARRIER_NAME];
    carrierId = passingData[Consts.CARRIER_ID];
    commodityId = passingData[Consts.COMMODITY_ID];
    varietyName = passingData[Consts.VARIETY_NAME];
    varietyId = passingData[Consts.VARIETY_ID];
    gradeId = passingData[Consts.GRADE_ID];
    specificationNumber = passingData[Consts.SPECIFICATION_NUMBER];
    specificationVersion = passingData[Consts.SPECIFICATION_VERSION];
    selectedSpecification = passingData[Consts.SELECTEDSPECIFICATION];
    specificationTypeName = passingData[Consts.SPECIFICATION_TYPE_NAME];
    itemUniqueId = passingData[Consts.ITEM_UNIQUE_ID];
    lotNo = passingData[Consts.LOT_NO];
    gtin = passingData[Consts.GTIN];
    packDate = passingData[Consts.PACK_DATE];
    lotSize = passingData[Consts.LOT_SIZE];
    poNumber = passingData[Consts.PO_NUMBER];
    productTransfer = passingData[Consts.PRODUCT_TRANSFER];
    itemSkuId = passingData[Consts.ITEM_SKU_ID];
    itemSkuName = passingData[Consts.ITEM_SKU_NAME];
    callerActivity = passingData[Consts.CALLER_ACTIVITY] ?? '';

    if (myInspectionResult == "AC" || myInspectionResult == AppStrings.accept) {
      myInspectionResult = AppStrings.accept;
    } else if (myInspectionResult == "RJ" ||
        myInspectionResult == AppStrings.reject) {
      myInspectionResult = AppStrings.reject;
    } else if (myInspectionResult == AppStrings.a_minus) {
      myInspectionResult = AppStrings.a_minus;
    } else if (myInspectionResult == "AW" ||
        myInspectionResult.toLowerCase() ==
            AppStrings.acceptCondition.toLowerCase()) {
      myInspectionResult = AppStrings.acceptCondition;
    }

    finalInspectionResult.value = myInspectionResult;
    updateFinalInspectionResult(finalInspectionResult.value);
    super.onInit();
  }

  void updateFinalInspectionResult(String? inspectionResult) async {
    qualityControlItems = await dao.findQualityControlDetails(inspectionID!);

    qtyShipped.value = qualityControlItems?.qtyShipped ?? 0;
    qtyRejected.value = qualityControlItems?.qtyRejected ?? 0;
    gtyRejectController.value.text = qtyRejected.value.toString();
    log("heree is Inspection Result $inspectionResult");
    if (inspectionResult == "RJ" || inspectionResult == AppStrings.reject) {
      finalInspectionResultColor = Colors.red;
      finalInspectionResult.value = AppStrings.reject;
      layoutQtyRejectedVisibility.value = true;
    } else if (inspectionResult == "AC" ||
        inspectionResult == AppStrings.accept) {
      finalInspectionResultColor = Colors.green;
      finalInspectionResult.value = AppStrings.accept;
      layoutQtyRejectedVisibility.value = false;
    } else if (inspectionResult == AppStrings.a_minus) {
      finalInspectionResultColor = Colors.yellow;
      finalInspectionResult.value = AppStrings.a_minus;
      layoutQtyRejectedVisibility.value = false;
    } else if (inspectionResult == "AW" ||
        inspectionResult?.toLowerCase() == AppStrings.acceptCondition ||
        inspectionResult == "Accept w/Protection") {
      finalInspectionResultColor = Colors.green;
      finalInspectionResult.value = AppStrings.acceptCondition;
      layoutQtyRejectedVisibility.value = false;
    }
    resultRejectionDetail = await dao.getResultRejectionDetails(inspectionID!);

    if (resultRejectionDetail != null) {
      rejectionDetailsVisibility.value = true;
      txtRejectionDetails.value = resultRejectionDetail?.resultReason ?? "";
      if (resultRejectionDetail?.defectComments != null &&
          resultRejectionDetail?.defectComments != "") {
        defectCommentsVisibility.value = true;
        txtDefectComment.value = resultRejectionDetail?.defectComments ?? "";
      }
    } else {
      debugPrint(" 🔴 Reject Rejection Database is null 🔴 ");
    }
  }

  Future<void> setSelected(String value, String inspectionResult) async {
    qualityControlItems = await dao.findQualityControlDetails(inspectionID!);

    if (value == AppStrings.reject) {
      layoutQtyRejectedVisibility.value = false;
      if (qualityControlItems != null) {
        if (qualityControlItems!.qtyRejected == 0) {
          gtyRejectController.value.text = '0';
        } else {
          gtyRejectController.value.text =
              qualityControlItems!.qtyRejected.toString();
        }
        int qtyRejected = int.parse(gtyRejectController.value.text);
        int qtyReceived = qualityControlItems!.qtyShipped! - qtyRejected;

        await dao.updateQuantityRejected(
            inspectionID!, qtyRejected, qtyReceived);
      }
    } else {
      if (!(inspectionResult == "RJ" ||
          inspectionResult == AppStrings.reject)) {
        // linearLayoutReject.setVisibility(View.GONE);
        layoutQtyRejectedVisibility.value = false;
      } else {}
      if (qualityControlItems != null &&
          qualityControlItems!.qtyRejected! > 0) {
        // linearLayoutReject.setVisibility(View.VISIBLE);
        layoutQtyRejectedVisibility.value = false;
      }
    }

    if (inspectionResult == "AC" || inspectionResult == AppStrings.accept) {
      finalInspectionResult.value = value;
    } else if (inspectionResult == AppStrings.a_minus) {
      finalInspectionResult.value = value;
    } else if (inspectionResult == "AW" ||
        inspectionResult.toLowerCase() == AppStrings.acceptCondition) {
      finalInspectionResult.value = value;
    } else if (inspectionResult == "RJ" ||
        inspectionResult == AppStrings.reject) {
      finalInspectionResult.value = value;
      finalInspectionResult.value = AppStrings.reject;
    }
    if (newResultAccept.value == value) {
      layoutQtyRejectedVisibility.value = false;
    } else if (newResultA.value == value) {
      layoutQtyRejectedVisibility.value = false;
    } else if (newResultProtection.value == value) {
      layoutQtyRejectedVisibility.value = false;
    } else if (newResultReject.value == value) {
      layoutQtyRejectedVisibility.value = true;
    }

    finalInspectionResult.value = value;
    update();
  }

  bool isOverrideControllerValidate(BuildContext context) {
    if (ovverRiddenCommentTextController.value.text.trim().isEmpty) {
      AppAlertDialog.validateAlerts(
        context,
        AppStrings.error,
        AppStrings.pleaseEnterComments,
      );
      return false;
    }
    if (layoutQtyRejectedVisibility.isTrue) {
      if (gtyRejectController.value.text.trim().isEmpty) {
        AppAlertDialog.validateAlerts(
          context,
          AppStrings.error,
          AppStrings.pleaseEnterValidQtyRejected,
        );
        return false;
      }
    }
    return true;
  }

  Future<void> saveAndContinueClick(
      BuildContext context, String? inspectionResult) async {
    bool isSaved = await saveFieldsToDB(context, inspectionResult);
    log("Is Saved $isSaved");
    if (isSaved) {
      bool isValid = true;
      if (isValid) {
        Map<String, dynamic> passingData = {
          Consts.SERVER_INSPECTION_ID: inspectionID,
          Consts.CARRIER_NAME: carrierName,
          Consts.CARRIER_ID: carrierId,
          Consts.PARTNER_NAME: partnerName,
          Consts.PARTNER_ID: partnerId,
          Consts.COMMODITY_NAME: commodityName,
          Consts.COMMODITY_ID: commodityId,
          Consts.ITEM_SKU: itemSku,
          Consts.ITEM_SKU_NAME: itemSkuName,
          Consts.ITEM_SKU_ID: itemSkuId,
          Consts.LOT_NO: lotNo,
          Consts.GTIN: gtin,
          Consts.PACK_DATE: packDate,
          Consts.VARIETY_NAME: varietyName,
          Consts.VARIETY_ID: varietyId,
          Consts.GRADE_ID: gradeId,
          Consts.SPECIFICATION_NUMBER: specificationNumber,
          Consts.SPECIFICATION_VERSION: specificationVersion,
          Consts.SPECIFICATION_NAME: selectedSpecification,
          Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
          Consts.ITEM_UNIQUE_ID: itemUniqueId,
          Consts.LOT_SIZE: lotSize,
          Consts.PO_NUMBER: poNumber,
          Consts.PRODUCT_TRANSFER: productTransfer,
        };

        final String tag = DateTime.now().millisecondsSinceEpoch.toString();
        if (callerActivity == "PurchaseOrderDetailsActivity" ||
            callerActivity == "NewPurchaseOrderDetailsActivity") {
          Get.offAll(() => PurchaseOrderDetailsScreen(tag: tag),
              arguments: passingData);
        } else {
          Get.back(
            result: inspectionID,
          );
        }
      }
    }
  }

  // Save & action Button Click
  Future<bool> saveFieldsToDB(
      BuildContext context, String? inspectionResult) async {
    bool hasErrors = false;

    String comments = ovverRiddenCommentTextController.value.text;
    String result = "";

    if (finalInspectionResult.value == newResultList[0]) {
      result = "AC";
    } else if (finalInspectionResult.value == newResultList[1]) {
      result = AppStrings.a_minus;
    } else if (finalInspectionResult.value == newResultList[2]) {
      result = "AW";
    } else if (finalInspectionResult.value == newResultList[3]) {
      result = "RJ";
    }
    qualityControlItems = await dao.findQualityControlDetails(inspectionID!);
    log("Hereee is ${qualityControlItems?.inspectionID}");
    if (layoutQtyRejectedVisibility.isTrue ||
        rejectionDetailsVisibility.isTrue) {
      String tempqty = gtyRejectController.value.text;

      if (tempqty.isEmpty) {
        if ((inspectionResult == 'RJ' ||
                inspectionResult?.toLowerCase() == AppStrings.reject) &&
            (result == 'AC' ||
                result == AppStrings.a_minus ||
                result == 'AW')) {
          gtyRejectController.value.text = '0';

          int qtyRejected = int.tryParse(gtyRejectController.value.text) ?? 0;
          int qtyReceived = qualityControlItems!.qtyShipped! - qtyRejected;

          if (comments.isEmpty) {
            // ovverRiddenCommentTextController.value.text = 'overridden_comments';
            hasErrors = true;
          } else {
            await dao.updateQuantityRejected(
                inspectionID!, qtyRejected, qtyReceived);
          }
        } else {
          hasErrors = true;
        }
      } else if (qualityControlItems != null &&
          (int.parse(tempqty) > qualityControlItems!.qtyShipped! ||
              int.parse(tempqty) < 0)) {
        hasErrors = true;
      } else {
        if (tempqty.isNotEmpty && tempqty != '') {
          int qtyRejected = int.parse(tempqty);
          int qtyReceived = 0;
          log("here is qty  ${qualityControlItems?.qtyReceived}");
          if (qualityControlItems != null) {
            qtyReceived = qualityControlItems!.qtyShipped! - qtyRejected;
            log("here is qty received $qtyReceived");
          }

          await dao.updateQuantityRejected(
              inspectionID!, qtyRejected, qtyReceived);
        }
      }
    }
    if (finalInspectionResult.value != inspectionResult) {
      if (comments.isEmpty) {
        hasErrors = true;
      }
    }
    if (!hasErrors) {
      int orgQtyRejected =
          int.tryParse(qualityControlItems!.qtyRejected.toString()) ?? 0;

      int orgQtyShipped = int.parse(qualityControlItems!.qtyShipped.toString());

      qualityControlItems = await dao.findQualityControlDetails(inspectionID!);

      int? userId = appStorage.getUserData()?.id;
      if (qualityControlItems != null) {
        await dao.createOrUpdateOverriddenResult(
          inspectionID!,
          userId!,
          result,
          comments,
          DateTime.now().millisecondsSinceEpoch,
          finalInspectionResult.value,
          orgQtyShipped,
          orgQtyRejected,
          qualityControlItems?.qtyShipped ?? 0,
          qualityControlItems?.qtyRejected ?? 0,
        );
      } else {
        await dao.createOrUpdateOverriddenResult(
          inspectionID!,
          userId!,
          result,
          comments,
          DateTime.now().millisecondsSinceEpoch,
          finalInspectionResult.value,
          orgQtyShipped,
          orgQtyRejected,
          orgQtyShipped,
          orgQtyRejected,
        );
      }
      return true;
    } else {
      return false;
    }
  }
}
