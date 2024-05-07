import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/result_rejection_details.dart';
import 'package:pverify/services/database/application_dao.dart';

import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/theme/colors.dart';

class OverriddenResultScreenController extends GetxController {
  final ApplicationDao dao = ApplicationDao();

  ResultRejectionDetail? resultRejectionDetail;
  List newResultList = AppStrings.newResultList;

  final ovverRiddenCommentTextController = TextEditingController().obs;
  final gtyRejectController = TextEditingController().obs;

  late Map<String, dynamic> passingData;

  String? partnerName;
  String? commodityName;
  String? itemSku;
  RxString newResultAccept = 'Accept'.obs;
  RxString newResultA = 'A-'.obs;
  RxString newResultProtection = 'Accept w/Protection'.obs;
  RxString newResultReject = 'Reject'.obs;
  RxString? finalInspectionResult = ''.obs;
  RxString? txtRejectionDetails = ''.obs;
  RxString? txtDefectComment = ''.obs;

  RxInt qtyShipped = 0.obs;
  RxInt qtyRejected = 0.obs;
  int? serverInspectionID;

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
    updateFinalInspectionResult(finalInspectionResult?.value);
    super.onInit();
  }

  void updateFinalInspectionResult(String? inspectionResult) async {
    serverInspectionID = passingData[Consts.SERVER_INSPECTION_ID] ?? -1;

    QualityControlItem? qualityControlItems =
        await dao.findQualityControlDetails(serverInspectionID!);

    qtyShipped.value = qualityControlItems?.qtyShipped ?? 0;
    qtyRejected.value = qualityControlItems?.qtyRejected ?? 0;
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

  backClickDialog(BuildContext context, dynamic Function()? onYesTap) {
    AppAlertDialog.confirmationAlert(
      onYesTap: onYesTap,
      context,
      AppStrings.alert,
      AppStrings.calculateResult,
    );
  }

  Future<void> saveAndContinue(BuildContext context) async {
    log("Save & continue callled");
  }
}
