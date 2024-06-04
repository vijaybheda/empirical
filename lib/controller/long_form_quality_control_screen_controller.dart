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
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
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
  final List<String> claimFieldList = <String>[
    "No Claim",
    "Partner Claim",
    "Carrier Claim",
  ];
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

    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    inspectionId = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? '';
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    varietyName = args[Consts.VARIETY_NAME] ?? '';
    varietySize = args[Consts.VARIETY_SIZE] ?? '';
    varietyId = args[Consts.VARIETY_ID] ?? 0;
    gradeId = args[Consts.GRADE_ID] ?? 0;
    completed = args[Consts.COMPLETED] ?? false;
    specificationNumber = args[Consts.SPECIFICATION_NUMBER] ?? '';
    specificationVersion = args[Consts.SPECIFICATION_VERSION] ?? '';
    selectedSpecification = args[Consts.SPECIFICATION_NAME] ?? '';
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME] ?? '';
    lotNo = args[Consts.LOT_NO] ?? '';
    String packDateString = args[Consts.PACK_DATE] ?? '';
    if (packDateString.isNotEmpty) {
      packDate = DateTime.fromMillisecondsSinceEpoch(int.parse(packDateString));
    }
    gtin = args[Consts.GTIN] ?? '';
    isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
    itemSKU = args[Consts.ITEM_SKU] ?? '';
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
    lotSize = args[Consts.LOT_SIZE] ?? '';
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    poLineNo = args[Consts.PO_LINE_NO] ?? 0;
    dateTypeDesc = args[Consts.DATETYPE] ?? '';

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
    String qcComments = commentsController.text;

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

    double pulpTempMin = 0,
        pulpTempMax = 0,
        recorderTempMin = 0,
        recorderTempMax = 0;

    // pulpTempMin
    if (pulpTempMinController.text.isNotEmpty) {
      if (isValidNumber(pulpTempMinController.text)) {
        pulpTempMin = double.parse(pulpTempMinController.text);
      } else {
        hasErrors = true;
        Utils.showErrorAlertDialog(
            "Pulp Temp Min should not exceed 4 digits & 2 decimals");
      }
    }

    // pulpTempMax
    if (pulpTempMaxController.text.isNotEmpty) {
      if (isValidNumber(pulpTempMaxController.text)) {
        pulpTempMax = double.parse(pulpTempMaxController.text);
      } else {
        hasErrors = true;
        Utils.showErrorAlertDialog(
            "Pulp Temp Max should not exceed 4 digits & 2 decimals");
      }
    }

    // recorderTempMin
    if (recorderTempMinController.text.isNotEmpty) {
      if (isValidNumber(recorderTempMinController.text)) {
        recorderTempMin = double.parse(recorderTempMinController.text);
      } else {
        hasErrors = true;
        Utils.showErrorAlertDialog(
            "Recorder Temp Min should not exceed 4 digits & 2 decimals");
      }
    }

    // recorderTempMax
    if (recorderTempMaxController.text.isNotEmpty) {
      if (isValidNumber(recorderTempMaxController.text)) {
        recorderTempMax = double.parse(recorderTempMaxController.text);
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
    }
    // rpc
    int rpcIndex = rpcList.indexOf(selectedRpc.value);
    String rpc = rpcList[rpcIndex];

    // claimFiledAgainst
    int clamFiledAgainstIndex =
        claimFieldList.indexOf(selectedClaimField.value);
    // String claimFiledAgainst1 = claimFieldList[clamFiledAgainstIndex];
    String claimFiledAgainst =
        getClaimFiledAgainst(claimFieldList[clamFiledAgainstIndex]);
    int uomQtyShippedID = 0;
    int uomQtyRejectedID = 0;
    int uomQtyReceivedID = 0;
    int brandID = 0;
    int reasonID = 0;
    int originID = 0;

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
    rpcList.indexOf(selectedRpc.value);

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
          lot_no: lotNoController.text,
          qcdOpen1: selectedTempRecorder.value,
          qcdOpen2: lotNoController.text,
          qcdOpen3: qtyInspectedOkController.text,
          qcdOpen4: sensitechSerialNoController.text,
          workDate: workDate,
          gtin: gtin ?? "",
          lot_size: 0,
          shipDate: 0,
          dateType: dateTypeDesc,
          gln: gln ?? '',
          glnType: '',
        );
      } else {
        await dao.updateQualityControl(
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
          seal_no: _appStorage.currentSealNumber ?? '',
          lot_no: lotNoController.text,
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
    recorderTempMinController.text = '0';
    recorderTempMaxController.text = '0';
    pulpTempMinController.text = '0';
    pulpTempMaxController.text = '0';
    String packDateString = args[Consts.PACK_DATE] ?? '';
    String workDateString = args[Consts.WORK_DATE] ?? '';

    if (packDateString.isNotEmpty) {
      try {
        packDate =
            DateTime.fromMillisecondsSinceEpoch(int.parse(packDateString));
        if (packDate != null) {
          packDateController.text = Utils().dateFormat.format(packDate!);
        }
      } catch (e) {
        log("Error parsing packDateString: $e");
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
      QualityControlItem item = qualityControlItems!;
      log("Here is QualityControlItem ${item.toJson()}");
      qcID = qualityControlItems!.qcID;
      qtyShippedController.text = qualityControlItems!.qtyShipped.toString();

      if (qualityControlItems!.dateType != "") {
        dateTypeDesc = getDateTypeDesc(qualityControlItems!.dateType);
        packDateController.text = dateTypeDesc;
        workDateController.text = dateTypeDesc;
      }

      int packDateMillis =
          int.tryParse(qualityControlItems!.packDate.toString()) ?? 0;
      int workDate =
          int.tryParse(qualityControlItems!.workDate.toString()) ?? 0;
      // Check if packDateMillis is valid
      if (packDateMillis > 0) {
        try {
          DateTime parsedDate =
              DateTime.fromMillisecondsSinceEpoch(packDateMillis);
          String formattedDate = Utils().dateFormat.format(parsedDate);
          packDateController.text = formattedDate;
        } catch (e) {
          log("Error parsing packDateMillis: $e");
          packDateController.text = "";
        }
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
          (qualityControlItems?.qtyRejected ?? '0').toString();
      log("hereee is Quality COntrol ${qualityControlItems?.qtyRejected}");
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

      lotNoController.text = qualityControlItems!.lot ?? '';
      qtyInspectedOkController.text = qualityControlItems?.qcdOpen3 ?? '';
      sensitechSerialNoController.text = qualityControlItems?.qcdOpen4 ?? '';
      updateQtyApproved();
    }

    setUOMSpinner();
    setBrandSpinner();
    setOriginSpinner();
    setReasonSpinner();
    setSpinnerClaimField();
    setRpcSpinner();
    setTempSpinner();
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
    for (int i = 0; i < uomList.length; i++) {
      if (uomList.elementAt(i).uomName == uomName) {
        return uomList.elementAt(i);
      }
    }
    return null;
    // return uomList.firstWhereOrNull((uomItem) => uomItem.uomName == uomName);
  }

  UOMItem? getUOMPos(int uomID) {
    for (int i = 0; i < uomList.length; i++) {
      if (uomList.elementAt(i).uomID == uomID) {
        return uomList.elementAt(i);
      }
    }
    return null;
    // return uomList.firstWhereOrNull((uomItem) => uomItem.uomID == uomID);
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
    selectedReason = reasonList.firstWhere(
      (reasonItem) => reasonItem.reasonID == qualityControlItems!.reasonID,
      orElse: () => ReasonItem(0, 'Select One'),
    );
  }

  // Method to set CLAIM FIELD spinner
  void setSpinnerClaimField() {
    if (selectedClaimField.value == "PC") {
      selectedClaimField.value = "Partner Claim";
    } else if (selectedClaimField.value == "CC") {
      selectedClaimField.value = "Carrier Claim";
    } else if (selectedClaimField.value == "NC") {
      selectedClaimField.value = "No Claim";
    } else {
      selectedClaimField.value = "No Claim";
    }

    int selectedIndexClaimField =
        claimFieldList.indexOf(selectedClaimField.value);
    selectedClaimField.value = claimFieldList[selectedIndexClaimField];

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
  void setRpcSpinner() {
    int selectedIndexRpc = rpcList.indexOf(selectedRpc.value);
    selectedRpc.value = rpcList[selectedIndexRpc];
  }

  // Method to set TEMPERATURE spinner
  void setTempSpinner() {
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

  String getClaimFiledAgainst(String claimFiledAgainst) {
    String noClaim = claimFieldList.elementAt(0);
    String partnerClaim = claimFieldList.elementAt(1);
    String carrierClaim = claimFieldList.elementAt(2);

    if (noClaim == claimFiledAgainst) {
      return "NC";
    } else if (partnerClaim == claimFiledAgainst) {
      return "PC";
    } else if (carrierClaim == claimFiledAgainst) {
      return "CC";
    } else {
      return "";
    }
  }

  void checkQuantityAlert() {
    return Utils.showErrorAlertDialog("Please enter a valid quantity");
  }

  Future<void> specAttributOnClick(BuildContext context) async {
    String? qtyShippedString = qtyShippedController.text;
    if (qtyShippedString.isNotEmpty) {
      int qtyShipped = int.tryParse(qtyShippedString) ?? 0;
      if (qtyShipped > 3000) {
        AppAlertDialog.confirmationAlert(
          context,
          "",
          "Are you sure you want to enter $qtyShipped quantity",
          onYesTap: () async {
            if (isValidQuantityRejected.value) {
              await saveFieldsToDB();
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
          await saveFieldsToDB();
          startSpecificationAttributesActivity();
        } else {
          Utils.showErrorAlertDialog("Please enter a valid quantity");
        }
      }
    } else {
      if (isValidQuantityRejected.value) {
        await saveFieldsToDB();
        startSpecificationAttributesActivity();
      } else {
        Utils.showErrorAlertDialog("Please enter a valid quantity");
      }
    }
  }

  String get lotNoString => lotNoController.text.trim();

  void startSpecificationAttributesActivity() {
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

  Future shortFormClick() async {
    if (isValidQuantityRejected.value) {
      await saveFieldsToDB();
      startQCShortFormActivity();
    } else {
      Utils.showErrorAlertDialog("Please enter a valid quantity");
    }
  }

  void startQCShortFormActivity() {
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
    callerActivity == "NewPurchaseOrderDetailsActivity"
        ? "NewPurchaseOrderDetailsActivity"
        : "PurchaseOrderDetailsActivity";
    passingData[Consts.CALLER_ACTIVITY] = callerActivity;
    Get.to(() => QCDetailsShortFormScreen(tag: uniqueTag),
        arguments: passingData);
  }

  Future backButtonClick() async {
    await saveFieldsToDB();
    Get.back();
    Get.back();
  }
}
