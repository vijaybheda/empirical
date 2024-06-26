import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/purchase_order_header.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/utils.dart';

class PoNumberListController extends GetxController {
  final TextEditingController searchSuppController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  String? carrierName;
  int? carrierID;
  String? partnerName;
  final RxInt selectedIndex = RxInt(-1);

  RxList<PurchaseOrderHeader> filteredPoList = <PurchaseOrderHeader>[].obs;
  RxList<PurchaseOrderHeader> purchaseOrderHeaderList1 =
      <PurchaseOrderHeader>[].obs;

  double get listHeight => 200.h;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    if (purchaseOrderHeaderList1.isEmpty) {
      appStorage.purchaseOrderHeaderList = await dao.getPOHeaderListFromTable();
      if (appStorage.purchaseOrderHeaderList!.isEmpty) {
        Get.off(() => const QualityControlHeader(), arguments: {
          Consts.CALLER_ACTIVITY: 'TrendingReportActivity',
          Consts.CARRIER_NAME: carrierName,
          Consts.CARRIER_ID: carrierID,
        });
      } else {
        purchaseOrderHeaderList1.value = appStorage.purchaseOrderHeaderList!;
        int i = 0;
        while (i < purchaseOrderHeaderList1.length) {
          PurchaseOrderHeader tempPurchaseOrder = purchaseOrderHeaderList1[i];

          List<PurchaseOrderDetails> purchaseOrderDetails =
              await dao.getPODetailsFromTable(
            tempPurchaseOrder.poNumber,
            appStorage.getUserData()!.supplierId!,
          );
          if (purchaseOrderDetails.isEmpty) {
            purchaseOrderHeaderList1.removeAt(i);
          } else {
            List<int> inspIDs = await dao
                .getPartnerSKUInspectionIDsByPONo(tempPurchaseOrder.poNumber);

            for (int j = 0; j < inspIDs.length; j++) {
              var inspection = await dao.findInspectionByID(inspIDs[j]);
              if (inspection == null) {
                var partnerItemSKU = await dao.findPartnerItemSKUPONumber(
                    inspIDs[j], tempPurchaseOrder.poNumber);
                if (partnerItemSKU != null) {
                  PurchaseOrderDetails? targetObject;
                  for (var customObject in purchaseOrderDetails) {
                    if (customObject.itemSkuCode == partnerItemSKU.itemSKU &&
                        customObject.poNumber == tempPurchaseOrder.poNumber) {
                      targetObject = customObject;
                      break;
                    }
                  }
                  if (targetObject != null) {
                    purchaseOrderDetails.remove(targetObject);
                  }
                }
              }
            }
            if (purchaseOrderDetails.isEmpty) {
              purchaseOrderHeaderList1.removeAt(i);
            } else {
              i++;
            }
          }
        }
        PurchaseOrderHeader listItem = PurchaseOrderHeader(
            poNumber: '', partnerId: 0, partnerName: 'Other');
        purchaseOrderHeaderList1.insert(0, listItem);

        setData(purchaseOrderHeaderList1);
      }
    } else {
      setData(purchaseOrderHeaderList1);
    }
  }

  void setData(List<PurchaseOrderHeader> itemSKUList) {
    filteredPoList.value = itemSKUList;
    update(['poList']);
  }

  void clearSearch() {
    searchSuppController.clear();
    searchAndAssignPurchaseOrderHeader('');
    unFocus();
  }

  void searchAndAssignPurchaseOrderHeader(String searchValue) {
    selectedIndex.value = -1;
    filteredPoList.clear();
    if (searchValue.isEmpty) {
      filteredPoList.addAll(purchaseOrderHeaderList1);
    } else {
      List<PurchaseOrderHeader> data = filteredPoList
          .where((element) => element.partnerName
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
          .toList();
      filteredPoList.addAll(data);
    }
    update(['poList']);
  }

  void scrollToSection(String letter, int index) {
    int targetIndex = filteredPoList
        .indexWhere((supplier) => supplier.partnerName.startsWith(letter));
    if (targetIndex != -1) {
      scrollController.animateTo(
        (targetIndex * listHeight) + (index * (listHeight * .45)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }
}
