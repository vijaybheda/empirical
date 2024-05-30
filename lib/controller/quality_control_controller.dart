import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
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

  final RxBool isShortForm = false.obs;
  List<String> truckTempOk = AppStrings.truckTempOk;
  List<String> type = AppStrings.types;
  List<String> loadType = AppStrings.stowage;

  RxString selectedLoadType = 'Internal Managed'.obs;
  RxString selectedTruckTempOK = 'Yes'.obs;
  RxString selectedTypes = 'Quality Assurance'.obs;
  int spacingBetweenFields = 10;
  final AppStorage appStorage = AppStorage.instance;
  List<PurchaseOrderDetails> purchaseOrderDetails = [];
  QCHeaderDetails? qcHeaderDetails;
  List<int> inspectionIDs = [];

  final ApplicationDao dao = ApplicationDao();

  String callerActivity = '';
  String cteType = '';
  String sealNumber = '';
  String poNumber = '';
  String carrierName = '';
  int carrierID = 0;

  bool orderNoEnabled = true;

  void setSelected(String value, String type) {
    if (type == 'TruckTempOK') {
      selectedTruckTempOK.value = value;
    } else if (type == 'Type') {
      selectedTypes.value = value;
    } else {
      // Load Types
      selectedLoadType.value = value;
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
      poNumber = args[Consts.PO_NUMBER] ?? '';
      sealNumber = args[Consts.SEAL_NUMBER] ?? '';
      callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';

      if (poNumber.isNotEmpty) {
        orderNoTextController.value.text = poNumber;
        orderNoEnabled = false;
      }
    }
  }

  // LOGIN SCREEN VALIDATION'S

  bool isQualityControlFieldsValidate(BuildContext context) {
    if (isShortForm.value == true) {
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

  Future<void> saveAction() async {
    qcHeaderDetails =
        await dao.findTempQCHeaderDetails(orderNoTextController.value.text);

    if (AppStorage.instance.getUserData()!.supplierId != 0) {
      purchaseOrderDetails = await dao.getPODetailsFromTable(
          orderNoTextController.value.text,
          AppStorage.instance.getUserData()!.supplierId ?? 0);

      inspectionIDs = await dao
          .getPartnerSKUInspectionIDsByPONo(orderNoTextController.value.text);
    }
    String type = '';
    if (selectedTypes.value == 'Quality Assurance') {
      type = 'QA';
    } else {
      type = selectedTypes.value;
    }
    appStorage.currentSealNumber =
        sealTextController.value.text.trim().toString();
    if (qcHeaderDetails == null) {
      await dao.createTempQCHeaderDetails(
          carrierID,
          orderNoTextController.value.text,
          sealTextController.value.text,
          certificateDepartureTextController.value.text,
          factoryReferenceTextController.value.text,
          usdaReferenceTextController.value.text,
          containerTextController.value.text,
          totalQuantityTextController.value.text,
          selectedLoadType.value,
          transportConditionTextController.value.text,
          commentTextController.value.text,
          selectedTruckTempOK.value[0],
          type,
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
          selectedLoadType.value,
          transportConditionTextController.value.text,
          selectedTruckTempOK.value[0],
          type,
          cteType);
    }

    if (purchaseOrderDetails.isNotEmpty) {
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
        if (selectedTypes.value == "Transfer") {
          /*
          Get.to(() => DeliveredFromActivity(), arguments: {
            'poNumber': orderNoTextController.value.text,
            'sealNumber': sealTextController.value.text,
            'carrierName': 'carrierName', // Need to pass dynamic value
            'carrierID': 'carrierID', // Need to pass dynamic value
            'productTransfer': productTransfer,
          });
          */
        } else if (selectedTypes.value == "CTE") {
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
          poNumber = orderNoTextController.value.text.trim();
          Get.to(() => const SelectSupplierScreen(), arguments: {
            Consts.CALLER_ACTIVITY: 'QualityControlHeaderActivity',
            Consts.CARRIER_ID: carrierID,
            Consts.CARRIER_NAME: carrierName,
            Consts.PO_NUMBER: poNumber,
            Consts.SEAL_NUMBER: sealNumber,
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
      if (selectedTypes.value == "Transfer") {
        /*
        Get.to(() => DeliveredFromActivity(), arguments: {
          'poNumber': orderNoTextController.value.text,
          'sealNumber': sealTextController.value.text,
          'carrierName': 'carrierName', // Need to pass dynamic value
          'carrierID': 'carrierID', // Need to pass dynamic value
        });
        */
      } else if (selectedTypes.value == "CTE") {
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
        poNumber = orderNoTextController.value.text.trim();
        Get.to(() => const SelectSupplierScreen(), arguments: {
          Consts.CALLER_ACTIVITY: 'QualityControlHeaderActivity',
          Consts.CARRIER_ID: carrierID,
          Consts.CARRIER_NAME: carrierName,
          Consts.PO_NUMBER: poNumber,
          Consts.SEAL_NUMBER: sealNumber,
        });
      }
    }
  }
}
