import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';

class PurchaseOrderDetailsController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;
  PurchaseOrderDetailsController({
    required this.partner,
    required this.carrier,
    required this.commodity,
    required this.qcHeaderDetails,
  });

  @override
  void onInit() {
    itemSkuList.assignAll(getPurchaseOrderData());
    super.onInit();
    filteredItemSkuList.assignAll(itemSkuList);
    listAssigned.value = true;
  }

  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<PurchaseOrderItem> filteredItemSkuList = <PurchaseOrderItem>[].obs;
  RxList<PurchaseOrderItem> itemSkuList = <PurchaseOrderItem>[].obs;
  RxBool listAssigned = false.obs;

  void searchAndAssignItems(String value) {
    // TODO: implement search logic
  }

  List<PurchaseOrderItem> getPurchaseOrderData() {
    List<PurchaseOrderItem> list = [];

    for (var item in (appStorage.selectedItemSKUList ?? [])) {
      list.add(PurchaseOrderItem.newData(
          item.name,
          item.sku,
          item.poNo,
          "",
          item.lotNo,
          item.commodityID,
          item.commodityName,
          item.packDate,
          item.ftlFlag,
          item.branded));
    }
    return list;
  }

  Future<void> calculateResult(BuildContext context) async {
    /*int totalQualityDefectId = 0;
    int totalConditionDefectId = 0;

    List<FinishedGoodsItemSKU> selectedItemSKUList =
        appStorage.selectedItemSKUList ?? [];
    for (int i = 0; i < selectedItemSKUList.length; i++) {
      FinishedGoodsItemSKU itemSKU = selectedItemSKUList.elementAt(i);
      bool isComplete = await dao.isInspectionComplete(
          partner.id!, itemSKU.sku!, itemSKU.uniqueItemId!);

      if (isComplete) {
        PartnerItemSKUInspections? partnerItemSKU =
            await dao.findPartnerItemSKU(
                partner.id!, itemSKU.sku!, itemSKU.uniqueItemId!);

        if (partnerItemSKU != null) {
          Inspection? inspection = await dao
              .findInspectionByID(partnerItemSKU.inspectionId!.toInt());
          if (inspection == null) {
            return;
          }
          specificationTypeName = inspection.specificationTypeName;
          specificationNumber = inspection.specificationNumber;
          specificationVersion = inspection.specificationVersion;
          List<SpecificationGradeToleranceArray>
              specificationGradeToleranceArrayList =
              appStorage.specificationGradeToleranceArrayList ?? [];
          for (int abc = 0;
              abc < specificationGradeToleranceArrayList.length;
              abc++) {
            if (specificationGradeToleranceArrayList[abc]
                .getSpecificationGradeToleranceList()
                .isNotEmpty) {
              if (specificationGradeToleranceArrayList[abc]
                          .getSpecificationNumber() ==
                      specificationNumber &&
                  specificationGradeToleranceArrayList[abc]
                          .getSpecificationVersion() ==
                      specificationVersion) {
                appStorage.specificationGradeToleranceList = appStorage
                    .specificationGradeToleranceArrayList[abc]
                    .getSpecificationGradeToleranceList();
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
                  specificationNumber, specificationVersion);

          if (!specificationTypeName
                  .equalsIgnoreCase("Finished Goods Produce") &&
              !specificationTypeName.equalsIgnoreCase("Raw Produce")) {
            if (appStorage.specificationAnalyticalList != null) {
              for (var item in (appStorage.specificationAnalyticalList ?? [])) {
                var dbobj = await dao.findSpecAnalyticalObj(
                    inspection.inspectionId, item.analyticalID);
                if (dbobj != null && dbobj.comply == "N") {
                  if (dbobj.inspectionResult != null &&
                      dbobj.inspectionResult == "N") {
                    // Do nothing
                  } else {
                    result = "RJ";
                    rejectReason += "${dbobj.analyticalName} = N";
                    rejectReasonArray.add("${dbobj.analyticalName} = N");
                    await dao.createOrUpdateResultReasonDetails(
                        inspection.inspectionId,
                        result,
                        "${dbobj.analyticalName} = N",
                        dbobj.comment);
                    await dao.createIsPictureReqSpecAttribute(
                        inspection.inspectionId,
                        result,
                        "${dbobj.analyticalName} = N",
                        dbobj.pictureRequired!);
                    break;
                  }
                }
              }
              if (result == "") {
                result = "AC";
              }
              footerRightButtonText.setVisibility(View.VISIBLE);
            }

            if (result == "A-" || result == "AC") {
              var qualityControlItems =
                  await dao.findQualityControlDetails(inspection.inspectionId);
              await dao.updateQuantityRejected(
                  inspection.inspectionId, 0, qualityControlItems.qtyShipped);
            }
            await dao.updateInspectionResult(inspection.inspectionId, result);
            await dao.createOrUpdateInspectionSpecification(
                inspection.inspectionId,
                specificationNumber,
                specificationVersion,
                specificationName);
            await dao.updateInspectionComplete(inspection.inspectionId, true);
            await dao.updateItemSKUInspectionComplete(
                inspection.inspectionId, "true");

            Util.setInspectionUploadStatus(context, inspection.inspectionId,
                Consts.INSPECTION_UPLOAD_READY);
          } else if (appStorage.specificationGradeToleranceList != null &&
              (appStorage.specificationGradeToleranceList ?? []).isNotEmpty) {
            int totalSampleSize = 0;
            List<InspectionSample> samples =
                await dao.findInspectionSamples(inspection.inspectionId);
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
    }*/
  }
}
