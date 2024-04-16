import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/custom_listview_dialog.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';
import 'package:simple_barcode_scanner/enum.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';

class QCDetailsShortFormScreenController extends GetxController {
  final PartnerItem partner;

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

  UOMItem? uom;

  List<UOMItem> uomList = <UOMItem>[].obs;

  RxList<SpecificationAnalytical> listSpecAnalyticals =
      <SpecificationAnalytical>[].obs;

  int? qcID;

  String dateTypeDesc = '';

  QCDetailsShortFormScreenController({
    required this.partner,
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
      print(e.toString());
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
  }

  Future<void> loadFieldsFromDB() async {
    if (inspectionId == null) {
      throw Exception('Inspection ID is null');
    }
    QualityControlItem? qualityControlItems =
        await dao.findQualityControlDetails(inspectionId!);

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
      qcID = qualityControlItems.qcID;
      qtyShippedController.text = qualityControlItems.qtyShipped.toString();
      if (qualityControlItems.dateType != "") {
        dateTypeDesc = getDateTypeDesc(qualityControlItems.dateType);
        packDateController.text = dateTypeDesc;
      }
      if (qualityControlItems.packDate != null &&
          qualityControlItems.packDate! > 0) {
        packDateController.text =
            getDateStingFromTime(qualityControlItems.packDate ?? 0);
      } else {
        packDateController.text = "";
      }

      lotNoController.text = qualityControlItems.lot ?? '';
      gtinController.text = qualityControlItems.gtin ?? '';
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
}
