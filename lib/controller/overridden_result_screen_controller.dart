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
  List newResultList = AppStrings.newResultList;

  final ovverRiddenCommentTextController = TextEditingController().obs;
  final gtyRejectController = TextEditingController().obs;

  QualityControlItem? qualityControlItems;
  late Map<String, dynamic> passingData;

  int? carrierId;
  int? partnerId;
  int? commodityId;
  int? varietyId;
  int? gradeId;
  int? itemSkuId;
  int? serverInspectionID;
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
  String carrierName = "";

  RxString newResultAccept = 'Accept'.obs;
  RxString newResultA = 'A-'.obs;
  RxString newResultProtection = 'Accept w/Protection'.obs;
  RxString newResultReject = 'Reject'.obs;
  RxString? finalInspectionResult = ''.obs;
  RxString? txtRejectionDetails = ''.obs;
  RxString? txtDefectComment = ''.obs;

  RxBool layoutQtyRejectedVisibility = false.obs;
  RxBool rejectionDetailsVisibility = false.obs;
  RxBool defectCommentsVisibility = false.obs;

  Color finalInspectionResultColor = AppColors.white;

  @override
  void onInit() {
    passingData = Get.arguments as Map<String, dynamic>;

    partnerName = passingData[Consts.PARTNER_NAME];
    commodityName = passingData[Consts.COMMODITY_NAME];
    itemSku = passingData[Consts.ITEM_SKU];
    finalInspectionResult?.value = passingData[Consts.INSPECTION_RESULT];
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

    updateFinalInspectionResult(finalInspectionResult?.value);
    super.onInit();
  }

  void updateFinalInspectionResult(String? inspectionResult) async {
    serverInspectionID = passingData[Consts.SERVER_INSPECTION_ID] ?? -1;

    qualityControlItems =
        await dao.findQualityControlDetails(serverInspectionID!);

    qtyShipped.value = qualityControlItems?.qtyShipped ?? 0;
    qtyRejected.value = qualityControlItems?.qtyRejected ?? 0;
    gtyRejectController.value.text = qtyRejected.value.toString();
    if (inspectionResult == "RJ" || inspectionResult == AppStrings.reject) {
      finalInspectionResultColor = Colors.red;
      finalInspectionResult?.value = AppStrings.reject;
      layoutQtyRejectedVisibility.value = true;
    } else if (inspectionResult == "AC" ||
        inspectionResult == AppStrings.accept) {
      finalInspectionResultColor = Colors.green;
      finalInspectionResult?.value = AppStrings.accept;
      layoutQtyRejectedVisibility.value = false;
    } else if (inspectionResult == "A-") {
      finalInspectionResultColor = Colors.yellow;
      finalInspectionResult?.value = "A-";
      layoutQtyRejectedVisibility.value = false;
    } else if (inspectionResult == "AW" ||
        inspectionResult?.toLowerCase() == AppStrings.acceptCondition) {
      finalInspectionResultColor = Colors.green;
      finalInspectionResult?.value = AppStrings.acceptCondition;
      layoutQtyRejectedVisibility.value = false;
    }
    resultRejectionDetail =
        await dao.getResultRejectionDetails(serverInspectionID!);

    if (resultRejectionDetail != null) {
      rejectionDetailsVisibility.value = true;
      txtRejectionDetails?.value = resultRejectionDetail?.resultReason ?? "";
      if (resultRejectionDetail?.defectComments != null &&
          resultRejectionDetail?.defectComments != "") {
        defectCommentsVisibility.value = true;
        txtDefectComment?.value = resultRejectionDetail?.defectComments ?? "";
      }
    } else {
      debugPrint(" 🔴 Reject Rejection Database is null 🔴 ");
    }
  }

  void setSelected(String value, String inspectionResult) {
    if (inspectionResult == "AC" || inspectionResult == AppStrings.accept) {
      newResultAccept.value = value;
    } else if (inspectionResult == "A-") {
      newResultA.value = value;
    } else if (inspectionResult == "AW" ||
        inspectionResult.toLowerCase() == AppStrings.acceptCondition) {
      newResultProtection.value = value;
    } else if (inspectionResult == "RJ" ||
        inspectionResult == AppStrings.reject) {
      newResultReject.value = value;
      finalInspectionResult?.value = AppStrings.reject;
    } else if (newResultAccept.value == value) {
      layoutQtyRejectedVisibility.value = false;
    } else if (newResultA.value == value) {
      layoutQtyRejectedVisibility.value = false;
    } else if (newResultProtection.value == value) {
      layoutQtyRejectedVisibility.value = false;
    } else if (newResultReject.value == value) {
      layoutQtyRejectedVisibility.value = true;
    }
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
          Consts.SERVER_INSPECTION_ID: serverInspectionID,
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

        Get.to(
            () => PurchaseOrderDetailsScreen(
                  tag: tag,
                ),
            arguments: passingData);

        /* Get.back(result: {Consts.INSPECTION_ID: serverInspectionID}); */
      }
    }
  }

  // Save & action Button Click
  Future<bool> saveFieldsToDB(
      BuildContext context, String? inspectionResult) async {
    bool hasErrors = false;
    ovverRiddenCommentTextController.value.text = '';

    String comments = ovverRiddenCommentTextController.value.text;
    String result = "";

    if (newResultAccept.value == newResultList[0]) {
      result = "AC";
    } else if (newResultA.value == newResultList[1]) {
      result = "A-";
    } else if (newResultProtection.value == newResultList[2]) {
      result = "AW";
    } else if (newResultReject.value == newResultList[3]) {
      result = "RJ";
    }
    qualityControlItems =
        await dao.findQualityControlDetails(serverInspectionID!);
    log("Hereee is ${qualityControlItems?.inspectionID}");
    if (layoutQtyRejectedVisibility.isTrue ||
        rejectionDetailsVisibility.isTrue) {
      String tempqty = gtyRejectController.value.text;

      if (tempqty.isEmpty || tempqty == '') {
        if ((inspectionResult == 'RJ' ||
                inspectionResult?.toLowerCase() == AppStrings.reject) &&
            (result == 'AC' || result == 'A-' || result == 'AW')) {
          gtyRejectController.value.text = '0';

          int qtyRejected = int.parse(gtyRejectController.value.text);
          int qtyReceived = qualityControlItems!.qtyShipped! - qtyRejected;

          if (comments.isEmpty) {
            ovverRiddenCommentTextController.value.text = 'overridden_comments';
            hasErrors = true;
          } else {
            dao.updateQuantityRejected(
                serverInspectionID!, qtyRejected, qtyReceived);
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

          dao.updateQuantityRejected(
              serverInspectionID!, qtyRejected, qtyReceived);
        }
      }
    }
    if (!newResultList.contains(inspectionResult?.toLowerCase())) {
      if (comments.isEmpty) {
        hasErrors = true;
      }
    }
    if (hasErrors) {
      var orgQtyRejected =
          int.parse(qualityControlItems?.qtyRejected.toString() ?? "0");

      int orgQtyShipped = int.parse(qualityControlItems!.qtyShipped.toString());

      var userId = appStorage.getUserData()?.id;
      if (qualityControlItems != null) {
        dao.createOrUpdateOverriddenResult(
          serverInspectionID!,
          userId!,
          result,
          comments,
          DateTime.now().millisecondsSinceEpoch,
          inspectionResult!,
          orgQtyShipped,
          orgQtyRejected,
          qualityControlItems?.qtyShipped ?? 0,
          qualityControlItems?.qtyRejected ?? 0,
        );
      } else {
        dao.createOrUpdateOverriddenResult(
          serverInspectionID!,
          userId!,
          result,
          comments,
          DateTime.now().millisecondsSinceEpoch,
          inspectionResult!,
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
