import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/defects/table_dialog.dart';
import 'package:pverify/ui/inspection_photos/inspection_photos_screen.dart';
import 'package:pverify/ui/purchase_order/new_purchase_order_details_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_details_screen.dart';
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class SpecificationAttributesController extends GetxController {
  int? partnerID;
  int? carrierID;
  int? commodityID;
  int? poLineNo, varietyId, gradeId, itemSkuId;
  int? inspectionId;
  int? serverInspectionId;
  int sampleSizeByCount = 0;
  int? qcID;

  String? partnerName;
  String? carrierName;
  String? commodityName;
  String? inspectionResult;
  String? itemSKU, itemSkuName, lotNo;
  String? poNumber;
  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;
  String? selectedSpecification;
  String? productTransfer;
  String? callerActivity;
  String? is1stTimeActivity;
  String? gtin,
      gln,
      sealNumber,
      varietyName,
      varietySize,
      itemUniqueId,
      lotSize;
  String? resultComply;

  String? packDate;
  String? footerLeftButtonText,
      footerMiddleButtonText,
      footerMiddle2ButtonText,
      footerMiddle3ButtonText;
  String? headerText, varietyText, commodityText;
  String dateTypeDesc = '';
  String tag = 'SpecificationAttributesActivity';

  bool? isMyInspectionScreen;
  bool? partialCompleted;
  bool? completed;
  bool hasError2 = false;
  RxBool hasInitialised = false.obs;

  RxList<SpecificationAnalytical> listSpecAnalyticals =
      <SpecificationAnalytical>[].obs;
  List<SpecificationAnalyticalRequest> listSpecAnalyticalsRequest = [];
  List<String> operatorList = ['Select', 'Yes', 'No', 'N/A'];
  List<SpecificationAnalyticalRequest?> dbobjList = [];

  final AppStorage _appStorage = AppStorage.instance;
  final ApplicationDao dao = ApplicationDao();

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }
    if (args.isNotEmpty) {
      serverInspectionId = args[Consts.SERVER_INSPECTION_ID] ?? -1;
      inspectionId = args[Consts.SERVER_INSPECTION_ID] ?? -1;
      partnerName = args[Consts.PARTNER_NAME] ?? '';
      partnerID = args[Consts.PARTNER_ID] ?? 0;
      carrierName = args[Consts.CARRIER_NAME] ?? '';
      carrierID = args[Consts.CARRIER_ID] ?? 0;
      commodityName = args[Consts.COMMODITY_NAME] ?? '';
      commodityID = args[Consts.COMMODITY_ID] ?? 0;
      completed = args[Consts.COMPLETED] ?? false;

      specificationNumber = args[Consts.SPECIFICATION_NUMBER] ?? '';
      specificationVersion = args[Consts.SPECIFICATION_VERSION] ?? '';

      selectedSpecification = args[Consts.SELECTEDSPECIFICATION] ?? '';
      specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME] ?? '';

      poNumber = args[Consts.PO_NUMBER] ?? '';

      lotNo = args[Consts.LOT_NO] ?? '';
      itemSKU = args[Consts.ITEM_SKU];
      dateTypeDesc = args[Consts.DATETYPE] ?? '';
      varietyName = args[Consts.VARIETY_NAME] ?? '';
      varietySize = args[Consts.VARIETY_SIZE] ?? '';
      varietyId = args[Consts.VARIETY_ID] ?? 0;
      isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
      itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
      itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
      gtin = args[Consts.GTIN] ?? '';
      packDate = args[Consts.PACK_DATE] ?? '';
      itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
      lotSize = args[Consts.LOT_SIZE] ?? '';
      poNumber = args[Consts.PO_NUMBER] ?? '';
      callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
      poLineNo = args[Consts.PO_LINE_NO] ?? 0;
      productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';
      dateTypeDesc = args[Consts.DATETYPE] ?? '';
    }

    if (serverInspectionId! > -1) {
      inspectionId = serverInspectionId;
    } else if (_appStorage.currentInspection != null) {
      inspectionId = _appStorage.currentInspection?.inspectionId;
    }

    headerText = partnerName;
    if (commodityName!.isEmpty) {
      commodityText = "";
    } else {
      commodityText = commodityName;
      varietyText = itemSKU;
    }

    Future.delayed(const Duration(milliseconds: 100)).then((value) async {
      _appStorage.specificationAnalyticalList =
          await dao.getSpecificationAnalyticalFromTable(
        specificationNumber!,
        specificationVersion!,
      );
      await setSpecAnalyticalTable();
      hasInitialised.value = true;
    });
    super.onInit();
  }

  Future<void> setSpecAnalyticalTable() async {
    if (_appStorage.specificationAnalyticalList == null) {
      return;
    }
    listSpecAnalyticals.value = _appStorage.specificationAnalyticalList ?? [];
    for (var specAnalytical in listSpecAnalyticals) {
      if (specAnalytical.specTargetTextDefault == "Y" ||
          specAnalytical.specTargetTextDefault == "Y") {
        specAnalytical.specTargetTextDefault = "Y";
      } else if (specAnalytical.specTargetTextDefault == "N" ||
          specAnalytical.specTargetTextDefault == "N") {
        specAnalytical.specTargetTextDefault = "N";
      }
    }

    listSpecAnalyticals.sort((a, b) => a.order!.compareTo(b.order!));

    for (final item in listSpecAnalyticals) {
      SpecificationAnalyticalRequest reqobj = SpecificationAnalyticalRequest(
        analyticalID: item.analyticalID,
        analyticalName: item.description,
        specTypeofEntry: item.specTypeofEntry,
        isPictureRequired: item.isPictureRequired,
        specMin: item.specMin,
        specMax: item.specMax,
        description: item.description,
        inspectionResult: item.inspectionResult,
      );

      final SpecificationAnalyticalRequest? dbobj =
          await dao.findSpecAnalyticalObj(inspectionId, item.analyticalID!);

      if (dbobj != null) {
        if (dbobj.comment != null && dbobj.comment!.isNotEmpty) {
          reqobj = reqobj.copyWith(comment: dbobj.comment);
        }
        reqobj = reqobj.copyWith(comply: dbobj.comply);

        if (item.specTypeofEntry == 1) {
          reqobj = reqobj.copyWith(sampleNumValue: dbobj.sampleNumValue);
        } else if (item.specTypeofEntry == 2) {
          for (int i = 0; i < operatorList.length; i++) {
            if (dbobj.sampleTextValue == operatorList[i]) {
              reqobj = reqobj.copyWith(sampleTextValue: operatorList[i]);
            }
          }
        } else if (item.specTypeofEntry == 3) {
          reqobj = reqobj.copyWith(sampleNumValue: dbobj.sampleNumValue);
          for (int i = 0; i < operatorList.length; i++) {
            if (dbobj.sampleTextValue == operatorList[i]) {
              reqobj = reqobj.copyWith(sampleTextValue: operatorList[i]);
            }
          }
        }
      } else {
        reqobj = reqobj.copyWith(comply: "N/A");
      }
      listSpecAnalyticalsRequest.add(reqobj);
      dbobjList.add(dbobj);
    }

    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      update();
    });
  }

  // Save Inspection
  Future<void> saveDefectEntriesAndContinue() async {
    if (!hasError2) {
      await saveFieldsToDB(false);
    }
  }

  Future<void> saveAsDraftAndGotoMyInspectionScreen() async {
    if (!hasError2) {
      await saveFieldsToDB(false);
    }
  }

  Future<bool> saveFieldsToDB(bool isComplete) async {
    try {
      // Delete existing records
      await dao.deleteSpecAttributesByInspectionId(inspectionId!);

      /// Lists to store blank names
      List<String> blankAnalyticalNames = [];
      List<String> blankCommentNames = [];

      /// Loop through items
      for (SpecificationAnalyticalRequest item in listSpecAnalyticalsRequest) {
        if (item.analyticalName != null && item.analyticalName!.length > 1) {
          if (item.analyticalName!.substring(0, 2) == "02") {
            if (item.sampleNumValue == 0) {
              blankAnalyticalNames.add(item.analyticalName!);
            }
          } else if (item.analyticalName!.substring(0, 2) == "01" ||
              item.analyticalName!.substring(0, 2) == "03" ||
              item.analyticalName!.substring(0, 2) == "05") {
            if (item.sampleTextValue == "N/A") {
              blankAnalyticalNames.add(item.analyticalName!);
            }
          }
          if (item.analyticalName!.substring(0, 2) == "04" ||
              item.analyticalName!.substring(0, 2) == "07" ||
              item.analyticalName!.substring(0, 2) == "09" ||
              item.analyticalName!.substring(0, 2) == "10" ||
              item.analyticalName!.substring(0, 2) == "11" ||
              item.analyticalName!.substring(0, 2) == "12") {
            if (item.comment == null) {
              blankCommentNames.add(item.analyticalName!);
            }
          }
        }
      }

      /// If there are no blank analytical names
      if (blankAnalyticalNames.isEmpty) {
        /// If there are blank comments
        if (blankCommentNames.isNotEmpty) {
          String message = '';
          for (var i = 0; i < blankCommentNames.length; i++) {
            message += 'Please enter a comment for ${blankCommentNames[i]}\n';
          }

          AppAlertDialog.confirmationAlert(
              Get.context!, AppStrings.alert, message, onYesTap: () async {
            Get.back();

            for (SpecificationAnalyticalRequest item2
                in listSpecAnalyticalsRequest) {
              if ((item2.isPictureRequired ?? false) && item2.comply == 'N') {
                resultComply = 'N';
              } else {
                resultComply = 'Y';
              }
              await dao.createSpecificationAttributes(
                inspectionId!,
                item2.analyticalID!,
                item2.sampleTextValue!,
                item2.sampleNumValue!,
                item2.comply!,
                item2.comment ?? '',
                item2.analyticalName!,
                item2.isPictureRequired!,
                item2.inspectionResult!,
              );
            }
            _appStorage.resumeFromSpecificationAttributes = true;
          });
        } else {
          resultComply = 'Y';
          for (SpecificationAnalyticalRequest item2
              in listSpecAnalyticalsRequest) {
            /// item2.specTypeofEntry == 1
            if (item2.specTypeofEntry == 1) {
              if (item2.sampleNumValue == null) {
                hasError2 = true;
                break;
              }
              if (item2.sampleNumValue == 0) {
                hasError2 = true;
                break;
              } else {
                hasError2 = false;

                if ((item2.isPictureRequired ?? false) && item2.comply == "N") {
                  resultComply = "N";
                }

                await dao.createSpecificationAttributes(
                  inspectionId!,
                  item2.analyticalID!,
                  item2.sampleTextValue ?? '',
                  item2.sampleNumValue!,
                  item2.comply!,
                  item2.comment ?? '',
                  item2.analyticalName!,
                  item2.isPictureRequired!,
                  item2.inspectionResult ?? '',
                );

                if (callerActivity == "NewPurchaseOrderDetailsActivity") {
                  if (item2.description?.contains("Quality Check") ?? false) {
                    if (item2.sampleNumValue != null &&
                        item2.specMin != null &&
                        item2.specMax != null &&
                        item2.sampleNumValue! > 0 &&
                        item2.sampleNumValue! < item2.specMin!) {
                      await dao.updateInspectionRating(
                          inspectionId!, item2.sampleNumValue!);
                      await dao.updateInspectionResult(inspectionId!, "RJ");
                    } else if (item2.sampleNumValue! >= item2.specMin! &&
                        item2.sampleNumValue! <= item2.specMax!) {
                      await dao.updateInspectionRating(
                          inspectionId!, item2.sampleNumValue!);
                      await dao.updateInspectionResult(inspectionId!, "AC");
                    }

                    await dao.updateItemSKUInspectionComplete(
                        inspectionId!, true);
                    await dao.updateInspectionComplete(inspectionId!, true);
                    await dao.updateSelectedItemSKU(
                      inspectionId!,
                      partnerID!,
                      itemSkuId!,
                      itemSKU!,
                      itemUniqueId!,
                      true,
                      false,
                    );
                    Utils.setInspectionUploadStatus(
                        inspectionId!, Consts.INSPECTION_UPLOAD_READY);

                    await dao.createOrUpdateInspectionSpecification(
                      inspectionId!,
                      specificationNumber,
                      specificationVersion,
                      specificationName,
                    );
                  }
                }
              }
            }

            /// item2.specTypeofEntry == 2
            else if (item2.specTypeofEntry == 2) {
              if (item2.sampleTextValue == "Select") {
                hasError2 = true;

                AppAlertDialog.confirmationAlert(Get.context!, AppStrings.alert,
                    "Please enter value for spec attributes with 'Select'",
                    onYesTap: () {
                  hasError2 = false;
                });
                break;
              } else {
                hasError2 = false;
                if ((item2.isPictureRequired ?? false) && item2.comply == "N") {
                  resultComply = "N";
                }

                await dao.createSpecificationAttributes(
                  inspectionId!,
                  item2.analyticalID!,
                  item2.sampleTextValue ?? '',
                  item2.sampleNumValue ?? 0,
                  item2.comply ?? '',
                  item2.comment ?? '',
                  item2.analyticalName ?? '',
                  item2.isPictureRequired ?? false,
                  item2.inspectionResult ?? '',
                );
              }
            }

            /// item2.specTypeofEntry == 3
            else if (item2.specTypeofEntry == 3) {
              if (item2.sampleTextValue == "Select") {
                hasError2 = true;

                AppAlertDialog.confirmationAlert(Get.context!, AppStrings.alert,
                    "Please enter value for spec attributes with 'Select'",
                    onYesTap: () {
                  hasError2 = false;
                });
                break;
              } else if (item2.sampleNumValue == 0) {
                hasError2 = true;
              } else {
                hasError2 = false;
                if ((item2.isPictureRequired ?? false) && item2.comply == "N") {
                  resultComply = "N";
                }

                await dao.createSpecificationAttributes(
                  inspectionId!,
                  item2.analyticalID!,
                  item2.sampleTextValue!,
                  item2.sampleNumValue!,
                  item2.comply!,
                  item2.comment ?? '',
                  item2.analyticalName!,
                  item2.isPictureRequired!,
                  item2.inspectionResult!,
                );

                if (item2.description?.contains("Quality Check") ?? false) {
                  await dao.updateInspectionRating(
                      inspectionId!, item2.sampleNumValue!);
                }

                if (callerActivity == "NewPurchaseOrderDetailsActivity") {
                  if (item2.description?.contains("Quality Check") ?? false) {
                    if (item2.sampleNumValue! > 0 &&
                        item2.sampleNumValue! < item2.specMin!) {
                      await dao.updateInspectionResult(inspectionId!, "RJ");
                    } else if (item2.sampleNumValue! >= item2.specMin! &&
                        item2.sampleNumValue! <= item2.specMax!) {
                      await dao.updateInspectionResult(inspectionId!, "AC");
                    }

                    await dao.updateItemSKUInspectionComplete(
                        inspectionId!, true);
                    await dao.updateInspectionComplete(inspectionId!, true);
                    await dao.updateSelectedItemSKU(
                      inspectionId!,
                      partnerID!,
                      itemSkuId!,
                      itemSKU!,
                      itemUniqueId!,
                      true,
                      false,
                    );
                    Utils.setInspectionUploadStatus(
                        inspectionId!, Consts.INSPECTION_UPLOAD_READY);

                    await dao.createOrUpdateInspectionSpecification(
                      inspectionId!,
                      specificationNumber,
                      specificationVersion,
                      specificationName,
                    );
                  }
                }
              }
            }

            /// item2.specTypeofEntry ?
            else {
              if ((item2.isPictureRequired ?? false) && item2.comply == 'N') {
                resultComply = 'N';
              }
              await dao.createSpecificationAttributes(
                inspectionId!,
                item2.analyticalID!,
                item2.sampleTextValue!,
                item2.sampleNumValue!,
                item2.comply!,
                item2.comment ?? '',
                item2.analyticalName!,
                item2.isPictureRequired!,
                item2.inspectionResult!,
              );
            }
          }

          if (resultComply != null && resultComply == "N") {
            List<InspectionAttachment> picsFromDB = [];
            picsFromDB = await dao
                .findInspectionAttachmentsByInspectionId(inspectionId!);
            if (picsFromDB.isEmpty) {
              hasError2 = true;

              AppAlertDialog.confirmationAlert(Get.context!, AppStrings.alert,
                  "At least one picture is required", onYesTap: () {
                hasError2 = false;
              });
            }
          }

          if (!hasError2) {
            _appStorage.resumeFromSpecificationAttributes = true;
          } else {
            _appStorage.resumeFromSpecificationAttributes = false;
          }
          callStartActivity(isComplete);
        }
      } else {
        String message = '';
        for (var i = 0; i < blankAnalyticalNames.length; i++) {
          message += 'Please enter a value for ${blankAnalyticalNames[i]}\n';
        }

        AppAlertDialog.validateAlerts(Get.context!, AppStrings.alert, message);
      }
    } catch (e) {
      return false;
    }
    return true;
  }

  void callStartActivity(bool isComplete) {
    Map<String, dynamic> args = {
      Consts.SERVER_INSPECTION_ID: inspectionId,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.COMPLETED: completed,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SPECIFICATION_NAME: selectedSpecification,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.LOT_NO: lotNo,
      Consts.ITEM_SKU: itemSKU,
      Consts.ITEM_SKU_NAME: itemSkuName,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.GTIN: gtin,
      Consts.PACK_DATE: packDate,
      Consts.QUALITY_COMPLETED: true,
      Consts.ITEM_UNIQUE_ID: itemUniqueId,
      Consts.LOT_SIZE: lotSize,
      Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
      Consts.PO_NUMBER: poNumber,
      Consts.PRODUCT_TRANSFER: productTransfer,
      Consts.DATETYPE: dateTypeDesc,
    };

    if (isComplete) {
      Get.back();
    } else {
      if (callerActivity == "NewPurchaseOrderDetailsActivity") {
        args[Consts.CALLER_ACTIVITY] = "NewPurchaseOrderDetailsActivity";
      } else {
        args[Consts.CALLER_ACTIVITY] = "PurchaseOrderDetailsActivity";
      }
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      Get.to(() => QCDetailsShortFormScreen(tag: tag), arguments: args);
    }
  }

  //Discard Inspection
  Future deleteInspectionAndGotoMyInspectionScreen() async {
    if (_appStorage.currentInspection!.inspectionId != 0 ||
        serverInspectionId! > -1) {
      if (serverInspectionId! > -1) {
        await dao.deleteInspection(serverInspectionId!);
      } else {
        await dao
            .deleteInspection(_appStorage.currentInspection!.inspectionId!);
      }

      Map<String, dynamic> passingData = {
        Consts.SERVER_INSPECTION_ID: -1,
        Consts.PARTNER_NAME: partnerName,
        Consts.PARTNER_ID: partnerID,
        Consts.CARRIER_NAME: carrierName,
        Consts.CARRIER_ID: carrierID,
        Consts.COMMODITY_NAME: commodityName,
        Consts.COMMODITY_ID: commodityID,
        Consts.SPECIFICATION_NUMBER: specificationNumber,
        Consts.SPECIFICATION_VERSION: specificationVersion,
        Consts.SPECIFICATION_NAME: selectedSpecification,
        Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
        Consts.ITEM_SKU: itemSKU,
        Consts.ITEM_SKU_NAME: itemSkuName,
        Consts.ITEM_SKU_ID: itemSkuId,
        Consts.ITEM_UNIQUE_ID: itemUniqueId,
        Consts.LOT_NO: lotNo,
        Consts.GTIN: gtin,
        Consts.PACK_DATE: packDate,
        Consts.LOT_SIZE: lotSize,
        Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
        Consts.PO_NUMBER: poNumber,
        Consts.PRODUCT_TRANSFER: productTransfer,
        Consts.DATETYPE: dateTypeDesc,
      };

      if (isMyInspectionScreen ?? false) {
        final String tag = DateTime.now().millisecondsSinceEpoch.toString();
        Get.offAll(() => Home(tag: tag), arguments: passingData);
      } else {
        if (callerActivity == "NewPurchaseOrderDetailsActivity") {
          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.to(() => NewPurchaseOrderDetailsScreen(tag: tag),
              arguments: passingData);
        } else {
          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.to(() => PurchaseOrderDetailsScreen(tag: tag),
              arguments: passingData);
        }
      }
    }
  }

  Future<void> specialInstructions() async {
    if (_appStorage.commodityVarietyData != null &&
        _appStorage.commodityVarietyData!.exceptions.isNotEmpty) {
      //todo navigate to InspectionExceptionActitvity
    } else {
      AppSnackBar.info(message: "No Specification Instructions");
    }
  }

  //Specification
  Future onSpecificationTap() async {
    _appStorage.specificationGradeToleranceTable =
        await dao.getSpecificationGradeToleranceTable(
            specificationNumber!, specificationVersion!);
    showDialog(
        context: Get.context!,
        builder: (BuildContext context) {
          return tableDialog(context);
        });
  }

  Future<void> onCameraMenuTap() async {
    Map<String, dynamic> passingData = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VIEW_ONLY_MODE: false,
      Consts.INSPECTION_ID: inspectionId,
      Consts.PO_NUMBER: poNumber,
    };

    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    await Get.to(() => InspectionPhotos(tag: tag), arguments: passingData);
  }

  void onBackButtonClick() {
    // Get.back();
    // Get.back();
    // Get.back();

    Map<String, dynamic> passingData = {
      Consts.SERVER_INSPECTION_ID: -1,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SPECIFICATION_NAME: selectedSpecification,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.ITEM_SKU: itemSKU,
      Consts.ITEM_SKU_NAME: itemSkuName,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.ITEM_UNIQUE_ID: itemUniqueId,
      Consts.LOT_NO: lotNo,
      Consts.GTIN: gtin,
      Consts.PACK_DATE: packDate,
      Consts.LOT_SIZE: lotSize,
      Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
      Consts.PO_NUMBER: poNumber,
      Consts.PRODUCT_TRANSFER: productTransfer,
      Consts.DATETYPE: dateTypeDesc,
    };

    if (isMyInspectionScreen ?? false) {
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      Get.offAll(() => Home(tag: tag));
    } else if (callerActivity == "NewPurchaseOrderDetailsActivity") {
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      Get.to(() => NewPurchaseOrderDetailsScreen(tag: tag),
          arguments: passingData);
    } else {
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      Get.to(() => PurchaseOrderDetailsScreen(tag: tag),
          arguments: passingData);
    }
  }
}
