// ignore_for_file: camel_case_types, non_constant_identifier_names, unrelated_type_equality_checks, unnecessary_brace_in_string_interps, unused_local_variable, unnecessary_null_comparison, no_leading_underscores_for_local_identifiers

import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';

class QualityControl_Controller extends GetxController {
  final orderNoTextController = TextEditingController().obs;
  final commentTextController = TextEditingController().obs;
  final sealTextController = TextEditingController().obs;
  final certificateDepartureTextController = TextEditingController().obs;
  final factoryReferenceTextController = TextEditingController().obs;
  final usdaReferenceTextController = TextEditingController().obs;
  final containerTextController = TextEditingController().obs;
  final totalQuantityTextController = TextEditingController().obs;
  final transportConditionTextController = TextEditingController().obs;

  final isShortForm = false.obs;
  List truckTempOk = AppStrings.truckTempOk;
  List type = AppStrings.types;
  List loadType = AppStrings.stowage;

  var selectetdloadType = 'Internal Managed'.obs;
  var selectetdTruckTempOK = 'Yes'.obs;
  var selectetdTypes = 'Quality Assurance'.obs;
  var spacingBetweenFields = 10;
  final AppStorage appStorage = AppStorage.instance;
  late Future<List<PurchaseOrderDetails>> purchaseOrderDetails =
      Future.value([]);
  late Future<QCHeaderDetails?> qcHeaderDetails;
  late Future<List<int>> inspIDs;

  final ApplicationDao dao = ApplicationDao();

  String callerActivity = '';
  String cteType = ''; // As per Android Dev, Right now this value is blank.

  void setSelected(String value, String type) {
    if (type == 'TruckTempOK') {
      // TruckTempOK
      selectetdTruckTempOK.value = value;
    } else if (type == 'Type') {
      // Types
      selectetdTypes.value = value;
    } else {
      // Load Types
      selectetdloadType.value = value;
    }
  }

  @override
  void onInit() {
    super.onInit();
  }

  // LOGIN SCREEN VALIDATION'S

  bool isQualityControlFields_Validate(BuildContext context) {
    debugPrint('isShortForm:${isShortForm}');
    if (isShortForm == true) {
      if (orderNoTextController.value.text.trim().isEmpty) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.orderNoBlank);
        return false;
      }
      if (orderNoTextController.value.text.trim().length > 20) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.orderNoInvalid);
        return false;
      }
      if (sealTextController.value.text.trim().length > 15) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.sealInvalid);
        return false;
      }
      if (certificateDepartureTextController.value.text.trim().length > 20) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.certificateInvalid);
        return false;
      }
      if (factoryReferenceTextController.value.text.trim().length > 20) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.factoryReferenceInvalid);
        return false;
      }
      if (usdaReferenceTextController.value.text.trim().length > 20) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.usdaReferenceInvalid);
        return false;
      }
      if (containerTextController.value.text.trim().length > 20) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.containerInvalid);
        return false;
      }
      if (totalQuantityTextController.value.text.trim().length > 20) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.totalQuantityInvalid);
        return false;
      }
      return true;
    } else {
      if (orderNoTextController.value.text.trim().isEmpty) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.orderNoBlank);
        return false;
      }
      if (orderNoTextController.value.text.trim().length > 20) {
        AppAlertDialog.validateAlerts(
            context, AppStrings.error, AppStrings.orderNoInvalid);
        return false;
      }
      return true;
    }
  }

  saveAction(String _careername, int careerid) async {
    qcHeaderDetails =
        dao.findTempQCHeaderDetails(orderNoTextController.value.text);

    if (AppStorage.instance.getLoginData()!.supplierId != 0) {
      purchaseOrderDetails = dao.getPODetailsFromTable(
          orderNoTextController.value.text,
          AppStorage.instance.getLoginData()!.supplierId ?? 0);

      inspIDs = dao
          .getPartnerSKUInspectionIDsByPONo(orderNoTextController.value.text);
    }

    if (qcHeaderDetails == null) {
      dao.createTempQCHeaderDetails(
          careerid, // Carrier ID
          orderNoTextController.value.text,
          sealTextController.value.text,
          certificateDepartureTextController.value.text,
          factoryReferenceTextController.value.text,
          usdaReferenceTextController.value.text,
          containerTextController.value.text,
          totalQuantityTextController.value.text,
          selectetdloadType.value,
          transportConditionTextController.value.text,
          commentTextController.value.text,
          selectetdTruckTempOK.value,
          selectetdTypes.value,
          cteType);
    } else {
      QCHeaderDetails? headerDetails = await qcHeaderDetails;
      dao.updateTempQCHeaderDetails(
          headerDetails?.id ?? 0, // baseID
          orderNoTextController.value.text,
          sealTextController.value.text,
          certificateDepartureTextController.value.text,
          factoryReferenceTextController.value.text,
          usdaReferenceTextController.value.text,
          containerTextController.value.text,
          containerTextController.value.text,
          totalQuantityTextController.value.text,
          selectetdloadType.value,
          transportConditionTextController.value.text,
          selectetdTruckTempOK.value,
          selectetdTypes.value,
          cteType);
    }

    if (purchaseOrderDetails != null) {
    } else {
      // Here need to call showPurchaseOrder function.
      showPurchaseOrder();
    }
  }

  void showPurchaseOrder() {
    if (callerActivity.isNotEmpty) {
      if (callerActivity == "QualityControlHeaderActivity") {
        // CallerActivity are blank now.
        Get.back();
      } else {
        if (selectetdTypes.value == "Transfer") {
          /*
          Get.to(() => DeliveredFromActivity(), arguments: {
            'poNumber': orderNoTextController.value.text,
            'sealNumber': sealTextController.value.text,
            'carrierName': 'carrierName', // Need to pass dynamic value
            'carrierID': 'carrierID', // Need to pass dynamic value
            'productTransfer': productTransfer,
          });
          */
        } else if (selectetdTypes.value == "CTE") {
          if (cteType == "Shipping") {
            /*
            Get.to(() => PartnerActivityCTE(), arguments: {
              'poNumber': orderNoTextController.value.text,
              'sealNumber': sealTextController.value.text,
              'carrierName': 'carrierName', // Need to pass dynamic value
              'carrierID': 'carrierID', // Need to pass dynamic value
              'cteType': cteType,
            });
            */
          } else {
            /*
            Get.to(() => SourceLocationActivity(), arguments: {
              'poNumber': orderNoTextController.value.text,
              'sealNumber': sealTextController.value.text,
              'carrierName': 'carrierName', // Need to pass dynamic value
              'carrierID': 'carrierID', // Need to pass dynamic value
              'cteType': cteType,
            });
            */
          }
        } else {
          /*
          Get.to(() => PartnerActivity(), arguments: {
            'poNumber': orderNoTextController.value.text,
            'sealNumber': sealTextController.value.text,
            'carrierName': 'carrierName', // Need to pass dynamic value
            'carrierID': 'carrierID', // Need to pass dynamic value
          });
          */
        }
      }
    } else {
      if (selectetdTypes.value == "Transfer") {
        /*
        Get.to(() => DeliveredFromActivity(), arguments: {
          'poNumber': orderNoTextController.value.text,
          'sealNumber': sealTextController.value.text,
          'carrierName': 'carrierName', // Need to pass dynamic value
          'carrierID': 'carrierID', // Need to pass dynamic value
        });
        */
      } else if (selectetdTypes.value == "CTE") {
        if (cteType == "Shipping") {
          /*
          Get.to(() => PartnerActivityCTE(), arguments: {
            'poNumber': orderNoTextController.value.text,
            'sealNumber': sealTextController.value.text,
            'carrierName': 'carrierName', // Need to pass dynamic value
            'carrierID': 'carrierID', // Need to pass dynamic value
            'cteType': cteType,
          });
          */
        } else {
          /*
          Get.to(() => SourceLocationActivity(), arguments: {
            'poNumber': orderNoTextController.value.text,
            'sealNumber': sealTextController.value.text,
            'carrierName': 'carrierName', // Need to pass dynamic value
            'carrierID': 'carrierID', // Need to pass dynamic value
            'cteType': cteType,
          });
          */
        }
      } else {
        /*
        Get.to(() => PartnerActivity(), arguments: {
          'poNumber': orderNoTextController.value.text,
          'sealNumber': sealTextController.value.text,
          'carrierName': 'carrierName', // Need to pass dynamic value
          'carrierID': 'carrierID', // Need to pass dynamic value
        });
        */
      }
    }
  }
}
