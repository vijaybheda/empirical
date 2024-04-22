// ignore_for_file: camel_case_types, non_constant_identifier_names, unrelated_type_equality_checks, unnecessary_brace_in_string_interps, unused_local_variable, unnecessary_null_comparison, no_leading_underscores_for_local_identifiers, prefer_is_empty

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/supplier/choose_supplier.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';

class QualityControlController extends GetxController {
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
  List<PurchaseOrderDetails> purchaseOrderDetails = [];
  QCHeaderDetails? qcHeaderDetails;
  List<int> inspIDs = [];

  final ApplicationDao dao = ApplicationDao();

  String callerActivity = '';
  String cteType = ''; // As per Android Dev, Right now this value is blank.
  String seal_number = '';
  String po_number = '';
  String carrierName = '';
  int carrierID = 0;

  bool orderNoEnabled = true;

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
    setArguments();
  }

  void setArguments() {
    Map<String, dynamic>? args = Get.arguments;

    if (args != null) {
      carrierName = args[Consts.CARRIER_NAME] ?? '';
      carrierID = args[Consts.CARRIER_ID] ?? 0;
      po_number = args[Consts.PO_NUMBER] ?? '';
      seal_number = args[Consts.SEAL_NUMBER] ?? '';
      callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';

      if (po_number.isNotEmpty) {
        orderNoTextController.value.text = po_number;
        orderNoEnabled = false;
      }
    }
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

  Future<void> saveAction(CarrierItem carrier) async {
    qcHeaderDetails =
        await dao.findTempQCHeaderDetails(orderNoTextController.value.text);

    if (AppStorage.instance.getUserData()!.supplierId != 0) {
      purchaseOrderDetails = await dao.getPODetailsFromTable(
          orderNoTextController.value.text,
          AppStorage.instance.getUserData()!.supplierId ?? 0);

      inspIDs = await dao
          .getPartnerSKUInspectionIDsByPONo(orderNoTextController.value.text);
    }
    appStorage.currentSealNumber =
        sealTextController.value.text.trim().toString();
    if (qcHeaderDetails == null) {
      await dao.createTempQCHeaderDetails(
          carrier.id!,
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
      qcHeaderDetails =
          await dao.findTempQCHeaderDetails(orderNoTextController.value.text);
    } else {
      QCHeaderDetails? headerDetails = qcHeaderDetails;
      await dao.updateTempQCHeaderDetails(
          headerDetails?.id ?? 0,
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

    if (purchaseOrderDetails.length != 0) {
    } else {
      // Here need to call showPurchaseOrder function.
      showPurchaseOrder(carrier);
    }
  }

  void showPurchaseOrder(CarrierItem carrier) {
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
          Get.to(
              () => SelectSupplierScreen(
                  carrier: carrier, qcHeaderDetails: qcHeaderDetails),
              arguments: {
                Consts.CALLER_ACTIVITY: 'QualityControlHeaderActivity',
                // TODO: Need to pass dynamic value
                // 'name': ,
                // 'id': ,
              });
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
        Get.to(
            () => SelectSupplierScreen(
                carrier: carrier, qcHeaderDetails: qcHeaderDetails),
            arguments: {
              Consts.CALLER_ACTIVITY: 'QualityControlHeaderActivity',
              // TODO: Need to pass dynamic value
              // 'name': ,
              // 'id': ,
            });
      }
    }
  }
}
