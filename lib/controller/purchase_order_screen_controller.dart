import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/user_data.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/purchase_order/new_purchase_order_details_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_details_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class PurchaseOrderScreenController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;

  late final String poNumber;
  late final String sealNumber;
  late final String partnerName;
  late final int partnerID;
  late final String carrierName;
  late final int carrierID;
  late final int commodityID;
  late final String commodityName;
  late final String productTransfer;

  final TextEditingController searchController = TextEditingController();
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
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments not allowed');
    }

    poNumber = args[Consts.PO_NUMBER] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? '';
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';

    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    UserData? userData = appStorage.getUserData();

    if (userData != null) {
      if (filteredItemSkuList.isEmpty) {
        int enterpriseId =
            await dao.getEnterpriseIdByUserId(userData.userName!.toLowerCase());
        // TODO:
        List<FinishedGoodsItemSKU>? finishedGoodItems =
            await dao.getFinishedGoodItemSkuFromTable(
          partner.id!,
          enterpriseId,
          commodity.id!,
          commodity.name!,
          userData.supplierId!,
          userData.headquarterSupplierId!,
          partner.name!,
        );

        itemSkuList.addAll(finishedGoodItems ?? []);
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
    appStorage.selectedItemSKUList = appStorage.selectedItemSKUList;

    // remove if exist in appStorage.selectedItemSKUList
    appStorage.selectedItemSKUList.removeWhere((element) {
      return element.id == partner.id;
    });
    if (partner.isSelected ?? false) {
      appStorage.selectedItemSKUList.add(partner);
    }

    debugPrint("${appStorage.selectedItemSKUList.length}");
    int index = filteredItemSkuList.indexWhere((element) {
      return element.id == partner.id;
    });

    if (index != -1) {
      filteredItemSkuList[index] = partner;
      int filteredIndex = filteredItemSkuList.indexWhere((element) {
        return element.id == partner.id;
      });
      if (filteredIndex != -1) {
        itemSkuList[filteredIndex] = partner;
      }
      update(['itemSkuList']);
    }
  }

  Future<void> navigateToPurchaseOrderDetails(
    PartnerItem partner,
    CarrierItem carrier,
    CommodityItem commodity,
  ) async {
    UserData? userData = appStorage.getUserData();

    if (userData == null) {
      return;
    }

    int userId =
        await dao.getHeadquarterIdByUserId(userData.userName!.toLowerCase());

    if (appStorage.selectedItemSKUList.isNotEmpty) {
      if (userId == 4180) {
        Get.to(
            () => NewPurchaseOrderDetailsScreen(
                partner: partner,
                carrier: carrier,
                commodity: commodity,
                qcHeaderDetails: qcHeaderDetails),
            arguments: {
              Consts.SERVER_INSPECTION_ID: qcHeaderDetails?.id ?? 0,
              Consts.PARTNER_NAME: partner..name,
              Consts.PARTNER_ID: partner.id,
              Consts.CARRIER_NAME: carrier.name,
              Consts.CARRIER_ID: carrier.id,
              Consts.COMMODITY_ID: commodity.id,
              Consts.COMMODITY_NAME: commodity.name,
              Consts.PO_NUMBER: qcHeaderDetails?.poNo,
              Consts.SEAL_NUMBER: qcHeaderDetails?.sealNo,
            });
      } else {
        Get.to(
            () => PurchaseOrderDetailsScreen(
                partner: partner,
                carrier: carrier,
                commodity: commodity,
                qcHeaderDetails: qcHeaderDetails),
            arguments: {
              Consts.SERVER_INSPECTION_ID: qcHeaderDetails?.id ?? 0,
              Consts.PARTNER_ID: partner.id,
              Consts.PARTNER_NAME: partner.name,
              Consts.CARRIER_ID: carrier.id,
              Consts.CARRIER_NAME: carrier.name,
              Consts.COMMODITY_ID: commodity.id,
              Consts.COMMODITY_NAME: commodity.name,
              Consts.PO_NUMBER: qcHeaderDetails?.poNo,
            });
      }
    } else {
      AppAlertDialog.validateAlerts(
        Get.context!,
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

  void clearSearch() {
    searchController.clear();
    searchAndAssignOrder('');
    unFocus();
  }
}
