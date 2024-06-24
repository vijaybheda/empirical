import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/dialog_progress_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/new_purchase_order_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_grade_tolerance.dart';
import 'package:pverify/models/specification_grade_tolerance_array.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/commodity/commodity_id_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_screen.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';
import 'package:pverify/ui/trailer_temp/trailertemp.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/utils.dart';

class NewPurchaseOrderDetailsController extends GetxController {
  int serverInspectionID = -1;
  String partnerName = "";
  int partnerID = 0;
  String carrierName = "";
  int carrierID = 0;
  int commodityID = 0;
  String commodityName = "";
  String? poNumber;
  String sealNumber = "";
  String callerActivity = "";
  String? specificationNumber,
      specificationVersion,
      specificationName,
      specificationTypeName;
  String currentLotNumber = '',
      currentItemSKU = '',
      currentPackDate = '',
      currentLotSize = '',
      currentItemSKUName = '';
  String itemUniqueId = "";
  int itemSkuId = 0;
  bool isGTINSamePartner = true;

  final TextEditingController searchController = TextEditingController();

  RxList<NewPurchaseOrderItem> filteredInspectionsList =
      <NewPurchaseOrderItem>[].obs;
  RxList<NewPurchaseOrderItem> itemSkuList = <NewPurchaseOrderItem>[].obs;
  RxBool listAssigned = false.obs;

  final AppStorage appStorage = AppStorage.instance;
  final ApplicationDao dao = ApplicationDao();
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  NewPurchaseOrderDetailsController();

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }
    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? "";
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? "";
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    poNumber = args[Consts.PO_NUMBER] ?? "";
    sealNumber = args[Consts.SEAL_NUMBER] ?? "";
    currentLotNumber = args[Consts.LOT_NO] ?? "";
    currentItemSKU = args[Consts.ITEM_SKU] ?? "";
    currentPackDate = args[Consts.PACK_DATE] ?? "";
    currentLotSize = args[Consts.LOT_SIZE] ?? "";
    currentItemSKUName = args[Consts.ITEM_SKU_NAME] ?? "";
    specificationNumber = args[Consts.SPECIFICATION_NUMBER];
    specificationVersion = args[Consts.SPECIFICATION_VERSION];
    specificationName = args[Consts.SPECIFICATION_NAME];
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME];
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? "";
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? "";
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? "";
    isGTINSamePartner = args[Consts.IS_GTIN_SAME_PARTNER] ?? true;

    super.onInit();

    if (callerActivity != "") {
      if (callerActivity == "GTINActivity") {
        if (appStorage.selectedItemSKUList.isNotEmpty) {
          if (!isGTINSamePartner) {
            Future.delayed(const Duration(milliseconds: 500), () {
              AppAlertDialog.validateAlerts(
                Get.context!,
                AppStrings.alert,
                "GTIN has to be for the same supplier: $partnerName\nFinish & upload pfg for $partnerName\n\nFor a new supplier go to the Home page and select Inspect New Product",
              );
            });
          }
        }
      }
    }

    onCreate();
    onResume();
  }

  void searchAndAssignItems(String searchValue) {
    filteredInspectionsList.clear();
    if (searchValue.isEmpty) {
      filteredInspectionsList.addAll(itemSkuList);
    } else {
      var items = itemSkuList.where((element) {
        String? sku = element.sku;
        String searchKey = searchValue.toLowerCase();

        return (sku != null && sku.toLowerCase().contains(searchKey));
      }).toList();
      filteredInspectionsList.addAll(items);
    }
    update();
  }

  void clearSearch() {
    searchController.clear();
    searchAndAssignItems("");
    unFocus();
  }

  List<NewPurchaseOrderItem> getPurchaseOrderData() {
    List<NewPurchaseOrderItem> list = [];

    for (FinishedGoodsItemSKU item in appStorage.selectedItemSKUList) {
      NewPurchaseOrderItem purchaseOrderItem = NewPurchaseOrderItem(
        description: item.name,
        sku: item.sku,
        poNumber: item.poNo,
        sealNumber: "",
        lotNumber: item.lotNo,
        commodityId: item.commodityID,
        commodityName: item.commodityName,
        packDate: item.packDate,
        quantity: item.quantity,
        quantityUOM: item.quantityUOM,
        quantityUOMName: item.quantityUOMName,
        number_spec: item.number_spec,
        version_spec: item.version_spec,
        poLineNo: item.poLineNo,
        partnerId: item.partnerId,
        ftl: item.FTLflag,
        branded: item.Branded,
      );
      list.add(purchaseOrderItem);
    }
    return list;
  }

  void onCreate() async {
    List<FinishedGoodsItemSKU> selectedItemSKUList =
        await dao.getSelectedItemSKUList();
  }

  Future<void> onResume() async {
    if (callerActivity != "") {
      if (callerActivity == "QCDetailsShortForm") {
        for (var i = 0; i < appStorage.selectedItemSKUList.length; i++) {
          bool isComplete = await dao.isInspectionComplete(
              partnerID,
              appStorage.selectedItemSKUList[i].sku!,
              appStorage.selectedItemSKUList[i].uniqueItemId);

          if (isComplete) {
            PartnerItemSKUInspections? partnerItemSKU =
                await dao.findPartnerItemSKU(
                    partnerID,
                    appStorage.selectedItemSKUList[i].sku!,
                    appStorage.selectedItemSKUList[i].uniqueItemId);

            if (partnerItemSKU != null) {
              Inspection? inspection2 =
                  await dao.findInspectionByID(partnerItemSKU.inspectionId!);
              if (inspection2 != null && inspection2.result != null) {
                callerActivity = "NewPurchaseOrderDetailsActivity";
                AppAlertDialog.confirmationAlert(
                    Get.context!, AppStrings.alert, "Calculate results?",
                    onYesTap: () {
                  calculateButtonClick();
                });
                break;
              }
            }
          }
        }
      }
    }
  }

  Future<void> calculateButtonClick() async {
    String itemsSpecStr = "";
    String result = "";

    List<SpecificationGradeToleranceArray>
        specificationGradeToleranceArrayList = [];

    for (var i = 0; i < appStorage.selectedItemSKUList.length; i++) {
      bool isComplete = await dao.isInspectionComplete(
          partnerID,
          appStorage.selectedItemSKUList[i].sku!,
          appStorage.selectedItemSKUList[i].uniqueItemId);

      if (isComplete) {
        PartnerItemSKUInspections? partnerItemSKU =
            await dao.findPartnerItemSKU(
                partnerID,
                appStorage.selectedItemSKUList[i].sku!,
                appStorage.selectedItemSKUList[i].uniqueItemId);

        if (partnerItemSKU != null && partnerItemSKU.inspectionId != null) {
          Inspection? inspection =
              await dao.findInspectionByID(partnerItemSKU.inspectionId!);

          if (inspection != null && inspection.inspectionId != null) {
            await dao
                .deleteRejectionDetailByInspectionId(inspection.inspectionId!);

            QCHeaderDetails? qcHeaderDetails =
                await dao.findTempQCHeaderDetails(inspection.poNumber!);

            if (qcHeaderDetails != null && qcHeaderDetails.truckTempOk == "N") {
              result = "RJ";

              QualityControlItem? qualityControlItems = await dao
                  .findQualityControlDetails(partnerItemSKU.inspectionId!);
              if (qualityControlItems != null) {
                await dao.updateQuantityRejected(inspection.inspectionId!,
                    qualityControlItems.qtyShipped!, 0);
              }

              await dao.updateInspectionResult(
                  inspection.inspectionId!, result);
              await dao.updateOverriddenResult(
                  inspection.inspectionId!, result);

              await dao.createOrUpdateInspectionSpecification(
                  inspection.inspectionId!,
                  specificationNumber,
                  specificationVersion,
                  specificationName);

              await dao.updateInspectionComplete(
                  inspection.inspectionId!, true);
              await dao.updateItemSKUInspectionComplete(
                  inspection.inspectionId!, true);
              Utils.setInspectionUploadStatus(
                  inspection.inspectionId!, Consts.INSPECTION_UPLOAD_READY);

              await dao.createOrUpdateResultReasonDetails(
                  inspection.inspectionId!, result, "Truck Temp Ok = No", "");

              // TODO: confirm with Android dev if this is correct
              // footerRightButtonText.visibility = Visibility.Visible;
              update();
            } else {
              try {
                itemsSpecStr +=
                    "${inspection.specificationNumber!}:${inspection.specificationVersion},";

                List<SpecificationGradeTolerance>
                    specificationGradeToleranceList =
                    await dao.getSpecificationGradeTolerance(
                        inspection.specificationNumber!,
                        inspection.specificationVersion!);
                SpecificationGradeToleranceArray
                    specificationGradeToleranceArray =
                    SpecificationGradeToleranceArray(
                  specificationNumber: inspection.specificationNumber,
                  specificationVersion: inspection.specificationVersion,
                  specificationGradeToleranceList:
                      specificationGradeToleranceList,
                );
                specificationGradeToleranceArrayList
                    .add(specificationGradeToleranceArray);
              } catch (e) {
                print(e);
              }
            }
          }
        }
      }
    }
    if (result != "RJ") {
      if (itemsSpecStr.isNotEmpty && itemsSpecStr.endsWith(",")) {
        itemsSpecStr = itemsSpecStr.substring(0, itemsSpecStr.length - 1);

        appStorage.specificationGradeToleranceArrayList =
            specificationGradeToleranceArrayList;
        // TODO: implement calculate Result
        // await calculateResult();
        update();
      } else {
        AppSnackBar.info(message: "No Items are complete for calculation");
      }
    }
  }

  Future<void> onHomeMenuTap() async {
    bool isValid = true;
    bool isValid2 = true;
    bool isValid3 = true;

    for (var i = 0; i < appStorage.selectedItemSKUList.length; i++) {
      bool isComplete = await dao.isInspectionComplete(
          partnerID,
          appStorage.selectedItemSKUList[i].sku!,
          appStorage.selectedItemSKUList[i].uniqueItemId);

      PartnerItemSKUInspections? partnerItemSKU =
          await dao.findPartnerItemSKUPOLine(
              partnerID,
              appStorage.selectedItemSKUList[i].sku!,
              appStorage.selectedItemSKUList[i].poLineNo!,
              poNumber!);

      if (partnerItemSKU != null) {
        Inspection? inspection =
            await dao.findInspectionByID(partnerItemSKU.inspectionId!);

        if (inspection != null) {
          QualityControlItem? qualityControlItems =
              await dao.findQualityControlDetails(inspection.inspectionId!);
          if (qualityControlItems != null) {
            if (qualityControlItems.qtyShipped! <
                    qualityControlItems.qtyRejected! ||
                qualityControlItems.qtyShipped! <= 0) {
              isValid2 = false;
            }
          }

          appStorage.specificationAnalyticalList =
              await dao.getSpecificationAnalyticalFromTable(
                  appStorage.selectedItemSKUList[i].number_spec!,
                  appStorage.selectedItemSKUList[i].version_spec!);

          if (appStorage.specificationAnalyticalList != null) {
            for (final item in appStorage.specificationAnalyticalList!) {
              if (item.analyticalName?.contains("Quality Check") ?? false) {
                if ((item.isPictureRequired ?? false) &&
                    (inspection.rating > 0 && inspection.rating <= 2)) {
                  List<InspectionAttachment>? picsFromDB =
                      await dao.findInspectionAttachmentsByInspectionId(
                          inspection.inspectionId!);

                  if (picsFromDB.isEmpty) {
                    isValid = false;
                    break;
                  }
                }
              } else if (item.analyticalName?.contains("Branded") ?? false) {
                final SpecificationAnalyticalRequest? dbobj =
                    await dao.findSpecAnalyticalObj(
                        inspection.inspectionId!, item.analyticalID!);

                if (dbobj == null) {
                  isValid3 = false;
                  break;
                }
              }
            }
          }
        }
      }
    }

    if (isValid) {
      if (isValid2) {
        if (isValid3) {
          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.offAll(() => Home(tag: tag));
        } else {
          AppAlertDialog.validateAlerts(
            Get.context!,
            AppStrings.alert,
            "All inspected rows require Branded Y/N.\n\nIs the product in a PFG private label box?\n(White box for Peak or Brown box for Growers Choice)",
          );
        }
      } else {
        AppAlertDialog.validateAlerts(
          Get.context!,
          AppStrings.alert,
          "Please enter valid quantity shipped/rejected.",
        );
      }
    } else {
      AppAlertDialog.validateAlerts(
        Get.context!,
        AppStrings.alert,
        "All rejected rows require at least 1 picture",
      );
    }
  }

  void onTailerTempMenuTap() {
    Map<String, dynamic> arguments = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PO_NUMBER: poNumber,
      Consts.CALLER_ACTIVITY: "NewPurchaseOrderDetailsActivity",
    };
    Get.to(() => const TrailerTemp(), arguments: arguments);
  }

  Future<void> onQCHeaderMenuTap() async {
    Map<String, dynamic> arguments = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PO_NUMBER: poNumber,
      Consts.CALLER_ACTIVITY: "QualityControlHeaderActivity",
    };
    Get.to(() => const QualityControlHeader(), arguments: arguments);
  }

  Future<void> onAddGradingStandardMenuTap() async {
    Map<String, dynamic> passingData = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.PO_NUMBER: poNumber,
      Consts.CALLER_ACTIVITY: "NewPurchaseOrderDetailsActivity",
    };
    Get.to(
      () => const CommodityIDScreen(),
      arguments: passingData,
    );
  }

  Future<void> onSelectItemMenuTap() async {
    Map<String, dynamic> passingData = {
      Consts.PO_NUMBER: poNumber,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMMODITY_NAME: commodityName,
    };
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.to(
      () => PurchaseOrderScreen(tag: tag),
      arguments: passingData,
    );
  }

  Future<void> uploadAllInspections() async {
    final List<int> uploadCheckedList =
        await dao.findReadyToUploadInspectionIDs();

    if (uploadCheckedList.isNotEmpty) {
      final List<int> failedList = [];

      for (int i = 0; i < uploadCheckedList.length; i++) {
        final Inspection? inspection =
            await dao.findInspectionByID(uploadCheckedList[i]);

        if (inspection?.commodityId == 0) {
          uploadCheckedList.removeAt(i);
          failedList.add(uploadCheckedList[i]);
        }
      }

      final ProgressController progressController =
          Get.put(ProgressController());
      Utils.showLinearProgressWithMessage(
        message: AppStrings.uploadMessage,
        progressController: progressController,
        totalInspection: uploadCheckedList.length,
      );

      int numberOfInspections = uploadCheckedList.length;
      int listIndex = 0;
      int progressDialogStatus = 0;

      while (progressDialogStatus < numberOfInspections) {
        try {
          await Utils().uploadInspection(uploadCheckedList[listIndex]);
          progressDialogStatus = ++listIndex;

          // Update the progress bar
          progressController.updateProgress(progressDialogStatus.toDouble());
          if (progressDialogStatus >= numberOfInspections) {
            Get.back();
          }
        } catch (e) {
          print('upload error = $e');
        }
      }
    } else {
      final List<int> incompleteInspectionList =
          await dao.getAllIncompleteInspectionIDs();

      for (int i = 0; i < incompleteInspectionList.length; i++) {
        await dao.deleteInspection(incompleteInspectionList[i]);
      }

      await Get.to(() => const CacheDownloadScreen(), arguments: {
        Consts.IS_QCDETAILSHORT_SCREEN: true,
      });

      await appStorage.setInt(
          StorageKey.kCacheDate, DateTime.now().millisecondsSinceEpoch);
      await appStorage.write(StorageKey.kIsCSVDownloaded1, true);
    }
  }

  Future<void> downloadTap() async {
    if (globalConfigController.hasStableInternet.value) {
      UpdateDataAlert.showUpdateDataDialog(
        Get.context!,
        onOkPressed: () async {
          bool checkInsp = await dao.checkInspections();
          if (checkInsp) {
            UpdateDataAlert.showUpdateDataDialog(Get.context!,
                onOkPressed: () async {
              await uploadAllInspections();
            }, message: AppStrings.updateDataMessage);
          } else {
            debugPrint('Download button tap.');
            await Get.off(
              () => const CacheDownloadScreen(),
              arguments: {
                Consts.IS_QCDETAILSHORT_SCREEN: true,
              },
            );
          }
        },
        message: AppStrings.updateDataConfirmation,
      );
    } else {
      UpdateDataAlert.showUpdateDataDialog(Get.context!, onOkPressed: () {
        debugPrint('Download button tap.');
      }, message: AppStrings.downloadWifiError);
    }
  }
}
