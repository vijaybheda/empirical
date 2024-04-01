import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/specification_supplier_gtin.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/commodity/commodity_id_screen.dart';
import 'package:pverify/ui/scorecard/scorecard_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/dialogs/supplier_list_dialog.dart';
import 'package:pverify/utils/utils.dart';

class SelectSupplierScreenController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final CarrierItem carrier;

  // constructor
  SelectSupplierScreenController({required this.carrier});

  final TextEditingController searchOpenSuppController =
      TextEditingController();
  final RxInt selectedIndex = RxInt(-1);

  final ApplicationDao dao = ApplicationDao();

  RxList<PartnerItem> filteredPartnerList = <PartnerItem>[].obs;
  RxList<PartnerItem> partnersList = <PartnerItem>[].obs;
  RxList<PartnerItem> filteredNonOpenPartnersList = <PartnerItem>[].obs;
  RxList<PartnerItem> nonOpenPartnersList = <PartnerItem>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 180.h;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  void assignInitialData() {
    List<PartnerItem>? _partnersList = appStorage.getPartnerList();
    if (_partnersList == null) {
      partnersList.value = [];
      filteredPartnerList.value = [];
      listAssigned.value = true;
      update(['partnerList']);
    } else {
      partnersList.value = [];
      filteredPartnerList.value = [];

      partnersList.addAll(_partnersList);

      List<PartnerItem> nonOpenPartners = _partnersList
          .where((element) => (element.name != null &&
              !(element.name!.toLowerCase().contains("open"))))
          .toList();
      filteredNonOpenPartnersList.addAll(nonOpenPartners);
      nonOpenPartnersList.addAll(nonOpenPartners);

      partnersList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredPartnerList.addAll(_partnersList);
      filteredPartnerList.sort((a, b) => a.name!.compareTo(b.name!));
      listAssigned.value = true;
      update(['partnerList']);
    }
  }

  void searchAndAssignPartner(String searchValue) {
    filteredPartnerList.clear();
    if (searchValue.isEmpty) {
      filteredPartnerList.addAll(partnersList);
    } else {
      filteredPartnerList.value = partnersList
          .where((element) =>
              element.name!.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();
    }
    update(['partnerList']);
  }

  void searchAndAssignNonOpenPartner(String searchValue) {
    filteredNonOpenPartnersList.clear();
    if (searchValue.isEmpty) {
      filteredNonOpenPartnersList.addAll(nonOpenPartnersList);
    } else {
      filteredNonOpenPartnersList.value = nonOpenPartnersList
          .where((element) =>
              element.name!.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();
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

    bool isOnline = globalConfigController.hasStableInternet.value;

    String packDate = "";
    String dateType = "";
    String dateTypeDesc = "";
    String gtinStr = "";
    String lotNumber = "";

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
              packDate = barcodeResult.substring(22, 28);
              debugPrint("gtin 2 = $packDate");

              dateType = check02;
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

              DateFormat fromUser = DateFormat("yyMMdd");
              DateFormat myFormat = DateFormat("MM-dd-yyyy");

              try {
                packDate = myFormat.format(fromUser.parse(packDate));
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
            packDate = barcodeResult.substring(18, 24);
            debugPrint("gtin 2 = $packDate");

            dateType = check02;
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

            DateFormat formatter = DateFormat("MM-dd-yyyy");
            packDate = formatter.format(DateTime.parse(packDate));

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

  Future<void> loadGtinOfflineMode(String dateType) async {
    List<SpecificationSupplierGTIN>? specificationSupplierGTINList =
        appStorage.getSpecificationSupplierGTINList();

    debugPrint(
        'specificationSupplierGTINList ${specificationSupplierGTINList?.length}');
    /*if (specificationSupplierGTINList.length > 1) {
      List<FinishedGoodsItemSKU> list = [];
      for (int i = 0; i < specificationSupplierGTINList.length; i++) {
        FinishedGoodsItemSKU listItem = FinishedGoodsItemSKU(
          itemSkuId: int.parse(specificationSupplierGTINList[i].itemSkuId),
          itemSkuCode: specificationSupplierGTINList[i].itemSkuCode,
          itemSkuName: specificationSupplierGTINList[i].itemSkuName,
          commodityId: specificationSupplierGTINList[i].commodityId,
          commodityName: specificationSupplierGTINList[i].commodityName,
          supplierId: specificationSupplierGTINList[i].supplierId,
          supplierName: specificationSupplierGTINList[i].supplierName,
          dateType: dateType,
          gtin: gtinstr,
          lotNumber: lotNumber,
          packDate: packDate2,
        );
        list.add(listItem);
      }
      itemListAdapter = GtinItemsAdapter(list: list, dao: dao);
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Select an item"),
            content: Container(
              width: double.maxFinite,
              child: itemListAdapter,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  if (AppInfo.selectedItemSKUList != null &&
                      AppInfo.selectedItemSKUList.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PurchaseOrderDetailsActivity(
                          partnerName: AppInfo
                              .specificationSupplierGTINList[0].supplierName,
                          partnerId: int.parse(
                              AppInfo.selectedItemSKUList[0].partnerId),
                          carrierName: carrierName,
                          carrierId: carrierID,
                          commodityId:
                              AppInfo.selectedItemSKUList[0].commodityID,
                          commodityName: AppInfo
                              .specificationSupplierGTINList[0].commodityName,
                          poNumber: po_number,
                        ),
                      ),
                    );
                  } else {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Alert"),
                          content: Text("Please select an item."),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(),
                              child: Text("OK"),
                            ),
                          ],
                        );
                      },
                    );
                  }
                },
                child: Text("OK"),
              ),
            ],
          );
        },
      );
    } else {
      if (AppInfo.selectedItemSKUList != null &&
          AppInfo.selectedItemSKUList.isNotEmpty &&
          specificationSupplierGTINList.isNotEmpty &&
          int.parse(specificationSupplierGTINList[0].supplierId) !=
              int.parse(AppInfo.selectedItemSKUList[0].partnerId)) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PurchaseOrderDetailsActivity(
              partnerId: int.parse(AppInfo.selectedItemSKUList[0].partnerId),
              carrierName: carrierName,
              carrierId: carrierID,
              poNumber: po_number,
              commodityName: AppInfo.selectedItemSKUList[0].commodityName,
              commodityId: AppInfo.selectedItemSKUList[0].commodityID,
              isGTINSamePartner: false,
            ),
          ),
        );
      } else {
        if (specificationSupplierGTINList.isNotEmpty) {
          String itemUniqueId = Uuid().v4();
          dao.createSelectedItemSKU(
            int.parse(specificationSupplierGTINList[0].itemSkuId),
            specificationSupplierGTINList[0].itemSkuCode,
            po_number,
            lotNumber,
            specificationSupplierGTINList[0].itemSkuName,
            specificationSupplierGTINList[0].commodityName,
            itemUniqueId,
            specificationSupplierGTINList[0].commodityId,
            "",
            specificationSupplierGTINList[0].supplierId,
            packDate2,
            gtinstr,
            specificationSupplierGTINList[0].supplierName,
            "",
            "",
            dateType,
          );
          AppInfo.selectedItemSKUList.add(
            FinishedGoodsItemSKU(
              int.parse(specificationSupplierGTINList[0].itemSkuId),
              specificationSupplierGTINList[0].itemSkuCode,
              specificationSupplierGTINList[0].itemSkuName,
              specificationSupplierGTINList[0].commodityId,
              specificationSupplierGTINList[0].commodityName,
              itemUniqueId,
              lotNumber,
              packDate2,
              specificationSupplierGTINList[0].supplierId,
              gtinstr,
              specificationSupplierGTINList[0].supplierName,
              dateType,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PurchaseOrderDetailsActivity(
                partnerName: specificationSupplierGTINList[0].supplierName,
                partnerId:
                    int.parse(specificationSupplierGTINList[0].supplierId),
                carrierName: carrierName,
                carrierId: carrierID,
                poNumber: po_number,
                commodityName: specificationSupplierGTINList[0].commodityName,
                commodityId: specificationSupplierGTINList[0].commodityId,
                isGTINSamePartner: true,
              ),
            ),
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text("Alert"),
                content: Text("No Item/Sku found for this GTIN"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("OK"),
                  ),
                ],
              );
            },
          );
        }
      }
    }*/
  }

  void navigateToPartnerDetails(PartnerItem partner) {
    Get.to(() => ScorecardScreen(partner: partner));
  }

  void navigateToCommodityIdScreen(BuildContext context, PartnerItem partner) {
    if (partner.name != null &&
        partner.name!.isNotEmpty &&
        partner.name!.toLowerCase().contains("open")) {
      SupplierListDialog.show(context);
    } else {
      Get.to(() => CommodityIDScreen(partner: partner));
    }
  }
}
