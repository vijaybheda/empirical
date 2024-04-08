import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/partner_item.dart';

class QCDetailsShortFormScreenController extends GetxController {
  final PartnerItem partner;
  QCDetailsShortFormScreenController({required this.partner});

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  @override
  void onInit() {
    super.onInit();
    // specificationSelection();
  }

  /*void specificationSelection() {
    if (callerActivity == "TrendingReportActivity" || isMyInspectionScreen) {
      bool isOnline = globalConfigController.hasStableInternet.value;
      CacheUtil.offlineLoadCommodityVarietyDocuments(
          specificationNumber, specificationVersion);

      if (AppInfo.commodityVarietyData != null &&
          AppInfo.commodityVarietyData.exceptionList.isNotEmpty) {
        if (is1stTimeActivity != "") {
          if (is1stTimeActivity == "PurchaseOrderDetailsActivity") {
            CustomListViewDialog customDialog =
                CustomListViewDialog(QC_Details_short_form());
            customDialog.show();
            customDialog.setCanceledOnTouchOutside(false);
          }
        }
      }
    } else {
      if (AppInfo.specificationByItemSKUList != null &&
          AppInfo.specificationByItemSKUList.isNotEmpty) {
        specificationNumber =
            AppInfo.specificationByItemSKUList[0].specificationNumber;
        specificationVersion =
            AppInfo.specificationByItemSKUList[0].specificationVersion;
        specificationName =
            AppInfo.specificationByItemSKUList[0].specificationName;
        selectedSpecification =
            AppInfo.specificationByItemSKUList[0].specificationName;
        specificationTypeName =
            AppInfo.specificationByItemSKUList[0].specificationTypeName;
        sampleSizeByCount =
            AppInfo.specificationByItemSKUList[0].sampleSizeByCount;

        bool isOnline = globalConfigController.hasStableInternet.value;

        CacheUtil.offlineLoadCommodityVarietyDocuments(
            specificationNumber, specificationVersion);

        if (AppInfo.commodityVarietyData != null &&
            AppInfo.commodityVarietyData.exceptionList.isNotEmpty) {
          if (is1stTimeActivity != "") {
            if (is1stTimeActivity == "PurchaseOrderDetailsActivity") {
              CustomListViewDialog customDialog =
                  CustomListViewDialog(QC_Details_short_form());
              customDialog.show();
              customDialog.setCanceledOnTouchOutside(false);
            }
          }
        }
      }
    }
  }*/
}
