import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';

class PurchaseOrderScreenController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  PurchaseOrderScreenController({
    required this.partner,
    required this.carrier,
    required this.commodity,
  });

  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<FinishedGoodsItemSKU> filteredCommodityList =
      <FinishedGoodsItemSKU>[].obs;
  RxList<FinishedGoodsItemSKU> commodityList = <FinishedGoodsItemSKU>[].obs;
  RxBool listAssigned = false.obs;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    LoginData? loginData = appStorage.getLoginData();

    if (loginData != null) {
      if (filteredCommodityList.isEmpty) {
        int enterpriseId = await dao
            .getEnterpriseIdByUserId(loginData.userName!.toLowerCase());
        // TODO:
        List<FinishedGoodsItemSKU>? _filteredCommodityList =
            await dao.getFinishedGoodItemSkuFromTable(
          partner.id!,
          enterpriseId,
          commodity.id!,
          commodity.name!,
          loginData.supplierId!,
          loginData.headquarterSupplierId!,
          partner.name!,
        );

        filteredCommodityList.value = _filteredCommodityList ?? [];
        listAssigned.value = true;
        update();
      } else {
        // TODO:
        // filteredCommodityList = asd;
        listAssigned.value = true;
        update();
      }
    }
  }

  void updateCommodityItem(FinishedGoodsItemSKU partner) {
    int index = filteredCommodityList.indexWhere((element) {
      return element.uniqueItemId == partner.uniqueItemId;
    });

    if (index != -1) {
      filteredCommodityList[index] = partner;
      update(['commodityList']);
    }
  }

  Future<void> navigateToPurchaseOrderDetails(
    BuildContext context,
    PartnerItem partner,
    CarrierItem carrier,
    CommodityItem commodity,
  ) async {
    LoginData? loginData = appStorage.getLoginData();

    if (loginData == null) {
      return;
    }

    int userId =
        await dao.getHeadquarterIdByUserId(loginData.userName!.toLowerCase());

    if (appStorage.selectedItemSKUList != null &&
        (appStorage.selectedItemSKUList ?? []).isNotEmpty) {
      // TODO: implement
      // Get.to(() => userId == 4180
      //     ? NewPurchaseOrderDetailsActivity()
      //     : PurchaseOrderDetailsActivity());
    } else {
      AppAlertDialog.validateAlerts(
        context,
        AppStrings.alert,
        AppStrings.noItemSkuSelected,
      );
    }
  }
}
