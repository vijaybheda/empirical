import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_grade_tolerance_array.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class PurchaseOrderDetailsController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;

  final TextEditingController searchController = TextEditingController();

  late final int? serverInspectionID;
  late final String? partnerName;
  late final int? partnerID;
  late final String? carrierName;
  late final int? carrierID;
  late final int? commodityID;
  late final String? commodityName;
  late final String? poNumber;
  late final String? sealNumber;
  late final String? specificationNumber;
  late final String? specificationVersion;
  late final String? specificationName;
  late final String? specificationTypeName;

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

    serverInspectionID = args['serverInspectionID'] ?? -1;
    partnerName = args['partnerName'] ?? '';
    partnerID = args['partnerID'] ?? 0;
    carrierName = args['carrierName'] ?? '';
    carrierID = args['carrierID'] ?? 0;
    commodityID = args['commodityID'] ?? 0;
    commodityName = args['commodityName'] ?? '';
    poNumber = args['poNumber'] ?? '';
    sealNumber = args['sealNumber'] ?? '';
    specificationNumber = args['specificationNumber'] ?? '';
    specificationVersion = args['specificationVersion'] ?? '';
    specificationName = args['specificationName'] ?? '';
    specificationTypeName = args['specificationTypeName'] ?? '';

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
        appStorage.selectedItemSKUList ?? [];
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
                            dbobj.pictureRequired!);
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

  Future<void> onItemTap(PurchaseOrderItem goodsItem) async {
    await Get.to(
        () => QCDetailsShortFormScreen(
              partner: partner,
              carrier: carrier,
              commodity: commodity,
              qcHeaderDetails: qcHeaderDetails,
              purchaseOrderItem: goodsItem,
            ),
        arguments: {
          'serverInspectionID': serverInspectionID,
          'partnerName': partner.name,
          'partnerID': partner.id,
          'carrierName': carrier.name,
          'carrierID': carrier.id,
          'commodityName': commodity.name,
          'commodityID': commodity.id,
          // 'sampleSizeByCount': ,
          // 'inspectionResult': ,
          // 'itemSKU': ,
          'poNumber': qcHeaderDetails?.poNo,
          // 'specificationNumber': ,
          // 'specificationVersion': ,
          // 'specificationName': ,
          // 'specificationTypeName': ,
          // 'selectedSpecification': ,
          // 'productTransfer': ,
          // 'callerActivity': ,
          // 'is1stTimeActivity': ,
          // 'isMyInspectionScreen': ,
        });
  }
}
