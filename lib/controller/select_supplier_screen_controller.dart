import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/specification_supplier_gtin.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/commodity/commodity_id_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_details_screen.dart';
import 'package:pverify/ui/scorecard/scorecard_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/dialogs/supplier_list_dialog.dart';
import 'package:pverify/utils/utils.dart';

class SelectSupplierScreenController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  String gtinStr = "";
  String lotNumber = "";
  String packDate2 = "";
  // final CarrierItem carrier;
  // final QCHeaderDetails? qcHeaderDetails;

  // constructor
  SelectSupplierScreenController(
      /*{required this.carrier, this.qcHeaderDetails}*/);

  final TextEditingController searchSuppController = TextEditingController();

  final TextEditingController searchNonOpenSuppController =
      TextEditingController();
  final RxInt selectedIndex = RxInt(-1);

  final ApplicationDao dao = ApplicationDao();

  RxList<PartnerItem> filteredPartnerList = <PartnerItem>[].obs;
  RxList<PartnerItem> partnersList = <PartnerItem>[].obs;
  RxList<PartnerItem> filteredNonOpenPartnersList = <PartnerItem>[].obs;
  RxList<PartnerItem> nonOpenPartnersList = <PartnerItem>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 200.h;

  String? callerActivity;
  String? sealNumber;
  String? poNumber;
  String? carrierName;
  int? carrierID;
  String? cteType;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    cteType = args[Consts.CTEType] ?? '';

    super.onInit();
    assignInitialData();
  }

  void assignInitialData() {
    List<PartnerItem>? storedPartnersList = appStorage.getPartnerList();
    if (storedPartnersList == null) {
      partnersList.value = [];
      filteredPartnerList.value = [];
      listAssigned.value = true;

      filteredNonOpenPartnersList.clear();
      nonOpenPartnersList.clear();

      update(['partnerList']);
    } else {
      partnersList.clear();
      filteredPartnerList.clear();

      filteredNonOpenPartnersList.clear();
      nonOpenPartnersList.clear();

      partnersList.addAll(storedPartnersList);

      List<PartnerItem> nonOpenPartners = storedPartnersList
          .where((element) => (element.name != null &&
              !(element.name!.toLowerCase().contains("open"))))
          .toList();
      filteredNonOpenPartnersList.addAll(nonOpenPartners);
      nonOpenPartnersList.addAll(nonOpenPartners);

      partnersList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredPartnerList.addAll(storedPartnersList);
      filteredPartnerList.sort((a, b) => a.name!.compareTo(b.name!));
      listAssigned.value = true;
      update(['partnerList']);
    }
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
    filteredPartnerList.clear();
    if (searchValue.isEmpty) {
      filteredPartnerList.addAll(partnersList);
    } else {
      List<PartnerItem> data = partnersList
          .where((element) =>
              element.name!.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();
      filteredPartnerList.addAll(data);
    }
    update(['partnerList']);
  }

  void searchAndAssignNonOpenPartner(String searchValue) {
    selectedIndex.value = -1;
    filteredNonOpenPartnersList.clear();
    if (searchValue.isEmpty) {
      filteredNonOpenPartnersList.addAll(nonOpenPartnersList);
    } else {
      List<PartnerItem> data = nonOpenPartnersList
          .where((element) =>
              element.name!.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();
      filteredNonOpenPartnersList.addAll(data);
    }
    update(['nonOpenPartnerList']);
  }

  List<String> getListOfAlphabets() {
    Set<String> uniqueAlphabets = {};

    for (PartnerItem supplier in filteredPartnerList) {
      if (supplier.name!.isNotEmpty &&
          supplier.name![0].toUpperCase().contains(RegExp(r'[A-Z0-9]'))) {
        uniqueAlphabets.add(supplier.name![0].toUpperCase());
      }
    }

    return uniqueAlphabets.toList();
  }

  void scrollToSection(String letter, int index) {
    int targetIndex = filteredPartnerList
        .indexWhere((supplier) => supplier.name!.startsWith(letter));
    if (targetIndex != -1) {
      scrollController.animateTo(
        (targetIndex * listHeight) + (index * (listHeight * .45)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
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

  void navigateToScorecardScreen(PartnerItem partner) {
    final arguments = {
      Consts.SCORECARD_NAME: partner.name,
      Consts.SCORECARD_ID: partner.id,
      Consts.REDPERCENTAGE: partner.redPercentage,
      Consts.GREENPERCENTAGE: partner.greenPercentage,
      Consts.YELLOWPERCENTAGE: partner.yellowPercentage,
      Consts.ORANGEPERCENTAGE: partner.orangePercentage,
    };
    Get.to(() => ScorecardScreen(partner: partner), arguments: arguments);
  }

  Future<void> navigateToCommodityIdScreen(
      BuildContext context, PartnerItem partner) async {
    if (partner.name != null &&
        partner.name!.isNotEmpty &&
        partner.name!.toLowerCase().contains("open")) {
      selectedIndex.value = -1;
      PartnerItem? selectedPartner =
          await SupplierListDialog.showListDialog(context);
      if (selectedPartner != null) {
        clearSearch();
        // TODO: handle other type of partner Item
        Get.to(() => const CommodityIDScreen(), arguments: {
          Consts.PARTNER_ID: partner.id,
          Consts.PARTNER_NAME: partner.name,
          Consts.SEAL_NUMBER: sealNumber,
          Consts.PO_NUMBER: poNumber,
          Consts.CARRIER_NAME: carrierName,
          Consts.CARRIER_ID: carrierID,
          Consts.CTEType: cteType,
        });
      }
    } else {
      clearSearch();
      Get.to(() => const CommodityIDScreen(), arguments: {
        Consts.PARTNER_ID: partner.id,
        Consts.PARTNER_NAME: partner.name,
        Consts.SEAL_NUMBER: sealNumber,
        Consts.PO_NUMBER: poNumber,
        Consts.CARRIER_NAME: carrierName,
        Consts.CARRIER_ID: carrierID,
        Consts.CTEType: cteType,
      });
    }
  }

  Future<void> navigateToScanBarcodeScreen({
    Function(String scannedCode)? onBarcodeScanned,
  }) async {
    String? res = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.DEFAULT);
    if (res.length > 10) {
      if (onBarcodeScanned != null) {
        onBarcodeScanned(res);
      }
    } else {
      return;
    }

    // if (onBarcodeScanned != null) {
    // onBarcodeScanned!('(01)1233455566778(13)090818(10)912');

    // /// Production Date= 11 > Yellow Peppers Bulk
    // onBarcodeScanned!('(01)10012345612340(11)180322(10)01234');

    // /// Due Date= 12 > Yellow Peppers Bulk
    // onBarcodeScanned!('(01)10012345612340(12)180322(10)01234');
    //
    // /// Pack Date= 13 > Yellow Peppers Bulk
    // onBarcodeScanned!('(01)10012345612340(13)180322(10)01234');
    //
    // /// Date does not change represented by = 14 > Only displays GTIN# > Yellow Peppers Bulk
    // onBarcodeScanned!('(01)10012345612340(14)180322(10)01234');
    //
    // /// Best Used Before Date= 15 > Yellow Peppers Bulk
    // onBarcodeScanned!('(01)10012345612340(15)180322(10)01234');
    //
    // /// Sell By Date= 16 > Yellow Peppers Bulk
    // onBarcodeScanned!('(01)10012345612340(16)180322(10)01234');
    //
    // /// Expiration Date= 17 > Yellow Peppers Bulk
    // onBarcodeScanned!('(01)10012345612340(17)180322(10)01234');
    //
    // /// Production Date= 11 > Tomato Beef STK
    // onBarcodeScanned!('(01)10851059002829(11)240101(10)99123');
    //
    // /// Due Date= 12 > Tomato Beef STK
    // onBarcodeScanned!('(01)10851059002829(12)240101(10)99123');
    //
    // /// Pack Date= 13 > Tomato Beef STK
    // onBarcodeScanned!('(01)10851059002829(13)240101(10)99123');
    //
    // /// Date does not change represented by = 14 > Only displays GTIN# > > Tomato Beef STK
    // onBarcodeScanned!('(01)10851059002829(14)240101(10)99123');
    //
    // /// Best Used Before Date= 15 > Tomato Beef STK
    // onBarcodeScanned!('(01)10851059002829(15)240101(10)99123');
    //
    // /// Sell By Date= 16 > Tomato Beef STK
    // onBarcodeScanned!('(01)10851059002829(16)240101(10)99123');
    //
    // /// Expiration Date= 17 > Tomato Beef STK
    // onBarcodeScanned!('(01)10851059002829(17)240101(10)99123');
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
}
