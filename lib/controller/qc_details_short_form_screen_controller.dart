import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/defects/defects_screen.dart';
import 'package:pverify/ui/inspection_photos/inspection_photos_screen.dart';
import 'package:pverify/ui/long_form_quality_control_screen.dart';
import 'package:pverify/ui/purchase_order/new_purchase_order_details_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_details_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/dialogs/custom_listview_dialog.dart';
import 'package:pverify/utils/utils.dart';

class QCDetailsShortFormScreenController extends GetxController {
  int serverInspectionID = 0;
  bool? completed;
  bool? partialCompleted;
  String? partnerName;
  int? partnerID;
  String? carrierName;
  int? carrierID;
  String? commodityName;
  int? commodityID;
  int sampleSizeByCount = 0;
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
  bool? isMyInspectionScreen;
  String? gtin,
      gln,
      sealNumber,
      varietyName,
      varietySize,
      itemUniqueId,
      lotSize;
  int? poLineNo, varietyId, gradeId, itemSkuId;
  String? poCreatedDate;

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

  String? resultComply;

  bool isPartialComplete = false, isComplete = false;

  var packDateFocusNode = FocusNode();

  bool hasErrors2 = false;

  List<String> operatorList = ['Select', 'Yes', 'No', 'N/A'];

  List<SpecificationAnalyticalRequest?> dbobjList = [];

  String? glnAINumber, glnAINumberDesc;

  QCDetailsShortFormScreenController();

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  final AppStorage _appStorage = AppStorage.instance;

  RxBool hasInitialised = false.obs;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }

    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
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
    lotNoController.text = lotNo ?? '';
    String packDateString = args[Consts.PACK_DATE] ?? '';
    if (packDateString.isNotEmpty) {
      try {
        packDate = Utils.parseDate(packDateString);
        if (packDate != null) {
          packDateController.text = Utils().dateFormat.format(packDate!);
        }
      } catch (e) {
        log("Error parsing packDateString: $e");
      }
    }

    gtin = args[Consts.GTIN] ?? '';
    dateTypeDesc = args[Consts.DATETYPE] ?? '';

    isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;

    itemSKU = args[Consts.ITEM_SKU] ?? '';
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
    lotSize = args[Consts.LOT_SIZE] ?? '';
    partialCompleted = args[Consts.PARTIAL_COMPLETED] ?? false;
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';

    specificationName = args[Consts.SPECIFICATION_NAME] ?? '';
    sampleSizeByCount = args[Consts.SAMPLE_SIZE_BY_COUNT] ?? 0;
    varietyName = args[Consts.VARIETY_NAME] ?? '';
    varietySize = args[Consts.VARIETY_SIZE] ?? '';
    varietyId = args[Consts.VARIETY_ID] ?? 0;
    gradeId = args[Consts.GRADE_ID] ?? 0;

    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    poLineNo = args[Consts.PO_LINE_NO] ?? 0;

    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    is1stTimeActivity = args[Consts.IS1STTIMEACTIVITY] ?? '';
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';
    poCreatedDate = args[Consts.PO_CREATED_DATE] ?? '';

    // maybe unused in initial setter
    inspectionResult = args[Consts.INSPECTION_RESULT] ?? '';

    packDateController.addListener(() {
      if (packDateFocusNode.hasFocus) {
        packDateFocusNode.unfocus();
        selectDate(Get.context!, onDateSelected: (selectedDate) {
          packDate = selectedDate;
          packDateController.text = Utils().dateFormat.format(selectedDate);
        });
      }
    });

    setUOMSpinner();
    super.onInit();
    Future.delayed(const Duration(milliseconds: 100)).then((value) async {
      await specificationSelection();

      if (serverInspectionID < 0) {
        if (!(completed ?? false) && !(partialCompleted ?? false)) {
          await createNewInspection(
            itemSKU!,
            itemSkuId!,
            lotNoString,
            packDate?.millisecondsSinceEpoch ?? 0,
            specificationNumber!,
            specificationVersion!,
            specificationName ?? '',
            specificationTypeName ?? '',
            sampleSizeByCount,
            gtinString,
            poNumber!,
            poLineNo!,
            itemSkuName!,
            poCreatedDate!,
          );
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

      if (inspectionId != null) {
        await loadFieldsFromDB();
      }
      _appStorage.specificationAnalyticalList =
          await dao.getSpecificationAnalyticalFromTable(
              specificationNumber!, specificationVersion!);
      await setSpecAnalyticalTable();
      hasInitialised.value = true;
      Future.delayed(const Duration(milliseconds: 100)).then((value) {
        update();
      });
    });
  }

  String get lotNoString => lotNoController.text.trim();
  String get gtinString => gtinController.text.trim();
  String get glnString => glnController.text.trim();

  Future<void> specificationSelection() async {
    // bool isOnline = globalConfigController.hasStableInternet.value;
    if (callerActivity == "TrendingReportActivity" || isMyInspectionScreen!) {
      await Utils().offlineLoadCommodityVarietyDocuments(
          specificationNumber!, specificationVersion!);

      if (_appStorage.commodityVarietyData != null &&
          _appStorage.commodityVarietyData!.exceptions.isNotEmpty) {
        if (is1stTimeActivity != "") {
          if (is1stTimeActivity == "PurchaseOrderDetailsActivity") {
            CustomListViewDialog customDialog = CustomListViewDialog(
              // Get.context!,
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
        selectedSpecification = specificationByItemSKU.specificationNumber;
        specificationTypeName = specificationByItemSKU.specificationTypeName;
        sampleSizeByCount = specificationByItemSKU.sampleSizeByCount ?? 0;

        await Utils().offlineLoadCommodityVarietyDocuments(
            specificationNumber!, specificationVersion!);

        if (_appStorage.commodityVarietyData != null &&
            _appStorage.commodityVarietyData!.exceptions.isNotEmpty) {
          if (is1stTimeActivity != "") {
            if (is1stTimeActivity == "PurchaseOrderDetailsActivity") {
              CustomListViewDialog customDialog =
                  CustomListViewDialog(/*Get.context!,*/ (selectedValue) {});
              customDialog.setCanceledOnTouchOutside(false);
              customDialog.show();
            }
          }
        }
      }
    }
    return;
  }

  Future<String?> scanBarcode({
    required Function(String scanResult)? onScanResult,
  }) async {
    String? res = await FlutterBarcodeScanner.scanBarcode(
        "#ff6666", 'Cancel', true, ScanMode.DEFAULT);
    if (res.isNotEmpty && res != '-1') {
      if (onScanResult != null) {
        onScanResult(res);
      }
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
      context: Get.context!,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365 * 2)),
      initialDate: packDate ?? now,
      currentDate: now,
      lastDate: lastDate ?? now.add(const Duration(days: 365 * 2)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
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

    UOMItem? chileUOMID = getUOMID("Case");
    chileUOMID ??= getUOMID("Caja");

    if (qualityControlItems != null) {
      if (qualityControlItems!.uomQtyShippedID != null) {
        selectedUOM = uomList.firstWhereOrNull(
            (element) => element.uomID == qualityControlItems!.uomQtyShippedID);
      }
    } else {
      if (qualityControlItems != null) {
        if (qualityControlItems!.uomQtyShippedID != null) {
          selectedUOM = getUOMPos(qualityControlItems!.uomQtyShippedID!);
        }
      } else {
        // just for Walmart Chile demo purpose
        selectedUOM = chileUOMID;
      }
    }
    if (qualityControlItems != null) {
      lotNoController.text = qualityControlItems!.lot ?? '';
      gtinController.text = qualityControlItems!.gtin ?? '';
      glnController.text = qualityControlItems!.gln ?? '';
      glnAINumber = qualityControlItems!.glnType ?? '';
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  UOMItem? getUOMID(String uomName) {
    return uomList.firstWhereOrNull((uomItem) => uomItem.uomName == uomName);
  }

  UOMItem? getUOMPos(int uomID) {
    return uomList.firstWhereOrNull((uomItem) => uomItem.uomID == uomID);
  }

  Future<void> createNewInspection(
    String itemSku,
    int itemSkuId,
    String lotNo,
    int packDate,
    String specificationNumber,
    String specificationVersion,
    String specificationName,
    String specificationTypeName,
    int sampleSizeByCount,
    String gtin,
    String poNumber,
    int poLineNo,
    String itemSkuName,
    String poCreatedDate,
  ) async {
    try {
      var userId = _appStorage.getUserData()?.id;
      _appStorage.currentInspection = Inspection(
        userId: userId,
        partnerId: partnerID,
        carrierId: carrierID,
        createdTime: DateTime.now().millisecondsSinceEpoch,
        complete: 0.toString(),
        downloadId: -1,
        commodityId: commodityID,
        itemSKU: itemSKU,
        specificationName: specificationName,
        specificationNumber: specificationNumber,
        specificationVersion: specificationVersion,
        specificationTypeName: specificationTypeName,
        sampleSizeByCount: sampleSizeByCount,
        packDate: packDate.toString(),
        itemSKUId: itemSkuId,
        commodityName: commodityName,
        lotNo: lotNo,
        poNumber: poNumber,
        partnerName: partnerName,
        itemSkuName: itemSkuName,
        poLineNo: poLineNo,
        rating: 0,
        poCreatedDate: poCreatedDate,
      );
      var inspectionID =
          await dao.createInspection(_appStorage.currentInspection!);
      inspectionId = inspectionID;
      _appStorage.currentInspection?.inspectionId = inspectionId;
      serverInspectionID = inspectionId!;
    } catch (e) {
      log(e.toString());
      return;
    }
  }

  Future<void> setSpecAnalyticalTable() async {
    if (_appStorage.specificationAnalyticalList == null) {
      return;
    }
    listSpecAnalyticals.value = _appStorage.specificationAnalyticalList ?? [];
    for (var specAnalytical in listSpecAnalyticals) {
      if (specAnalytical.specTargetTextDefault == "Y") {
        specAnalytical.specTargetTextDefault = "Y";
      } else if (specAnalytical.specTargetTextDefault == "N") {
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

  Future<void> loadFieldsFromDB() async {
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
      if (qualityControlItems!.qtyShipped != null) {
        qtyShippedController.text = qualityControlItems!.qtyShipped.toString();
      }
      if (qualityControlItems!.dateType != "") {
        dateTypeDesc = getDateTypeDesc(qualityControlItems!.dateType);
        packDateController.text = dateTypeDesc;
      }
      int _packDate =
          int.tryParse(qualityControlItems!.packDate.toString()) ?? 0;
      if (_packDate > 0) {
        packDateController.text = getDateStingFromTime(_packDate);
      } else {
        packDateController.text = "";
      }

      lotNoController.text = qualityControlItems!.lot ?? '';
      gtinController.text = qualityControlItems!.gtin ?? '';
    }
    update();
  }

  Future<void> saveAsDraftAndGotoMyInspectionScreen() async {
    bool saved = await saveFieldsToDB();
    if (saved) {
      bool saveSpecAtt = await saveFieldsToDBSpecAttribute(false);
      if (saveSpecAtt) {
        try {
          await callStartActivity(false);
        } catch (e) {
          Utils.hideLoadingDialog();
        }
      } else {
        Utils.hideLoadingDialog();
      }
    } else {
      Utils.hideLoadingDialog();
    }
  }

  Future<bool> saveFieldsToDB() async {
    String qtyShippedString = qtyShippedController.text.trim();
    int qtyShipped = 0;
    if (qtyShippedString.isNotEmpty) {
      try {
        int qtyLength = qtyShippedController.text.length;
        if (qtyLength > 8) {
          hasErrors2 = true;

          AppAlertDialog.validateAlerts(
              Get.context!, AppStrings.alert, AppStrings.errorQtyShippedLength);
        } else {
          qtyShipped = int.tryParse(qtyShippedController.text) ?? 0;
          if (qtyShipped < 1) {
            hasErrors2 = true;
            return false;
          }
        }
      } catch (e) {
        AppSnackBar.error(
            message: '${AppStrings.errorEnterValidValue} for Shipped Quantity');
        return false;
      }
    } else {
      /*AppSnackBar.error(
          message: '${AppStrings.errorEnterValidValue} for Shipped Quantity');*/
      return false;
    }

    String lotNo = lotNoController.text;
    if (lotNo.length > 30) {
      AppAlertDialog.validateAlerts(
          Get.context!, AppStrings.alert, AppStrings.errorLotNoLength);
      return false;
    }

    String packDateString = packDateController.text.trim();
    int packDate = 0;
    if (packDateString.isNotEmpty) {
      DateTime parsedDate = Utils().dateFormat.parse(packDateString);
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
      uomQtyShippedID = selectedUOM!.uomID!;
      uomQtyRejectedID = selectedUOM!.uomID!;
      uomQtyReceivedID = selectedUOM!.uomID!;
    }

    String gtin = gtinController.text;
    // Utils.showLoadingDialog();
    // No quality control id, create a new one in the database.
    try {
      if (qcID == null) {
        // TODO: null check below variables
        // inspectionId
        // poNumber
        // selectedSpecification
        // _appStorage.currentSealNumber
        qcID = await dao.createQualityControl(
          inspectionId: inspectionId!,
          brandID: brandID,
          originID: originID,
          qtyShipped: qtyShipped,
          uomQtyShippedID: uomQtyShippedID,
          poNumber: poNumber!,
          pulpTempMin: 0,
          pulpTempMax: 0,
          recorderTempMin: 0,
          recorderTempMax: 0,
          rpc: '',
          claimFiledAgainst: '',
          qtyRejected: 0,
          uomQtyRejectedID: uomQtyRejectedID,
          reasonID: reasonID,
          qcComments: '',
          qtyReceived: qtyShipped,
          uomQtyReceivedID: uomQtyReceivedID,
          specificationName: selectedSpecification!,
          packDate: packDate,
          seal_no: _appStorage.currentSealNumber!,
          lot_no: lotNo,
          qcdOpen1: typeofCut,
          qcdOpen2: '',
          qcdOpen3: '',
          qcdOpen4: '',
          workDate: 0,
          gtin: gtin,
          lot_size: 0,
          shipDate: 0,
          dateType: dateTypeDesc,
          // FIXME: ?? TODO: assign below
          gln: gln ?? '',
          glnType: glnAINumber ?? '',
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
          qcID: qcID!,
          qtyShipped: qtyShipped,
          uomQtyShippedID: uomQtyShippedID,
          qtyRejected: qtyRejected,
          uomQtyRejectedID: uomQtyRejectedID,
          qtyReceived: qtyReceived,
          uomQtyReceivedID: uomQtyReceivedID,
          selectedSpecification: selectedSpecification!,
          packDate: packDate,
          lot_no: lotNo,
          gtin: gtin,
          shipDate: 0,
          dateType: dateTypeDesc,
          // FIXME: ?? TODO: assign below
          gln: gln ?? '',
          glnType: glnAINumber ?? '',
        );
      }
    } catch (e) {
      log('Error while saving quality control details: $e');
      return false;
    }

    return true;
  }

  Future<bool> saveFieldsToDBSpecAttribute(bool isComplete) async {
    try {
      // TODO: check null for inspectionId
      // Delete existing records
      await dao.deleteSpecAttributesByInspectionId(inspectionId!);

      /// Lists to store blank names
      List<String> blankAnalyticalNames = [];
      List<String> blankCommentNames = [];

      /// Loop through items
      for (SpecificationAnalyticalRequest item in listSpecAnalyticalsRequest) {
        if (item.analyticalName != null && item.analyticalName!.length > 1) {
          if (item.analyticalName!.substring(0, 2) == "02") {
            if (item.sampleNumValue != null && item.sampleNumValue == 0) {
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
                item2.comment!,
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
                hasErrors2 = true;
                break;
              }
              if (item2.sampleNumValue == 0) {
                hasErrors2 = true;
                break;
              } else {
                hasErrors2 = false;

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
                hasErrors2 = true;

                AppAlertDialog.confirmationAlert(Get.context!, AppStrings.alert,
                    "Please enter value for spec attributes with 'Select'",
                    onYesTap: () {
                  hasErrors2 = false;
                });
                break;
              } else {
                hasErrors2 = false;
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
                hasErrors2 = true;

                AppAlertDialog.confirmationAlert(Get.context!, AppStrings.alert,
                    "Please enter value for spec attributes with 'Select'",
                    onYesTap: () {
                  hasErrors2 = false;
                });
                break;
              } else {
                if (item2.sampleNumValue == null) {
                  hasErrors2 = true;
                  break;
                }
                if (item2.sampleNumValue == 0) {
                  hasErrors2 = true;
                  break;
                } else {
                  hasErrors2 = false;
                  if ((item2.isPictureRequired ?? false) &&
                      item2.comply == "N") {
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
                item2.comment!,
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
              hasErrors2 = true;

              AppAlertDialog.confirmationAlert(Get.context!, AppStrings.alert,
                  "At least one picture is required", onYesTap: () {
                hasErrors2 = false;
              });
            }
          }

          if (!hasErrors2) {
            _appStorage.resumeFromSpecificationAttributes = true;
          } else {
            _appStorage.resumeFromSpecificationAttributes = false;
          }
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

  Future<void> callStartActivity(bool isComplete) async {
    try {
      if (callerActivity != "TrendingReportActivity") {
        await dao.createPartnerItemSKU(
            partnerID!,
            itemSKU!,
            lotNoString,
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

        await dao.updateItemSKUInspectionComplete(inspectionId!, false);
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
                    (dbobj.inspectionResult == "No" ||
                        dbobj.inspectionResult == "N")) {
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
                      inspection.inspectionId!, true);
                  Utils.setInspectionUploadStatus(
                      inspection.inspectionId!, Consts.INSPECTION_UPLOAD_READY);

                  break;
                }
              }
            }
          }
        }
      }

      Map<String, dynamic> passingData = {
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
        Consts.LOT_NO: lotNoString,
        Consts.ITEM_SKU: itemSKU,
        Consts.ITEM_SKU_NAME: itemSkuName,
        Consts.ITEM_SKU_ID: itemSkuId,
        Consts.GTIN: gtinString,
        Consts.PACK_DATE: packDate?.millisecondsSinceEpoch.toString(),
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
          await dao.updateItemSKUInspectionComplete(inspectionId!, true);
        }
        passingData[Consts.IS_MY_INSPECTION_SCREEN] = true;
        passingData[Consts.CALLER_ACTIVITY] = 'QCDetailsShortForm';
        // TODO: Implement navigation to InspectionMenuActivity
        // Get.offAll(
        //       () => InspectionMenuActivity(),
        //   arguments: passingData,
        // );
      } else {
        if (isComplete) {
          setComplete(true);
          await dao.updateItemSKUInspectionComplete(inspectionId!, true);
          await callNextItemQCDetails();
        } else {
          passingData[Consts.CALLER_ACTIVITY] = 'GTINActivity';

          if (isMyInspectionScreen ?? false) {
            final String tag = DateTime.now().millisecondsSinceEpoch.toString();
            Get.offAll(() => Home(tag: tag));
          } else {
            if (callerActivity == "GTINActivity") {
              final String tag =
                  DateTime.now().millisecondsSinceEpoch.toString();
              Get.to(() => PurchaseOrderDetailsScreen(tag: tag),
                  arguments: passingData);
            } else if (callerActivity == "NewPurchaseOrderDetailsActivity") {
              Get.offAll(
                () => const NewPurchaseOrderDetailsScreen(),
                arguments: passingData,
              );
            } else {
              final String tag =
                  DateTime.now().millisecondsSinceEpoch.toString();
              Get.to(
                () => PurchaseOrderDetailsScreen(tag: tag),
                arguments: passingData,
              );
            }
          }
        }
      }
    } catch (e) {
      log(e.toString());
      rethrow;
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
    return Utils().dateFormat.format(date);
  }

  Future<void> setComplete(bool complete) async {
    if (serverInspectionID > -1) {
      await dao.updateInspectionComplete(serverInspectionID, complete);
    }
  }

  Future<void> callNextItemQCDetails() async {
    lotNo = lotNo;
    itemSKU = itemSKU;
    itemSkuId = itemSkuId;
    itemUniqueId = itemUniqueId;
    itemSkuName = itemSkuName;
    commodityID = commodityID;
    commodityName = commodityName;
    packDate = packDate;
    gtin = gtinString;

    for (int j = 0; j < _appStorage.selectedItemSKUList.length; j++) {
      if (_appStorage.selectedItemSKUList[j].uniqueItemId == itemUniqueId) {
        _appStorage.selectedItemSKUList[j].lotNo = lotNoString;
        _appStorage.selectedItemSKUList[j].sku = itemSKU;
        _appStorage.selectedItemSKUList[j].id = itemSkuId;
        _appStorage.selectedItemSKUList[j].name = itemSkuName;
        _appStorage.selectedItemSKUList[j].commodityID = commodityID;
        _appStorage.selectedItemSKUList[j].commodityName = commodityName;
        _appStorage.selectedItemSKUList[j].packDate = packDateController.text;
        _appStorage.selectedItemSKUList[j].gtin = gtinString;
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

  Future<void> callPurchaseOrderDetailsActivity() async {
    Map<String, dynamic> bundle = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.ITEM_SKU: itemSKU,
      Consts.ITEM_SKU_NAME: itemSkuName,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.LOT_NO: lotNoString,
      Consts.GTIN: gtinString,
      Consts.PACK_DATE: packDate?.millisecondsSinceEpoch.toString(),
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
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      var res = await Get.to(() => PurchaseOrderDetailsScreen(tag: tag),
          arguments: bundle);
    } else if (callerActivity == 'NewPurchaseOrderDetailsActivity') {
      var res = await Get.to(() => const NewPurchaseOrderDetailsScreen(),
          arguments: bundle);
    } else {
      final String tag = DateTime.now().millisecondsSinceEpoch.toString();
      var res = await Get.to(() => PurchaseOrderDetailsScreen(tag: tag),
          arguments: bundle);
    }

    // Get.back();
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

    await Get.to(() => const InspectionPhotos(), arguments: passingData);
  }

  Future onSpecialInstrMenuTap() async {
    if (_appStorage.commodityVarietyData != null &&
        (_appStorage.commodityVarietyData?.exceptions ?? []).isNotEmpty) {
      CustomListViewDialog customDialog = CustomListViewDialog(
        // Get.context!,
        (selectedValue) {},
      );
      customDialog.setCanceledOnTouchOutside(false);
      customDialog.show();
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
        Consts.LOT_NO: lotNoString,
        Consts.GTIN: gtinString,
        Consts.PACK_DATE: packDate?.millisecondsSinceEpoch.toString(),
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
          Get.offAll(() => const NewPurchaseOrderDetailsScreen(),
              arguments: passingData);
        } else {
          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          var res = await Get.to(() => PurchaseOrderDetailsScreen(tag: tag),
              arguments: passingData);
        }
      }
    }
  }

  Future onLongFormClick() async {
    if (await saveFieldsToDB()) {
      if (!hasErrors2) {
        await saveFieldsToDBSpecAttribute(true);

        if (_appStorage.resumeFromSpecificationAttributes) {
          _appStorage.resumeFromSpecificationAttributes = false;

          Map<String, dynamic> passingData = {
            Consts.SERVER_INSPECTION_ID: inspectionId,
            Consts.COMPLETED: completed,
            Consts.PARTNER_NAME: partnerName,
            Consts.PARTNER_ID: partnerID,
            Consts.CARRIER_NAME: carrierName,
            Consts.CARRIER_ID: carrierID,
            Consts.COMMODITY_NAME: commodityName,
            Consts.COMMODITY_ID: commodityID,
            Consts.SPECIFICATION_NUMBER: specificationNumber,
            Consts.SPECIFICATION_VERSION: specificationVersion,
            Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
            Consts.SPECIFICATION_NAME: specificationName,
            Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
            Consts.ITEM_SKU: itemSKU,
            Consts.ITEM_SKU_NAME: itemSkuName,
            Consts.ITEM_SKU_ID: itemSkuId,
            Consts.ITEM_UNIQUE_ID: itemUniqueId,
            Consts.LOT_NO: lotNoString,
            Consts.GTIN: gtinString,
            Consts.PACK_DATE: packDate?.millisecondsSinceEpoch.toString(),
            Consts.LOT_SIZE: lotSize,
            Consts.PO_NUMBER: poNumber,
            Consts.PO_LINE_NO: poLineNo,
            Consts.PRODUCT_TRANSFER: productTransfer,
            Consts.DATETYPE: dateTypeDesc,
          };

          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          if (callerActivity == "GTINActivity") {
            passingData[Consts.CALLER_ACTIVITY] = 'GTINActivity';
            Get.to(() => LongFormQualityControlScreen(tag: tag),
                arguments: passingData);
          } else if (callerActivity == "NewPurchaseOrderDetailsActivity") {
            passingData[Consts.CALLER_ACTIVITY] =
                'NewPurchaseOrderDetailsActivity';
            Get.to(() => LongFormQualityControlScreen(tag: tag),
                arguments: passingData);
          } else {
            passingData[Consts.CALLER_ACTIVITY] =
                'PurchaseOrderDetailsActivity';
            Get.to(() => LongFormQualityControlScreen(tag: tag),
                arguments: passingData);
          }
        }
      }
    }
  }

  Future saveContinue(BuildContext context) async {
    String qtyShippedString = qtyShippedController.text;
    if (qtyShippedString.isNotEmpty && int.parse(qtyShippedString) > 3000) {
      AppAlertDialog.confirmationAlert(context, AppStrings.alert,
          'Are you sure you want to enter $qtyShippedString quantity?',
          onYesTap: () async {
        if (await saveFieldsToDB()) {
          if (!hasErrors2) {
            await saveFieldsToDBSpecAttribute(true);
            if (_appStorage.resumeFromSpecificationAttributes) {
              await callStartActivity(true);
            }
          } else {
            AppSnackBar.error(message: AppStrings.errorEnterValidValue);
          }
        }
      });
    } else {
      if (await saveFieldsToDB()) {
        if (!hasErrors2) {
          bool hasSaved = await saveFieldsToDBSpecAttribute(true);
          if (_appStorage.resumeFromSpecificationAttributes && hasSaved) {
            await callStartActivity(true);
          }
        } else {
          AppSnackBar.error(message: AppStrings.errorEnterValidValue);
        }
      }
    }
  }

  Future<void> onInspectionWorksheetClick() async {
    if (await saveFieldsToDB()) {
      if (!hasErrors2) {
        bool saveSpecAtt = await saveFieldsToDBSpecAttribute(false);
        if (!saveSpecAtt) {
          return;
        }
      }
    }
    if (_appStorage.resumeFromSpecificationAttributes) {
      startDefectsActivity();
    }
  }

  void startDefectsActivity() {
    Map<String, dynamic> passingData = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.COMPLETED: completed,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VARIETY_NAME: varietyName,
      Consts.VARIETY_SIZE: varietySize,
      Consts.VARIETY_ID: varietyId,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SAMPLE_SIZE_BY_COUNT: sampleSizeByCount,
      Consts.SPECIFICATION_NAME: specificationName,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
      Consts.ITEM_SKU: itemSKU,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.LOT_NO: lotNoString,
      Consts.GTIN: gtinString,
      Consts.PACK_DATE: packDate?.millisecondsSinceEpoch.toString(),
      Consts.ITEM_UNIQUE_ID: itemUniqueId,
      Consts.LOT_SIZE: lotSize,
      Consts.ITEM_SKU_NAME: itemSkuName,
      Consts.PO_NUMBER: poNumber,
      Consts.PO_LINE_NO: poLineNo,
      Consts.PRODUCT_TRANSFER: productTransfer,
    };

    String callerActivityValue = '';
    if (callerActivity == 'TrendingReportActivity') {
      callerActivityValue = 'TrendingReportActivity';
    } else if (callerActivity == 'GTINActivity') {
      callerActivityValue = 'GTINActivity';
    } else if (callerActivity == 'NewPurchaseOrderDetailsActivity') {
      callerActivityValue = 'NewPurchaseOrderDetailsActivity';
    } else {
      callerActivityValue = 'PurchaseOrderDetailsActivity';
    }

    passingData[Consts.CALLER_ACTIVITY] = callerActivityValue;
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.to(() => DefectsScreen(tag: tag), arguments: passingData);
  }

  String? scanGTINResultContents(String scanResult) {
    String barcodeResult = scanResult;
    String packDate2 = "";

    if (barcodeResult.length > 18) {
      String check01;
      if (barcodeResult.startsWith("(")) {
        check01 = barcodeResult.substring(1, 3);
        if (check01 == "01") {
          gtinController.text = barcodeResult.substring(4, 18);
          log("gtin = ${gtinController.text}");

          if (barcodeResult.length >= 28) {
            String check02 = barcodeResult.substring(19, 21);
            log("gtin 1 = $check02");

            if (["11", "12", "13", "15", "16", "17"].contains(check02)) {
              packDate2 = barcodeResult.substring(22, 28);
              log("gtin 2 = $packDate2");

              dateTypeDesc = getDateTypeDesc(check02);

              try {
                packDate = DateFormat('yyMMdd').parse(packDate2);
              } catch (e) {
                return null;
              }

              packDateController.text = Utils().dateFormat.format(packDate!);

              if (barcodeResult.length >= 32) {
                String check03 = barcodeResult.substring(29, 31);
                log("gtin 3 = $check03");
                if (check03 == "10") {
                  lotNoController.text = barcodeResult.substring(32);
                  log("gtin 3 = ${lotNoController.text}");
                } else {
                  AppAlertDialog.validateAlerts(Get.context!, AppStrings.alert,
                      "Invalid check digit for lot number");
                  return null;
                }
              } else {
                AppAlertDialog.validateAlerts(Get.context!, AppStrings.alert,
                    "Insufficient length for lot number");
                return null;
              }
            } else if (check02 == "10") {
              lotNoController.text = barcodeResult.substring(22);
              log("gtin 3 = ${lotNoController.text}");
            }
          }
        } else {
          AppAlertDialog.validateAlerts(
              Get.context!, AppStrings.alert, "Invalid check digit for GTIN");
          return null;
        }
      } else {
        check01 = barcodeResult.substring(0, 2);
        if (check01 == "01") {
          gtinController.text = barcodeResult.substring(2, 16);
          log("gtin = ${gtinController.text}");

          if (barcodeResult.length > 24) {
            String check02 = barcodeResult.substring(16, 18);
            log("gtin 1 = $check02");

            if (["11", "12", "13", "15", "16", "17"].contains(check02)) {
              packDate2 = barcodeResult.substring(18, 24);
              log("gtin 2 = $packDate2");

              dateTypeDesc = getDateTypeDesc(check02);

              try {
                packDate = DateFormat('yyMMdd').parse(packDate2);
              } catch (e) {
                log("Error parsing pack date");
                return null;
              }

              packDateController.text = Utils().dateFormat.format(packDate!);

              if (barcodeResult.length > 27) {
                String check03 = barcodeResult.substring(24, 26);
                log("gtin 3 = $check03");
                if (check03 == "10") {
                  lotNoController.text = barcodeResult.substring(26);
                  log("gtin 3 = ${lotNoController.text}");
                }
              }
            } else if (check02 == "10") {
              lotNoController.text = barcodeResult.substring(22);
              log("gtin 3 = ${lotNoController.text}");
            }
          }
        } else {
          AppAlertDialog.validateAlerts(
              Get.context!, AppStrings.alert, "Invalid check digit for GTIN");
          return null;
        }
      }
    } else {
      AppAlertDialog.validateAlerts(
          Get.context!, AppStrings.alert, "Insufficient length for barcode");
      return null;
    }
    return gtinController.text;
  }

  String? scanGLNResultContents(String contents) {
    String barcodeResult = contents;

    if (barcodeResult.length > 10) {
      String check01;
      if (barcodeResult.startsWith("(")) {
        check01 = barcodeResult.substring(1, 4);
        if (["410", "411", "412", "413", "414", "415", "416", "417"]
            .contains(check01)) {
          glnController.text = barcodeResult.substring(5);

          print("gln = ${glnController.text}");

          glnAINumber = check01;
          switch (check01) {
            case "410":
              glnAINumberDesc = "Ship To/ Deliver To";
              break;
            case "411":
              glnAINumberDesc = "Bill To";
              break;
            case "412":
              glnAINumberDesc = "Purchased From";
              break;
            case "413":
              glnAINumberDesc = "Ship for / Deliver for";
              break;
            case "414":
              glnAINumberDesc = "Identification of physical location";
              break;
            case "415":
              glnAINumberDesc = "GLN of invoicing party";
              break;
            case "416":
              glnAINumberDesc = "GLN of production or service location";
              break;
            case "417":
              glnAINumberDesc = "Party global location number";
              break;
            default:
              glnAINumberDesc = "";
          }
        } else {
          Utils.showErrorAlertDialog("Error reading GLN Barcode");
          return null;
        }
      } else {
        Utils.showErrorAlertDialog("Error reading GLN Barcode");
        return null;
      }
    } else {
      Utils.showErrorAlertDialog("Error reading GLN Barcode");
      return null;
    }
    return glnController.text;
  }

  Future<void> backToMyInspectionScreen() async {
    if (callerActivity == "NewPurchaseOrderDetailsActivity") {
      if (serverInspectionID > -1) {
        Inspection? inspection =
            await dao.findInspectionByID(serverInspectionID);
        if (inspection != null && inspection.rating > 0) {
          if (await saveFieldsToDB()) {
            await saveFieldsToDBSpecAttribute(false);
            await dao.createPartnerItemSKU(
                partnerID!,
                itemSKU!,
                lotNoString,
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
            await dao.updateItemSKUInspectionComplete(inspectionId!, false);
            await dao.updateSelectedItemSKU(
              inspectionId!,
              partnerID!,
              itemSkuId!,
              itemSKU!,
              itemUniqueId!,
              false,
              true,
            );
          } else {
            AppAlertDialog.confirmationAlert(
                Get.context!, AppStrings.alert, AppStrings.unsavedDataMessage,
                onYesTap: () async {
              await dao.deleteInspection(serverInspectionID);
              Get.back();
            });
          }
        } else {
          await dao.deleteInspection(serverInspectionID);
        }
      }
      Get.back();
    } else {
      if (await saveFieldsToDB()) {
        await saveFieldsToDBSpecAttribute(false);
        await dao.createPartnerItemSKU(
            partnerID!,
            itemSKU!,
            lotNoString,
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
        await dao.updateItemSKUInspectionComplete(inspectionId!, false);
        await dao.updateSelectedItemSKU(
          inspectionId!,
          partnerID!,
          itemSkuId!,
          itemSKU!,
          itemUniqueId!,
          false,
          true,
        );

        Map<String, dynamic> passingData = {
          Consts.SERVER_INSPECTION_ID: serverInspectionID,
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
          Consts.PACK_DATE: packDate?.millisecondsSinceEpoch.toString(),
          Consts.LOT_SIZE: lotSize,
          Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
          Consts.PO_NUMBER: poNumber,
          Consts.PRODUCT_TRANSFER: productTransfer,
        };

        if (isMyInspectionScreen ?? false) {
          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.offAll(() => Home(tag: tag));
        } else if (callerActivity == "NewPurchaseOrderDetailsActivity") {
          Get.offAll(
            () => const NewPurchaseOrderDetailsScreen(),
            arguments: passingData,
          );
        } else {
          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.to(
            () => PurchaseOrderDetailsScreen(tag: tag),
            arguments: passingData,
          );
        }
      } else {
        AppAlertDialog.confirmationAlert(
            Get.context!, AppStrings.alert, AppStrings.unsavedDataMessage,
            onYesTap: () async {
          await dao.deleteInspection(serverInspectionID);
          Get.back();
        });
      }
    }
  }
}
