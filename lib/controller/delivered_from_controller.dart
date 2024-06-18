import 'package:flutter/widgets.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/delivery_to_item.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/specification_supplier_gtin.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/commodity_transfer/commodity_transfer_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_details_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class DeliveredFromController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final TextEditingController searchSuppController = TextEditingController();
  final TextEditingController searchNonOpenSuppController =
      TextEditingController();
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  final AppStorage appStorage = AppStorage.instance;
  final ApplicationDao dao = ApplicationDao();

  RxList<DeliveryToItem> filteredDeliveryToItemList = <DeliveryToItem>[].obs;
  RxList<DeliveryToItem> deliveryToItemList = <DeliveryToItem>[].obs;

  final RxInt selectedIndex = RxInt(-1);

  int? carrierID;

  double get listHeight => 200.h;

  String gtinStr = "";
  String lotNumber = "";
  String packDate2 = "";
  String? callerActivity;
  String? sealNumber;
  String? poNumber;
  String? carrierName;
  String? cteType;
  String? productTransfer;

  RxBool listAssigned = false.obs;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }

    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    poNumber = args[Consts.PO_NUMBER] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    cteType = args[Consts.CTEType] ?? '';
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';

    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    List<DeliveryToItem>? storedDeliveryList = appStorage.getDeliveryToList();
    if (storedDeliveryList != null && storedDeliveryList.isNotEmpty) {
      await JsonFileOperations.instance.offlineLoadDeliveredFrom();
      deliveryToItemList.clear();
      filteredDeliveryToItemList.clear();

      storedDeliveryList
          .sort((a, b) => a.partnerName!.compareTo(b.partnerName!));

      deliveryToItemList.addAll(storedDeliveryList);

      if (appStorage.getUserData() != null &&
          appStorage.getUserData()?.supplierId != 0) {
        for (DeliveryToItem obj in deliveryToItemList) {
          if (obj.partnerID == appStorage.getUserData()?.supplierId) {
            deliveryToItemList.remove(obj);
            break;
          }
        }
      }
      filteredDeliveryToItemList.addAll(deliveryToItemList);
    } else {
      deliveryToItemList.value = [];
      filteredDeliveryToItemList.value = [];
    }
    listAssigned.value = true;
    update(['deliveryList']);
    Future.delayed(const Duration(milliseconds: 500)).then((_) {
      update();
    });
  }

  void clearSearch() {
    searchSuppController.clear();
    searchAndAssignPartner('');
    unFocus();
  }

  void clearOpenSearch() {
    searchNonOpenSuppController.clear();
    searchAndAssignNonOpenPartner('');
  }

  void searchAndAssignPartner(String searchValue) {
    filteredDeliveryToItemList.clear();
    if (searchValue.isEmpty) {
      filteredDeliveryToItemList.addAll(deliveryToItemList);
    } else {
      List<DeliveryToItem> data = deliveryToItemList
          .where((element) => element.partnerName!
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
          .toList();
      filteredDeliveryToItemList.addAll(data);
    }
    update(['deliveryList']);
  }

  Future<void> scanGTINResultContents(String contents) async {
    String barcodeResult = contents;

    debugPrint(barcodeResult);
    if (barcodeResult.isEmpty) {
      return;
    }
    bool isOnline = globalConfigController.hasStableInternet.value;

    String dateType = "";
    String dateTypeDesc = "";

    if (barcodeResult.length > 18) {
      String check01;
      if (barcodeResult.startsWith("(")) {
        check01 = barcodeResult.substring(1, 3);
        if (check01 == "01") {
          gtinStr = barcodeResult.substring(4, 18);
          debugPrint("gtin = $gtinStr");

          if (barcodeResult.length >= 28) {
            String check02 = barcodeResult.substring(19, 21);
            debugPrint("gtin 1 = $check02");

            if (["11", "12", "13", "15", "16", "17"].contains(check02)) {
              packDate2 = barcodeResult.substring(22, 28);
              debugPrint("gtin 2 = $packDate2");

              dateType = check02;
              dateTypeDesc = getDateTypeDesc(check02, dateTypeDesc);

              DateFormat fromUser = Utils().dateFormat;
              DateFormat myFormat = Utils().dateFormat;

              try {
                packDate2 = myFormat.format(fromUser.parse(packDate2));
              } catch (e) {
                debugPrint(e as String?);
              }

              if (barcodeResult.length >= 32) {
                String check03 = barcodeResult.substring(29, 31);
                if (check03 == "10") {
                  lotNumber = barcodeResult.substring(32);

                  if (isOnline) {
                    // TODO: implement online flow
                    /*WSSpecificationSupplierGTIN webservice =
                        WSSpecificationSupplierGTIN(context);
                    webservice.RequestSpecificationSupplierGTIN(
                        gtinStr,
                        po_number,
                        seal_number,
                        carrierID,
                        carrierName,
                        lotNumber,
                        packDate,
                        "",
                        dateType);*/
                  } else {
                    List<SpecificationSupplierGTIN>?
                        specificationSupplierGTINList = await ApplicationDao()
                            .getSpecificationSupplierGTINFromTable(gtinStr);
                    if (specificationSupplierGTINList != null) {
                      appStorage.saveSpecificationSupplierGTINList(
                          specificationSupplierGTINList);
                      loadGtinOfflineMode(dateType);
                    }
                  }
                } else {
                  Utils.showErrorAlertDialog("Error reading GTIN Barcode");
                }
              } else {
                Utils.showErrorAlertDialog("Error reading GTIN Barcode");
              }
            } else if (check02 == "10") {
              lotNumber = barcodeResult.substring(22);
              debugPrint("gtin 3 = $lotNumber");

              if (isOnline) {
                // TODO: implement online flow
                /*WSSpecificationSupplierGTIN webservice =
                    WSSpecificationSupplierGTIN(context);
                webservice.RequestSpecificationSupplierGTIN(
                    gtinStr,
                    po_number,
                    seal_number,
                    carrierID,
                    carrierName,
                    lotNumber,
                    packDate,
                    "",
                    dateType);*/
              } else {
                var specificationSupplierGTINList =
                    await dao.getSpecificationSupplierGTINFromTable(gtinStr);

                if (specificationSupplierGTINList != null) {
                  appStorage.saveSpecificationSupplierGTINList(
                      specificationSupplierGTINList);
                  loadGtinOfflineMode(dateType);
                }
              }
            } else {
              Utils.showErrorAlertDialog("Error reading GTIN Barcode");
            }
          } else {
            Utils.showErrorAlertDialog("Error reading GTIN Barcode");
          }
        } else {
          Utils.showErrorAlertDialog("Error reading GTIN Barcode");
        }
      } else {
        check01 = barcodeResult.substring(0, 2);
        if (check01 == "01") {
          gtinStr = barcodeResult.substring(2, 16);
          debugPrint("gtin = $gtinStr");

          String check02 = barcodeResult.substring(16, 18);
          debugPrint("gtin 1 = $check02");

          if (["11", "12", "13", "15", "16", "17"].contains(check02)) {
            packDate2 = barcodeResult.substring(18, 24);
            debugPrint("gtin 2 = $packDate2");

            dateType = check02;
            dateTypeDesc = getDateTypeDesc(check02, dateTypeDesc);

            DateFormat formatter = Utils().dateFormat;
            packDate2 = formatter.format(DateTime.parse(packDate2));

            String check03 = barcodeResult.substring(24, 26);
            debugPrint("gtin 3 = $check03");
            if (check03 == "10") {
              lotNumber = barcodeResult.substring(26);
              debugPrint("gtin 3 = $lotNumber");

              if (isOnline) {
                // TODO: implement online flow
                /*WSSpecificationSupplierGTIN webservice =
                    WSSpecificationSupplierGTIN(context);
                webservice.RequestSpecificationSupplierGTIN(
                    gtinStr,
                    po_number,
                    seal_number,
                    carrierID,
                    carrierName,
                    lotNumber,
                    packDate,
                    "",
                    dateType);*/
              } else {
                var specificationSupplierGTINList =
                    await dao.getSpecificationSupplierGTINFromTable(gtinStr);

                if (specificationSupplierGTINList != null) {
                  appStorage.saveSpecificationSupplierGTINList(
                      specificationSupplierGTINList);
                  loadGtinOfflineMode(dateType);
                }
              }
            } else {
              Utils.showErrorAlertDialog("Error reading GTIN Barcode");
            }
          } else if (check02 == "10") {
            lotNumber = barcodeResult.substring(22);
            debugPrint("gtin 3 = $lotNumber");

            if (isOnline) {
              // TODO: implement online flow
              /*WSSpecificationSupplierGTIN webservice =
                  WSSpecificationSupplierGTIN(context);
              webservice.RequestSpecificationSupplierGTIN(
                  gtinStr,
                  po_number,
                  seal_number,
                  carrierID,
                  carrierName,
                  lotNumber,
                  packDate,
                  "",
                  dateType);*/
            } else {
              var specificationSupplierGTINList =
                  await dao.getSpecificationSupplierGTINFromTable(gtinStr);

              if (specificationSupplierGTINList != null) {
                appStorage.saveSpecificationSupplierGTINList(
                    specificationSupplierGTINList);
                loadGtinOfflineMode(dateType);
              }
            }
          } else {
            Utils.showErrorAlertDialog("Error reading GTIN Barcode");
          }
        } else {
          Utils.showErrorAlertDialog("Error reading GTIN Barcode");
        }
      }
    } else {
      Utils.showErrorAlertDialog("Error reading GTIN Barcode");
    }
  }

  String getDateTypeDesc(String check02, String dateTypeDesc) {
    switch (check02) {
      case "11":
        dateTypeDesc = "Production Date";
        break;
      case "12":
        dateTypeDesc = "Due Date";
        break;
      case "13":
        dateTypeDesc = "Pack Date";
        break;
      case "15":
        dateTypeDesc = "Best Before Date";
        break;
      case "16":
        dateTypeDesc = "Sell By Date";
        break;
      case "17":
        dateTypeDesc = "Expiration Date";
        break;
    }
    return dateTypeDesc;
  }

  Future<void> loadGtinOfflineMode(String dateType) async {
    List<SpecificationSupplierGTIN> specificationSupplierGTINList =
        appStorage.getSpecificationSupplierGTINList() ?? [];

    debugPrint(
        'specificationSupplierGTINList ${specificationSupplierGTINList.length}');

    if (specificationSupplierGTINList.length > 1) {
      List<FinishedGoodsItemSKU> list = [];

      for (var item in specificationSupplierGTINList) {
        FinishedGoodsItemSKU listItem = FinishedGoodsItemSKU.fromGtinOffline(
          id: int.parse(item.itemSkuId!),
          sku: item.itemSkuId,
          name: item.itemSkuName,
          commodityID: item.commodityId,
          commodityName: item.commodityName,
          partnerId: item.supplierId,
          partnerName: item.supplierName,
          dateType: dateType,
          gtin: gtinStr,
          lotNo: lotNumber,
          packDate: packDate2,
        );

        list.add(listItem);
      }

      // TODO: Implement GtinItemsAdapter and AlertDialog in Flutter
    } else {
      if (appStorage.selectedItemSKUList.isNotEmpty &&
          specificationSupplierGTINList[0].supplierId !=
              appStorage.selectedItemSKUList[0].partnerId) {
        Map<String, dynamic> arguments = {
          Consts.PARTNER_ID: appStorage.selectedItemSKUList[0].partnerId,
          Consts.CARRIER_NAME: carrierName,
          Consts.CARRIER_ID: carrierID,
          Consts.PO_NUMBER: poNumber,
          Consts.COMMODITY_NAME:
              appStorage.selectedItemSKUList[0].commodityName,
          Consts.COMMODITY_ID: appStorage.selectedItemSKUList[0].commodityID,
          Consts.IS_GTIN_SAME_PARTNER: false,
          Consts.CALLER_ACTIVITY: "GTINActivity",
        };

        final String tag = DateTime.now().millisecondsSinceEpoch.toString();
        Get.to(
          () => PurchaseOrderDetailsScreen(tag: tag),
          arguments: arguments,
        );
      } else {
        if (specificationSupplierGTINList.isNotEmpty) {
          String itemUniqueId = generateUUID();
          SpecificationSupplierGTIN item =
              specificationSupplierGTINList.elementAt(0);

          await dao.createSelectedItemSKU(
            skuId: int.parse(item.itemSkuId!),
            itemSKUCode: item.itemSkuCode,
            poNo: poNumber,
            lotNo: lotNumber,
            itemSKUName: item.itemSkuName,
            commodityName: item.commodityName,
            uniqueId: itemUniqueId,
            commodityId: item.commodityId,
            description: "",
            partnerID: item.supplierId,
            packDate: packDate2,
            GTIN: gtinStr,
            partnerName: item.supplierName,
            ftl: "",
            branded: "",
            dateType: dateType,
          );

          appStorage.selectedItemSKUList.add(
            FinishedGoodsItemSKU.fromGtinStorage(
              id: int.parse(item.itemSkuId!),
              sku: item.itemSkuCode,
              name: item.itemSkuName,
              commodityID: item.commodityId,
              commodityName: item.commodityName,
              uniqueItemId: itemUniqueId,
              lotNo: lotNumber,
              packDate: packDate2,
              partnerId: item.supplierId,
              gtin: gtinStr,
              partnerName: item.supplierName,
              dateType: dateType,
            ),
          );

          Map<String, dynamic> arguments = {
            Consts.PARTNER_NAME: item.supplierName,
            Consts.PARTNER_ID: item.supplierId,
            Consts.CARRIER_NAME: carrierName,
            Consts.CARRIER_ID: carrierID,
            Consts.PO_NUMBER: poNumber,
            Consts.COMMODITY_NAME: item.commodityName,
            Consts.COMMODITY_ID: item.commodityId,
            Consts.IS_GTIN_SAME_PARTNER: true,
            Consts.CALLER_ACTIVITY: "GTINActivity",
          };

          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.to(
            () => PurchaseOrderDetailsScreen(tag: tag),
            arguments: arguments,
          );
        } else {
          AppAlertDialog.confirmationAlert(
            Get.context!,
            AppStrings.alert,
            'No Item/Sku found for this GTIN',
            onYesTap: () {
              Get.back();
            },
          );
        }
      }
    }
  }

  Future<String?> scanBarcode() async {
    String? res = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.DEFAULT);
    if (res.isNotEmpty && res != '-1') {
      // if (onBarcodeScanned != null) {
      //   onBarcodeScanned!(res);
      // }
      return res;
    } else {
      return null;
    }
  }

  List<String> getListOfAlphabets() {
    Set<String> uniqueAlphabets = {};

    for (DeliveryToItem supplier in filteredDeliveryToItemList) {
      if (supplier.partnerName!.isNotEmpty &&
          supplier.partnerName![0]
              .toUpperCase()
              .contains(RegExp(r'[A-Z0-9]'))) {
        uniqueAlphabets.add(supplier.partnerName![0].toUpperCase());
      }
    }

    return uniqueAlphabets.toList();
  }

  void scrollToSection(String letter, int index) {
    int targetIndex = filteredDeliveryToItemList
        .indexWhere((supplier) => supplier.partnerName!.startsWith(letter));
    if (targetIndex != -1) {
      scrollController.animateTo(
        (targetIndex * listHeight) + (index * (listHeight * .45)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  void searchAndAssignNonOpenPartner(String searchValue) {
    selectedIndex.value = -1;
    filteredDeliveryToItemList.clear();
    if (searchValue.isEmpty) {
      filteredDeliveryToItemList.addAll(deliveryToItemList);
    } else {
      List<DeliveryToItem> data = deliveryToItemList
          .where((element) => element.partnerName!
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
          .toList();
      filteredDeliveryToItemList.addAll(data);
    }
    update(['nonOpenDeliveryList']);
  }

  Future<void> navigateToCommodityTransferScreen(
      BuildContext context, DeliveryToItem deliveryToItem) async {
    clearSearch();
    var passingData = {
      Consts.PARTNER_ID: deliveryToItem.partnerID,
      Consts.PARTNER_NAME: deliveryToItem.partnerName,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.PO_NUMBER: poNumber,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.CTEType: cteType,
      Consts.PRODUCT_TRANSFER: productTransfer,
      Consts.CALLER_ACTIVITY: "DeliveredFromActivity",
    };
    Get.to(() => const CommodityTransferScreen(), arguments: passingData);
  }
}
