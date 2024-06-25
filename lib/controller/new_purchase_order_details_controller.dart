import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/defect_categories.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/new_purchase_order_item.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_grade_tolerance.dart';
import 'package:pverify/models/specification_grade_tolerance_array.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/commodity/commodity_id_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_screen.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';
import 'package:pverify/ui/trailer_temp/trailertemp.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class NewPurchaseOrderDetailsController extends GetxController {
  int serverInspectionID = -1;
  String partnerName = "";
  int partnerID = 0;
  String carrierName = "";
  int carrierID = 0;
  int commodityID = 0;
  String commodityName = "";
  String? poNumber;
  String sealNumber = "";
  String callerActivity = "";
  String? specificationNumber,
      specificationVersion,
      specificationName,
      specificationTypeName;
  String currentLotNumber = '',
      currentItemSKU = '',
      currentPackDate = '',
      currentLotSize = '',
      currentItemSKUName = '';
  String itemUniqueId = "";
  int itemSkuId = 0;
  bool isGTINSamePartner = true;

  final TextEditingController searchController = TextEditingController();

  RxList<NewPurchaseOrderItem> filteredInspectionsList =
      <NewPurchaseOrderItem>[].obs;
  RxList<NewPurchaseOrderItem> itemSkuList = <NewPurchaseOrderItem>[].obs;
  RxBool listAssigned = false.obs;

  final AppStorage appStorage = AppStorage.instance;
  final ApplicationDao dao = ApplicationDao();

  NewPurchaseOrderDetailsController();

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }
    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? "";
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? "";
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    poNumber = args[Consts.PO_NUMBER] ?? "";
    sealNumber = args[Consts.SEAL_NUMBER] ?? "";
    currentLotNumber = args[Consts.LOT_NO] ?? "";
    currentItemSKU = args[Consts.ITEM_SKU] ?? "";
    currentPackDate = args[Consts.PACK_DATE] ?? "";
    currentLotSize = args[Consts.LOT_SIZE] ?? "";
    currentItemSKUName = args[Consts.ITEM_SKU_NAME] ?? "";
    specificationNumber = args[Consts.SPECIFICATION_NUMBER];
    specificationVersion = args[Consts.SPECIFICATION_VERSION];
    specificationName = args[Consts.SPECIFICATION_NAME];
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME];
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? "";
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? "";
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? "";
    isGTINSamePartner = args[Consts.IS_GTIN_SAME_PARTNER] ?? true;

    super.onInit();

    if (callerActivity != "") {
      if (callerActivity == "GTINActivity") {
        if (appStorage.selectedItemSKUList.isNotEmpty) {
          if (!isGTINSamePartner) {
            Future.delayed(const Duration(milliseconds: 500), () {
              AppAlertDialog.validateAlerts(
                Get.context!,
                AppStrings.alert,
                "GTIN has to be for the same supplier: $partnerName\nFinish & upload pfg for $partnerName\n\nFor a new supplier go to the Home page and select Inspect New Product",
              );
            });
          }
        }
      }
    }

    onCreate();
    onResume();
  }

  void searchAndAssignItems(String searchValue) {
    filteredInspectionsList.clear();
    if (searchValue.isEmpty) {
      filteredInspectionsList.addAll(itemSkuList);
    } else {
      var items = itemSkuList.where((element) {
        String? sku = element.sku;
        String searchKey = searchValue.toLowerCase();

        return (sku != null && sku.toLowerCase().contains(searchKey));
      }).toList();
      filteredInspectionsList.addAll(items);
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    searchAndAssignItems("");
    unFocus();
  }

  List<NewPurchaseOrderItem> getPurchaseOrderData() {
    List<NewPurchaseOrderItem> list = [];

    for (FinishedGoodsItemSKU item in appStorage.selectedItemSKUList) {
      NewPurchaseOrderItem purchaseOrderItem = NewPurchaseOrderItem(
        description: item.name,
        sku: item.sku,
        poNumber: item.poNo,
        sealNumber: "",
        lotNumber: item.lotNo,
        commodityId: item.commodityID,
        commodityName: item.commodityName,
        packDate: item.packDate,
        quantity: item.quantity,
        quantityUOM: item.quantityUOM,
        quantityUOMName: item.quantityUOMName,
        number_spec: item.number_spec,
        version_spec: item.version_spec,
        poLineNo: item.poLineNo,
        partnerId: item.partnerId,
        ftl: item.FTLflag,
        branded: item.Branded,
      );
      list.add(purchaseOrderItem);
    }
    return list;
  }

  void onCreate() async {
    List<FinishedGoodsItemSKU> selectedItemSKUList =
        await dao.getSelectedItemSKUList();
  }

  List<FinishedGoodsItemSKU> get selectedItemSKUList =>
      appStorage.selectedItemSKUList;
  Future<void> onResume() async {
    if (callerActivity != "") {
      if (callerActivity == "QCDetailsShortForm") {
        for (var i = 0; i < appStorage.selectedItemSKUList.length; i++) {
          bool isComplete = await dao.isInspectionComplete(
              partnerID,
              appStorage.selectedItemSKUList[i].sku!,
              appStorage.selectedItemSKUList[i].uniqueItemId);

          if (isComplete) {
            PartnerItemSKUInspections? partnerItemSKU =
                await dao.findPartnerItemSKU(
                    partnerID,
                    appStorage.selectedItemSKUList[i].sku!,
                    appStorage.selectedItemSKUList[i].uniqueItemId);

            if (partnerItemSKU != null) {
              Inspection? inspection2 =
                  await dao.findInspectionByID(partnerItemSKU.inspectionId!);
              if (inspection2 != null && inspection2.result != null) {
                callerActivity = "NewPurchaseOrderDetailsActivity";
                AppAlertDialog.confirmationAlert(
                    Get.context!, AppStrings.alert, "Calculate results?",
                    onYesTap: () {
                  calculateButtonClick();
                });
                break;
              }
            }
          }
        }
      }
    }
  }

  Future<void> calculateButtonClick() async {
    String itemsSpecStr = "";
    String result = "";

    List<SpecificationGradeToleranceArray>
        specificationGradeToleranceArrayList = [];

    for (var i = 0; i < appStorage.selectedItemSKUList.length; i++) {
      bool isComplete = await dao.isInspectionComplete(
          partnerID,
          appStorage.selectedItemSKUList[i].sku!,
          appStorage.selectedItemSKUList[i].uniqueItemId);

      if (isComplete) {
        PartnerItemSKUInspections? partnerItemSKU =
            await dao.findPartnerItemSKU(
                partnerID,
                appStorage.selectedItemSKUList[i].sku!,
                appStorage.selectedItemSKUList[i].uniqueItemId);

        if (partnerItemSKU != null && partnerItemSKU.inspectionId != null) {
          Inspection? inspection =
              await dao.findInspectionByID(partnerItemSKU.inspectionId!);

          if (inspection != null && inspection.inspectionId != null) {
            await dao
                .deleteRejectionDetailByInspectionId(inspection.inspectionId!);

            QCHeaderDetails? qcHeaderDetails =
                await dao.findTempQCHeaderDetails(inspection.poNumber!);

            if (qcHeaderDetails != null && qcHeaderDetails.truckTempOk == "N") {
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

              // TODO: confirm with Android dev if this is correct
              // footerRightButtonText.visibility = Visibility.Visible;
              update();
            } else {
              try {
                itemsSpecStr +=
                    "${inspection.specificationNumber!}:${inspection.specificationVersion},";

                List<SpecificationGradeTolerance>
                    specificationGradeToleranceList =
                    await dao.getSpecificationGradeTolerance(
                        inspection.specificationNumber!,
                        inspection.specificationVersion!);
                SpecificationGradeToleranceArray
                    specificationGradeToleranceArray =
                    SpecificationGradeToleranceArray(
                  specificationNumber: inspection.specificationNumber,
                  specificationVersion: inspection.specificationVersion,
                  specificationGradeToleranceList:
                      specificationGradeToleranceList,
                );
                specificationGradeToleranceArrayList
                    .add(specificationGradeToleranceArray);
              } catch (e) {
                debugPrint("$e");
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
        // TODO: implement calculate Result
        await calculateResult();
        update();
      } else {
        AppSnackBar.info(message: "No Items are complete for calculation");
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
            partnerID, itemSKU.sku!, itemSKU.uniqueItemId);

        if (isComplete) {
          PartnerItemSKUInspections? partnerItemSKU =
              await dao.findPartnerItemSKU(
                  partnerID, itemSKU.sku!, itemSKU.uniqueItemId);

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
                // TODO: implement logic
                // footerRightButtonText.setVisibility(View.VISIBLE);
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
              } else {
                QualityControlItem? qualityControlItems = await dao
                    .findQualityControlDetails(inspection.inspectionId!);

                if (qualityControlItems != null) {
                  await dao.updateQuantityRejected(inspection.inspectionId!,
                      qualityControlItems.qtyShipped!, 0);
                }
              }
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
                  if (defectCategory.name == "Quality" &&
                      (defectCategory.defectList != null)) {
                    for (DefectItem defectItem
                        in defectCategory.defectList ?? []) {
                      if (defectItem.name?.contains("Total Quality") ?? false) {
                        totalQualityDefectId = defectItem.id ?? 0;
                        break;
                      }
                    }
                  } else if (defectCategory.name == "Condition" &&
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
                          double vsdpercent = totalSeverityVerySeriousDamage *
                              100 /
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
                          double vsdpercent = totalSeverityVerySeriousDamage *
                              100 /
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
                          double sdpercent = totalSeveritySeriousDamage *
                              100 /
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
                          double sdpercent = totalSeveritySeriousDamage *
                              100 /
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
                              totalSeverityDamage * 100 / totalSampleSize;
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
                              totalSeverityDamage * 100 / totalSampleSize;
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
                              totalSeverityInjury * 100 / totalSampleSize;
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
                              totalSeverityInjury * 100 / totalSampleSize;
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
                              totalSeverityDecay * 100 / totalSampleSize;
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
                              totalSeverityDecay * 100 / totalSampleSize;
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
                              ((totalcount / totalSampleSize) * 100)
                                  .roundToDouble();
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
                          if (defectList.elementAt(k).defectCategory ==
                                  "quality" ||
                              defectList.elementAt(k).defectCategory ==
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

                                  if (defectList.elementAt(k).defectCategory ==
                                      "quality") {
                                    totalQualitycount += defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!;
                                    totalQualityVerySeriousDamage += defectList
                                        .elementAt(k)
                                        .verySeriousDamageCnt!;
                                  } else if (defectList
                                          .elementAt(k)
                                          .defectCategory ==
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
                                        totalQualityVerySeriousDamage *
                                            100 /
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
                                      totalQualityVerySeriousDamage *
                                          100 /
                                          totalSampleSize;

                                  if (result != "RJ") {
                                    double vsdpercent =
                                        totalConditionVerySeriousDamage *
                                            100 /
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
                                      totalConditionVerySeriousDamage *
                                          100 /
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
                                            .defectCategory ==
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
                                            .defectCategory ==
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
                                          totalQualitySeriousDamage *
                                              100 /
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
                                        totalQualitySeriousDamage *
                                            100 /
                                            totalSampleSize;
                                    if (result != "RJ") {
                                      double vsdpercent =
                                          totalConditionSeriousDamage *
                                              100 /
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
                                        totalConditionSeriousDamage *
                                            100 /
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
                                            .defectCategory ==
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
                                            .defectCategory ==
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
                                  double vsdpercent = totalQualityDamage *
                                      100 /
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
                                    totalQualityDamage * 100 / totalSampleSize;
                                if (result != "RJ") {
                                  double vsdpercent = totalConditionDamage *
                                      100 /
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

                                double vsdpercent6 = totalConditionDamage *
                                    100 /
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
                                            .defectCategory ==
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
                                            .defectCategory ==
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
                                      double vsdpercent = totalQualityInjury *
                                          100 /
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
                                    double vsdpercent7 = totalQualityInjury *
                                        100 /
                                        totalSampleSize;

                                    if (result != "RJ") {
                                      double vsdpercent = totalConditionInjury *
                                          100 /
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

                                    double vsdpercent8 = totalConditionInjury *
                                        100 /
                                        totalSampleSize;
                                  }
                                }
                              }
                              if (tempSeverityDefectName == "Decay") {
                                if (defectList.elementAt(k).decayCnt! > 0) {
                                  totalcount +=
                                      defectList.elementAt(k).decayCnt!;
                                  iscalculated = true;
                                  if (defectList.elementAt(k).defectCategory ==
                                      "quality") {
                                    totalQualitycount +=
                                        defectList.elementAt(k).decayCnt!;
                                    totalQualityDecay +=
                                        defectList.elementAt(k).decayCnt!;
                                  } else if (defectList
                                          .elementAt(k)
                                          .defectCategory ==
                                      "condition") {
                                    totalConditionCount +=
                                        defectList.elementAt(k).decayCnt!;
                                    totalConditionDecay +=
                                        defectList.elementAt(k).decayCnt!;
                                  }

                                  if (result != "RJ") {
                                    double vsdpercent = totalQualityDecay *
                                        100 /
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
                                      totalQualityDecay * 100 / totalSampleSize;

                                  if (result != "RJ") {
                                    double vsdpercent = totalConditionDecay *
                                        100 /
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
                                  double vsdpercent10 = totalConditionDecay *
                                      100 /
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
                                      (totalcount * 100) / totalSampleSize;
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
                                    (totalcount * 100) / totalSampleSize;
                              }
                            } else if (defectName == "Total Quality (%)" &&
                                (defectList.elementAt(k).defectCategory ==
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
                                        totalQualityVerySeriousDamage *
                                            100 /
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
                                      totalQualityVerySeriousDamage *
                                          100 /
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
                                          totalQualitySeriousDamage *
                                              100 /
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
                                        totalQualitySeriousDamage *
                                            100 /
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
                                      double vsdpercent = totalQualityDamage *
                                          100 /
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

                                    double vsdpercent13 = totalQualityDamage *
                                        100 /
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
                                      double vsdpercent = totalQualityInjury *
                                          100 /
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

                                    double vsdpercent14 = totalQualityInjury *
                                        100 /
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
                                    double vsdpercent = totalQualityDecay *
                                        100 /
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
                                      totalQualityDecay * 100 / totalSampleSize;
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
                                      totalQualitycount * 100 / totalSampleSize;
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
                                    totalQualitycount * 100 / totalSampleSize;
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
                            } else if (defectList.elementAt(k).defectCategory ==
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
                                        totalConditionVerySeriousDamage *
                                            100 /
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
                                      totalConditionVerySeriousDamage *
                                          100 /
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
                                          totalConditionSeriousDamage *
                                              100 /
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
                                        totalConditionSeriousDamage *
                                            100 /
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
                                      double vsdpercent = totalConditionDamage *
                                          100 /
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
                                    double vsdpercentTB = totalConditionDamage *
                                        100 /
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
                                      double vsdpercent = totalConditionInjury *
                                          100 /
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
                                    double vsdpercentTA = totalConditionInjury *
                                        100 /
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
                                    double vsdpercent = totalConditionDecay *
                                        100 /
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
                                  double vsdpercentAB = totalConditionDecay *
                                      100 /
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
                                  double vsdpercent = totalConditionCount *
                                      100 /
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
                                    totalConditionCount * 100 / totalSampleSize;
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
                          } else if (defectList.elementAt(k).defectCategory ==
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
                                    (totalSizecount * 100) / totalSampleSize;

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
                                  (totalSizecount * 100) / totalSampleSize;
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
                          } else if (defectList.elementAt(k).defectCategory ==
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
                                    (colorcount * 100) / totalSampleSize;

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
                                  (colorcount * 100) / totalSampleSize;
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
                          (totalQualitycount * 100) / totalSampleSize;
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
                          (totalConditionCount * 100) / totalSampleSize;
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
                      double sizeper = (totalSize * 100) / totalSampleSize;

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
                      double sizeper = (totalColor * 100) / totalSampleSize;
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
                              (totalQualityVerySeriousDamage * 100) /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Serious Damage") {
                          qualpercentage = (totalQualitySeriousDamage * 100) /
                              totalSampleSize;
                        } else if (tempSeverityDefectName == "Damage") {
                          qualpercentage =
                              (totalQualityDamage * 100) / totalSampleSize;
                        } else if (tempSeverityDefectName == "Injury") {
                          qualpercentage =
                              (totalQualityInjury * 100) / totalSampleSize;
                        } else if (tempSeverityDefectName == "Decay") {
                          qualpercentage =
                              (totalQualityDecay * 100) / totalSampleSize;
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
                              (totalConditionVerySeriousDamage * 100) /
                                  totalSampleSize;
                        } else if (tempSeverityDefectName == "Serious Damage") {
                          condpercentage = (totalConditionSeriousDamage * 100) /
                              totalSampleSize;
                        } else if (tempSeverityDefectName == "Damage") {
                          condpercentage =
                              (totalConditionDamage * 100) / totalSampleSize;
                        } else if (tempSeverityDefectName == "Injury") {
                          condpercentage =
                              (totalConditionInjury * 100) / totalSampleSize;
                        } else if (tempSeverityDefectName == "Decay") {
                          condpercentage =
                              (totalConditionDecay * 100) / totalSampleSize;
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

                    double calpercentage = (totalcount * 100) / totalSampleSize;
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

              /*************************************************************************/
              if (result != "RJ") {
                if (appStorage.specificationAnalyticalList != null) {
                  for (SpecificationAnalytical item
                      in appStorage.specificationAnalyticalList ?? []) {
                    SpecificationAnalyticalRequest? dbobj;

                    dbobj = await dao.findSpecAnalyticalObj(
                        inspection.inspectionId!, item.analyticalID!);

                    if (dbobj != null && dbobj.comply == "N") {
                      if (dbobj.inspectionResult != null &&
                          (dbobj.inspectionResult == "No" ||
                              dbobj.inspectionResult == "N")) {
                      } else {
                        List<String> exceptions = [
                          "Manager Approval",
                          "Approval",
                          "Manager Rejection"
                        ];

                        result = "RJ";
                        await dao.createOrUpdateResultReasonDetails(
                            inspection.inspectionId!,
                            result,
                            "${dbobj.analyticalName ?? ""} = N",
                            dbobj.comment ?? "");
                        break;
                      }
                    }
                  }
                  if (result == "") {
                    result = "AC";
                  }
                }
              }

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

                      QualityControlItem? qualityControlItems = await dao
                          .findQualityControlDetails(inspection.inspectionId!);

                      await dao.updateQuantityRejected(
                          inspection.inspectionId!,
                          qualityControlItems?.qtyRejected ?? 0,
                          qualityControlItems!.qtyReceived!);

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
      debugPrint("Calculate Result :- $e");
    }
  }

  Future<void> onHomeMenuTap() async {
    bool isValid = true;
    bool isValid2 = true;
    bool isValid3 = true;

    for (var i = 0; i < appStorage.selectedItemSKUList.length; i++) {
      bool isComplete = await dao.isInspectionComplete(
          partnerID,
          appStorage.selectedItemSKUList[i].sku!,
          appStorage.selectedItemSKUList[i].uniqueItemId);

      PartnerItemSKUInspections? partnerItemSKU =
          await dao.findPartnerItemSKUPOLine(
              partnerID,
              appStorage.selectedItemSKUList[i].sku!,
              appStorage.selectedItemSKUList[i].poLineNo!,
              poNumber!);

      if (partnerItemSKU != null) {
        Inspection? inspection =
            await dao.findInspectionByID(partnerItemSKU.inspectionId!);

        if (inspection != null) {
          QualityControlItem? qualityControlItems =
              await dao.findQualityControlDetails(inspection.inspectionId!);
          if (qualityControlItems != null) {
            if (qualityControlItems.qtyShipped! <
                    qualityControlItems.qtyRejected! ||
                qualityControlItems.qtyShipped! <= 0) {
              isValid2 = false;
            }
          }

          appStorage.specificationAnalyticalList =
              await dao.getSpecificationAnalyticalFromTable(
                  appStorage.selectedItemSKUList[i].number_spec!,
                  appStorage.selectedItemSKUList[i].version_spec!);

          if (appStorage.specificationAnalyticalList != null) {
            for (final item in appStorage.specificationAnalyticalList!) {
              if (item.analyticalName?.contains("Quality Check") ?? false) {
                if ((item.isPictureRequired ?? false) &&
                    (inspection.rating > 0 && inspection.rating <= 2)) {
                  List<InspectionAttachment>? picsFromDB =
                      await dao.findInspectionAttachmentsByInspectionId(
                          inspection.inspectionId!);

                  if (picsFromDB.isEmpty) {
                    isValid = false;
                    break;
                  }
                }
              } else if (item.analyticalName?.contains("Branded") ?? false) {
                final SpecificationAnalyticalRequest? dbobj =
                    await dao.findSpecAnalyticalObj(
                        inspection.inspectionId!, item.analyticalID!);

                if (dbobj == null) {
                  isValid3 = false;
                  break;
                }
              }
            }
          }
        }
      }
    }

    if (isValid) {
      if (isValid2) {
        if (isValid3) {
          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.offAll(() => Home(tag: tag));
        } else {
          AppAlertDialog.validateAlerts(
            Get.context!,
            AppStrings.alert,
            "All inspected rows require Branded Y/N.\n\nIs the product in a PFG private label box?\n(White box for Peak or Brown box for Growers Choice)",
          );
        }
      } else {
        AppAlertDialog.validateAlerts(
          Get.context!,
          AppStrings.alert,
          "Please enter valid quantity shipped/rejected.",
        );
      }
    } else {
      AppAlertDialog.validateAlerts(
        Get.context!,
        AppStrings.alert,
        "All rejected rows require at least 1 picture",
      );
    }
  }

  void onTailerTempMenuTap() {
    Map<String, dynamic> arguments = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PO_NUMBER: poNumber,
      Consts.CALLER_ACTIVITY: "NewPurchaseOrderDetailsActivity",
    };
    Get.to(() => const TrailerTemp(), arguments: arguments);
  }

  Future<void> onQCHeaderMenuTap() async {
    Map<String, dynamic> arguments = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PO_NUMBER: poNumber,
      Consts.CALLER_ACTIVITY: "QualityControlHeaderActivity",
    };
    Get.to(() => const QualityControlHeader(), arguments: arguments);
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
      Consts.CALLER_ACTIVITY: "NewPurchaseOrderDetailsActivity",
    };
    Get.to(
      () => const CommodityIDScreen(),
      arguments: passingData,
    );
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
    };
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.to(
      () => PurchaseOrderScreen(tag: tag),
      arguments: passingData,
    );
  }
}
