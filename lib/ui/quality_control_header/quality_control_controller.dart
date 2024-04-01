// ignore_for_file: camel_case_types, non_constant_identifier_names, unrelated_type_equality_checks, unnecessary_brace_in_string_interps, unused_local_variable, unnecessary_null_comparison

import 'dart:ffi';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/services/database/column_names.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/alert.dart';

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

  // private List<PurchaseOrderDetails> purchaseOrderDetails;

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
        validateAlerts(context, AppStrings.error, AppStrings.orderNoBlank);
        return false;
      }
      if (orderNoTextController.value.text.trim().length > 20) {
        validateAlerts(context, AppStrings.error, AppStrings.orderNoInvalid);
        return false;
      }
      if (sealTextController.value.text.trim().length > 15) {
        validateAlerts(context, AppStrings.error, AppStrings.sealInvalid);
        return false;
      }
      if (certificateDepartureTextController.value.text.trim().length > 20) {
        validateAlerts(
            context, AppStrings.error, AppStrings.certificateInvalid);
        return false;
      }
      if (factoryReferenceTextController.value.text.trim().length > 20) {
        validateAlerts(
            context, AppStrings.error, AppStrings.factoryReferenceInvalid);
        return false;
      }
      if (usdaReferenceTextController.value.text.trim().length > 20) {
        validateAlerts(
            context, AppStrings.error, AppStrings.usdaReferenceInvalid);
        return false;
      }
      if (containerTextController.value.text.trim().length > 20) {
        validateAlerts(context, AppStrings.error, AppStrings.containerInvalid);
        return false;
      }
      if (totalQuantityTextController.value.text.trim().length > 20) {
        validateAlerts(
            context, AppStrings.error, AppStrings.totalQuantityInvalid);
        return false;
      }
      return true;
    } else {
      if (orderNoTextController.value.text.trim().isEmpty) {
        validateAlerts(context, AppStrings.error, AppStrings.orderNoBlank);
        return false;
      }
      if (orderNoTextController.value.text.trim().length > 20) {
        validateAlerts(context, AppStrings.error, AppStrings.orderNoInvalid);
        return false;
      }
      return true;
    }
  }

  saveAction() {
    qcHeaderDetails =
        dao.findTempQCHeaderDetails(orderNoTextController.value.text);

    var supplierID = 0;
    if (supplierID != 0) {
      purchaseOrderDetails = dao.getPODetailsFromTable(
          orderNoTextController.value.text,
          supplierID); // Here need to pass actual SupplierID instead of 0.

      inspIDs = dao
          .getPartnerSKUInspectionIDsByPONo(orderNoTextController.value.text);
    }

    if (qcHeaderDetails == null) {
       //dao.createTempQCHeaderDetails(partnerID, poNo, sealNo, qchOpen1, qchOpen2, qchOpen3, qchOpen4, qchOpen5, qchOpen6, qchOpen9, qchOpen10, truckTempOk, productTransfer, cteType);
    } else {
      // dao.updateTempQCHeaderDetailsToQCHeaderDetails(inspectionID, orderNoTextController.value.text);
    }

    if (purchaseOrderDetails != null) {
    } else {
      // Here need to call showPurchaseOrder function.
    }
  }
}
