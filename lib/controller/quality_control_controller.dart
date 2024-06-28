import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/delivered_from/delivered_from_screen.dart';
import 'package:pverify/ui/supplier/choose_supplier.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/extensions/int_extension.dart';

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
  String productTransfer = "";
  int carrierID = 0;

  bool orderNoEnabled = true;

  void setSelected(String value, String type) {
    if (type == 'TruckTempOK') {
      selectedTruckTempOK.value = value;
    } else if (type == 'Type') {
      selectedTypes.value = value;
      if (value == 'Quality Assurance') {
        productTransfer = 'QA';
      } else if (value == 'Transfer') {
        productTransfer = 'Transfer';
      } else {
        productTransfer = value;
      }
    } else {
      // Load Types
      selectedLoadType.value = value;
    }
  }

  @override
  void onInit() {
    super.onInit();
    setArguments();
    loadFieldsFromDB();
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

  void loadFieldsFromDB() async {
    if (poNumber.isNotEmpty) {
      qcHeaderDetails = await dao.findTempQCHeaderDetails(poNumber);
    }

    if (qcHeaderDetails != null) {
      orderNoTextController.value.text = qcHeaderDetails!.poNo ?? '';
      sealTextController.value.text = qcHeaderDetails!.sealNo ?? '';
      certificateDepartureTextController.value.text =
          qcHeaderDetails!.qchOpen1 ?? '';
      factoryReferenceTextController.value.text =
          qcHeaderDetails!.qchOpen2 ?? '';
      usdaReferenceTextController.value.text = qcHeaderDetails!.qchOpen3 ?? '';
      containerTextController.value.text = qcHeaderDetails!.qchOpen4 ?? '';
      totalQuantityTextController.value.text = qcHeaderDetails!.qchOpen5 ?? '';
      transportConditionTextController.value.text =
          qcHeaderDetails!.qchOpen9 ?? '';
      commentTextController.value.text = qcHeaderDetails!.qchOpen10 ?? '';
    }
  }

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
    } else if (selectedTypes.value == 'Transfer') {
      type = 'Transfer';
    } else {
      type = selectedTypes.value;
    }
    appStorage.currentSealNumber =
        sealTextController.value.text.trim().toString();

    if (qcHeaderDetails == null) {
      await dao.createTempQCHeaderDetails(
        partnerID: carrierID,
        poNo: orderNoTextController.value.text,
        sealNo: sealTextController.value.text,
        qchOpen1: certificateDepartureTextController.value.text,
        qchOpen2: factoryReferenceTextController.value.text,
        qchOpen3: usdaReferenceTextController.value.text,
        qchOpen4: containerTextController.value.text,
        qchOpen5: totalQuantityTextController.value.text,
        qchOpen6: selectedLoadType.value,
        qchOpen9: transportConditionTextController.value.text,
        qchOpen10: commentTextController.value.text,
        truckTempOk: selectedTruckTempOK.value[0],
        cteType: cteType,
        productTransfer: type,
      );
      qcHeaderDetails =
          await dao.findTempQCHeaderDetails(orderNoTextController.value.text);
    } else {
      QCHeaderDetails? headerDetails = qcHeaderDetails;
      await dao.updateTempQCHeaderDetails(
          baseId: headerDetails?.id ?? 0,
          poNo: orderNoTextController.value.text,
          sealNo: sealTextController.value.text,
          qchOpen1: certificateDepartureTextController.value.text,
          qchOpen2: factoryReferenceTextController.value.text,
          qchOpen3: usdaReferenceTextController.value.text,
          qchOpen4: containerTextController.value.text,
          qchOpen5: totalQuantityTextController.value.text,
          qchOpen6: selectedLoadType.value,
          qchOpen9: transportConditionTextController.value.text,
          qchOpen10: commentTextController.value.text,
          truckTempOk: selectedTruckTempOK.value[0],
          cteType: cteType,
          productTransfer: type);
    }

    if (purchaseOrderDetails.isNotEmpty) {
      if (!callerActivity.equals("")) {
        if (callerActivity.equals("QualityControlHeaderActivity")) {
          Get.back();
        } else {
          // showBeginInspectionScreen();
        }
      } else {
        // showBeginInspectionScreen();
      }
    } else {
      // Here need to call showPurchaseOrder function.
      showPurchaseOrder();
    }
  }

  /*Future<void> showBeginInspectionScreen() async {
    for (int i = 0; i < purchaseOrderDetails.length; i++) {
      String itemUniqueId = generateUUID();

      String ftlflag =
          await dao.getFTLFlagFromItemSku(purchaseOrderDetails[i].itemSkuId!);
      String brandedFlag = await dao
          .getBrandedFlagFromItemSku(purchaseOrderDetails[i].itemSkuId!);

      appStorage.selectedItemSKUList.add(FinishedGoodsItemSKU(
        poLineNo: purchaseOrderDetails[i].poLineNumber,
        itemSkuId: purchaseOrderDetails[i].itemSkuId,
        itemSkuCode: purchaseOrderDetails[i].itemSkuCode,
        itemSkuName: purchaseOrderDetails[i].itemSkuName,
        commodityId: purchaseOrderDetails[i].commodityId,
        commodityName: purchaseOrderDetails[i].commodityName,
        uniqueItemId: itemUniqueId,
        partnerId: purchaseOrderDetails[i].partnerId,
        partnerName: purchaseOrderDetails[i].partnerName,
        quantity: purchaseOrderDetails[i].quantity,
        poNumber: purchaseOrderDetails[i].poNumber,
        quantityUOMId: purchaseOrderDetails[i].quantityUOMId,
        quantityUOMName: purchaseOrderDetails[i].quantityUOMName,
        numberSpecification: purchaseOrderDetails[i].numberSpecification,
        versionSpecification: purchaseOrderDetails[i].versionSpecification,
        ftlflag: ftlflag,
        brandedFlag: brandedFlag,
        createdDate: purchaseOrderDetails[i].createdDate,
      ));

      appStorage.selectedItemSKUList
          .sort((a, b) => a.poLineNo!.compareTo(b.poLineNo!));
    }

    int userid = await dao.getHeadquaterIdByUserId(
        appStorage.getUserData()!.userName!.toLowerCase());

    final String tag = DateTime.now().millisecondsSinceEpoch.toString();

    if (userid == 4180) {
      Map<String, dynamic> arguments = {
        'partnerName': purchaseOrderDetails[0].partnerName,
        'partnerId': purchaseOrderDetails[0].partnerId,
        'carrierName': carrierName,
        'carrierId': carrierID,
        'poNumber': poNumber,
        'callerActivity': 'QualityControlHeaderActivity',
      };
      Get.to(() => NewPurchaseOrderDetailsScreen(tag: tag),
          arguments: arguments);
    } else {
      Map<String, dynamic> arguments = {
        'partnerName': purchaseOrderDetails[0].partnerName,
        'partnerId': purchaseOrderDetails[0].partnerId,
        'carrierName': carrierName,
        'carrierId': carrierID,
        'poNumber': poNumber,
        'callerActivity': 'QualityControlHeaderActivity',
      };
      Get.to(() => PurchaseOrderDetailsScreen(tag: tag), arguments: arguments);
    }
    Get.back();
  }*/

  void showPurchaseOrder() {
    poNumber = orderNoTextController.value.text.trim();
    sealNumber = sealTextController.value.text.trim();

    if (callerActivity.isNotEmpty) {
      if (callerActivity == "QualityControlHeaderActivity") {
        // CallerActivity are blank now.
        Get.back();
      } else {
        if (selectedTypes.value == "Transfer") {
          Map<String, Object> passingData = {
            Consts.PO_NUMBER: poNumber,
            Consts.SEAL_NUMBER: sealNumber,
            Consts.CARRIER_NAME: carrierName,
            Consts.CARRIER_ID: carrierID,
            Consts.PRODUCT_TRANSFER: productTransfer,
            Consts.CALLER_ACTIVITY: 'QualityControlHeaderActivity',
          };
          Get.to(() => const DeliveredFromScreen(), arguments: passingData);
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
          var passingData = {
            Consts.CALLER_ACTIVITY: 'QualityControlHeaderActivity',
            Consts.CARRIER_ID: carrierID,
            Consts.CARRIER_NAME: carrierName,
            Consts.PO_NUMBER: poNumber,
            Consts.SEAL_NUMBER: sealNumber,
          };

          Get.to(() => const SelectSupplierScreen(), arguments: passingData);
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
