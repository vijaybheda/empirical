import 'dart:developer';

import 'package:flutter/cupertino.dart';
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
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_grade_tolerance.dart';
import 'package:pverify/models/specification_grade_tolerance_array.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/commodity/commodity_id_screen.dart';
import 'package:pverify/ui/commodity_transfer/commodity_transfer_screen.dart';
import 'package:pverify/ui/overridden_result/overridden_result_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_screen.dart';
import 'package:pverify/ui/purchase_order_cte/purchase_order_screen_cte.dart';
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';
import 'package:pverify/ui/trailer_temp/trailertemp.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/dialogs/custom_listview_dialog.dart';
import 'package:pverify/utils/utils.dart';

class PurchaseOrderDetailsController extends GetxController {
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
      productTransfer;
  int? itemSkuId;
  bool isGTINSamePartner = true;
  String callerActivity = '';

  PurchaseOrderDetailsController();

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }

    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    poNumber = args[Consts.PO_NUMBER] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    currentLotNumber = args[Consts.LOT_NO] ?? '';
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

    dao
        .getSelectedItemSKUList()
        .then((List<FinishedGoodsItemSKU> selectedItemSKUList) {
      appStorage.selectedItemSKUList = selectedItemSKUList;
      Future.delayed(const Duration(milliseconds: 100))
          .then((value) => update());
    });
    super.onInit();
    initAsyncActions();
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
        String searchKey = searchValue.toLowerCase();

        return (sku != null && sku.toLowerCase().contains(searchKey)) ||
            (description != null &&
                description.toLowerCase().contains(searchKey));
      }).toList();
      filteredInspectionsList.addAll(items);
    }
    update();
  }

  List<PurchaseOrderItem> getPurchaseOrderData() {
    List<PurchaseOrderItem> list = [];

    for (FinishedGoodsItemSKU item in (selectedItemSKUList)) {
      PurchaseOrderItem newData = PurchaseOrderItem.newData(
          item.name,
          item.sku,
          item.poNo,
          "",
          item.lotNo,
          item.commodityID,
          item.commodityName,
          item.packDate,
          item.FTLflag,
          item.Branded);
      list.add(newData);
    }
    return list;
  }

  Future<void> calculateButtonClick(BuildContext context) async {
    String itemsSpecStr = "";
    String result = "";

    List<SpecificationGradeToleranceArray>
        specificationGradeToleranceArrayList = [];
    for (int i = 0; i < selectedItemSKUList.length; i++) {
      bool isComplete = await dao.isInspectionComplete(partnerID!,
          selectedItemSKUList[i].sku!, selectedItemSKUList[i].uniqueItemId);

      if (isComplete) {
        PartnerItemSKUInspections? partnerItemSKU =
            await dao.findPartnerItemSKU(
                partnerID!,
                selectedItemSKUList[i].sku!,
                selectedItemSKUList[i].uniqueItemId);
        if (partnerItemSKU != null) {
          Inspection? inspection =
              await dao.findInspectionByID(partnerItemSKU.inspectionId!);
          if (inspection != null && inspection.inspectionId != null) {
            await dao
                .deleteRejectionDetailByInspectionId(inspection.inspectionId!);

            QCHeaderDetails? qcHeaderDetails =
                await dao.findTempQCHeaderDetails(inspection.poNumber!);

            if (qcHeaderDetails != null &&
                qcHeaderDetails.truckTempOk == 'No') {
              result = "RJ";

              QualityControlItem? qualityControlItems = await dao
                  .findQualityControlDetails(partnerItemSKU.inspectionId!);

              if (qualityControlItems != null) {
                await dao.updateQuantityRejected(inspection.inspectionId!,
                    qualityControlItems.qtyShipped!, 0);
              }

              await dao.updateInspectionResult(
                  inspection.inspectionId!, result);
              await dao.updateOverriddenResult(
                  inspection.inspectionId!, result);

              await dao.createOrUpdateInspectionSpecification(
                  inspection.inspectionId!,
                  specificationNumber,
                  specificationVersion,
                  specificationName);

              await dao.updateInspectionComplete(
                  inspection.inspectionId!, true);
              await dao.updateItemSKUInspectionComplete(
                  inspection.inspectionId!, true);
              Utils.setInspectionUploadStatus(
                  inspection.inspectionId!, Consts.INSPECTION_UPLOAD_READY);

              await dao.createOrUpdateResultReasonDetails(
                  inspection.inspectionId!, result, "Truck Temp Ok = No", "");

              // footerRightButtonText.visibility = Visibility.visible;
              // itemAdapter.notifyDataSetChanged();
              update();
            } else {
              try {
                itemsSpecStr +=
                    "${inspection.specificationNumber!}:${inspection.specificationVersion!},";

                List<SpecificationGradeTolerance>
                    specificationGradeToleranceList =
                    await dao.getSpecificationGradeTolerance(
                        inspection.specificationNumber!,
                        inspection.specificationVersion!);
                specificationGradeToleranceArrayList
                    .add(SpecificationGradeToleranceArray(
                  specificationNumber: inspection.specificationNumber,
                  specificationVersion: inspection.specificationVersion,
                  specificationGradeToleranceList:
                      specificationGradeToleranceList,
                ));
              } catch (e) {
                log(e.toString());
              }
            }
          }
        }
      }
    }
    if (result != "RJ") {
      if (itemsSpecStr.isNotEmpty && itemsSpecStr.endsWith(",")) {
        itemsSpecStr = itemsSpecStr.substring(0, itemsSpecStr.length - 1);

        appStorage.specificationGradeToleranceArrayList =
            specificationGradeToleranceArrayList;
        listAssigned.value = false;
        update();
        await calculateResult();

        listAssigned.value = true;
        update();
      } else {
        AppSnackBar.info(message: AppStrings.noItemsCompleted);
      }
    }
  }

  Future<void> calculateResult() async {
    int totalQualityDefectId = 0;
    int totalConditionDefectId = 0;

    try {
      for (int i = 0; i < selectedItemSKUList.length; i++) {
        FinishedGoodsItemSKU itemSKU = selectedItemSKUList.elementAt(i);
        bool isComplete = await dao.isInspectionComplete(
            partnerID!, itemSKU.sku!, itemSKU.uniqueItemId);

        if (isComplete) {
          PartnerItemSKUInspections? partnerItemSKU =
              await dao.findPartnerItemSKU(
                  partnerID!, itemSKU.sku!, itemSKU.uniqueItemId);

          if (partnerItemSKU != null) {
            Inspection? inspection =
                await dao.findInspectionByID(partnerItemSKU.inspectionId!);
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
                if ((specificationGradeToleranceArrayList[abc]
                            .specificationNumber ==
                        specificationNumber) &&
                    (specificationGradeToleranceArrayList[abc]
                            .specificationVersion ==
                        specificationVersion)) {
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

            if ((!(specificationTypeName!.toLowerCase() ==
                    ("Finished Goods Produce".toLowerCase())) &&
                !(specificationTypeName!.toLowerCase() ==
                    ("Raw Produce".toLowerCase())))) {
              if (appStorage.specificationAnalyticalList != null) {
                for (SpecificationAnalytical item
                    in (appStorage.specificationAnalyticalList ?? [])) {
                  SpecificationAnalyticalRequest? dbobj =
                      await dao.findSpecAnalyticalObj(
                          inspection.inspectionId!, item.analyticalID!);
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
                      int resultReason =
                          await dao.createOrUpdateResultReasonDetails(
                              inspection.inspectionId!,
                              result,
                              "${dbobj.analyticalName} = N",
                              dbobj.comment ?? '');
                      int isPictureReqSpec =
                          await dao.createIsPictureReqSpecAttribute(
                        inspection.inspectionId!,
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
                }
              }

              if (result == "A-" || result == "AC") {
                QualityControlItem? qualityControlItems = await dao
                    .findQualityControlDetails(inspection.inspectionId!);

                if (qualityControlItems != null) {
                  bool isQuantityRejected = await dao.updateQuantityRejected(
                      inspection.inspectionId!,
                      0,
                      qualityControlItems.qtyShipped!);
                }
              }
              /*else {
                QualityControlItem? qualityControlItems = await dao
                    .findQualityControlDetails(inspection.inspectionId!);

                if (qualityControlItems != null) {
                  await dao.updateQuantityRejected(inspection.inspectionId!,
                      qualityControlItems.qtyShipped!, 0);
                }
              }*/
              int inspectionResult = await dao.updateInspectionResult(
                  inspection.inspectionId!, result);
              int inspectionSpecification =
                  await dao.createOrUpdateInspectionSpecification(
                      inspection.inspectionId!,
                      specificationNumber,
                      specificationVersion,
                      specificationName);

              int inspectionComplete = await dao.updateInspectionComplete(
                  inspection.inspectionId!, true);

              bool updateItemSKU = await dao.updateItemSKUInspectionComplete(
                  inspection.inspectionId!, true);
              Utils.setInspectionUploadStatus(
                  inspection.inspectionId!, Consts.INSPECTION_UPLOAD_READY);
              update();
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
              if (appStorage.defectCategoriesList != null) {
                for (DefectCategories defectCategory
                    in appStorage.defectCategoriesList ?? []) {
                  if (defectCategory.name?.toLowerCase() ==
                          "quality".toLowerCase() &&
                      (defectCategory.defectList != null)) {
                    for (DefectItem defectItem
                        in defectCategory.defectList ?? []) {
                      if (defectItem.name?.contains("Total Quality") ?? false) {
                        totalQualityDefectId = defectItem.id ?? 0;
                        break;
                      }
                    }
                  } else if (defectCategory.name?.toLowerCase() ==
                          "condition".toLowerCase() &&
                      (defectCategory.defectList != null)) {
                    for (DefectItem defectItem
                        in defectCategory.defectList ?? []) {
                      if (defectItem.name?.contains("Total Condition") ??
                          false) {
                        totalConditionDefectId = defectItem.id ?? 0;
                        break;
                      }
                    }
                  }
                }
              }

              for (int n = 0;
                  n < appStorage.specificationGradeToleranceList!.length;
                  n++) {
                SpecificationGradeTolerance gradeTolerance =
                    appStorage.specificationGradeToleranceList!.elementAt(n);

                double specTolerancePercentage =
                    gradeTolerance.specTolerancePercentage?.toDouble() ?? 0.0;
                int? defectID = gradeTolerance.defectID;
                int? severityDefectID = gradeTolerance.severityDefectID;
                String tempSeverityDefectName = "";
                String defectName = gradeTolerance.defectName ?? '';

                if (appStorage.severityDefectsList != null) {
                  for (int m = 0;
                      m < appStorage.severityDefectsList!.length;
                      m++) {
                    if ((severityDefectID != null) &&
                        severityDefectID ==
                            appStorage.severityDefectsList!.elementAt(m).id) {
                      tempSeverityDefectName =
                          appStorage.severityDefectsList!.elementAt(m).name ??
                              '';
                      break;
                    }
                  }
                }

                int totalcount = 0;
                bool iscalculated = false;
                int totalQualitycount = 0;
                int totalQualityInjury = 0;
                int totalQualityDamage = 0;
                int totalQualitySeriousDamage = 0;
                int totalQualityVerySeriousDamage = 0;
                int totalQualityDecay = 0;

                int totalSize = 0;
                int totalColor = 0;

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

                String defectsNameResultReason = "";

                if (samples.isNotEmpty) {
                  for (int f = 0; f < samples.length; f++) {
                    List<InspectionDefect> defectList = await dao
                        .findInspectionDefects(samples.elementAt(f).sampleId!);
                    String sizeDefectName = '';
                    String colorDefectName = '';

                    if (defectList.isNotEmpty) {
                      if (defectID == null || defectID == 0) {
                        for (int k = 0; k < defectList.length; k++) {
                          if ((defectList
                                      .elementAt(k)
                                      .defectCategory
                                      ?.toLowerCase() ==
                                  "quality") ||
                              (defectList
                                      .elementAt(k)
                                      .defectCategory
                                      ?.toLowerCase() ==
                                  "condition")) {
                            if (defectList.elementAt(k).verySeriousDamageCnt! >
                                0) {
                              if (tempSeverityDefectName ==
                                  "Very Serious Damage") {
                                totalcount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                totalSeverityVerySeriousDamage += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                iscalculated = true;
                              }
                            }
                            if (defectList.elementAt(k).seriousDamageCnt! > 0) {
                              if (tempSeverityDefectName == "Serious Damage") {
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
                                  totalSeveritySeriousDamage += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
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

                        if (result != "RJ" &&
                            tempSeverityDefectName == "Very Serious Damage") {
                          double vsdpercent =
                              (totalSeverityVerySeriousDamage * 100)
                                      .toDouble() /
                                  totalSampleSize;
                          if (vsdpercent > specTolerancePercentage) {
                            result = "RJ";
                            //rejectReason += "Total Severity VSD % exceeds tolerance";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
                                result,
                                "Total Severity VSD % exceeds tolerance",
                                "");
                            break;
                          } else if ((vsdpercent >
                                  specTolerancePercentage / 2) &&
                              (vsdpercent <= specTolerancePercentage)) {
                            result = "A-";
                          }
                        }

                        if (tempSeverityDefectName == "Very Serious Damage") {
                          double vsdpercent =
                              (totalSeverityVerySeriousDamage * 100)
                                      .toDouble() /
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
                                inspection.inspectionId!,
                                "RJ",
                                rejectReason,
                                "");
                          }
                        }

                        if (result != "RJ" &&
                            tempSeverityDefectName == "Serious Damage") {
                          double sdpercent =
                              (totalSeveritySeriousDamage * 100).toDouble() /
                                  totalSampleSize;
                          if (sdpercent > specTolerancePercentage) {
                            result = "RJ";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
                                result,
                                " Total Severity SD % exceeds tolerance",
                                "");
                          } else if ((sdpercent >
                                  specTolerancePercentage / 2) &&
                              (sdpercent <= specTolerancePercentage)) {
                            result = "A-";
                          }
                        }

                        if (tempSeverityDefectName == "Serious Damage") {
                          double sdpercent =
                              (totalSeveritySeriousDamage * 100).toDouble() /
                                  totalSampleSize;
                          if (sdpercent > specTolerancePercentage) {
                            if (rejectReason != "") {
                              rejectReason += ", ";
                            }
                            rejectReasonArray
                                .add("Total Severity SD % exceeds tolerance");

                            rejectReason +=
                                " Total Severity SD % exceeds tolerance";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
                                "RJ",
                                rejectReason,
                                "");
                          }
                        }

                        if (result != "RJ" &&
                            tempSeverityDefectName == "Damage") {
                          double dpercent =
                              (totalSeverityDamage * 100).toDouble() /
                                  totalSampleSize;
                          if (dpercent > specTolerancePercentage) {
                            result = "RJ";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
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
                              (totalSeverityDamage * 100).toDouble() /
                                  totalSampleSize;
                          if (dpercent > specTolerancePercentage) {
                            if (rejectReason != "") {
                              rejectReason += ", ";
                            }
                            rejectReasonArray.add(
                                "Total Severity Damage % exceeds tolerance");

                            rejectReason +=
                                " Total Severity Damage % exceeds tolerance";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
                                "RJ",
                                rejectReason,
                                "");
                          }
                        }

                        if (result != "RJ" &&
                            tempSeverityDefectName == "Injury") {
                          double ipercent =
                              (totalSeverityInjury * 100).toDouble() /
                                  totalSampleSize;
                          if (ipercent > specTolerancePercentage) {
                            result = "RJ";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
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
                              (totalSeverityInjury * 100).toDouble() /
                                  totalSampleSize;
                          if (ipercent > specTolerancePercentage) {
                            if (rejectReason != "") {
                              rejectReason += ", ";
                            }
                            rejectReasonArray.add(
                                "Total Severity Injury % exceeds tolerance");

                            rejectReason +=
                                "Total Severity Injury % exceeds tolerance";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
                                "RJ",
                                rejectReason,
                                "");
                          }
                        }

                        if (result != "RJ" &&
                            tempSeverityDefectName == "Decay") {
                          double depercent =
                              (totalSeverityDecay * 100).toDouble() /
                                  totalSampleSize;
                          if (depercent > specTolerancePercentage) {
                            result = "RJ";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
                                result,
                                " Total Severity Decay % exceeds tolerance",
                                "");
                          } else if ((depercent >
                                  specTolerancePercentage / 2) &&
                              (depercent <= specTolerancePercentage)) {
                            result = "A-";
                          }
                        }

                        if (tempSeverityDefectName == "Decay") {
                          double depercent =
                              (totalSeverityDecay * 100).toDouble() /
                                  totalSampleSize;
                          if (depercent > specTolerancePercentage) {
                            if (rejectReason != "") {
                              rejectReason += ", ";
                            }
                            rejectReasonArray.add(
                                "Total Severity Decay % exceeds tolerance");

                            rejectReason +=
                                " Total Severity Decay % exceeds tolerance";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
                                "RJ",
                                rejectReason,
                                "");
                          }
                        }

                        if (result != "RJ" && tempSeverityDefectName == "") {
                          // double qualpercentage =
                          //     (totalcount * 100) / totalSampleSize;
                          double qualpercentage =
                              ((totalcount / totalSampleSize) * 100);
                          if (qualpercentage > specTolerancePercentage) {
                            result = "RJ";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
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
                              ((totalcount * 100) / totalSampleSize)
                                  .roundToDouble();
                          if (qualpercentage > specTolerancePercentage) {
                            if (rejectReason != "") {
                              rejectReason += ", ";
                            }
                            rejectReasonArray
                                .add("Total Severity % exceeds tolerance");

                            rejectReason +=
                                "Total Severity % exceeds tolerance";
                            await dao.createOrUpdateResultReasonDetails(
                                inspection.inspectionId!,
                                "RJ",
                                rejectReason,
                                "");
                          }
                        }
                      } else {
                        for (int k = 0; k < defectList.length; k++) {
                          if (defectList
                                      .elementAt(k)
                                      .defectCategory
                                      ?.toLowerCase() ==
                                  "quality" ||
                              defectList
                                      .elementAt(k)
                                      .defectCategory
                                      ?.toLowerCase() ==
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

                                  if (defectList
                                          .elementAt(k)
                                          .defectCategory
                                          ?.toLowerCase() ==
                                      "quality") {
                                    totalQualitycount += defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!;
                                    totalQualityVerySeriousDamage += defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!;
                                  } else if (defectList
                                          .elementAt(k)
                                          .defectCategory
                                          ?.toLowerCase() ==
                                      "condition") {
                                    totalConditionCount += defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!;
                                    totalConditionVerySeriousDamage +=
                                        defectList
                                            .elementAt(k)
                                            .verySeriousDamageCnt!;
                                  }

                                  if (result != "RJ") {
                                    double vsdpercent =
                                        (totalQualityVerySeriousDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection.inspectionId!,
                                          result,
                                          "$defectNameResult - Quality (VSD)  % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }

                                  double vsdpercent1 =
                                      (totalQualityVerySeriousDamage * 100)
                                              .toDouble() /
                                          totalSampleSize;

                                  if (result != "RJ") {
                                    double vsdpercent =
                                        (totalConditionVerySeriousDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection.inspectionId!,
                                          result,
                                          "$defectNameResult - Condition (VSD)  % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }

                                  double vsdpercent2 =
                                      (totalConditionVerySeriousDamage * 100)
                                              .toDouble() /
                                          totalSampleSize;
                                }
                              }
                              if (tempSeverityDefectName == "Serious Damage") {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    0) {
                                  if (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! >
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

                                    if (defectList
                                            .elementAt(k)
                                            .defectCategory
                                            ?.toLowerCase() ==
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
                                            .defectCategory
                                            ?.toLowerCase() ==
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
                                          (totalQualitySeriousDamage * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao.createOrUpdateResultReasonDetails(
                                            inspection.inspectionId!,
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
                                        (totalQualitySeriousDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (result != "RJ") {
                                      double vsdpercent =
                                          (totalConditionSeriousDamage * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao.createOrUpdateResultReasonDetails(
                                            inspection.inspectionId!,
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
                                        (totalConditionSeriousDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                  }
                                }
                              }
                              if (tempSeverityDefectName == "Damage") {
                                if (defectList.elementAt(k).damageCnt! > 0) {
                                  if (defectList.elementAt(k).damageCnt! >
                                      defectList
                                          .elementAt(k)
                                          .seriousDamageCnt!) {
                                    totalcount +=
                                        (defectList.elementAt(k).damageCnt! -
                                            defectList
                                                .elementAt(k)
                                                .seriousDamageCnt!);
                                    iscalculated = true;
                                    if (defectList
                                            .elementAt(k)
                                            .defectCategory
                                            ?.toLowerCase() ==
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
                                            .defectCategory
                                            ?.toLowerCase() ==
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
                                      (totalQualityDamage * 100).toDouble() /
                                          totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
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
                                    (totalQualityDamage * 100).toDouble() /
                                        totalSampleSize;
                                if (result != "RJ") {
                                  double vsdpercent =
                                      (totalConditionDamage * 100).toDouble() /
                                          totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
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
                                    (totalConditionDamage * 100).toDouble() /
                                        totalSampleSize;
                              }
                              if (tempSeverityDefectName == "Injury") {
                                if (defectList.elementAt(k).injuryCnt! > 0) {
                                  if (defectList.elementAt(k).injuryCnt! >
                                      defectList.elementAt(k).damageCnt!) {
                                    totalcount +=
                                        (defectList.elementAt(k).injuryCnt! -
                                            defectList.elementAt(k).damageCnt!);
                                    iscalculated = true;
                                    if (defectList
                                            .elementAt(k)
                                            .defectCategory
                                            ?.toLowerCase() ==
                                        "quality") {
                                      totalQualitycount += defectList
                                              .elementAt(k)
                                              .injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                      totalQualityInjury += defectList
                                              .elementAt(k)
                                              .injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                    } else if (defectList
                                            .elementAt(k)
                                            .defectCategory
                                            ?.toLowerCase() ==
                                        "condition") {
                                      totalConditionCount += defectList
                                              .elementAt(k)
                                              .injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                      totalConditionInjury += defectList
                                              .elementAt(k)
                                              .injuryCnt! -
                                          defectList.elementAt(k).damageCnt!;
                                    }

                                    if (result != "RJ") {
                                      double vsdpercent =
                                          (totalQualityInjury * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao.createOrUpdateResultReasonDetails(
                                            inspection.inspectionId!,
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
                                    double vsdpercent7 =
                                        (totalQualityInjury * 100).toDouble() /
                                            totalSampleSize;

                                    if (result != "RJ") {
                                      double vsdpercent =
                                          (totalConditionInjury * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao.createOrUpdateResultReasonDetails(
                                            inspection.inspectionId!,
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

                                    double vsdpercent8 =
                                        (totalConditionInjury * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                  }
                                }
                              }
                              if (tempSeverityDefectName == "Decay") {
                                if (defectList.elementAt(k).decayCnt! > 0) {
                                  totalcount +=
                                      defectList.elementAt(k).decayCnt!;
                                  iscalculated = true;
                                  if (defectList
                                          .elementAt(k)
                                          .defectCategory
                                          ?.toLowerCase() ==
                                      "quality") {
                                    totalQualitycount +=
                                        defectList.elementAt(k).decayCnt!;
                                    totalQualityDecay +=
                                        defectList.elementAt(k).decayCnt!;
                                  } else if (defectList
                                          .elementAt(k)
                                          .defectCategory
                                          ?.toLowerCase() ==
                                      "condition") {
                                    totalConditionCount +=
                                        defectList.elementAt(k).decayCnt!;
                                    totalConditionDecay +=
                                        defectList.elementAt(k).decayCnt!;
                                  }

                                  if (result != "RJ") {
                                    double vsdpercent =
                                        (totalQualityDecay * 100).toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection.inspectionId!,
                                          result,
                                          "$defectNameResult - Quality (Decay)  % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }
                                  double vsdpercent9 =
                                      (totalQualityDecay * 100).toDouble() /
                                          totalSampleSize;

                                  if (result != "RJ") {
                                    double vsdpercent =
                                        (totalConditionDecay * 100).toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection.inspectionId!,
                                          result,
                                          "$defectNameResult - Condition (Decay)  % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }
                                  double vsdpercent10 =
                                      (totalConditionDecay * 100).toDouble() /
                                          totalSampleSize;
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
                                  if (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! >
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
                                      defectList
                                          .elementAt(k)
                                          .seriousDamageCnt!) {
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
                                  totalcount +=
                                      defectList.elementAt(k).decayCnt!;
                                }
                                iscalculated = true;

                                if (result != "RJ") {
                                  double qualpercentage =
                                      (totalcount * 100).toDouble() /
                                          totalSampleSize;
                                  if (qualpercentage >
                                      specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
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
                                    (totalcount * 100).toDouble() /
                                        totalSampleSize;
                              }
                            } else if (defectName == "Total Quality (%)" &&
                                (defectList
                                        .elementAt(k)
                                        .defectCategory
                                        ?.toLowerCase() ==
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
                                        (totalQualityVerySeriousDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao.createOrUpdateResultReasonDetails(
                                          inspection.inspectionId!,
                                          result,
                                          "Total Quality - (VSD) % exceeds tolerance",
                                          defectList.elementAt(k).comment ??
                                              "");
                                    } else if ((vsdpercent >
                                            specTolerancePercentage / 2) &&
                                        (vsdpercent <=
                                            specTolerancePercentage)) {
                                      result = "A-";
                                    }
                                  }

                                  double vsdpercent11 =
                                      (totalQualityVerySeriousDamage * 100)
                                              .toDouble() /
                                          totalSampleSize;
                                  if (vsdpercent11 > specTolerancePercentage) {
                                    if (rejectReason != "") {
                                      rejectReason += ", ";
                                    }

                                    rejectReasonArray.add(
                                        "Total Quality - (VSD) % exceeds tolerance");

                                    rejectReason +=
                                        "Total Quality - (VSD) % exceeds tolerance";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
                                        "RJ",
                                        rejectReason,
                                        defectList.elementAt(k).comment ?? "");
                                  }
                                }
                              }
                              if (tempSeverityDefectName == "Serious Damage") {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    0) {
                                  if (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! >
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
                                          (totalQualitySeriousDamage * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao.createOrUpdateResultReasonDetails(
                                            inspection.inspectionId!,
                                            result,
                                            "Total Quality - (SD) % exceeds tolerance",
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
                                        (totalQualitySeriousDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent12 >
                                        specTolerancePercentage) {
                                      if (rejectReason != "") {
                                        rejectReason += ", ";
                                      }
                                      rejectReasonArray.add(
                                          "Total Quality - (SD) % exceeds tolerance");

                                      rejectReason +=
                                          "Total Quality - (SD) % exceeds tolerance";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              "RJ",
                                              rejectReason,
                                              defectList.elementAt(k).comment ??
                                                  "");
                                    }
                                  }
                                }
                              }
                              if (tempSeverityDefectName == "Damage") {
                                if (defectList.elementAt(k).damageCnt! > 0) {
                                  if (defectList.elementAt(k).damageCnt! >
                                      defectList
                                          .elementAt(k)
                                          .seriousDamageCnt!) {
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

                                    if (result != "RJ") {
                                      double vsdpercent =
                                          (totalQualityDamage * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao.createOrUpdateResultReasonDetails(
                                            inspection.inspectionId!,
                                            result,
                                            "Total Quality - (Damage) % exceeds tolerance",
                                            defectList.elementAt(k).comment ??
                                                "");
                                      } else if ((vsdpercent >
                                              specTolerancePercentage / 2) &&
                                          (vsdpercent <=
                                              specTolerancePercentage)) {
                                        result = "A-";
                                      }
                                    }

                                    double vsdpercent13 =
                                        (totalQualityDamage * 100).toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent13 >
                                        specTolerancePercentage) {
                                      if (rejectReason != "") {
                                        rejectReason += ", ";
                                      }
                                      rejectReasonArray.add(
                                          "Total Quality - (Damage) % exceeds tolerance");

                                      rejectReason +=
                                          "Total Quality - (Damage) % exceeds tolerance";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              "RJ",
                                              rejectReason,
                                              defectList.elementAt(k).comment ??
                                                  "");
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
                                      double vsdpercent =
                                          (totalQualityInjury * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao
                                            .createOrUpdateResultReasonDetails(
                                                inspection.inspectionId!,
                                                result,
                                                "Total Quality - (Injury) " +
                                                    " % exceeds tolerance",
                                                defectList
                                                        .elementAt(k)
                                                        .comment ??
                                                    "");
                                      } else if ((vsdpercent >
                                              specTolerancePercentage / 2) &&
                                          (vsdpercent <=
                                              specTolerancePercentage)) {
                                        result = "A-";
                                      }
                                    }

                                    double vsdpercent14 =
                                        (totalQualityInjury * 100).toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent14 >
                                        specTolerancePercentage) {
                                      if (rejectReason != "") {
                                        rejectReason += ", ";
                                      }
                                      rejectReasonArray.add(
                                          "Total Quality - (Injury) " +
                                              " % exceeds tolerance");

                                      rejectReason +=
                                          "Total Quality - (Injury) " +
                                              " % exceeds tolerance";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              "RJ",
                                              rejectReason,
                                              defectList.elementAt(k).comment ??
                                                  "");
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
                                        (totalQualityDecay * 100).toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              result,
                                              "Total Quality - (Decay) " +
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
                                  double vsdpercent15 =
                                      (totalQualityDecay * 100).toDouble() /
                                          totalSampleSize;
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
                                        inspection.inspectionId!,
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
                                  if (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! >
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
                                      defectList
                                          .elementAt(k)
                                          .seriousDamageCnt!) {
                                    totalQualitycount +=
                                        defectList.elementAt(k).damageCnt! -
                                            defectList
                                                .elementAt(k)
                                                .seriousDamageCnt!;
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
                                      (totalQualitycount * 100).toDouble() /
                                          totalSampleSize;
                                  if (totalqualitypercent >
                                      specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
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
                                    (totalQualitycount * 100).toDouble() /
                                        totalSampleSize;
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
                                      inspection.inspectionId!,
                                      result,
                                      rejectReason,
                                      defectList.elementAt(k).comment ?? "");
                                }
                              }
                              iscalculated = true;
                            } else if (defectList
                                        .elementAt(k)
                                        .defectCategory
                                        ?.toLowerCase() ==
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
                                        (totalConditionVerySeriousDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              result,
                                              "Total Condition - (VSD) " +
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
                                  double vsdpercentT =
                                      (totalConditionVerySeriousDamage * 100)
                                              .toDouble() /
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
                                        inspection.inspectionId!,
                                        "RJ",
                                        rejectReason,
                                        defectList.elementAt(k).comment ?? "");
                                  }
                                }
                              }
                              if (tempSeverityDefectName == "Serious Damage") {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    0) {
                                  if (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! >
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
                                          (totalConditionSeriousDamage * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao
                                            .createOrUpdateResultReasonDetails(
                                                inspection.inspectionId!,
                                                result,
                                                "Total Condition - (SD) " +
                                                    " % exceeds tolerance",
                                                defectList
                                                        .elementAt(k)
                                                        .comment ??
                                                    "");
                                      } else if ((vsdpercent >
                                              specTolerancePercentage / 2) &&
                                          (vsdpercent <=
                                              specTolerancePercentage)) {
                                        result = "A-";
                                      }
                                    }
                                    double vsdpercentTT =
                                        (totalConditionSeriousDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (vsdpercentTT >
                                        specTolerancePercentage) {
                                      if (rejectReason != "") {
                                        rejectReason += ", ";
                                      }
                                      rejectReasonArray.add(
                                          "Total Condition - (SD) " +
                                              "% exceeds tolerance");

                                      rejectReason +=
                                          "Total Condition - (SD) " +
                                              " % exceeds tolerance";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              "RJ",
                                              rejectReason,
                                              defectList.elementAt(k).comment ??
                                                  "");
                                    }
                                  }
                                }
                              }
                              if (tempSeverityDefectName == "Damage") {
                                if (defectList.elementAt(k).damageCnt! > 0) {
                                  if (defectList.elementAt(k).damageCnt! >
                                      defectList
                                          .elementAt(k)
                                          .seriousDamageCnt!) {
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
                                    if (result != "RJ") {
                                      double vsdpercent =
                                          (totalConditionDamage * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao
                                            .createOrUpdateResultReasonDetails(
                                                inspection.inspectionId!,
                                                result,
                                                "Total Condition - (Damage) " +
                                                    " % exceeds tolerance",
                                                defectList
                                                        .elementAt(k)
                                                        .comment ??
                                                    "");
                                      } else if ((vsdpercent >
                                              specTolerancePercentage / 2) &&
                                          (vsdpercent <=
                                              specTolerancePercentage)) {
                                        result = "A-";
                                      }
                                    }
                                    double vsdpercentTB =
                                        (totalConditionDamage * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (vsdpercentTB >
                                        specTolerancePercentage) {
                                      if (rejectReason != "") {
                                        rejectReason += ", ";
                                      }
                                      rejectReasonArray.add(
                                          "Total Condition - (Damage) " +
                                              "% exceeds tolerance");

                                      rejectReason +=
                                          "Total Condition - (Damage) " +
                                              " % exceeds tolerance";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              "RJ",
                                              rejectReason,
                                              defectList.elementAt(k).comment ??
                                                  "");
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
                                      double vsdpercent =
                                          (totalConditionInjury * 100)
                                                  .toDouble() /
                                              totalSampleSize;
                                      if (vsdpercent >
                                          specTolerancePercentage) {
                                        result = "RJ";
                                        await dao
                                            .createOrUpdateResultReasonDetails(
                                                inspection.inspectionId!,
                                                result,
                                                "Total Condition - (Injury) " +
                                                    " % exceeds tolerance",
                                                defectList
                                                        .elementAt(k)
                                                        .comment ??
                                                    "");
                                      } else if ((vsdpercent >
                                              specTolerancePercentage / 2) &&
                                          (vsdpercent <=
                                              specTolerancePercentage)) {
                                        result = "A-";
                                      }
                                    }
                                    double vsdpercentTA =
                                        (totalConditionInjury * 100)
                                                .toDouble() /
                                            totalSampleSize;
                                    if (vsdpercentTA >
                                        specTolerancePercentage) {
                                      if (rejectReason != "") {
                                        rejectReason += ", ";
                                      }
                                      rejectReasonArray.add(
                                          "Total Condition - (Injury) " +
                                              "% exceeds tolerance");

                                      rejectReason +=
                                          "Total Condition - (Injury) " +
                                              " % exceeds tolerance";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              "RJ",
                                              rejectReason,
                                              defectList.elementAt(k).comment ??
                                                  "");
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
                                    double vsdpercent =
                                        (totalConditionDecay * 100).toDouble() /
                                            totalSampleSize;
                                    if (vsdpercent > specTolerancePercentage) {
                                      result = "RJ";
                                      await dao
                                          .createOrUpdateResultReasonDetails(
                                              inspection.inspectionId!,
                                              result,
                                              "Total Condition - (Decay) " +
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
                                  double vsdpercentAB =
                                      (totalConditionDecay * 100).toDouble() /
                                          totalSampleSize;
                                  if (vsdpercentAB > specTolerancePercentage) {
                                    if (rejectReason != "") {
                                      rejectReason += ", ";
                                    }
                                    rejectReasonArray.add(
                                        "Total Condition - (Decay) " +
                                            "% exceeds tolerance");

                                    rejectReason +=
                                        "Total Condition - (Decay) " +
                                            " % exceeds tolerance";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
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
                                  if (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! >
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
                                      defectList
                                          .elementAt(k)
                                          .seriousDamageCnt!) {
                                    totalConditionCount +=
                                        defectList.elementAt(k).damageCnt! -
                                            defectList
                                                .elementAt(k)
                                                .seriousDamageCnt!;
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
                                      (totalConditionCount * 100).toDouble() /
                                          totalSampleSize;
                                  if (vsdpercent > specTolerancePercentage) {
                                    result = "RJ";
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
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
                                    (totalConditionCount * 100).toDouble() /
                                        totalSampleSize;
                                if (vsdpercentAC > specTolerancePercentage) {
                                  if (rejectReason != "") {
                                    rejectReason += ", ";
                                  }
                                  rejectReasonArray.add("Total Condition " +
                                      "% exceeds tolerance");

                                  rejectReason += "Total Condition " +
                                      "% exceeds tolerance";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection.inspectionId!,
                                      "RJ",
                                      rejectReason,
                                      defectList.elementAt(k).comment ?? "");
                                }

                                iscalculated = true;
                              }
                            }
                          } else if (defectList
                                  .elementAt(k)
                                  .defectCategory
                                  ?.toLowerCase() ==
                              "size") {
                            if (defectList.elementAt(k).defectId == defectID) {
                              sizeDefectName =
                                  defectList.elementAt(k).spinnerSelection ??
                                      '';

                              int totalSizecount = 0;
                              if (tempSeverityDefectName ==
                                  "Very Serious Damage") {
                                totalSizecount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                totalSize += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                              }
                              if (tempSeverityDefectName == "Serious Damage") {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  totalSizecount += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!;
                                  totalSize += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
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
                                  if (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! >
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
                                      defectList
                                          .elementAt(k)
                                          .seriousDamageCnt!) {
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
                                  totalSize +=
                                      defectList.elementAt(k).decayCnt!;
                                }
                              }
                              iscalculated = true;
                              if (result != "RJ") {
                                double sizepercent =
                                    (totalSizecount * 100).toDouble() /
                                        totalSampleSize;

                                if (sizepercent > specTolerancePercentage) {
                                  result = "RJ";
                                  if (sizeDefectName != "") {
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
                                        result,
                                        "$sizeDefectName : Size % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else {
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
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
                                  (totalSizecount * 100).toDouble() /
                                      totalSampleSize;
                              if (sizepercent1 > specTolerancePercentage) {
                                if (sizeDefectName != "") {
                                  if (rejectReason != "") {
                                    rejectReason += ", ";
                                  }
                                  // rejectReasonArray.add(sizeDefectName + " : Size % exceeds tolerance");

                                  rejectReason +=
                                      "$sizeDefectName : Size % exceeds tolerance";
                                  await dao.createOrUpdateResultReasonDetails(
                                      inspection.inspectionId!,
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
                                      inspection.inspectionId!,
                                      "RJ",
                                      rejectReason,
                                      defectList.elementAt(k).comment ?? "");
                                }
                              }
                            }
                          } else if (defectList
                                  .elementAt(k)
                                  .defectCategory
                                  ?.toLowerCase() ==
                              "color") {
                            if (defectList.elementAt(k).defectId == defectID) {
                              colorDefectName =
                                  defectList.elementAt(k).spinnerSelection ??
                                      '';

                              int colorcount = 0;

                              if (tempSeverityDefectName ==
                                  "Very Serious Damage") {
                                colorcount += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                                totalColor += defectList
                                    .elementAt(k)
                                    .verySeriousDamageCnt!;
                              }
                              if (tempSeverityDefectName == "Serious Damage") {
                                if (defectList.elementAt(k).seriousDamageCnt! >
                                    defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!) {
                                  colorcount += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
                                      defectList
                                          .elementAt(k)
                                          .verySeriousDamageCnt!;
                                  totalColor += defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! -
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
                                  if (defectList
                                          .elementAt(k)
                                          .seriousDamageCnt! >
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
                                      defectList
                                          .elementAt(k)
                                          .seriousDamageCnt!) {
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
                                  colorcount +=
                                      defectList.elementAt(k).decayCnt!;
                                  totalColor +=
                                      defectList.elementAt(k).decayCnt!;
                                }
                              }
                              iscalculated = true;
                              if (result != "RJ") {
                                double colorpercent =
                                    (colorcount * 100).toDouble() /
                                        totalSampleSize;

                                if (colorpercent > specTolerancePercentage) {
                                  result = "RJ";

                                  if (colorDefectName != "") {
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
                                        result,
                                        "$colorDefectName : Color % exceeds tolerance",
                                        defectList.elementAt(k).comment ?? "");
                                  } else {
                                    await dao.createOrUpdateResultReasonDetails(
                                        inspection.inspectionId!,
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
                                  (colorcount * 100).toDouble() /
                                      totalSampleSize;
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
                                      inspection.inspectionId!,
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
                                      inspection.inspectionId!,
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
                          (totalQualitycount * 100).toDouble() /
                              totalSampleSize;
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
                            inspection.inspectionId!, result, rejectReason, "");
                      } else if ((qualpercentage >
                              specTolerancePercentage / 2) &&
                          (qualpercentage <= specTolerancePercentage)) {
                        result = "A-";
                      }
                    } else if (defectID != null &&
                        totalConditionCount > 0 &&
                        defectID == totalConditionDefectId &&
                        tempSeverityDefectName == "") {
                      double condPercentage =
                          (totalConditionCount * 100).toDouble() /
                              totalSampleSize;
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
                            inspection.inspectionId!, result, rejectReason, "");
                        break;
                      } else if ((condPercentage >
                              specTolerancePercentage / 2) &&
                          (condPercentage <= specTolerancePercentage)) {
                        result = "A-";
                      }
                    } else if (defectID != null &&
                        totalSize > 0 &&
                        tempSeverityDefectName == "" &&
                        result != "RJ") {
                      print("total size = $totalSize");
                      double sizeper =
                          (totalSize * 100).toDouble() / totalSampleSize;

                      print(
                          "size per = $sizeper spec tolerance - $specTolerancePercentage");

                      if (sizeper > specTolerancePercentage) {
                        result = "RJ";
                        if (rejectReason != "") {
                          rejectReason += ", ";
                        }
                        rejectReasonArray.add("Total Size % exceeds tolerance");

                        rejectReason += "Total Size % exceeds tolerance";
                        await dao.createOrUpdateResultReasonDetails(
                            inspection.inspectionId!, result, rejectReason, "");
                        break;
                      } else if ((sizeper > specTolerancePercentage / 2) &&
                          (sizeper <= specTolerancePercentage)) {
                        result = "A-";
                      }
                    } else if (defectID != null &&
                        totalColor > 0 &&
                        tempSeverityDefectName == "" &&
                        result != "RJ") {
                      double sizeper =
                          (totalColor * 100).toDouble() / totalSampleSize;
                      if (sizeper > specTolerancePercentage) {
                        result = "RJ";
                        if (rejectReason != "") {
                          rejectReason += ", ";
                        }
                        rejectReasonArray
                            .add("Total Color % exceeds tolerance");

                        rejectReason += "Total Color % exceeds tolerance";
                        await dao.createOrUpdateResultReasonDetails(
                            inspection.inspectionId!, result, rejectReason, "");
                        break;
                      } else if ((sizeper > specTolerancePercentage / 2) &&
                          (sizeper <= specTolerancePercentage)) {
                        result = "A-";
                      }
                    }

                    if (result != "RJ") {
                      if (defectID != null &&
                          totalQualityDefectId != 0 &&
                          defectID == totalQualityDefectId) {
                        double qualpercentage = 0;
                        if (tempSeverityDefectName == "Very Serious Damage") {
                          qualpercentage =
                              (totalQualityVerySeriousDamage * 100).toDouble() /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Serious Damage") {
                          qualpercentage =
                              (totalQualitySeriousDamage * 100).toDouble() /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Damage") {
                          qualpercentage =
                              (totalQualityDamage * 100).toDouble() /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Injury") {
                          qualpercentage =
                              (totalQualityInjury * 100).toDouble() /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Decay") {
                          qualpercentage =
                              (totalQualityDecay * 100).toDouble() /
                                  totalSampleSize;
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
                              inspection.inspectionId!,
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
                              (totalConditionVerySeriousDamage * 100)
                                      .toDouble() /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Serious Damage") {
                          condpercentage =
                              (totalConditionSeriousDamage * 100).toDouble() /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Damage") {
                          condpercentage =
                              (totalConditionDamage * 100).toDouble() /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Injury") {
                          condpercentage =
                              (totalConditionInjury * 100).toDouble() /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Decay") {
                          condpercentage =
                              (totalConditionDecay * 100).toDouble() /
                                  totalSampleSize;
                        }

                        if (condpercentage > specTolerancePercentage) {
                          result = "RJ";
                          if (rejectReason != "") {
                            rejectReason += ", ";
                          }
                          rejectReasonArray.add(
                              "Total Condition Defects % exceeds tolerance");

                          rejectReason +=
                              " Total Condition Defects % exceeds tolerance";
                          await dao.createOrUpdateResultReasonDetails(
                              inspection.inspectionId!,
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

                    double calpercentage =
                        (totalcount * 100).toDouble() / totalSampleSize;
                    if (result != "RJ" && totalcount > 0) {
                      if (calpercentage > specTolerancePercentage) {
                        List<String> exceptions = [
                          "Manager Approval",
                          "Approval",
                          "Manager Rejection"
                        ];

                        result = "RJ";
                        if (rejectReason != "") {
                          rejectReason += ", ";
                        }
                        rejectReasonArray
                            .add("Defects Severity % exceeds tolerance");

                        rejectReason += "Defects Severity % exceeds tolerance";
                        await dao.createOrUpdateResultReasonDetails(
                            inspection.inspectionId!, result, rejectReason, "");
                      } else if ((calpercentage >
                              specTolerancePercentage / 2) &&
                          (calpercentage <= specTolerancePercentage)) {
                        result = "A-";
                      }

                      if (result != "RJ" &&
                          result != "A-" &&
                          (calpercentage >= 0 &&
                              calpercentage < (specTolerancePercentage / 2))) {
                        result = "AC";
                      }
                    }
                  } else if (!iscalculated && result == "") {
                    result = "AC";
                  }
                }
              }

              // if (result != "RJ") {
              //   if (appStorage.specificationAnalyticalList != null) {
              //     for (SpecificationAnalytical item
              //         in appStorage.specificationAnalyticalList ?? []) {
              //       SpecificationAnalyticalRequest? dbobj;
              //
              //       dbobj = await dao.findSpecAnalyticalObj(
              //           inspection.inspectionId!, item.analyticalID!);
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
              //
              //           result = "RJ";
              //           await dao.createOrUpdateResultReasonDetails(
              //               inspection.inspectionId!,
              //               result,
              //               "${dbobj.analyticalName ?? ""} = N",
              //               dbobj.comment ?? "");
              //           break;
              //         }
              //       }
              //     }
              //     if (result == "") {
              //       result = "AC";
              //     }
              //   }
              // }

              if (appStorage.specificationAnalyticalList != null) {
                for (SpecificationAnalytical item
                    in appStorage.specificationAnalyticalList!) {
                  SpecificationAnalyticalRequest? dbobj =
                      await dao.findSpecAnalyticalObj(
                          inspection.inspectionId!, item.analyticalID!);

                  if (dbobj != null &&
                      (dbobj.comply == "N" || dbobj.comply == "No")) {
                    if (dbobj.inspectionResult != null &&
                        (dbobj.inspectionResult == "No" ||
                            dbobj.inspectionResult == "N")) {
                    } else {
                      if (rejectReason.isNotEmpty) {
                        rejectReason += ", ";
                      }
                      result = "RJ";
                      rejectReasonArray.add("${dbobj.analyticalName} = N");

                      rejectReason += "${dbobj.analyticalName} = N";
                      await dao.createOrUpdateResultReasonDetails(
                          inspection.inspectionId!,
                          "RJ",
                          rejectReason,
                          dbobj.comment ?? '');
                    }
                  }
                }
                if (result.isEmpty) {
                  result = "AC";
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
                  inspection.inspectionId!, listString);

              OverriddenResult? overriddenResult =
                  await dao.getOverriddenResult(inspection.inspectionId!);

              if ((result == "A-" || result == "AC") &&
                  overriddenResult == null) {
                QualityControlItem? qualityControlItems = await dao
                    .findQualityControlDetails(inspection.inspectionId!);
                await dao.updateQuantityRejected(inspection.inspectionId!, 0,
                    qualityControlItems!.qtyShipped!);
              }

              await dao.updateInspectionResult(
                  inspection.inspectionId!, result);
              await dao.createOrUpdateInspectionSpecification(
                  inspection.inspectionId!,
                  specificationNumber,
                  specificationVersion,
                  specificationName);

              await dao.updateInspectionComplete(
                  inspection.inspectionId!, true);
              await dao.updateItemSKUInspectionComplete(
                  inspection.inspectionId!, true);
              Utils.setInspectionUploadStatus(
                  inspection.inspectionId!, Consts.INSPECTION_UPLOAD_READY);

              update();
            } else {
              AppAlertDialog.validateAlerts(Get.context!, AppStrings.alert,
                  AppStrings.noGradeTolarenceDataFound);
            }
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }

  void clearSearch() {
    searchController.clear();
    searchAndAssignItems("");
    unFocus();
  }

  Future<void> onItemTap(PurchaseOrderItem goodsItem, int index) async {
    FinishedGoodsItemSKU? finishedGoodsItemSKU = selectedItemSKUList[index];
    bool isComplete = await dao.isInspectionComplete(
        partnerID!, goodsItem.sku!, finishedGoodsItemSKU.id.toString());
    bool ispartialComplete = await dao.isInspectionPartialComplete(
        partnerID!, goodsItem.sku!, finishedGoodsItemSKU.id.toString());

    // FIXME: below
    // String current_lot_number = viewHolder.edit_LotNo.getText().toString();
    String? currentItemSKU = goodsItem.sku;
    String? currentItemSKUName = goodsItem.description;
    // String? current_pack_Date = packDate;
    int currentItemSKUId = finishedGoodsItemSKU.id!;
    String currentUniqueId = finishedGoodsItemSKU.uniqueItemId!;
    int? currentCommodityId = finishedGoodsItemSKU.commodityID;
    String currentCommodityName = finishedGoodsItemSKU.commodityName!;
    String? currentGtin = finishedGoodsItemSKU.gtin;
    String? dateType = finishedGoodsItemSKU.dateType;

    Map<String, dynamic> passingData = {};

    if (!isComplete && !ispartialComplete) {
      passingData[Consts.SERVER_INSPECTION_ID] = -1;
    } else {
      PartnerItemSKUInspections? partnerItemSKU = await dao.findPartnerItemSKU(
          partnerID!, currentItemSKU!, currentUniqueId);
      if (partnerItemSKU != null) {
        passingData[Consts.SERVER_INSPECTION_ID] = partnerItemSKU.inspectionId;
      }
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

    passingData[Consts.LOT_NO] = currentLotNumber;
    passingData[Consts.LOT_SIZE] = currentLotSize;
    passingData[Consts.ITEM_SKU] = currentItemSKU;
    passingData[Consts.ITEM_SKU_NAME] = currentItemSKUName;
    passingData[Consts.ITEM_SKU_ID] = currentItemSKUId;
    passingData[Consts.PACK_DATE] = currentPackDate;

    passingData[Consts.COMPLETED] = isComplete;
    passingData[Consts.PARTIAL_COMPLETED] = ispartialComplete;

    passingData[Consts.COMMODITY_ID] = currentCommodityId;
    passingData[Consts.COMMODITY_NAME] = currentCommodityName;
    passingData[Consts.ITEM_UNIQUE_ID] = currentUniqueId;
    passingData[Consts.GTIN] = currentGtin;
    passingData[Consts.PRODUCT_TRANSFER] = productTransfer;
    passingData[Consts.DATETYPE] = dateType;
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    await Get.to(() => QCDetailsShortFormScreen(tag: tag),
        arguments: passingData);
  }

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
      // Get.context!,
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
        partnerID!, goodsItem.sku!, finishedGoodsItemSKU.id.toString());
    bool ispartialComplete = await dao.isInspectionPartialComplete(
        partnerID!, goodsItem.sku!, finishedGoodsItemSKU.id.toString());

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
      Consts.SERVER_INSPECTION_ID: inspection.inspectionId!,
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

    await Get.to(() => const OverriddenResultScreen(), arguments: passingData);
    AppAlertDialog.confirmationAlert(
        Get.context!, AppStrings.alert, 'Calculate results?',
        onYesTap: () async {
      await calculateButtonClick(Get.context!);
    });
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

    if (inspectionResult.isNotEmpty) {
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
    Inspection? inspection,
    PartnerItemSKUInspections? partnerItemSKU,
    String lotNo,
    String packDate,
    bool isComplete,
    bool isPartialComplete,
    int? inspectionId,
    String poNumber,
    String sealNumber,
    int position,
    Function(Map data)? poInterface,
  ) async {
    bool checkItemSKUAndLot =
        await dao.checkItemSKUAndLotNo(goodsItem.sku!, lotNo);
    checkItemSKUAndLot = false;
    bool isValid = true;

    if (isComplete) {
      for (int i = 0; i < selectedItemSKUList.length; i++) {
        FinishedGoodsItemSKU finishedGoodsItemSKU = selectedItemSKUList[i];
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
      if (isComplete || isPartialComplete || !checkItemSKUAndLot) {
        String currentLotNumber = lotNo;
        String currentItemSKU = goodsItem.sku!;
        String currentItemSKUName = goodsItem.description!;
        String currentPackDate = packDate;
        int currentItemSKUId = finishedGoodsItemSKU.id!;
        String currentUniqueId = finishedGoodsItemSKU.uniqueItemId!;
        int? currentCommodityId = finishedGoodsItemSKU.commodityID;
        String currentCommodityName = finishedGoodsItemSKU.commodityName!;
        String? currentGtin = finishedGoodsItemSKU.gtin;
        String? dateType = finishedGoodsItemSKU.dateType;

        if (poInterface != null) {
          Map<String, dynamic> bundle = {
            Consts.LOT_NO: currentLotNumber,
            Consts.ITEM_SKU: currentItemSKU,
            Consts.ITEM_SKU_NAME: currentItemSKUName,
            Consts.PACK_DATE: currentPackDate,
            Consts.ITEM_SKU_ID: currentItemSKUId,
            Consts.ITEM_UNIQUE_ID: currentUniqueId,
            Consts.GTIN: currentGtin,
            Consts.DATETYPE: dateType,
            // Consts.COMMODITY_ID: currentCommodityId,
            Consts.COMMODITY_ID: commodityID,
            Consts.COMMODITY_NAME: currentCommodityName,
          };
          poInterface(bundle);
        }

        if (!isComplete && !isPartialComplete) {
          finishedGoodsItemSKU.lotNo = currentLotNumber;
          finishedGoodsItemSKU.poNo = goodsItem.poNumber;
        }

        // bool isOnline = globalConfigController.hasStableInternet.value;

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
              partnerID!, currentItemSKU, currentUniqueId);
          bool ispartialComplete = await dao.isInspectionPartialComplete(
              partnerID!, currentItemSKU, currentUniqueId);

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
          passigData[Consts.PO_NUMBER] = poNumber;
          passigData[Consts.SEAL_NUMBER] = sealNumber;
          passigData[Consts.PARTNER_NAME] = partnerName;
          passigData[Consts.PARTNER_ID] = partnerID;
          passigData[Consts.CARRIER_NAME] = carrierName;
          passigData[Consts.CARRIER_ID] = carrierID;
          passigData[Consts.LOT_NO] = currentLotNumber;
          passigData[Consts.ITEM_SKU] = currentItemSKU;
          passigData[Consts.ITEM_SKU_NAME] = currentItemSKUName;
          passigData[Consts.ITEM_SKU_ID] = currentItemSKUId;
          passigData[Consts.PACK_DATE] = currentPackDate;
          passigData[Consts.COMPLETED] = isComplete;
          passigData[Consts.PARTIAL_COMPLETED] = ispartialComplete;
          passigData[Consts.COMMODITY_ID] = currentCommodityId;
          // passigData[Consts.COMMODITY_ID] = commodityID;
          passigData[Consts.COMMODITY_NAME] = currentCommodityName;
          passigData[Consts.ITEM_UNIQUE_ID] = currentUniqueId;
          passigData[Consts.GTIN] = currentGtin;
          passigData[Consts.PRODUCT_TRANSFER] = productTransfer;
          passigData[Consts.DATETYPE] = dateType;
          passigData[Consts.CALLER_ACTIVITY] = "PurchaseOrderDetailsActivity";
          passigData[Consts.IS1STTIMEACTIVITY] = "PurchaseOrderDetailsActivity";
          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          await Get.to(
            () => QCDetailsShortFormScreen(tag: tag),
            arguments: passigData,
          );
          AppAlertDialog.confirmationAlert(
              Get.context!, AppStrings.alert, 'Calculate results?',
              onYesTap: () {
            calculateButtonClick(Get.context!);
          });
        } else {
          AppAlertDialog.validateAlerts(Get.context!, AppStrings.alert,
              'No specification alert for $currentItemSKU');
        }
      }
    }
  }

  Future<void> onHomeMenuTap() async {
    bool isValid = true;
    for (int i = 0; i < selectedItemSKUList.length; i++) {
      bool isComplete = await dao.isInspectionComplete(partnerID!,
          selectedItemSKUList[i].sku!, selectedItemSKUList[i].uniqueItemId);

      if (isComplete) {
        PartnerItemSKUInspections? partnerItemSKU =
            await dao.findPartnerItemSKU(
                partnerID!,
                selectedItemSKUList[i].sku!,
                selectedItemSKUList[i].uniqueItemId);

        if (partnerItemSKU != null) {
          Inspection? inspection =
              await dao.findInspectionByID(partnerItemSKU.inspectionId!);
          QualityControlItem? qualityControlItems =
              await dao.findQualityControlDetails(partnerItemSKU.inspectionId!);

          if (inspection != null &&
              qualityControlItems != null &&
              inspection.result != null &&
              inspection.result == "RJ") {
            if (qualityControlItems.qtyRejected == 0 ||
                qualityControlItems.qtyRejected! >
                    qualityControlItems.qtyShipped!) {
              isValid = false;

              AppAlertDialog.validateAlerts(
                  Get.context!, AppStrings.alert, AppStrings.quantityRejected);
            }
          }
        }
      }
    }

    if (isValid) {
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      Get.offAll(() => Home(tag: tag));
    }
  }

  List<FinishedGoodsItemSKU> get selectedItemSKUList =>
      appStorage.selectedItemSKUList;

  void onTailerTempMenuTap() {
    Get.to(
        () => const TrailerTemp(
            // carrier: carrier,
            // orderNumber: poNumber!,
            ),
        arguments: {
          Consts.PARTNER_NAME: partnerName,
          Consts.PARTNER_ID: partnerID,
          Consts.CARRIER_NAME: carrierName,
          Consts.CARRIER_ID: carrierID,
          Consts.COMMODITY_ID: commodityID,
          Consts.COMMODITY_NAME: commodityName,
          Consts.PO_NUMBER: poNumber,
          Consts.PRODUCT_TRANSFER: productTransfer,
          Consts.CALLER_ACTIVITY: "PurchaseOrderDetailsActivity",
        });
  }

  Future<void> onQCHeaderMenuTap() async {
    Get.to(() => const QualityControlHeader(), arguments: {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PO_NUMBER: poNumber,
      Consts.PRODUCT_TRANSFER: productTransfer,
      Consts.CALLER_ACTIVITY: "QualityControlHeaderActivity",
    });
  }

  Future<void> onAddGradingStandardMenuTap() async {
    Map<String, dynamic> passingData = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PO_NUMBER: poNumber,
      Consts.PRODUCT_TRANSFER: productTransfer,
      Consts.CALLER_ACTIVITY: "PurchaseOrderDetailsActivity",
    };
    if (productTransfer == "Transfer") {
      Get.to(() => const CommodityTransferScreen(), arguments: passingData);
    } else {
      Get.to(
        () => const CommodityIDScreen(),
        arguments: passingData,
      );
    }
  }

  Future<void> onSelectItemMenuTap() async {
    Map<String, dynamic> passingData = {
      Consts.PO_NUMBER: poNumber,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PRODUCT_TRANSFER: productTransfer,
    };
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    if (productTransfer == "Transfer") {
      Get.to(
        () => PurchaseOrderScreenCTE(tag: tag),
        arguments: passingData,
      );
    } else {
      Get.to(
        () => PurchaseOrderScreen(tag: tag),
        arguments: passingData,
      );
    }
  }

  Future<void> initAsyncActions() async {
    if (callerActivity.isNotEmpty) {
      if (callerActivity == "GTINActivity") {
        if (selectedItemSKUList.isNotEmpty) {
          if (!isGTINSamePartner) {
            Future.delayed(const Duration(milliseconds: 500), () {
              AppAlertDialog.validateAlerts(
                  Get.context!,
                  AppStrings.alert,
                  "GTIN has to be for the same supplier: $partnerName\nFinish & upload pfg for $partnerName\n\n"
                  "For a new supplier go to the Home page and select Inspect New Product");
            });
          }
        }
      }
    }

    if (callerActivity.isNotEmpty) {
      if (callerActivity == "QualityControlHeaderActivity" ||
          callerActivity == "PurchaseOrderDetailsActivity") {
        for (int i = 0; i < selectedItemSKUList.length; i++) {
          bool isComplete = await dao.isInspectionComplete(partnerID!,
              selectedItemSKUList[i].sku!, selectedItemSKUList[i].uniqueItemId);

          if (isComplete) {
            PartnerItemSKUInspections? partnerItemSKU =
                await dao.findPartnerItemSKU(
                    partnerID!,
                    selectedItemSKUList[i].sku!,
                    selectedItemSKUList[i].uniqueItemId);

            if (partnerItemSKU != null) {
              Inspection? inspection2 =
                  await dao.findInspectionByID(partnerItemSKU.inspectionId!);
              if (inspection2 != null && inspection2.result != null) {
                callerActivity = "PurchaseOrderDetailsActivity";
                Future.delayed(const Duration(milliseconds: 500), () {
                  AppAlertDialog.confirmationAlert(
                      Get.context!, AppStrings.alert, "Calculate results?",
                      onYesTap: () {
                    calculateButtonClick(Get.context!);
                  });
                });
                break;
              }
            }
          }
        }
      }
    }
  }
}
