import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/inspection_exception/inspection_exception_screen.dart';
import 'package:pverify/ui/photos_selection/photos_selection.dart';
import 'package:pverify/ui/purchase_order/new_purchase_order_details_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/custom_listview_dialog.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class QCDetailsShortFormScreenController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;

  int serverInspectionID = 0;
  bool? completed;
  bool? partial_completed;
  String? partnerName;
  int? partnerID;
  String? carrierName;
  int? carrierID;
  String? commodityName;
  int? commodityID;
  int sampleSizeByCount = 0;
  String? inspectionResult;
  String? itemSKU, itemSkuName, lot_No;
  String? poNumber;
  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;
  String? selectedSpecification;
  String? productTransfer;
  String? callerActivity;
  String? is1stTimeActivity;
  bool? isMyInspectionScreen;
  String? gtin,
      gln,
      sealNumber,
      varietyName,
      varietySize,
      itemUniqueId,
      lotSize;
  int? poLineNo, varietyId, gradeId, itemSkuId;

  final ApplicationDao dao = ApplicationDao();

  int? inspectionId;

  final TextEditingController gtinController = TextEditingController();
  final TextEditingController glnController = TextEditingController();
  final TextEditingController lotNoController = TextEditingController();
  final TextEditingController packDateController = TextEditingController();
  final TextEditingController qtyShippedController = TextEditingController();

  DateTime? packDate;

  UOMItem? selectedUOM;

  List<UOMItem> uomList = <UOMItem>[].obs;

  RxList<SpecificationAnalytical> listSpecAnalyticals =
      <SpecificationAnalytical>[].obs;

  int? qcID;

  String dateTypeDesc = '';

  QualityControlItem? qualityControlItems;

  List<SpecificationAnalyticalRequest> listSpecAnalyticalsRequest = [];

  String? result_comply;

  bool isPartialComplete = false, isComplete = false;

  QCDetailsShortFormScreenController({
    required this.partner,
    required this.carrier,
    required this.commodity,
    required this.qcHeaderDetails,
  });

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  final AppStorage _appStorage = AppStorage.instance;

  RxBool hasInitialised = false.obs;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments not allowed');
    }

    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? '';
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    sampleSizeByCount = args[Consts.SAMPLE_SIZE_BY_COUNT] ?? 0;
    inspectionResult = args[Consts.INSPECTION_RESULT] ?? '';
    lot_No = args[Consts.Lot_No] ?? '';
    itemSKU = args[Consts.ITEM_SKU] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    specificationNumber = args[Consts.SPECIFICATION_NUMBER] ?? '';
    specificationVersion = args[Consts.SPECIFICATION_VERSION] ?? '';
    specificationName = args[Consts.SPECIFICATION_NAME] ?? '';
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME] ?? '';
    selectedSpecification = args[Consts.SELECTEDSPECIFICATION] ?? '';
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    is1stTimeActivity = args[Consts.IS1STTIMEACTIVITY] ?? '';
    isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
    completed = args[Consts.COMPLETED] ?? false;
    partial_completed = args[Consts.PARTIAL_COMPLETED] ?? false;

    gtin = args[Consts.GTIN] ?? '';
    itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
    lotSize = args[Consts.LOT_SIZE] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    varietyName = args[Consts.VARIETY_NAME] ?? '';
    varietySize = args[Consts.VARIETY_SIZE] ?? '';
    varietyId = args[Consts.VARIETY_ID] ?? 0;
    gradeId = args[Consts.GRADE_ID] ?? 0;
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    poLineNo = args[Consts.PO_LINE_NO] ?? 0;
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;

    setUOMSpinner();
    super.onInit();
    Future.delayed(const Duration(milliseconds: 100)).then((value) async {
      await specificationSelection();

      if (serverInspectionID < 0) {
        if (!(completed ?? false) && !(partial_completed ?? false)) {
          await createNewInspection(
              itemSKU,
              itemSkuId,
              lot_No,
              packDate,
              specificationNumber!,
              specificationVersion!,
              specificationName ?? '',
              specificationTypeName ?? '',
              sampleSizeByCount,
              gtin,
              poNumber,
              poLineNo,
              itemSkuName);
        }
      } else {
        if (callerActivity != "NewPurchaseOrderDetailsActivity") {
          await dao.updateInspection(
              serverInspectionID,
              commodityID!,
              commodityName!,
              varietyId!,
              varietyName!,
              gradeId!,
              specificationNumber!,
              specificationVersion!,
              specificationName ?? '',
              specificationTypeName ?? '',
              sampleSizeByCount,
              itemSKU!,
              itemSkuId!,
              poNumber!,
              0,
              "",
              itemSkuName!);
        }
        inspectionId = serverInspectionID;
      }

      await loadFieldsFromDB();
      hasInitialised.value = true;
      _appStorage.specificationAnalyticalList =
          await dao.getSpecificationAnalyticalFromTable(
              specificationNumber!, specificationVersion!);
      await setSpecAnalyticalTable();
    });
  }

  Future<void> specificationSelection() async {
    bool isOnline = globalConfigController.hasStableInternet.value;
    if (callerActivity == "TrendingReportActivity" || isMyInspectionScreen!) {
      await Utils().offlineLoadCommodityVarietyDocuments(
          specificationNumber!, specificationVersion!);

      if (_appStorage.commodityVarietyData != null &&
          _appStorage.commodityVarietyData!.exceptions.isNotEmpty) {
        if (is1stTimeActivity != "") {
          if (is1stTimeActivity == "PurchaseOrderDetailsActivity") {
            CustomListViewDialog customDialog = CustomListViewDialog(
              Get.context!,
              (selectedValue) {},
            );
            customDialog.setCanceledOnTouchOutside(false);
            customDialog.show();
          }
        }
      }
    } else {
      if (_appStorage.specificationByItemSKUList != null &&
          _appStorage.specificationByItemSKUList!.isNotEmpty) {
        SpecificationByItemSKU? specificationByItemSKU =
            _appStorage.specificationByItemSKUList!.first;
        specificationNumber = specificationByItemSKU.specificationNumber!;
        specificationVersion = specificationByItemSKU.specificationVersion!;
        specificationName = specificationByItemSKU.specificationName;
        selectedSpecification = specificationByItemSKU.specificationName;
        specificationTypeName = specificationByItemSKU.specificationTypeName;
        sampleSizeByCount = specificationByItemSKU.sampleSizeByCount ?? 0;

        await Utils().offlineLoadCommodityVarietyDocuments(
            specificationNumber!, specificationVersion!);

        if (_appStorage.commodityVarietyData != null &&
            _appStorage.commodityVarietyData!.exceptions.isNotEmpty) {
          if (is1stTimeActivity != "") {
            if (is1stTimeActivity == "PurchaseOrderDetailsActivity") {
              CustomListViewDialog customDialog =
                  CustomListViewDialog(Get.context!, (selectedValue) {});
              customDialog.setCanceledOnTouchOutside(false);
              customDialog.show();
            }
          }
        }
      }
    }
    return;
  }

  Future<String?> scanBarcode(
      {required Function(String scanResult)? onScanResult}) async {
    // TODO: Implement scanBarcode
    String? res = await Get.to(() => SimpleBarcodeScannerPage(
          scanType: ScanType.barcode,
          centerTitle: true,
          appBarTitle: 'Scan a Barcode',
          cancelButtonText: 'Cancel',
          isShowFlashIcon: true,
          lineColor: AppColors.primaryColor.value.toString(),
        ));
    if (res != null) {
      // if (onBarcodeScanned != null) {
      //   onBarcodeScanned!(res);
      // }
      return res;
    } else {
      return null;
    }
  }

  Future selectDate(BuildContext context,
      {DateTime? firstDate,
      DateTime? lastDate,
      required Function(DateTime selectedDate) onDateSelected}) async {
    DateTime now = DateTime.now();
    // show Adaptive Date Picker
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: firstDate ?? now,
      initialDate: packDate ?? now,
      currentDate: now,
      lastDate: lastDate ?? now.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      packDate = selectedDate;
      onDateSelected(selectedDate);
    }
    return selectedDate;
  }

  Future<void> setUOMSpinner() async {
    _appStorage.uomList = await JsonFileOperations.parseUOMJson() ?? [];

    uomList = _appStorage.uomList;
    uomList.sort((a, b) => a.uomName!.compareTo(b.uomName!));
// todo: walmart demo code
    SchedulerBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  Future<void> createNewInspection(
      item_sku,
      item_sku_id,
      lot_no,
      pack_date,
      String specificationNumber,
      String specificationVersion,
      String specificationName,
      String specificationTypeName,
      int sampleSizeByCount,
      gtin,
      po_number,
      poLineNo,
      item_sku_name) async {
    try {
      var userId = _appStorage.getUserData()?.id;
      _appStorage.currentInspection = Inspection(
        userId: userId,
        partnerId: partnerID,
        carrierId: carrierID,
        createdTime: DateTime.now().millisecondsSinceEpoch,
        complete: false,
        downloadId: -1,
        commodityId: commodityID,
        itemSKU: itemSKU,
        specificationName: specificationName,
        specificationNumber: specificationNumber,
        specificationVersion: specificationVersion,
        specificationTypeName: specificationTypeName,
        sampleSizeByCount: sampleSizeByCount,
        packDate: pack_date,
        itemSKUId: item_sku_id,
        commodityName: commodityName,
        lotNo: lot_no,
        poNumber: po_number,
        partnerName: partnerName,
        itemSkuName: item_sku_name,
        poLineNo: poLineNo,
        rating: 0,
      );
      var inspection_id =
          await dao.createInspection(_appStorage.currentInspection!);
      inspectionId = inspection_id;
      _appStorage.currentInspection?.inspectionId = inspectionId;
      // serverInspectionID = inspectionId!;
    } catch (e) {
      debugPrint(e.toString());
      return;
    }
  }

  Future<void> setSpecAnalyticalTable() async {
    if (_appStorage.specificationAnalyticalList == null) {
      return;
    }
    listSpecAnalyticals.value = _appStorage.specificationAnalyticalList ?? [];

    listSpecAnalyticals.sort((a, b) => a.order!.compareTo(b.order!));

    int row_no = 1;
    for (SpecificationAnalytical item in listSpecAnalyticals) {
      final SpecificationAnalyticalRequest reqobj =
          SpecificationAnalyticalRequest();

      final SpecificationAnalyticalRequest? dbobj =
          await dao.findSpecAnalyticalObj(inspectionId!, item.analyticalID!);

      reqobj.copyWith(
        analyticalID: item.analyticalID,
        analyticalName: item.description,
        specTypeofEntry: item.specTypeofEntry,
        isPictureRequired: item.isPictureRequired,
        specMin: item.specMin,
        specMax: item.specMax,
        description: item.description,
        inspectionResult: item.inspectionResult,
      );

      /*comment.setOnClickListener((v) {
        AlertDialog.Builder alert = AlertDialog.Builder(QC_Details_short_form.this);
        EditText edittext = EditText(QC_Details_short_form.this);
        edittext.setHorizontallyScrolling(false);
        edittext.setMaxLines(int.maxValue);

        if (reqobj.comment != null) {
          edittext.setText(reqobj.comment);
        }
        alert.setTitle(getString(R.string.comments));
        alert.setView(edittext);
        alert.setPositiveButton(getString(R.string.save), (dialog, whichButton) {
          String commentvalue = edittext.text.toString();
          reqobj.comment = commentvalue;
          if (commentvalue != "")
            comment.setImageDrawable(getResources().getDrawable(R.drawable.spec_comment_added));
          else
            comment.setImageDrawable(getResources().getDrawable(R.drawable.spec_comment));
        });
        alert.setNegativeButton(getString(R.string.cancel), (dialog, whichButton) {
          dialog.dismiss();
        });
        alert.show();
      });*/

      row_no++;
    }
    update();
  }

  Future<void> loadFieldsFromDB() async {
    if (inspectionId == null) {
      throw Exception('Inspection ID is null');
    }
    qualityControlItems = await dao.findQualityControlDetails(inspectionId!);

    if (_appStorage.getUserData() != null) {
      List<PurchaseOrderDetails> purchaseOrderDetails =
          await dao.getPODetailsFromTable(
              poNumber!, _appStorage.getUserData()!.supplierId!);

      if (purchaseOrderDetails.isNotEmpty) {
        for (var i = 0; i < purchaseOrderDetails.length; i++) {
          if (itemSkuId == purchaseOrderDetails[i].itemSkuId) {
            qtyShippedController.text =
                purchaseOrderDetails[i].quantity.toString();
          }
        }
      }
    }

    if (qualityControlItems != null) {
      qcID = qualityControlItems!.qcID;
      qtyShippedController.text = qualityControlItems!.qtyShipped.toString();
      if (qualityControlItems!.dateType != "") {
        dateTypeDesc = getDateTypeDesc(qualityControlItems!.dateType);
        packDateController.text = dateTypeDesc;
      }
      if (qualityControlItems!.packDate != null &&
          qualityControlItems!.packDate! > 0) {
        packDateController.text =
            getDateStingFromTime(qualityControlItems!.packDate ?? 0);
      } else {
        packDateController.text = "";
      }

      lotNoController.text = qualityControlItems!.lot ?? '';
      gtinController.text = qualityControlItems!.gtin ?? '';
    }
  }

  Future<void> saveAsDraftAndGotoMyInspectionScreen() async {
    await saveFieldsToDB();
    // TODO: implement below for saving inspection
    await saveFieldsToDBSpecAttribute(false);
    await callStartActivity(false);
  }

  Future<bool> saveFieldsToDB() async {
    ApplicationDao dao = ApplicationDao();
    bool hasErrors = false;

    String qtyShippedString = qtyShippedController.text.trim();
    int qtyShipped = 0;
    if (qtyShippedString != null) {
      try {
        qtyShipped = int.parse(qtyShippedString);
        if (qtyShipped < 1) {
          hasErrors = true;
        }
      } catch (e) {
        // Handle error, e.g. show a message to the user
        hasErrors = true;
      }
    } else {
      // Handle error, e.g. show a message to the user
      hasErrors = true;
    }

    String lotNo = lotNoController.text;
    if (lotNo.length > 30) {
      hasErrors = true;
      // Handle error, e.g. show a dialog to the user
    }

    String packDateString = packDateController.text.trim();
    int packDate = 0;
    if (packDateString.isNotEmpty) {
      DateTime parsedDate = DateTime.parse(packDateString);
      packDate = parsedDate.millisecondsSinceEpoch;
    }

    int uomQtyShippedID = 0;
    int uomQtyRejectedID = 0;
    int uomQtyReceivedID = 0;
    int brandID = 0;
    int reasonID = 0;
    int originID = 0;
    String typeofCut = '';

    if (uomList.isNotEmpty && selectedUOM != null) {
      // TODO: check null for selectedUOM!.uomID values
      uomQtyShippedID = selectedUOM!.uomID!;
      uomQtyRejectedID = selectedUOM!.uomID!;
      uomQtyReceivedID = selectedUOM!.uomID!;
    }

    String gtin = gtinController.text;

    // If we have no missing fields persist the data.
    if (!hasErrors) {
      // No quality control id, create a new one in the database.
      if (qcID == null) {
        // TODO: null check below variables
        // inspectionId
        // poNumber
        // selectedSpecification
        // _appStorage.currentSealNumber
        qcID = await dao.createQualityControl(
          inspectionId!,
          brandID,
          originID,
          qtyShipped,
          uomQtyShippedID,
          poNumber!,
          0,
          0,
          0,
          0,
          '',
          '',
          0,
          uomQtyRejectedID,
          reasonID,
          '',
          qtyShipped,
          uomQtyReceivedID,
          selectedSpecification!,
          packDate,
          _appStorage.currentSealNumber!,
          lotNo,
          typeofCut,
          '',
          '',
          '',
          0,
          gtin,
          0,
          0,
          dateTypeDesc,
        );
      } else {
        int qtyReceived = 0;
        int qtyRejected = 0;
        if (qualityControlItems != null &&
            qualityControlItems!.qtyShipped != null) {
          qtyReceived = qualityControlItems!.qtyShipped! -
              qualityControlItems!.qtyRejected!;
          qtyRejected = qualityControlItems!.qtyRejected!;
        }
        // TODO: check null
        // qcID
        // selectedSpecification
        await dao.updateQualityControlShortForm(
          qcID!,
          qtyShipped,
          uomQtyShippedID,
          qtyRejected,
          uomQtyRejectedID,
          qtyReceived,
          uomQtyReceivedID,
          selectedSpecification!,
          packDate,
          lotNo,
          gtin,
          0,
          dateTypeDesc,
        );
      }

      return true;
    }
    return false;
  }

  Future<void> saveFieldsToDBSpecAttribute(bool isComplete) async {
    // TODO: check null for inspectionId
    await dao.deleteSpecAttributesByInspectionId(inspectionId!);
    List<String> blankAnalyticalNames = [];
    List<String> blankCommentNames = [];

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

    if (blankAnalyticalNames.isEmpty) {
      if (blankCommentNames.isNotEmpty) {
        // Show dialog with blankCommentNames
        // On dialog positive button press:
        for (SpecificationAnalyticalRequest item2
            in listSpecAnalyticalsRequest) {
          if ((item2.isPictureRequired ?? false) && item2.comply == "N") {
            result_comply = "N";
          } else {
            result_comply = "Y";
          }
          // TODO: null check to below code block
          await dao.createSpecificationAttributes(
            inspectionId!,
            item2.analyticalID!,
            item2.sampleTextValue!,
            item2.sampleNumValue!,
            item2.comply!,
            item2.comment!,
            item2.analyticalName!,
            item2.isPictureRequired!,
            item2.inspectionResult!,
          );
        }
        _appStorage.resumeFromSpecificationAttributes = true;
      } else {
        result_comply = "Y";
        for (SpecificationAnalyticalRequest item2
            in listSpecAnalyticalsRequest) {
          // TODO: Similar to the above code block
        }
      }
    } else {
      // TODO: Show dialog with blankAnalyticalNames
    }
  }

  Future<void> callStartActivity(bool isComplete) async {
    if (callerActivity != "TrendingReportActivity") {
      await dao.createPartnerItemSKU(
          partnerID!,
          itemSKU!,
          lot_No!,
          packDateController.text,
          inspectionId!,
          lotSize!,
          itemUniqueId!,
          poLineNo!,
          poNumber!);
      await dao
          .copyTempTrailerTemperaturesToInspectionTrailerTemperatureTableByPartnerID(
              inspectionId!, carrierID!, poNumber!);
      await dao
          .copyTempTrailerTemperaturesDetailsToInspectionTrailerTemperatureDetailsTableByPartnerID(
              inspectionId!, carrierID!, poNumber!);

      await dao.updateItemSKUInspectionComplete(inspectionId!, "false");
    }
    if (isComplete) {
      await dao.updateSelectedItemSKU(inspectionId!, partnerID!, itemSkuId!,
          itemSKU!, itemUniqueId!, isComplete, false);
    } else {
      await dao.updateSelectedItemSKU(inspectionId!, partnerID!, itemSkuId!,
          itemSKU!, itemUniqueId!, isComplete, true);
    }

    if (callerActivity == "NewPurchaseOrderDetailsActivity") {
      Inspection? inspection = await dao.findInspectionByID(inspectionId!);
      if (inspection != null &&
          inspection.result != null &&
          inspection.result != "RJ") {
        String result = "";
        if (_appStorage.specificationAnalyticalList != null) {
          for (SpecificationAnalytical item
              in _appStorage.specificationAnalyticalList!) {
            SpecificationAnalyticalRequest? dbobj =
                await dao.findSpecAnalyticalObj(
                    inspection.inspectionId!, item.analyticalID!);

            if (dbobj != null && dbobj.comply == "N") {
              if (dbobj.inspectionResult != null &&
                  dbobj.inspectionResult == "N") {
              } else {
                // TODO: check null for dbobj.analyticalName
                result = "RJ";
                await dao.createOrUpdateResultReasonDetails(
                    inspection.inspectionId!,
                    result,
                    "${dbobj.analyticalName!} = N",
                    dbobj.comment!);

                await dao.updateInspectionResult(
                    inspection.inspectionId!, result);
                await dao.updateInspectionComplete(
                    inspection.inspectionId!, true);
                await dao.updateItemSKUInspectionComplete(
                    inspection.inspectionId!, 'true');
                Utils.setInspectionUploadStatus(
                    inspection.inspectionId!, Consts.INSPECTION_UPLOAD_READY);

                break;
              }
            }
          }
        }
      }
    }

    Map<String, dynamic> bundle = {
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
      Consts.Lot_No: lot_No,
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

    if ((isMyInspectionScreen ?? false)) {
      if (isComplete) {
        setComplete(true);
        await dao.updateItemSKUInspectionComplete(inspectionId!, "true");
      }
      // TODO: Implement navigation to InspectionMenuActivity
    } else {
      if (isComplete) {
        setComplete(true);
        await dao.updateItemSKUInspectionComplete(inspectionId!, "true");
        await callNextItemQCDetails();
      } else {
        // TODO: Implement navigation based on callerActivity
      }
    }
  }

  String getDateTypeDesc(String? dateType) {
    switch (dateType) {
      case '11':
        return 'Production Date';
      case '12':
        return 'Due Date';
      case '13':
        return 'Pack Date';
      case '15':
        return 'Best Before Date';
      case '16':
        return 'Sell By Date';
      case '17':
        return 'Expiration Date';
      default:
        return 'Unknown Date Type';
    }
  }

  String getDateStingFromTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd').format(date);
  }

  Future<void> setComplete(bool complete) async {
    if (serverInspectionID > -1) {
      await dao.updateInspectionComplete(serverInspectionID, complete);
    }
  }

  Future<void> callNextItemQCDetails() async {
    lot_No = lot_No;
    itemSKU = itemSKU;
    itemSkuId = itemSkuId;
    itemUniqueId = itemUniqueId;
    itemSkuName = itemSkuName;
    commodityID = commodityID;
    commodityName = commodityName;
    packDate = packDate;
    gtin = gtin;

    for (int j = 0; j < _appStorage.selectedItemSKUList.length; j++) {
      if (_appStorage.selectedItemSKUList[j].uniqueItemId == itemUniqueId) {
        _appStorage.selectedItemSKUList[j].lotNo = lot_No;
        _appStorage.selectedItemSKUList[j].sku = itemSKU;
        _appStorage.selectedItemSKUList[j].id = itemSkuId;
        _appStorage.selectedItemSKUList[j].name = itemSkuName;
        _appStorage.selectedItemSKUList[j].commodityID = commodityID;
        _appStorage.selectedItemSKUList[j].commodityName = commodityName;
        _appStorage.selectedItemSKUList[j].packDate = packDateController.text;
        _appStorage.selectedItemSKUList[j].gtin = gtin;
        break;
      }
    }

    PartnerItemSKUInspections? partnerItemSKU =
        await dao.findPartnerItemSKU(partnerID!, itemSKU!, itemUniqueId);
    isComplete = false;
    isPartialComplete = false;

    if (partnerItemSKU != null) {
      isComplete =
          await dao.isInspectionComplete(partnerID!, itemSKU!, itemUniqueId);
      if (!isComplete) {
        isPartialComplete = await dao.isInspectionPartialComplete(
            partnerID!, itemSKU!, itemUniqueId!);
      }
    }

    callPurchaseOrderDetailsActivity();
  }

  void callPurchaseOrderDetailsActivity() {
    Map<String, dynamic> bundle = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.ITEM_SKU: itemSKU,
      Consts.ITEM_SKU_NAME: itemSkuName,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.Lot_No: lot_No,
      Consts.GTIN: gtin,
      Consts.PACK_DATE: packDate,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VARIETY_NAME: varietyName,
      Consts.VARIETY_ID: varietyId,
      Consts.GRADE_ID: gradeId,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SPECIFICATION_NAME: specificationName,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.ITEM_UNIQUE_ID: itemUniqueId,
      Consts.LOT_SIZE: lotSize,
      Consts.PO_NUMBER: poNumber,
      Consts.PRODUCT_TRANSFER: productTransfer,
    };

    if (callerActivity == 'GTINActivity') {
      Get.to(() => PurchaseOrderDetails(), arguments: bundle);
    } else if (callerActivity == 'NewPurchaseOrderDetailsActivity') {
      Get.to(
          () => NewPurchaseOrderDetailsScreen(
                partner: partner,
                qcHeaderDetails: qcHeaderDetails,
                carrier: carrier,
                commodity: commodity,
              ),
          arguments: bundle);
    } else {
      Get.to(() => PurchaseOrderDetails(), arguments: bundle);
    }

    Get.back();
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

    await Get.to(() => const PhotosSelection(), arguments: passingData);
  }

  Future onSpecialInstrMenuTap() async {
    if (_appStorage.commodityVarietyData != null &&
        (_appStorage.commodityVarietyData?.exceptions ?? []).isNotEmpty) {
      Get.to(() => const InspectionExceptionScreen());
    } else {
      AppSnackBar.info(message: AppStrings.noSpecificationInstructions);
    }
  }

  Future onSpecificationTap() async {
    if ((specificationNumber != null && specificationNumber!.isNotEmpty) &&
        (specificationVersion != null && specificationVersion!.isNotEmpty)) {}

    _appStorage.specificationGradeToleranceTable =
        await dao.getSpecificationGradeTolerance(
            specificationNumber!, specificationVersion!);

    // TODO: Implement below code
    /*SpecTolearanceTableDialog customDialog2 = SpecTolearanceTableDialog(QC_Details_short_form.this, context,
        specificationNumber, specificationVersion);
    customDialog2.show();
    customDialog2.setCanceledOnTouchOutside(false);*/
  }

  Future deleteInspectionAndGotoMyInspectionScreen() async {
    if (serverInspectionID > -1) {
      await dao.deleteInspection(serverInspectionID);

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
        Consts.Lot_No: lot_No,
        Consts.GTIN: gtin,
        Consts.PACK_DATE: packDate,
        Consts.LOT_SIZE: lotSize,
        Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
        Consts.PO_NUMBER: poNumber,
        Consts.PRODUCT_TRANSFER: productTransfer,
        Consts.DATETYPE: dateTypeDesc,
      };

      if (isMyInspectionScreen ?? false) {
        Get.offAll(() => const Home(), arguments: passingData);
      } else {
        if (callerActivity == "NewPurchaseOrderDetailsActivity") {
          Get.offAll(
              () => NewPurchaseOrderDetailsScreen(
                    partner: partner,
                    qcHeaderDetails: qcHeaderDetails,
                    carrier: carrier,
                    commodity: commodity,
                  ),
              arguments: passingData);
        } else {
          Get.offAll(() => PurchaseOrderDetails(), arguments: passingData);
        }
      }
    }
  }
}
