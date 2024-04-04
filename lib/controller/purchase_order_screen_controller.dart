import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/purchase_order/new_purchase_order_details_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_details_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';

class PurchaseOrderScreenController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;
  PurchaseOrderScreenController({
    required this.partner,
    required this.carrier,
    required this.commodity,
    required this.qcHeaderDetails,
  });

  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<FinishedGoodsItemSKU> filteredItemSkuList =
      <FinishedGoodsItemSKU>[].obs;
  RxList<FinishedGoodsItemSKU> itemSkuList = <FinishedGoodsItemSKU>[].obs;
  RxBool listAssigned = false.obs;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    LoginData? loginData = appStorage.getLoginData();

    if (loginData != null) {
      if (filteredItemSkuList.isEmpty) {
        int enterpriseId = await dao
            .getEnterpriseIdByUserId(loginData.userName!.toLowerCase());
        // TODO:
        List<FinishedGoodsItemSKU>? _filteredItemSkuList =
            await dao.getFinishedGoodItemSkuFromTable(
          partner.id!,
          enterpriseId,
          commodity.id!,
          commodity.name!,
          loginData.supplierId!,
          loginData.headquarterSupplierId!,
          partner.name!,
        );

        itemSkuList.addAll(_filteredItemSkuList ?? []);
        filteredItemSkuList.addAll(itemSkuList);
        listAssigned.value = true;
        update();
      } else {
        // TODO:
        // filteredItemSkuList = asd;
        listAssigned.value = true;
        update();
      }
    }
  }

  void updateCommodityItem(FinishedGoodsItemSKU partner) {
    appStorage.selectedItemSKUList ??= <FinishedGoodsItemSKU>[];

    // remove if exist in appStorage.selectedItemSKUList
    appStorage.selectedItemSKUList?.removeWhere((element) {
      return element.id == partner.id;
    });
    if (partner.isSelected ?? false) {
      appStorage.selectedItemSKUList?.add(partner);
    }

    print(appStorage.selectedItemSKUList?.length);
    int index = filteredItemSkuList.indexWhere((element) {
      return element.id == partner.id;
    });

    if (index != -1) {
      filteredItemSkuList[index] = partner;
      int _index = filteredItemSkuList.indexWhere((element) {
        return element.id == partner.id;
      });
      if (_index != -1) {
        itemSkuList[_index] = partner;
      }
      update(['itemSkuList']);
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
      if (userId == 4180) {
        Get.to(() => NewPurchaseOrderDetailsScreen(
            partner: partner,
            carrier: carrier,
            commodity: commodity,
            qcHeaderDetails: qcHeaderDetails));
      } else {
        Get.to(() => PurchaseOrderDetailsScreen(
            partner: partner,
            carrier: carrier,
            commodity: commodity,
            qcHeaderDetails: qcHeaderDetails));
      }
    } else {
      AppAlertDialog.validateAlerts(
        context,
        AppStrings.alert,
        AppStrings.selectItemsku,
      );
    }
  }

  void searchAndAssignOrder(String value) {
    filteredItemSkuList.clear();
    if (value.isEmpty) {
      filteredItemSkuList.addAll(itemSkuList);
    } else {
      filteredItemSkuList.value = itemSkuList.where((element) {
        return element.name!.toLowerCase().contains(value.toLowerCase()) ||
            element.sku!.toLowerCase().contains(value.toLowerCase());
      }).toList();
    }
    update(['itemSkuList']);
  }
}
