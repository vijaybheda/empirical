// ignore_for_file: non_constant_identifier_names, unused_field, unnecessary_overrides, prefer_interpolation_to_compose_strings, unrelated_type_equality_checks, prefer_const_constructors, unnecessary_null_comparison, unused_local_variable

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/trailer_temp.dart';
import 'package:pverify/models/trailer_temperature_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/trailer_temp/trailerTempClass.dart';
import 'package:pverify/ui/trailer_temp/trailertemprature_details.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';

class TrailerTempController extends GetxController {
  Rx<TrailerEnum> currentMode = TrailerEnum.Nose.obs;

  final pallet1_top_TextController = TextEditingController().obs;
  final pallet1_middle_TextController = TextEditingController().obs;
  final pallet1_bottom_TextController = TextEditingController().obs;
  final pallet2_top_TextController = TextEditingController().obs;
  final pallet2_middle_TextController = TextEditingController().obs;
  final pallet2_bottom_TextController = TextEditingController().obs;
  final pallet3_top_TextController = TextEditingController().obs;
  final pallet3_middle_TextController = TextEditingController().obs;
  final pallet3_bottom_TextController = TextEditingController().obs;
  final commentTextController = TextEditingController().obs;

  final FocusNode pallet1_top_FocusNode = FocusNode();
  final FocusNode pallet1_middle_FocusNode = FocusNode();
  final FocusNode pallet1_bottom_FocusNode = FocusNode();
  final FocusNode pallet2_top_FocusNode = FocusNode();
  final FocusNode pallet2_middle_FocusNode = FocusNode();
  final FocusNode pallet2_bottom_FocusNode = FocusNode();
  final FocusNode pallet3_top_FocusNode = FocusNode();
  final FocusNode pallet3_middle_FocusNode = FocusNode();
  final FocusNode pallet3_bottom_FocusNode = FocusNode();

  final String CELSIUS_SYMBOL = "°";

  var selectetdTruckArea = AppStrings.nose.obs;
  trailerTempItem1? trailerNoseDetails;
  trailerTempItem2? trailerMiddleDetails;
  trailerTempItem1? trailerTailDetails;
  TrailerTempClass tailerTempData = TrailerTempClass();
  var activePallet = AppStrings.pallet1.obs;
  String callerActivity = '';
  final ApplicationDao dao = ApplicationDao();

  CarrierItem? carrier1;
  String? orderNumber1;

  var isOrderNumberAvailable = false;

  @override
  void onInit() {
    super.onInit();

    tailerTempData.nose = TrailerTempPallet();
    tailerTempData.middle = TrailerTempPallet();
    tailerTempData.tail = TrailerTempPallet();

    tailerTempData.nose?.pallet1 = Pallet();
    tailerTempData.nose?.pallet2 = Pallet();
    tailerTempData.nose?.pallet3 = Pallet();

    tailerTempData.middle?.pallet1 = Pallet();
    tailerTempData.middle?.pallet2 = Pallet();
    tailerTempData.middle?.pallet3 = Pallet();

    tailerTempData.tail?.pallet1 = Pallet();
    tailerTempData.tail?.pallet2 = Pallet();
    tailerTempData.tail?.pallet3 = Pallet();

    currentMode.value = TrailerEnum.Nose;

    pallet1_top_FocusNode.addListener(() {
      _textFieldListener(
          pallet1_top_TextController.value, pallet1_top_FocusNode);
    });
    pallet1_middle_FocusNode.addListener(() {
      _textFieldListener(
          pallet1_middle_TextController.value, pallet1_middle_FocusNode);
    });
    pallet1_bottom_FocusNode.addListener(() {
      _textFieldListener(
          pallet1_bottom_TextController.value, pallet1_bottom_FocusNode);
    });
    pallet2_top_FocusNode.addListener(() {
      _textFieldListener(
          pallet2_top_TextController.value, pallet2_top_FocusNode);
    });
    pallet2_middle_FocusNode.addListener(() {
      _textFieldListener(
          pallet2_middle_TextController.value, pallet2_middle_FocusNode);
    });
    pallet2_bottom_FocusNode.addListener(() {
      _textFieldListener(
          pallet2_bottom_TextController.value, pallet2_bottom_FocusNode);
    });
    pallet3_top_FocusNode.addListener(() {
      _textFieldListener(
          pallet3_top_TextController.value, pallet3_top_FocusNode);
    });
    pallet3_middle_FocusNode.addListener(() {
      _textFieldListener(
          pallet3_middle_TextController.value, pallet3_middle_FocusNode);
    });
    pallet3_bottom_FocusNode.addListener(() {
      _textFieldListener(
          pallet3_bottom_TextController.value, pallet3_bottom_FocusNode);
    });

    debugPrint('carrier ID ${carrier1?.id}');
    debugPrint('orderNumber1${orderNumber1 ?? ''}');
    isOrderNumberAvailable = false;
  }

  void addData(String mode, String level, String value) {
    if (mode == 'N') {
      tailerTempData.nose?.pallet1?.top =
          level == "T1" ? value : tailerTempData.nose?.pallet1?.top;
      tailerTempData.nose?.pallet2?.top =
          level == "T2" ? value : tailerTempData.nose?.pallet2?.top;
      tailerTempData.nose?.pallet3?.top =
          level == "T3" ? value : tailerTempData.nose?.pallet3?.top;

      tailerTempData.nose?.pallet1?.middle =
          level == "M1" ? value : tailerTempData.nose?.pallet1?.middle;
      tailerTempData.nose?.pallet2?.middle =
          level == "M2" ? value : tailerTempData.nose?.pallet2?.middle;
      tailerTempData.nose?.pallet3?.middle =
          level == "M3" ? value : tailerTempData.nose?.pallet3?.middle;

      tailerTempData.nose?.pallet1?.bottom =
          level == "B1" ? value : tailerTempData.nose?.pallet1?.bottom;
      tailerTempData.nose?.pallet2?.bottom =
          level == "B2" ? value : tailerTempData.nose?.pallet2?.bottom;
      tailerTempData.nose?.pallet3?.bottom =
          level == "B3" ? value : tailerTempData.nose?.pallet3?.bottom;
    } else if (mode == 'M') {
      tailerTempData.middle?.pallet1?.top =
          level == "T1" ? value : tailerTempData.middle?.pallet1?.top;
      tailerTempData.middle?.pallet2?.top =
          level == "T2" ? value : tailerTempData.middle?.pallet2?.top;
      tailerTempData.middle?.pallet3?.top =
          level == "T3" ? value : tailerTempData.middle?.pallet3?.top;

      tailerTempData.middle?.pallet1?.middle =
          level == "M1" ? value : tailerTempData.middle?.pallet1?.middle;
      tailerTempData.middle?.pallet2?.middle =
          level == "M2" ? value : tailerTempData.middle?.pallet2?.middle;
      tailerTempData.middle?.pallet3?.middle =
          level == "M3" ? value : tailerTempData.middle?.pallet3?.middle;

      tailerTempData.middle?.pallet1?.bottom =
          level == "B1" ? value : tailerTempData.middle?.pallet1?.bottom;
      tailerTempData.middle?.pallet2?.bottom =
          level == "B2" ? value : tailerTempData.middle?.pallet2?.bottom;
      tailerTempData.middle?.pallet3?.bottom =
          level == "B3" ? value : tailerTempData.middle?.pallet3?.bottom;
    } else {
      tailerTempData.tail?.pallet1?.top =
          level == "T1" ? value : tailerTempData.tail?.pallet1?.top;
      tailerTempData.tail?.pallet2?.top =
          level == "T2" ? value : tailerTempData.tail?.pallet2?.top;
      tailerTempData.tail?.pallet3?.top =
          level == "T3" ? value : tailerTempData.tail?.pallet3?.top;

      tailerTempData.tail?.pallet1?.middle =
          level == "M1" ? value : tailerTempData.tail?.pallet1?.middle;
      tailerTempData.tail?.pallet2?.middle =
          level == "M2" ? value : tailerTempData.tail?.pallet2?.middle;
      tailerTempData.tail?.pallet3?.middle =
          level == "M3" ? value : tailerTempData.tail?.pallet3?.middle;

      tailerTempData.tail?.pallet1?.bottom =
          level == "B1" ? value : tailerTempData.tail?.pallet1?.bottom;
      tailerTempData.tail?.pallet2?.bottom =
          level == "B2" ? value : tailerTempData.tail?.pallet2?.bottom;
      tailerTempData.tail?.pallet3?.bottom =
          level == "B3" ? value : tailerTempData.tail?.pallet3?.bottom;
    }
    setDataUI();
  }

  void loadDataFromDB() async {
    List? trailerTempMap = await dao.findTempTrailerTemperatureItems(
        carrier1!.id!.toInt(), orderNumber1.toString());

    if(trailerTempMap!=null){
        for (var element in trailerTempMap) {
          addData(
              element['Location'], element['Level'], element['value'].toString());
        }
     }

    TrailerTemperatureDetails? temperatureDetails =
        await dao.findTempTrailerTemperatureDetails(
            carrier1!.id!.toInt(), orderNumber1.toString());

    if (temperatureDetails != null) {
      commentTextController.value.text = temperatureDetails.comments ?? '';
    }
  }

  String setDataWithSymbol(String value) {
    String tempVal =
        value.contains(CELSIUS_SYMBOL) ? value : value + CELSIUS_SYMBOL;
    return value.isEmpty ? '' : tempVal;
  }

  setDataUI() {
    if (currentMode.value == TrailerEnum.Nose) {
      pallet1_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet1?.top ?? '');
      pallet1_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet1?.middle ?? '');
      pallet1_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet1?.bottom ?? '');
      pallet2_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet2?.top ?? '');
      pallet2_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet2?.middle ?? '');
      pallet2_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet2?.bottom ?? '');
      pallet3_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet3?.top ?? '');
      pallet3_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet3?.middle ?? '');
      pallet3_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.nose?.pallet3?.bottom ?? '');
    } else if (currentMode.value == TrailerEnum.Middle) {
      pallet1_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet1?.top ?? '');
      pallet1_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet1?.middle ?? '');
      pallet1_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet1?.bottom ?? '');
      pallet2_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet2?.top ?? '');
      pallet2_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet2?.middle ?? '');
      pallet2_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet2?.bottom ?? '');
      pallet3_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet3?.top ?? '');
      pallet3_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet3?.middle ?? '');
      pallet3_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.middle?.pallet3?.bottom ?? '');
    } else {
      pallet1_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet1?.top ?? '');
      pallet1_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet1?.middle ?? '');
      pallet1_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet1?.bottom ?? '');
      pallet2_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet2?.top ?? '');
      pallet2_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet2?.middle ?? '');
      pallet2_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet2?.bottom ?? '');
      pallet3_top_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet3?.top ?? '');
      pallet3_middle_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet3?.middle ?? '');
      pallet3_bottom_TextController.value.text =
          setDataWithSymbol(tailerTempData.tail?.pallet3?.bottom ?? '');
    }
  }

  @override
  void dispose() {
    super.dispose();
    pallet1_top_FocusNode.dispose();
    pallet1_middle_FocusNode.dispose();
    pallet1_bottom_FocusNode.dispose();
    pallet2_top_FocusNode.dispose();
    pallet2_middle_FocusNode.dispose();
    pallet2_bottom_FocusNode.dispose();
    pallet3_top_FocusNode.dispose();
    pallet3_middle_FocusNode.dispose();
    pallet3_bottom_FocusNode.dispose();
  }

  void _textFieldListener(TextEditingController value, FocusNode node) {
    if (value.text.isNotEmpty && node.hasFocus) {
      value.text = value.text.replaceAll(RegExp(CELSIUS_SYMBOL), '');
    } else if (node == pallet1_top_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet1;
      saveData(activePallet.value);
    } else if (node == pallet1_middle_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet1;
      saveData(activePallet.value);
    } else if (node == pallet1_bottom_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet1;
      saveData(activePallet.value);
    } else if (node == pallet2_top_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet2;
      saveData(activePallet.value);
    } else if (node == pallet2_middle_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet2;
      saveData(activePallet.value);
    } else if (node == pallet2_bottom_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet2;
      saveData(activePallet.value);
    } else if (node == pallet3_top_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet3;
      saveData(activePallet.value);
    } else if (node == pallet3_middle_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet3;
      saveData(activePallet.value);
    } else if (node == pallet3_bottom_FocusNode && !node.hasFocus) {
      activePallet.value = AppStrings.pallet3;
      saveData(activePallet.value);
    }
  }

  void saveData(String PalletTitle) {
    if (currentMode == TrailerEnum.Nose) {
      if (PalletTitle == AppStrings.pallet1) {
        tailerTempData.nose?.pallet1?.top =
            pallet1_top_TextController.value.text;
        tailerTempData.nose?.pallet1?.middle =
            pallet1_middle_TextController.value.text;
        tailerTempData.nose?.pallet1?.bottom =
            pallet1_bottom_TextController.value.text;
      } else if (PalletTitle == AppStrings.pallet2) {
        tailerTempData.nose?.pallet2?.top =
            pallet2_top_TextController.value.text;
        tailerTempData.nose?.pallet2?.middle =
            pallet2_middle_TextController.value.text;
        tailerTempData.nose?.pallet2?.bottom =
            pallet2_bottom_TextController.value.text;
      } else {
        tailerTempData.nose?.pallet3?.top =
            pallet3_top_TextController.value.text;
        tailerTempData.nose?.pallet3?.middle =
            pallet3_middle_TextController.value.text;
        tailerTempData.nose?.pallet3?.bottom =
            pallet3_bottom_TextController.value.text;
      }
    } else if (currentMode == TrailerEnum.Middle) {
      if (PalletTitle == AppStrings.pallet1) {
        tailerTempData.middle?.pallet1?.top =
            pallet1_top_TextController.value.text;
        tailerTempData.middle?.pallet1?.middle =
            pallet1_middle_TextController.value.text;
        tailerTempData.middle?.pallet1?.bottom =
            pallet1_bottom_TextController.value.text;
      } else if (PalletTitle == AppStrings.pallet2) {
        tailerTempData.middle?.pallet2?.top =
            pallet2_top_TextController.value.text;
        tailerTempData.middle?.pallet2?.middle =
            pallet2_middle_TextController.value.text;
        tailerTempData.middle?.pallet2?.bottom =
            pallet2_bottom_TextController.value.text;
      } else {
        tailerTempData.middle?.pallet3?.top =
            pallet3_top_TextController.value.text;
        tailerTempData.middle?.pallet3?.middle =
            pallet3_middle_TextController.value.text;
        tailerTempData.middle?.pallet3?.bottom =
            pallet3_bottom_TextController.value.text;
      }
    } else {
      if (PalletTitle == AppStrings.pallet1) {
        tailerTempData.tail?.pallet1?.top =
            pallet1_top_TextController.value.text;
        tailerTempData.tail?.pallet1?.middle =
            pallet1_middle_TextController.value.text;
        tailerTempData.tail?.pallet1?.bottom =
            pallet1_bottom_TextController.value.text;
      } else if (PalletTitle == AppStrings.pallet2) {
        tailerTempData.tail?.pallet2?.top =
            pallet2_top_TextController.value.text;
        tailerTempData.tail?.pallet2?.middle =
            pallet2_middle_TextController.value.text;
        tailerTempData.tail?.pallet2?.bottom =
            pallet2_bottom_TextController.value.text;
      } else {
        tailerTempData.tail?.pallet3?.top =
            pallet3_top_TextController.value.text;
        tailerTempData.tail?.pallet3?.middle =
            pallet3_middle_TextController.value.text;
        tailerTempData.tail?.pallet3?.bottom =
            pallet3_bottom_TextController.value.text;
      }
    }
    setDataUI();
  }

  // LOGIN SCREEN VALIDATION'S

  bool isLoginFieldsValidate(BuildContext context) {
    if (tailerTempData.nose?.pallet1?.top != "") {
      AppAlertDialog.validateAlerts(context, AppStrings.error,
          AppStrings.trailer_temperature_no_entries_alert);
      return false;
    }
    return true;
  }

  bool allDataBlank() {
    if (((tailerTempData.nose?.pallet1?.top == '' || tailerTempData.nose?.pallet1?.top == null) &&
            (tailerTempData.nose?.pallet1?.middle == '' ||
                tailerTempData.nose?.pallet1?.middle == null) &&
            (tailerTempData.nose?.pallet1?.bottom == '' ||
                tailerTempData.nose?.pallet1?.bottom == null)) &&
        ((tailerTempData.nose?.pallet2?.top == '' || tailerTempData.nose?.pallet2?.top == null) &&
            (tailerTempData.nose?.pallet2?.middle == '' ||
                tailerTempData.nose?.pallet2?.middle == null) &&
            (tailerTempData.nose?.pallet2?.bottom == '' ||
                tailerTempData.nose?.pallet2?.bottom == null)) &&
        ((tailerTempData.nose?.pallet3?.top == '' || tailerTempData.nose?.pallet3?.top == null) &&
            (tailerTempData.nose?.pallet3?.middle == '' ||
                tailerTempData.nose?.pallet3?.middle == null) &&
            (tailerTempData.nose?.pallet3?.bottom == '' ||
                tailerTempData.nose?.pallet3?.bottom == null)) &&
        ((tailerTempData.middle?.pallet1?.top == '' || tailerTempData.middle?.pallet1?.top == null) &&
            (tailerTempData.middle?.pallet1?.middle == '' ||
                tailerTempData.middle?.pallet1?.middle == null) &&
            (tailerTempData.middle?.pallet1?.bottom == '' ||
                tailerTempData.middle?.pallet1?.bottom == null)) &&
        ((tailerTempData.middle?.pallet2?.top == '' ||
                tailerTempData.middle?.pallet2?.top == null) &&
            (tailerTempData.middle?.pallet2?.middle == '' ||
                tailerTempData.middle?.pallet2?.middle == null) &&
            (tailerTempData.middle?.pallet2?.bottom == '' ||
                tailerTempData.middle?.pallet2?.bottom == null)) &&
        ((tailerTempData.middle?.pallet3?.top == '' ||
                tailerTempData.middle?.pallet3?.top == null) &&
            (tailerTempData.middle?.pallet3?.middle == '' ||
                tailerTempData.middle?.pallet3?.middle == null) &&
            (tailerTempData.middle?.pallet3?.bottom == '' ||
                tailerTempData.middle?.pallet3?.bottom == null)) &&
        ((tailerTempData.tail?.pallet1?.top == '' || tailerTempData.tail?.pallet1?.top == null) &&
            (tailerTempData.tail?.pallet1?.middle == '' ||
                tailerTempData.tail?.pallet1?.middle == null) &&
            (tailerTempData.tail?.pallet1?.bottom == '' ||
                tailerTempData.tail?.pallet1?.bottom == null)) &&
        ((tailerTempData.tail?.pallet2?.top == '' || tailerTempData.tail?.pallet2?.top == null) &&
            (tailerTempData.tail?.pallet2?.middle == '' ||
                tailerTempData.tail?.pallet2?.middle == null) &&
            (tailerTempData.tail?.pallet2?.bottom == '' ||
                tailerTempData.tail?.pallet2?.bottom == null)) &&
        ((tailerTempData.tail?.pallet3?.top == '' || tailerTempData.tail?.pallet3?.top == null) &&
            (tailerTempData.tail?.pallet3?.middle == '' ||
                tailerTempData.tail?.pallet3?.middle == null) &&
            (tailerTempData.tail?.pallet3?.bottom == '' ||
                tailerTempData.tail?.pallet3?.bottom == null))) {
      return true;
    } else {
      return false;
    }
  }

  void showPurchaseOrder() {
    if (callerActivity != null && callerActivity.isNotEmpty) {
      if (callerActivity == "PurchaseOrderDetailsActivity") {
        /*
      Get.offAll(() => PurchaseOrderDetailsActivity(), arguments: {
        "partnerName": partnerName,
        "partnerID": partnerID,
        "carrierName": carrierName,
        "carrierID": carrierID,
        "commodityID": commodityID,
        "commodityName": commodityName,
        "po_number": po_number,
        "callerActivity": "TrailerTempActivity",
      });
      */
      } else if (callerActivity == "NewPurchaseOrderDetailsActivity") {
        /*
      Get.offAll(() => NewPurchaseOrderDetailsActivity(), arguments: {
        "partnerName": partnerName,
        "partnerID": partnerID,
        "carrierName": carrierName,
        "carrierID": carrierID,
        "commodityID": commodityID,
        "commodityName": commodityName,
        "po_number": po_number,
        "callerActivity": "TrailerTempActivity",
      });
      */
      } else {
        Get.back();
      }
    } else {
      Get.back(); // Back to Quality Control Header Screen
    }
  }

  Future<void> saveTemperatureData(String location, String poNumber,
      int partnerID, TrailerTempClass tempData) async {
    if (location == 'N') {
      for (int i = 0; i < 9; i++) {
        String level;
        String value;
        if (i < 3) {
          level = i == 0
              ? 'T1'
              : i == 1
                  ? 'T2'
                  : 'T3';
          value = i == 0
              ? (tempData.nose?.pallet1?.top ?? '')
              : i == 1
                  ? tempData.nose?.pallet2?.top ?? ''
                  : tempData.nose?.pallet3?.top ?? '';
        } else if (i < 6) {
          level = i == 3
              ? 'M1'
              : i == 4
                  ? 'M2'
                  : 'M3';
          value = i == 3
              ? tempData.nose?.pallet1?.middle ?? ''
              : i == 4
                  ? tempData.nose?.pallet2?.middle ?? ''
                  : tempData.nose?.pallet3?.middle ?? '';
        } else {
          level = i == 6
              ? 'B1'
              : i == 7
                  ? 'B2'
                  : 'B3';
          value = i == 6
              ? tempData.nose?.pallet1?.bottom ?? ''
              : i == 7
                  ? tempData.nose?.pallet2?.bottom ?? ''
                  : tempData.nose?.pallet3?.bottom ?? '';
        }
        saveOrUpdateTempDataFromLayouts('N', poNumber, partnerID, level, value);
      }
    } else if (location == 'M') {
      for (int i = 0; i < 9; i++) {
        String level;
        String value;
        if (i < 3) {
          level = i == 0
              ? 'T1'
              : i == 1
                  ? 'T2'
                  : 'T3';
          value = i == 0
              ? (tempData.middle?.pallet1?.top ?? '')
              : i == 1
                  ? tempData.middle?.pallet2?.top ?? ''
                  : tempData.middle?.pallet3?.top ?? '';
        } else if (i < 6) {
          level = i == 3
              ? 'M1'
              : i == 4
                  ? 'M2'
                  : 'M3';
          value = i == 3
              ? tempData.middle?.pallet1?.middle ?? ''
              : i == 4
                  ? tempData.middle?.pallet2?.middle ?? ''
                  : tempData.middle?.pallet3?.middle ?? '';
        } else {
          level = i == 6
              ? 'B1'
              : i == 7
                  ? 'B2'
                  : 'B3';
          value = i == 6
              ? tempData.middle?.pallet1?.bottom ?? ''
              : i == 7
                  ? tempData.middle?.pallet2?.bottom ?? ''
                  : tempData.middle?.pallet3?.bottom ?? '';
        }
        saveOrUpdateTempDataFromLayouts('M', poNumber, partnerID, level, value);
      }
    } else {
      for (int i = 0; i < 9; i++) {
        String level;
        String value;
        if (i < 3) {
          level = i == 0
              ? 'T1'
              : i == 1
                  ? 'T2'
                  : 'T3';
          value = i == 0
              ? (tempData.tail?.pallet1?.top ?? '')
              : i == 1
                  ? tempData.tail?.pallet2?.top ?? ''
                  : tempData.tail?.pallet3?.top ?? '';
        } else if (i < 6) {
          level = i == 3
              ? 'M1'
              : i == 4
                  ? 'M2'
                  : 'M3';
          value = i == 3
              ? tempData.tail?.pallet1?.middle ?? ''
              : i == 4
                  ? tempData.tail?.pallet2?.middle ?? ''
                  : tempData.tail?.pallet3?.middle ?? '';
        } else {
          level = i == 6
              ? 'B1'
              : i == 7
                  ? 'B2'
                  : 'B3';
          value = i == 6
              ? tempData.tail?.pallet1?.bottom ?? ''
              : i == 7
                  ? tempData.tail?.pallet2?.bottom ?? ''
                  : tempData.tail?.pallet3?.bottom ?? '';
        }
        saveOrUpdateTempDataFromLayouts('B', poNumber, partnerID, level, value);
      }
    }
    await dao.createTempTrailerTemperatureDetails(partnerID.toString(), "", "",
        "", commentTextController.value.text, poNumber);
  }

  void saveOrUpdateTempDataFromLayouts(String location, String poNumber,
      int partnerID, String level, String value) {
    // if (trailerTempMap.containsKey(key)) {
    //   long trailerTemperatureId = trailerTempMap[key].trailerTemperatureId;
    //   if (value == null || value.isEmpty) {
    //     dao.deleteTempTrailerTemperatureEntryByTrailerTemperatureId(
    //         trailerTemperatureId);
    //   } else {
    //     // update the database with the current value
    //     //dao.updateTrailerTemperature(trailerTemperatureId, int.parse(value));
    //     dao.updateTempTrailerTemperature(
    //         trailerTemperatureId, int.parse(value));
    //   }
    // } else {
    // if (value != null && value.isNotEmpty) {
    //   dao.createTempTrailerTemperature(
    //       carrierID, location, level, int.parse(value), po_number);
    // }
    dao.createTempTrailerTemperature(
        partnerID, location, level, value, poNumber);
  }
}
