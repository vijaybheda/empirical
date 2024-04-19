import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_grade_tolerance_array.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/overridden_result/overridden_result_screen.dart';
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/dialogs/custom_listview_dialog.dart';
import 'package:pverify/utils/utils.dart';

class PurchaseOrderDetailsController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;

  final TextEditingController searchController = TextEditingController();

  int? serverInspectionID;
  String? partnerName;
  int? partnerID;
  String? carrierName;
  int? carrierID;
  int? commodityID;
  String? commodityName;
  String? poNumber;
  String? sealNumber;
  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;

  String? currentLotNumber,
      currentItemSKU,
      currentPackDate,
      currentLotSize,
      currentItemSKUName,
      itemUniqueId,
      callerActivity,
      productTransfer;
  int? itemSkuId;
  bool isGTINSamePartner = true;

  PurchaseOrderDetailsController({
    required this.partner,
    required this.carrier,
    required this.commodity,
    required this.qcHeaderDetails,
  });

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments not allowed');
    }

    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    poNumber = args[Consts.PO_NUMBER] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    currentLotNumber = args[Consts.Lot_No] ?? '';
    currentItemSKU = args[Consts.ITEM_SKU] ?? '';
    currentPackDate = args[Consts.PACK_DATE] ?? '';
    currentLotSize = args[Consts.LOT_SIZE] ?? '';
    currentItemSKUName = args[Consts.ITEM_SKU_NAME] ?? '';
    specificationNumber = args[Consts.SPECIFICATION_NUMBER];
    specificationVersion = args[Consts.SPECIFICATION_VERSION];
    specificationName = args[Consts.SPECIFICATION_NAME];
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME];
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? '';
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    isGTINSamePartner = args[Consts.IS_GTIN_SAME_PARTNER] ?? true;
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';

    itemSkuList.assignAll(getPurchaseOrderData());
    super.onInit();
    filteredInspectionsList.assignAll(itemSkuList);
    listAssigned.value = true;
  }

  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<PurchaseOrderItem> filteredInspectionsList = <PurchaseOrderItem>[].obs;
  RxList<PurchaseOrderItem> itemSkuList = <PurchaseOrderItem>[].obs;
  RxBool listAssigned = false.obs;

  void searchAndAssignItems(String searchValue) {
    filteredInspectionsList.clear();
    if (searchValue.isEmpty) {
      filteredInspectionsList.addAll(itemSkuList);
    } else {
      var items = itemSkuList.where((element) {
        String? sku = element.sku;
        String? description = element.description;

        return (sku != null &&
                sku.toLowerCase().contains(searchValue.toLowerCase())) ||
            (description != null &&
                description.toLowerCase().contains(searchValue.toLowerCase()));
      }).toList();
      filteredInspectionsList.addAll(items);
    }
    update(['inspectionItems']);
  }

  List<PurchaseOrderItem> getPurchaseOrderData() {
    List<PurchaseOrderItem> list = [];

    for (FinishedGoodsItemSKU item in (appStorage.selectedItemSKUList ?? [])) {
      list.add(PurchaseOrderItem.newData(
          item.name,
          item.sku,
          item.poNo,
          "",
          item.lotNo,
          item.commodityID,
          item.commodityName,
          item.packDate,
          item.FTLflag,
          item.Branded));
    }
    return list;
  }

  Future<void> calculateResult(BuildContext context) async {
    int totalQualityDefectId = 0;
    int totalConditionDefectId = 0;

    List<FinishedGoodsItemSKU> selectedItemSKUList =
        appStorage.selectedItemSKUList;
    for (int i = 0; i < selectedItemSKUList.length; i++) {
      FinishedGoodsItemSKU itemSKU = selectedItemSKUList.elementAt(i);
      bool isComplete = await dao.isInspectionComplete(
          partner.id!, itemSKU.sku!, itemSKU.uniqueItemId);

      if (isComplete) {
        PartnerItemSKUInspections? partnerItemSKU =
            await dao.findPartnerItemSKU(
                partner.id!, itemSKU.sku!, itemSKU.uniqueItemId);

        if (partnerItemSKU != null) {
          Inspection? inspection = await dao
              .findInspectionByID(partnerItemSKU.inspectionId!.toInt());
          if (inspection == null) {
            return;
          }
          if (inspection.specificationTypeName != null) {
            specificationTypeName = inspection.specificationTypeName!;
          }
          if (inspection.specificationNumber != null) {
            specificationNumber = inspection.specificationNumber!;
          }
          if (inspection.specificationVersion != null) {
            specificationVersion = inspection.specificationVersion!;
          }
          List<SpecificationGradeToleranceArray>
              specificationGradeToleranceArrayList =
              appStorage.specificationGradeToleranceArrayList ?? [];
          for (int abc = 0;
              abc < specificationGradeToleranceArrayList.length;
              abc++) {
            if ((specificationGradeToleranceArrayList[abc]
                        .specificationGradeToleranceList ??
                    [])
                .isNotEmpty) {
              if (specificationGradeToleranceArrayList[abc]
                          .specificationNumber ==
                      specificationNumber &&
                  specificationGradeToleranceArrayList[abc]
                          .specificationVersion ==
                      specificationVersion) {
                appStorage.specificationGradeToleranceList = appStorage
                    .specificationGradeToleranceArrayList![abc]
                    .specificationGradeToleranceList;
                break;
              }
            }
          }

          String result = "";
          String rejectReason = "";
          List<String> rejectReasonArray = [];
          List<String> defectNameReasonArray = [];

          appStorage.specificationAnalyticalList =
              await dao.getSpecificationAnalyticalFromDB(
                  specificationNumber!, specificationVersion!);

          if (!(specificationTypeName!.toLowerCase() ==
                  ("Finished Goods Produce".toLowerCase()) &&
              specificationTypeName!.toLowerCase() ==
                  ("Raw Produce".toLowerCase()))) {
            if (appStorage.specificationAnalyticalList != null) {
              for (var item in (appStorage.specificationAnalyticalList ?? [])) {
                SpecificationAnalyticalRequest? dbobj =
                    await dao.findSpecAnalyticalObj(
                        inspection.inspectionId!, item.analyticalID);
                if (dbobj != null && dbobj.comply == "N") {
                  if (dbobj.inspectionResult != null &&
                      dbobj.inspectionResult == "N") {
                    // Do nothing
                  } else {
                    result = "RJ";
                    rejectReason += "${dbobj.analyticalName} = N";
                    rejectReasonArray.add("${dbobj.analyticalName} = N");
                    int resultReason =
                        await dao.createOrUpdateResultReasonDetails(
                            inspection.inspectionId!,
                            result,
                            "${dbobj.analyticalName} = N",
                            dbobj.comment!);
                    if (resultReason != -1) {
                      // TODO: implement logic
                    }
                    int isPictureReqSpec =
                        await dao.createIsPictureReqSpecAttribute(
                            inspection.inspectionId!,
                            result,
                            "${dbobj.analyticalName} = N",
                            dbobj.isPictureRequired!);
                    if (isPictureReqSpec != -1) {
                      // TODO: implement logic
                    }
                    break;
                  }
                }
              }
              if (result == "") {
                result = "AC";
              }
              // TODO: implement logic
              // footerRightButtonText.setVisibility(View.VISIBLE);
            }

            if (result == "A-" || result == "AC") {
              QualityControlItem? qualityControlItems =
                  await dao.findQualityControlDetails(inspection.inspectionId!);

              bool isQuantityRejected = await dao.updateQuantityRejected(
                  inspection.inspectionId!,
                  0,
                  qualityControlItems!.qtyShipped!);
            }
            int inspectionResult = await dao.updateInspectionResult(
                inspection.inspectionId!, result);
            if (inspectionResult != -1) {
              // TODO: implement logic
            }
            int inspectionSpecification =
                await dao.createOrUpdateInspectionSpecification(
                    inspection.inspectionId!,
                    specificationNumber,
                    specificationVersion,
                    specificationName);
            if (inspectionSpecification != -1) {
              // TODO: implement logic
            }
            int inspectionComplete = await dao.updateInspectionComplete(
                inspection.inspectionId!, true);
            if (inspectionComplete != -1) {
              // TODO: implement logic
            }
            bool updateItemSKU = await dao.updateItemSKUInspectionComplete(
                inspection.inspectionId!, "true");

            // TODO: implement logic
            // await dao.updateInspectionUploadStatus(inspection.id!, (result == "RJ"? "RJ": "AC"));
          } else if (appStorage.specificationGradeToleranceList != null &&
              (appStorage.specificationGradeToleranceList ?? []).isNotEmpty) {
            int totalSampleSize = 0;
            List<InspectionSample> samples =
                await dao.findInspectionSamples(inspection.inspectionId!);
            if (samples.isNotEmpty) {
              for (int a = 0; a < samples.length; a++) {
                totalSampleSize += samples[a].setSize!;
              }
            }

            // TODO: implement logic
          } else {
            AppAlertDialog.validateAlerts(context, AppStrings.alert,
                AppStrings.noGradeTolarenceDataFound);
          }
        }
      }
    }
  }

  void clearSearch() {
    searchController.clear();
    searchAndAssignItems("");
    unFocus();
  }

  Future<void> onItemTap(PurchaseOrderItem goodsItem, int index) async {
    FinishedGoodsItemSKU? finishedGoodsItemSKU =
        appStorage.selectedItemSKUList[index];
    bool isComplete = await dao.isInspectionComplete(
        partner.id!, goodsItem.sku!, finishedGoodsItemSKU.id.toString());
    bool ispartialComplete = await dao.isInspectionPartialComplete(
        partner.id!, goodsItem.sku!, finishedGoodsItemSKU.id.toString());

    // FIXME: below
    // String current_lot_number = viewHolder.edit_LotNo.getText().toString();
    String? current_Item_SKU = goodsItem.sku;
    String? current_Item_SKU_Name = goodsItem.description;
    // String? current_pack_Date = packDate;

    Map<String, dynamic> passingData = {};

    if (!isComplete && !ispartialComplete) {
      passingData[Consts.SERVER_INSPECTION_ID] = -1;
    } else {
      // FIXME: below
      // passingData[Consts.SERVER_INSPECTION_ID] = viewHolder.inspectionId;

      passingData[Consts.SPECIFICATION_NUMBER] = specificationNumber;
      passingData[Consts.SPECIFICATION_VERSION] = specificationVersion;
      passingData[Consts.SPECIFICATION_NAME] = specificationName;
      passingData[Consts.SPECIFICATION_TYPE_NAME] = specificationTypeName;
    }

    passingData[Consts.PO_NUMBER] = poNumber;
    passingData[Consts.SEAL_NUMBER] = sealNumber;
    passingData[Consts.PARTNER_NAME] = partnerName;
    passingData[Consts.PARTNER_ID] = partnerID;
    passingData[Consts.CARRIER_NAME] = carrierName;
    passingData[Consts.CARRIER_ID] = carrierID;

    // FIXME: below
    // passingData[Consts.Lot_No] = current_lot_number;
    passingData[Consts.ITEM_SKU] = current_Item_SKU;
    passingData[Consts.ITEM_SKU_NAME] = current_Item_SKU_Name;
    // passingData[Consts.ITEM_SKU_ID] = current_Item_SKU_Id;
    // passingData[Consts.PACK_DATE] = current_pack_Date;

    passingData[Consts.COMPLETED] = isComplete;
    passingData[Consts.PARTIAL_COMPLETED] = ispartialComplete;

    // FIXME: below
    // passingData[Consts.COMMODITY_ID] = current_commodity_id;
    // passingData[Consts.COMMODITY_NAME] = current_commodity_name;
    // passingData[Consts.ITEM_UNIQUE_ID] = current_unique_id;
    // passingData[Consts.GTIN] = current_gtin;
    // passingData[Consts.PRODUCT_TRANSFER] = productTransfer;
    // passingData[Consts.DATETYPE] = dateType;

    await Get.to(
        () => QCDetailsShortFormScreen(
              partner: partner,
              carrier: carrier,
              commodity: commodity,
              qcHeaderDetails: qcHeaderDetails,
              purchaseOrderItem: goodsItem,
            ),
        arguments: passingData);
  }

  /*Future<void> onEditTap(PurchaseOrderItem goodsItem, int index) async {
    PartnerItemSKUInspections? partnerItemSKU = await dao.findPartnerItemSKU(
        partnerID,
        dataList.get(position).getSku(),
        appStorage.selectedItemSKUList.get(position).getUniqueItemId());

    Inspection? inspection =
        await dao.findInspectionByID(partnerItemSKU.getInspectionId());

    Map<String, dynamic> passingData = {
      Consts.SERVER_INSPECTION_ID: inspection.inspection_id,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME:
          appStorage.selectedItemSKUList[position].commodityName,
      Consts.COMMODITY_ID: appStorage.selectedItemSKUList[position].commodityID,
      Consts.INSPECTION_RESULT: finalInspectionResult,
      Consts.ITEM_SKU: goodsItem.sku,
      Consts.PO_NUMBER: po_number,
    };

    if (productTransfer == "Transfer") {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTableForTransfer(
              partnerID, goodsItem.sku, goodsItem.sku);
    } else {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTable(
              partnerID, goodsItem.sku, goodsItem.sku);
    }

    if (appStorage.specificationByItemSKUList != null &&
        appStorage.specificationByItemSKUList!.isNotEmpty) {
      specificationNumber =
          appStorage.specificationByItemSKUList!.first.specificationNumber;
      specificationVersion =
          appStorage.specificationByItemSKUList!.first.specificationVersion;
      specificationName =
          appStorage.specificationByItemSKUList!.first.specificationName;
      specificationTypeName =
          appStorage.specificationByItemSKUList!.first.specificationTypeName;
    }

    passingData.addAll({
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SPECIFICATION_NAME: specificationName,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.PRODUCT_TRANSFER: productTransfer,
    });

    await Get.to(
        () => QCDetailsShortFormScreen(
              partner: partner,
              carrier: carrier,
              commodity: commodity,
              qcHeaderDetails: qcHeaderDetails,
              purchaseOrderItem: goodsItem,
            ),
        arguments: passingData);
  }*/

  Future onInformationIconTap(PurchaseOrderItem goodsItem) async {
    if (productTransfer == "Transfer") {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTableForTransfer(
              partnerID!, goodsItem.sku!, goodsItem.sku!);
    } else {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTable(
              partnerID!, goodsItem.sku!, goodsItem.sku!);
    }

    if (appStorage.specificationByItemSKUList != null &&
        (appStorage.specificationByItemSKUList ?? []).isNotEmpty) {
      specificationNumber =
          appStorage.specificationByItemSKUList!.first.specificationNumber;
      specificationVersion =
          appStorage.specificationByItemSKUList!.first.specificationVersion;
      specificationName =
          appStorage.specificationByItemSKUList!.first.specificationName;
      specificationTypeName =
          appStorage.specificationByItemSKUList!.first.specificationTypeName;
    }

    await Utils().offlineLoadCommodityVarietyDocuments(
        specificationNumber ?? '', specificationVersion ?? '');

    CustomListViewDialog customDialog = CustomListViewDialog(
      Get.context!,
      (selectedValue) {},
    );
    customDialog.setCanceledOnTouchOutside(false);
    customDialog.show();
  }

  Future onEditIconTap(
      PurchaseOrderItem goodsItem,
      FinishedGoodsItemSKU finishedGoodsItemSKU,
      Inspection inspection,
      PartnerItemSKUInspections? partnerItemSKU) async {
    bool isComplete = await dao.isInspectionComplete(
        partner.id!, goodsItem.sku!, finishedGoodsItemSKU.id.toString());
    bool ispartialComplete = await dao.isInspectionPartialComplete(
        partner.id!, goodsItem.sku!, finishedGoodsItemSKU.id.toString());

    if (productTransfer == "Transfer") {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTableForTransfer(
              partnerID!, goodsItem.sku!, goodsItem.sku!);
    } else {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTable(
              partnerID!, goodsItem.sku!, goodsItem.sku!);
    }

    if (appStorage.specificationByItemSKUList != null &&
        (appStorage.specificationByItemSKUList ?? []).isNotEmpty) {
      specificationNumber =
          appStorage.specificationByItemSKUList!.first.specificationNumber;
      specificationVersion =
          appStorage.specificationByItemSKUList!.first.specificationVersion;
      specificationName =
          appStorage.specificationByItemSKUList!.first.specificationName;
      specificationTypeName =
          appStorage.specificationByItemSKUList!.first.specificationTypeName;
    }

    String? finalInspectionResult =
        await getFinalInspectionResult(inspection, partnerItemSKU);

    Map<String, dynamic> passingData = {
      Consts.SERVER_INSPECTION_ID: inspection.inspectionId,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: finishedGoodsItemSKU.commodityName,
      Consts.COMMODITY_ID: finishedGoodsItemSKU.commodityID,
      Consts.INSPECTION_RESULT: finalInspectionResult,
      Consts.ITEM_SKU: goodsItem.sku,
      Consts.PO_NUMBER: poNumber,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SPECIFICATION_NAME: specificationName,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.PRODUCT_TRANSFER: productTransfer,
      Consts.CALLER_ACTIVITY: 'PurchaseOrderDetailsActivity',
    };

    Get.to(() => const OverriddenResultScreen(), arguments: passingData);
  }

  Future<String?> getFinalInspectionResult(
      Inspection inspection, PartnerItemSKUInspections? partnerItemSKU) async {
    String? inspectionResult;
    inspectionResult = inspection.result ?? '';

    OverriddenResult? overriddenResult =
        await dao.getOverriddenResult(inspection.inspectionId!);

    if (overriddenResult != null) {
      inspectionResult = overriddenResult.overriddenResult;
      await dao.updateInspectionResult(
          inspection.inspectionId!, inspectionResult!);
    }

    if (overriddenResult != null) {
      inspectionResult = overriddenResult.overriddenResult;
      await dao.updateInspectionResult(
          inspection.inspectionId!, inspectionResult!);
    }

    if (inspectionResult != null && inspectionResult.isNotEmpty) {
      // Update UI to show result button and edit pencil
      // This will depend on your actual UI implementation

      if (inspectionResult == "RJ" || inspectionResult == "Reject") {
        // Update UI to show reject state
        // This will depend on your actual UI implementation

        QualityControlItem? qualityControlItems =
            await dao.findQualityControlDetails(partnerItemSKU!.inspectionId!);

        if (qualityControlItems != null) {
          int qtyShipped = qualityControlItems.qtyShipped ?? 0;
          int qtyRejected = qualityControlItems.qtyRejected ?? 0;

          if (qtyRejected == 0) {
            if (overriddenResult != null &&
                (overriddenResult.overriddenResult == "RJ" ||
                    overriddenResult.overriddenResult == "Reject")) {
              qtyRejected = 0;
            } else {
              qtyRejected = qtyShipped;
            }
          }

          int qtyReceived = qtyShipped - qtyRejected;

          await dao.updateQuantityRejected(
              inspection.inspectionId!, qtyRejected, qtyReceived);
        }

        // Update UI to show quantity rejected
        // This will depend on your actual UI implementation
      } else if (inspectionResult == "AC" || inspectionResult == "Accept") {
        // Update UI to show accept state
        // This will depend on your actual UI implementation
      } else if (inspectionResult == "A-") {
        // Update UI to show A- state
        // This will depend on your actual UI implementation
      } else if (inspectionResult == "AW" ||
          inspectionResult == "Accept Condition") {
        // Update UI to show AW state
        // This will depend on your actual UI implementation
      }
    }

    String? finalInspectionResult = inspectionResult;

    return finalInspectionResult;
  }

  Future onInspectTap(
    PurchaseOrderItem goodsItem,
    FinishedGoodsItemSKU finishedGoodsItemSKU,
    Inspection inspection,
    PartnerItemSKUInspections? partnerItemSKU,
    String lotNo,
    String packDate,
    bool isComplete,
    bool ispartialComplete,
    int inspectionId,
    String po_number,
    String seal_number,
    Function(Map data) poInterface,
  ) async {
    bool checkItemSKUAndLot =
        await dao.checkItemSKUAndLotNo(goodsItem.sku!, lotNo);
    checkItemSKUAndLot = false;
    bool isValid = true;

    if (isComplete) {
      for (int i = 0; i < appStorage.selectedItemSKUList.length; i++) {
        FinishedGoodsItemSKU finishedGoodsItemSKU =
            appStorage.selectedItemSKUList[i];
        bool isComplete = await dao.isInspectionComplete(partnerID!,
            finishedGoodsItemSKU.sku!, finishedGoodsItemSKU.uniqueItemId);

        if (isComplete) {
          PartnerItemSKUInspections? partnerItemSKU =
              await dao.findPartnerItemSKU(partnerID!,
                  finishedGoodsItemSKU.sku!, finishedGoodsItemSKU.uniqueItemId);

          if (partnerItemSKU != null) {
            Inspection? inspection =
                await dao.findInspectionByID(partnerItemSKU.inspectionId!);
            QualityControlItem? qualityControlItems = await dao
                .findQualityControlDetails(partnerItemSKU.inspectionId!);

            if (inspection != null &&
                inspection.result != null &&
                inspection.result == "RJ") {
              if (qualityControlItems?.qtyRejected != null &&
                      qualityControlItems?.qtyShipped != null &&
                      qualityControlItems!.qtyRejected == 0 ||
                  qualityControlItems!.qtyRejected! >
                      qualityControlItems.qtyShipped!) {
                isValid = false;

                AppAlertDialog.validateAlerts(Get.context!, AppStrings.alert,
                    AppStrings.quantityRejected);
              }
            }
          }
        }
      }
    }

    if (isValid) {
      if (isComplete || ispartialComplete || !checkItemSKUAndLot) {
        String current_lot_number = lotNo;
        String current_Item_SKU = goodsItem.sku!;
        String current_Item_SKU_Name = goodsItem.description!;
        String current_pack_Date = packDate;
        int current_Item_SKU_Id = finishedGoodsItemSKU.id!;
        String current_unique_id = finishedGoodsItemSKU.uniqueItemId!;
        int current_commodity_id = finishedGoodsItemSKU.commodityID!;
        String current_commodity_name = finishedGoodsItemSKU.commodityName!;
        String current_gtin = finishedGoodsItemSKU.gtin!;
        String dateType = finishedGoodsItemSKU.dateType!;

        if (poInterface != null) {
          Map<String, dynamic> bundle = {
            Consts.Lot_No: current_lot_number,
            Consts.ITEM_SKU: current_Item_SKU,
            Consts.ITEM_SKU_NAME: current_Item_SKU_Name,
            Consts.PACK_DATE: current_pack_Date,
            Consts.ITEM_SKU_ID: current_Item_SKU_Id,
            Consts.ITEM_UNIQUE_ID: current_unique_id,
            Consts.GTIN: current_gtin,
            Consts.DATETYPE: dateType,
            Consts.COMMODITY_ID: current_commodity_id,
            Consts.COMMODITY_NAME: current_commodity_name,
          };
          poInterface!(bundle);
        }

        if (!isComplete && !ispartialComplete) {
          finishedGoodsItemSKU.lotNo = current_lot_number;
          finishedGoodsItemSKU.poNo = goodsItem.poNumber;
        }

        bool isOnline = globalConfigController.hasStableInternet.value;

        if (productTransfer == "Transfer") {
          appStorage.specificationByItemSKUList =
              await dao.getSpecificationByItemSKUFromTableForTransfer(
                  partnerID!, goodsItem.sku!, goodsItem.sku!);
        } else {
          appStorage.specificationByItemSKUList =
              await dao.getSpecificationByItemSKUFromTable(
                  partnerID!, goodsItem.sku!, goodsItem.sku!);
        }

        if (appStorage.specificationByItemSKUList != null &&
            appStorage.specificationByItemSKUList!.isNotEmpty) {
          bool isComplete = await dao.isInspectionComplete(
              partnerID!, current_Item_SKU, current_unique_id);
          bool ispartialComplete = await dao.isInspectionPartialComplete(
              partnerID!, current_Item_SKU, current_unique_id);

          Map<String, dynamic> passigData = {};
          if (!isComplete && !ispartialComplete) {
            passigData[Consts.SERVER_INSPECTION_ID] = -1;
          } else {
            passigData[Consts.SERVER_INSPECTION_ID] = inspectionId;
            passigData[Consts.SPECIFICATION_NUMBER] = specificationNumber;
            passigData[Consts.SPECIFICATION_VERSION] = specificationVersion;
            passigData[Consts.SPECIFICATION_NAME] = specificationName;
            passigData[Consts.SPECIFICATION_TYPE_NAME] = specificationTypeName;
          }
          passigData[Consts.PO_NUMBER] = po_number;
          passigData[Consts.SEAL_NUMBER] = seal_number;
          passigData[Consts.PARTNER_NAME] = partnerName;
          passigData[Consts.PARTNER_ID] = partnerID;
          passigData[Consts.CARRIER_NAME] = carrierName;
          passigData[Consts.CARRIER_ID] = carrierID;
          passigData[Consts.Lot_No] = current_lot_number;
          passigData[Consts.ITEM_SKU] = current_Item_SKU;
          passigData[Consts.ITEM_SKU_NAME] = current_Item_SKU_Name;
          passigData[Consts.ITEM_SKU_ID] = current_Item_SKU_Id;
          passigData[Consts.PACK_DATE] = current_pack_Date;
          passigData[Consts.COMPLETED] = isComplete;
          passigData[Consts.PARTIAL_COMPLETED] = ispartialComplete;
          passigData[Consts.COMMODITY_ID] = current_commodity_id;
          passigData[Consts.COMMODITY_NAME] = current_commodity_name;
          passigData[Consts.ITEM_UNIQUE_ID] = current_unique_id;
          passigData[Consts.GTIN] = current_gtin;
          passigData[Consts.PRODUCT_TRANSFER] = productTransfer;
          passigData[Consts.DATETYPE] = dateType;

          Get.to(
            () => QCDetailsShortFormScreen(
              partner: partner,
              carrier: carrier,
              commodity: commodity,
              qcHeaderDetails: qcHeaderDetails,
              purchaseOrderItem: goodsItem,
            ),
            arguments: passigData,
          );
        } else {
          AppAlertDialog.validateAlerts(Get.context!, AppStrings.alert,
              'No specification alert for $current_Item_SKU');
        }
      } else {
        AppAlertDialog.validateAlerts(
            Get.context!, AppStrings.alert, 'Lot number alert');
      }
    }
  }
}
