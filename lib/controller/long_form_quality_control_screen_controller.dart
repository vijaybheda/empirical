import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/brand_item.dart';
import 'package:pverify/models/country_item.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/reason_item.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/spec_attributes/specification_attribute_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class LongFormQualityControlScreenController extends GetxController {
  final ApplicationDao dao = ApplicationDao();
  final AppStorage _appStorage = AppStorage.instance;

  //For UOM Dropdown
  List<UOMItem> uomList = <UOMItem>[].obs;
  UOMItem? selectedUOM;
  QualityControlItem? qualityControlItems;

  //For Brand Dropdown
  List<BrandItem> brandList = <BrandItem>[].obs;
  BrandItem? selectedBrand;

  //For Origin Dropdown
  List<CountryItem> originList = <CountryItem>[].obs;
  CountryItem? selectedOrigin;

  //For Reason Dropdown
  List<ReasonItem> reasonList = <ReasonItem>[].obs;
  ReasonItem? selectedReason;

  //For Claimfield Dropdown
  List<String> claimFieldList = <String>[
    "No Claim",
    "Partner Claim",
    "Carrier Claimn",
  ].obs;
  RxString selectedClaimField = "No Claim".obs;
  RxString selectedClaimFieldLabel = "No Claim".obs;

  //For Rpc Dropdown
  List<String> rpcList = <String>[
    "N/A",
    "Chep",
    "IFCO",
    "Other",
  ].obs;
  RxString selectedRpc = "N/A".obs;

  // For Temp Recorder Present
  List<String> tempRecorderList = <String>["Yes", "No"].obs;
  RxString selectedTempRecorder = "Yes".obs;

  final TextEditingController qtyShippedController = TextEditingController();
  final TextEditingController lotNoController = TextEditingController();
  final TextEditingController qtyRejectedController = TextEditingController();
  final TextEditingController qtyInspectedOkController =
      TextEditingController();
  final TextEditingController qtyAprrovedController = TextEditingController();
  final TextEditingController sensitechSerialNoController =
      TextEditingController();
  final TextEditingController packDateController = TextEditingController();
  final TextEditingController workDateController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();
  final TextEditingController pulpTempMinController = TextEditingController();
  final TextEditingController pulpTempMaxController = TextEditingController();
  final TextEditingController recorderTempMinController =
      TextEditingController();
  final TextEditingController recorderTempMaxController =
      TextEditingController();

  int serverInspectionID = 0;
  int? partnerID;
  int? carrierID;
  int? commodityID;
  int? poLineNo, varietyId, gradeId, itemSkuId;
  int? inspectionId;
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
  String dateTypeDesc = '';
  bool? isMyInspectionScreen;
  bool? partialCompleted;
  bool? completed;
  RxBool isValidQuantityRejected = false.obs;

  DateTime? packDate;
  DateTime? workDate;
  var packDateFocusNode = FocusNode();
  var workDateFocusNode = FocusNode();

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }

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
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';

    if (inspectionId != null) {
      loadFiledsFromDB(args);
    } else {
      log("Not called");
    }

    super.onInit();
  }

  Future<bool> saveFieldsToDB() async {
    bool hasErrors = false;

    // qtyShipped
    String qtyShippedString = qtyShippedController.text;
    int qtyShipped = 0;

    if (qtyShippedString.isNotEmpty) {
      try {
        qtyShipped = int.parse(qtyShippedString);
        if (qtyShipped < 1) {
          hasErrors = true;
        }
      } catch (e) {
        Utils.showErrorAlertDialog("Please enter a valid value");
        hasErrors = true;
      }
    } else {
      Utils.showErrorAlertDialog("Please enter a valid value");
      hasErrors = true;
    }

    // comments
    String qcComments = commentsController.text ?? "";

    // qtyRejected
    String qtyRejectedString = qtyRejectedController.text;
    int qtyRejected = 0;
    if (qtyRejectedString.isNotEmpty) {
      try {
        qtyRejected = int.parse(qtyRejectedString);
      } catch (e) {
        qtyRejectedController.text = '';
        Utils.showErrorAlertDialog("Please enter a valid value");
        hasErrors = true;
      }
    } else {
      qtyRejectedController.text = '';
      Utils.showErrorAlertDialog("Please enter a valid value");
      hasErrors = true;
    }

    // qtyReceived
    String qtyReceivedString = qtyAprrovedController.text;
    int qtyReceived = 0;
    if (qtyReceivedString.isNotEmpty) {
      try {
        qtyReceived = int.parse(qtyReceivedString);
      } catch (e) {
        qtyAprrovedController.clear();

        Utils.showErrorAlertDialog("Please enter a valid value");

        hasErrors = true;
      }
    } else {
      qtyAprrovedController.clear();
      Utils.showErrorAlertDialog("Please enter a valid value");
      hasErrors = true;
    }

    // lotNo
    int lotNoLength = lotNoController.text.length;
    if (lotNoLength > 30) {
      hasErrors = true;
      Utils.showErrorAlertDialog("Lot No should not exceed 30 characters");
    }

    // sensitechSerialNo
    int serialNoLength = sensitechSerialNoController.text.length;
    if (serialNoLength > 20) {
      hasErrors = true;
      Utils.showErrorAlertDialog(
          "Sensitech Serial Number should not exceed 20 characters");
    }

    // qtyInspectedOk
    int qtyInspectedOkLength = qtyInspectedOkController.text.length;
    if (qtyInspectedOkLength > 20) {
      hasErrors = true;
      Utils.showErrorAlertDialog(
          "QTY Inspected OK should not exceed 20 characters");
    }

    int pulpTempMin = 0,
        pulpTempMax = 0,
        recorderTempMin = 0,
        recorderTempMax = 0;

    // pulpTempMin
    if (pulpTempMinController.text.isNotEmpty) {
      if (isValidNumber(pulpTempMinController.text)) {
        pulpTempMin = int.parse(pulpTempMinController.text);
      } else {
        hasErrors = true;
        Utils.showErrorAlertDialog(
            "Pulp Temp Min should not exceed 4 digits & 2 decimals");
      }
    }

    // pulpTempMax
    if (pulpTempMaxController.text.isNotEmpty) {
      if (isValidNumber(pulpTempMaxController.text)) {
        pulpTempMax = int.parse(pulpTempMaxController.text);
      } else {
        hasErrors = true;
        Utils.showErrorAlertDialog(
            "Pulp Temp Max should not exceed 4 digits & 2 decimals");
      }
    }

    // recorderTempMin
    if (recorderTempMinController.text.isNotEmpty) {
      if (isValidNumber(recorderTempMinController.text)) {
        recorderTempMin = int.parse(recorderTempMinController.text);
      } else {
        hasErrors = true;
        Utils.showErrorAlertDialog(
            "Recorder Temp Min should not exceed 4 digits & 2 decimals");
      }
    }

    // recorderTempMax
    if (recorderTempMaxController.text.isNotEmpty) {
      if (isValidNumber(recorderTempMaxController.text)) {
        recorderTempMax = int.parse(recorderTempMaxController.text);
      } else {
        hasErrors = true;
        Utils.showErrorAlertDialog(
            "Recorder Temp Max should not exceed 4 digits & 2 decimals");
      }
    }

    // packDate
    String packDateS = packDateController.text.trim();
    int packDate = 0;
    if (packDateS.isNotEmpty) {
      DateTime parsedDate = Utils().dateFormat.parse(packDateS);
      packDate = parsedDate.millisecondsSinceEpoch;
      log("hereeeeee issss $packDate");
      log("hereeeeee issss S $packDateS");
    }
    // rpc
    int rpcIndex = rpcList.indexOf(selectedRpc.value);
    String rpc = rpcList[rpcIndex];

    // claimFiledAgainst
    int clamFiledAgainstIndex =
        claimFieldList.indexOf(selectedClaimField.value);
    String claimFiledAgainst = claimFieldList[clamFiledAgainstIndex];
    mapClaimFiledAgainst(claimFiledAgainst);

    int uomQtyShippedID = 0;
    int uomQtyRejectedID = 0;
    int uomQtyReceivedID = 0;
    int brandID = 0;
    int reasonID = 0;
    int originID = 0;
    String typeofCut = '';

    // uom
    if (uomList.isNotEmpty && selectedUOM != null) {
      uomQtyShippedID = selectedUOM!.uomID!;
      uomQtyRejectedID = selectedUOM!.uomID!;
      uomQtyReceivedID = selectedUOM!.uomID!;
    }

    // reason
    if (reasonList.isNotEmpty && selectedReason != null) {
      reasonID = selectedReason!.reasonID!;
    }

    // brand
    if (brandList.isNotEmpty && selectedBrand != null) {
      brandID = selectedBrand!.brandID!;
    }

    // origin
    if (originList.isNotEmpty && selectedOrigin != null) {
      originID = selectedOrigin!.countryID!;
    }

    // typeofCut
    int typeofCutIndex = rpcList.indexOf(selectedRpc.value);
    typeofCut = rpcList[typeofCutIndex];

    String workDateS = workDateController.text.trim();
    int workDate = 0;
    if (workDateS.isNotEmpty) {
      DateTime parsedDate = Utils().dateFormat.parse(workDateS);
      workDate = parsedDate.millisecondsSinceEpoch;
    }

    if (!hasErrors) {
      lotNo = lotNoController.text;
      if (qcID == null) {
        await dao.createQualityControl(
          inspectionId: inspectionId!,
          brandID: brandID,
          originID: originID,
          qtyShipped: qtyShipped,
          uomQtyShippedID: uomQtyShippedID,
          poNumber: poNumber!,
          pulpTempMin: pulpTempMin,
          pulpTempMax: pulpTempMax,
          recorderTempMin: recorderTempMin,
          recorderTempMax: recorderTempMax,
          rpc: rpc,
          claimFiledAgainst: claimFiledAgainst,
          qtyRejected: qtyRejected,
          uomQtyRejectedID: uomQtyRejectedID,
          reasonID: reasonID,
          qcComments: qcComments,
          qtyReceived: qtyReceived,
          uomQtyReceivedID: uomQtyReceivedID,
          specificationName: specificationName ?? "",
          packDate: packDate,
          seal_no: _appStorage.currentSealNumber!,
          lot_no: lotNo!,
          qcdOpen1: selectedTempRecorder.value,
          qcdOpen2: lotNoController.text,
          qcdOpen3: qtyInspectedOkController.text,
          qcdOpen4: sensitechSerialNoController.text,
          workDate: workDate,
          gtin: gtin ?? "",
          lot_size: 0,
          shipDate: 0,
          dateType: dateTypeDesc,
        );
      } else {
        log("here is Quanitity Rejected: $packDate");

        dao.updateQualityControl(
          qcID: qcID!,
          inspectionId: inspectionId!,
          brandID: brandID,
          originID: originID,
          qtyShipped: qtyShipped,
          uomQtyShippedID: uomQtyShippedID,
          poNumber: poNumber!,
          pulpTempMin: pulpTempMin,
          pulpTempMax: pulpTempMax,
          recorderTempMin: recorderTempMin,
          recorderTempMax: recorderTempMax,
          rpc: rpc,
          claimFiledAgainst: claimFiledAgainst,
          qtyRejected: qtyRejected,
          uomQtyRejectedID: uomQtyRejectedID,
          reasonID: reasonID,
          qcComments: qcComments,
          qtyReceived: qtyReceived,
          uomQtyReceivedID: uomQtyReceivedID,
          specificationName: specificationName ?? "",
          packDate: packDate,
          seal_no: _appStorage.currentSealNumber!,
          lot_no: lotNo!,
          qcdOpen1: selectedTempRecorder.value,
          qcdOpen2: lotNoController.text,
          qcdOpen3: qtyInspectedOkController.text,
          qcdOpen4: sensitechSerialNoController.text,
          workDate: workDate,
          gtin: gtin ?? "",
          lot_size: 0,
          shipDate: 0,
          dateType: dateTypeDesc,
        );
      }
      return true;
    }
    return false;
  }

  bool isValidNumber(String number) {
    // Regular expression to match the desired format: up to 4 whole numbers and up to 2 decimal places
    RegExp regex = RegExp(r'\d{1,4}(\.\d{0,2})?');
    return regex.hasMatch(number);
  }

  Future<void> loadFiledsFromDB(Map<String, dynamic> args) async {
    qtyRejectedController.text = "0";
    recorderTempMinController.text = '0';
    recorderTempMaxController.text = '0';
    pulpTempMinController.text = '0';
    pulpTempMaxController.text = '0';
    String packDateString = args[Consts.PACK_DATE] ?? '';
    String workDateString = args[Consts.WORK_DATE] ?? '';

    log("HERE IS WORKDATE $workDateString");
    log("HERE IS PACKDATE $packDateString");
    if (packDateString.isNotEmpty) {
      packDate = Utils().dateFormat.parse(packDateString);
      if (packDate != null) {
        packDateController.text = Utils().dateFormat.format(packDate!);
      }
    }
    if (workDateString.isNotEmpty) {
      workDate = Utils().dateFormat.parse(workDateString);
      if (workDate != null) {
        workDateController.text = Utils().dateFormat.format(workDate!);
      }
    }
    packDateController.addListener(() {
      if (packDateFocusNode.hasFocus) {
        packDateFocusNode.unfocus();
        selectDate(Get.context!, initialDate: packDate,
            onDateSelected: (selectedDate) {
          packDate = selectedDate;
          packDateController.text = Utils().dateFormat.format(selectedDate);
        });
      }
    });

    workDateController.addListener(() {
      if (workDateFocusNode.hasFocus) {
        workDateFocusNode.unfocus();
        selectDate(Get.context!, initialDate: workDate,
            onDateSelected: (selectedDate) {
          workDate = selectedDate;
          workDateController.text = Utils().dateFormat.format(selectedDate);
        });
      }
    });

    qualityControlItems = await dao.findQualityControlDetails(inspectionId!);

    if (qualityControlItems != null) {
      setUOMSpinner();
      setBrandSpinner();
      setOriginSpinner();
      setReasonSpinner();
      setSpinnerClaimField();
      setRpcSpinner();
      setTempSpinner();
      QualityControlItem item = qualityControlItems!;
      log("Here is QualityControlItem ${item.toJson()}");
      qcID = qualityControlItems!.qcID;
      qtyShippedController.text = qualityControlItems!.qtyShipped.toString();
      updateQtyApproved();

      if (qualityControlItems!.dateType != "") {
        dateTypeDesc = getDateTypeDesc(qualityControlItems!.dateType);
        packDateController.text = dateTypeDesc;
        workDateController.text = dateTypeDesc;
      }
      int packDate =
          int.tryParse(qualityControlItems!.packDate.toString()) ?? 0;
      int workDate =
          int.tryParse(qualityControlItems!.workDate.toString()) ?? 0;
      if (packDate > 0) {
        packDateController.text = getDateStingFromTime(packDate);
      } else {
        packDateController.text = "";
      }
      if (workDate > 0) {
        workDateController.text = getDateStingFromTime(workDate);
      } else {
        workDateController.text = "";
      }

      commentsController.text = qualityControlItems!.qcComments ?? '';
      qtyRejectedController.text =
          (qualityControlItems?.qtyRejected ?? '').toString();

      pulpTempMinController.text =
          (qualityControlItems?.pulpTempMin ?? '').toString();
      pulpTempMaxController.text =
          (qualityControlItems?.pulpTempMax ?? '').toString();
      recorderTempMinController.text =
          (qualityControlItems?.recorderTempMin ?? '').toString();
      recorderTempMaxController.text =
          (qualityControlItems?.recorderTempMax ?? '').toString();

      String rpcValue = qualityControlItems!.rpc!.isEmpty
          ? "N/A"
          : qualityControlItems?.rpc ?? "N/A";
      selectedRpc.value = rpcValue;

      String clamifiedValue = qualityControlItems!.claimFiledAgainst!.isEmpty
          ? "No Claim"
          : qualityControlItems?.claimFiledAgainst ?? "No Claim";
      selectedClaimField.value = clamifiedValue;

      String tempRecorderValue = qualityControlItems!.qcdOpen1!.isEmpty
          ? "Yes"
          : qualityControlItems?.qcdOpen1 ?? "Yes";
      selectedTempRecorder.value = tempRecorderValue;

      lotNoController.text = qualityControlItems!.qcdOpen2 ?? '';
      qtyInspectedOkController.text = qualityControlItems?.qcdOpen3 ?? '';
      sensitechSerialNoController.text = qualityControlItems?.qcdOpen4 ?? '';
    }
  }

  // Method to set UOM spinner
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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      update();
    });
    selectedUOM = uomList.firstWhere(
      (uomItem) => uomItem.uomID == qualityControlItems!.uomQtyShippedID,
      orElse: () => UOMItem(0, 'Select One'),
    );
    update();
  }

  UOMItem? getUOMID(String uomName) {
    return uomList.firstWhereOrNull((uomItem) => uomItem.uomName == uomName);
  }

  UOMItem? getUOMPos(int uomID) {
    return uomList.firstWhereOrNull((uomItem) => uomItem.uomID == uomID);
  }

  // Method to set BRAND spinner
  Future<void> setBrandSpinner() async {
    _appStorage.brandList = await JsonFileOperations.parseBrandJson() ?? [];

    brandList = _appStorage.brandList!;
    brandList.insert(0, BrandItem(brandID: 0, brandName: 'Select One'));
    List<String> brandListArray = ['Select One'];
    for (int j = 0; j < brandList.length; j++) {
      brandListArray.add(brandList[j].brandName!);
    }
    if (brandListArray.isNotEmpty) {
      selectedBrand = brandList[0];
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      update();
    });
    selectedBrand = brandList.firstWhere(
      (originItem) => originItem.brandID == qualityControlItems!.brandID,
      orElse: () => BrandItem(brandID: 0, brandName: 'Select One'),
    );
    update();
  }

  // Method to set ORIGIN spinner
  Future<void> setOriginSpinner() async {
    _appStorage.countryList = await JsonFileOperations.parseCountryJson() ?? [];

    originList = _appStorage.countryList!;

    List<String> originListArray = ['Select One'];
    originList.insert(0, CountryItem(0, 'Select One'));
    for (int j = 0; j < originList.length; j++) {
      originListArray.add(originList[j].countryName!);
    }
    if (originListArray.isNotEmpty) {
      selectedOrigin = originList[0];
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      update();
    });
    selectedOrigin = originList.firstWhere(
      (originItem) => originItem.countryID == qualityControlItems!.originID,
      orElse: () => CountryItem(0, 'Select One'),
    );
    update();
  }

  // Method to set REASON spinner
  Future<void> setReasonSpinner() async {
    _appStorage.reasonList = await JsonFileOperations.parseReasonJson() ?? [];
    reasonList = _appStorage.reasonList!;

    List<String> reasonListArray = ['Select One'];
    reasonList.insert(0, ReasonItem(0, 'Select One'));
    for (int j = 0; j < reasonList.length; j++) {
      reasonListArray.add(reasonList[j].reasonName!);
    }
    if (reasonListArray.isNotEmpty) {
      selectedReason = reasonList[0];
    }
    SchedulerBinding.instance.addPostFrameCallback((_) {
      update();
    });
    selectedReason = reasonList.firstWhere(
      (reasonItem) => reasonItem.reasonID == qualityControlItems!.reasonID,
      orElse: () => ReasonItem(0, 'Select One'),
    );
    update();
  }

  // Method to set CLAIM FIELD spinner
  setSpinnerClaimField() {
    int selectedIndexClaimField =
        claimFieldList.indexOf(selectedClaimField.value);

    selectedClaimField.value = claimFieldList[selectedIndexClaimField];

    log("Here ${selectedClaimField.value}");
    if (selectedClaimField.value == claimFieldList[0]) {
      selectedClaimFieldLabel.value = "NC";
    } else if (selectedClaimField.value == claimFieldList[1]) {
      selectedClaimFieldLabel.value = "PC";
    } else if (selectedClaimField.value == claimFieldList[2]) {
      selectedClaimFieldLabel.value = "CC";
    } else {
      selectedClaimFieldLabel.value = "";
    }
  }

  // Method to set RPC spinner
  setRpcSpinner() {
    int selectedIndexRpc = rpcList.indexOf(selectedRpc.value);
    selectedRpc.value = rpcList[selectedIndexRpc];
  }

  // Method to set TEMPERATURE spinner
  setTempSpinner() {
    int selectedIndexTemp =
        tempRecorderList.indexOf(selectedTempRecorder.value);
    selectedTempRecorder.value = tempRecorderList[selectedIndexTemp];
  }

  void updateQtyApproved() {
    String qtyShippedString = qtyShippedController.text;
    String qtyRejectedString = qtyRejectedController.text;

    if (qtyShippedString.isNotEmpty && qtyRejectedString.isNotEmpty) {
      int qtyShipped = 0;
      int qtyRejected = 0;

      try {
        qtyShipped = int.parse(qtyShippedString);
        qtyRejected = int.parse(qtyRejectedString);
        int qtyReceived = qtyShipped - qtyRejected;
        qtyAprrovedController.text = qtyReceived.toString();
        /* if (qtyReceived < 0) {
          qtyAprrovedController.text = qtyShipped.toString();
        } */
        if (qtyRejected > qtyShipped) {
          isValidQuantityRejected.value = false;
          Utils.showErrorAlertDialog("Please enter a valid Quantity");
        } else {
          isValidQuantityRejected.value = true;
        }
      } catch (e) {
        debugPrint('updateQtyApproved:$e');
      }
    }
  }

  Future<String?> scanBarcode({
    required Function(String scanResult)? onScanResult,
  }) async {
    String? res = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.DEFAULT);
    if (res.isNotEmpty && res != '-1') {
      if (onScanResult != null) {
        onScanResult(res);
      }
      return res;
    } else {
      return null;
    }
  }

  String? scanSensitechSerialNoContents(String contents) {
    String barcodeResult = contents;
    if (barcodeResult.isNotEmpty) {
      sensitechSerialNoController.text = barcodeResult;
    } else {
      Utils.showErrorAlertDialog("Error reading Sensitech Barcode");
      return null;
    }
    return sensitechSerialNoController.text;
  }

  Future<DateTime?> selectDate(BuildContext context,
      {DateTime? firstDate,
      DateTime? lastDate,
      required DateTime? initialDate,
      required Function(DateTime selectedDate) onDateSelected}) async {
    DateTime now = DateTime.now();
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: firstDate ?? now.subtract(const Duration(days: 365 * 2)),
      initialDate: initialDate ?? now,
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
      initialDate = selectedDate;
      onDateSelected(selectedDate);
    }
    return selectedDate;
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

  int findPositionInArray(List<String> array, String item) {
    return array.indexOf(item);
  }

  String mapClaimFiledAgainst(String claimFiledAgainst) {
    switch (claimFiledAgainst) {
      case "NC":
        return "NC";
      case "PC":
        return "PC";
      case "CC":
        return "CC";
      default:
        return "";
    }
  }

  checkQuantityAlert() {
    Utils.showErrorAlertDialog("Please enter a valid quantity");
  }

  specAttributOnClick(BuildContext context) {
    String? qtyShippedString = qtyShippedController.text;
    if (qtyShippedString.isNotEmpty) {
      int qtyShipped = int.tryParse(qtyShippedString) ?? 0;
      if (qtyShipped > 3000) {
        AppAlertDialog.confirmationAlert(
          context,
          "",
          "Are you sure you want to enter $qtyShipped quantity",
          onYesTap: () {
            if (isValidQuantityRejected.value) {
              saveFieldsToDB();
              startSpecificationAttributesActivity();
            } else {
              Utils.showErrorAlertDialog("Please enter a valid quantity");
            }
          },
          onNOTap: () {
            Get.back();
            qtyShippedController.text = "";
            qtyAprrovedController.text = "";
          },
        );
      } else {
        if (isValidQuantityRejected.value) {
          saveFieldsToDB();
          startSpecificationAttributesActivity();
        } else {
          Utils.showErrorAlertDialog("Please enter a valid quantity");
        }
      }
    } else {
      if (isValidQuantityRejected.value) {
        saveFieldsToDB();
        startSpecificationAttributesActivity();
      } else {
        Utils.showErrorAlertDialog("Please enter a valid quantity");
      }
    }
  }

  String get lotNoString => lotNoController.text.trim();
  startSpecificationAttributesActivity() {
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
      Consts.PACK_DATE: packDate?.millisecondsSinceEpoch.toString(),
      Consts.LOT_SIZE: lotSize,
      Consts.PO_NUMBER: poNumber,
      Consts.PO_LINE_NO: poLineNo,
      Consts.PRODUCT_TRANSFER: productTransfer,
      Consts.DATETYPE: dateTypeDesc,
    };

    final String uniqueTag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.to(() => SpecificationAttributesScreen(uniqueTag: uniqueTag),
        arguments: passingData);
    /* if (callerActivity == "NewPurchaseOrderDetailsActivity") {
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
    } */
  }
}
