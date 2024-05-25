import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/item_sku_data.dart';
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
  PurchaseOrderScreenController();

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
      throw Exception('Arguments required!');
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

  List<FinishedGoodsItemSKU> localItemSKUList = [];

  Future<void> assignInitialData() async {
    UserData? userData = appStorage.getUserData();

    if (userData != null) {
      if (filteredItemSkuList.isEmpty) {
        int enterpriseId =
            await dao.getEnterpriseIdByUserId(userData.userName!.toLowerCase());
        List<FinishedGoodsItemSKU>? finishedGoodItems =
            await dao.getFinishedGoodItemSkuFromTable(
          partnerID,
          enterpriseId,
          commodityID,
          commodityName,
          userData.supplierId!,
          userData.headquarterSupplierId!,
          partnerName,
        );

        itemSkuList.addAll(finishedGoodItems ?? []);
        filteredItemSkuList.addAll(itemSkuList);
        listAssigned.value = true;
        update();
      } else {
        listAssigned.value = true;
        update();
      }
    }
  }

  void updateSelectedItemSKUItem(FinishedGoodsItemSKU partner) {
    appStorage.selectedItemSKUList = appStorage.selectedItemSKUList;

    // remove if exist in appStorage.selectedItemSKUList
    appStorage.selectedItemSKUList.removeWhere((element) {
      return element.id == partner.id &&
          element.uniqueItemId == partner.uniqueItemId;
    });
    if (partner.isSelected ?? false) {
      appStorage.selectedItemSKUList.add(partner);
    } else {
      appStorage.selectedItemSKUList.remove(partner);
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
    } else {
      filteredItemSkuList.add(partner);
    }
    update(['itemSkuList']);
  }

  Future<void> navigateToPurchaseOrderDetails() async {
    UserData? userData = appStorage.getUserData();

    if (userData == null) {
      return;
    }

    int userId =
        await dao.getHeadquarterIdByUserId(userData.userName!.toLowerCase());

    if (appStorage.selectedItemSKUList.isNotEmpty) {
      if (userId == 4180) {
        Get.to(() => const NewPurchaseOrderDetailsScreen(), arguments: {
          Consts.PARTNER_NAME: partnerName,
          Consts.PARTNER_ID: partnerID,
          Consts.CARRIER_NAME: carrierName,
          Consts.CARRIER_ID: carrierID,
          Consts.COMMODITY_ID: commodityID,
          Consts.COMMODITY_NAME: commodityName,
          Consts.PO_NUMBER: poNumber,
          Consts.SEAL_NUMBER: sealNumber,
        });
      } else {
        final String tag = DateTime.now().millisecondsSinceEpoch.toString();
        Get.to(() => PurchaseOrderDetailsScreen(tag: tag), arguments: {
          Consts.PARTNER_ID: partnerID,
          Consts.PARTNER_NAME: partnerName,
          Consts.CARRIER_ID: carrierID,
          Consts.CARRIER_NAME: carrierName,
          Consts.COMMODITY_ID: commodityID,
          Consts.COMMODITY_NAME: commodityName,
          Consts.PO_NUMBER: poNumber,
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
      List<FinishedGoodsItemSKU> data = itemSkuList.where((element) {
        return element.name!.toLowerCase().contains(value.toLowerCase()) ||
            element.sku!.toLowerCase().contains(value.toLowerCase());
      }).toList();
      filteredItemSkuList.addAll(data);
    }
    update(['itemSkuList']);
  }

  void clearSearch() {
    searchController.clear();
    searchAndAssignOrder('');
    unFocus();
  }
}
