// ignore_for_file: unused_local_variable

import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/defects_data.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class WorksheetController extends GetxController {
  final sizeOfNewSetTextController = TextEditingController().obs;
  var isFirstTime = true;
  var isDefectEntry = true;

  RxInt activeTabIndex = 1.obs;

  var sampleSetObs = <SampleSetsObject>[].obs;
  SampleSetsObject tempSampleObj = SampleSetsObject();

  // LOGIN SCREEN VALIDATION'S

  bool isValid(BuildContext context) {
    if (sizeOfNewSetTextController.value.text.trim().isEmpty) {
      AppAlertDialog.validateAlerts(
          context, AppStrings.error, AppStrings.errorEnterSize);
      return false;
    }
    return true;
  }

  addSampleSets(String setsValue) {
    final int index;

    // debugPrint("sampleSetObs.last ${sampleSetObs.reversed.last.sampleId}");

    int id = sampleSetObs.isNotEmpty
        ? (int.tryParse(sampleSetObs.reversed.last.sampleId ?? "1") ?? 1) + 1
        : 1;
    /*  if (sampleSetObs.length >= 1) {
      index = sampleSetObs.elementAt(sampleSetObs.length - 1).setNumber! + 1;
    } else {
      index = sampleSetObs.length + 1;
    }*/
    tempSampleObj = SampleSetsObject();
    tempSampleObj.sampleValue = setsValue;
    tempSampleObj.sampleId = id.toString();
    sampleSetObs.insert(0, tempSampleObj);
    sizeOfNewSetTextController.value.text = "";
  }

  void addDefectRow({required int setIndex}) {
    DefectItem emptyDefectItem = DefectItem(
      injuryTextEditingController: TextEditingController(text: '0'),
      damageTextEditingController: TextEditingController(text: '0'),
      sDamageTextEditingController: TextEditingController(text: '0'),
      vsDamageTextEditingController: TextEditingController(text: '0'),
      decayTextEditingController: TextEditingController(text: '0'),
    );

    sampleSetObs[setIndex].defectItem == null
        ? sampleSetObs[setIndex].defectItem = [emptyDefectItem]
        : sampleSetObs[setIndex].defectItem?.add(emptyDefectItem);
    sampleSetObs.refresh();
  }

  void removeDefectRow({required int setIndex, required int rowIndex}) {
    sampleSetObs[setIndex].defectItem?.removeAt(rowIndex);
    sampleSetObs.refresh();
  }

  int getDefectItemIndex(
      {required int setIndex, required DefectItem defectItem}) {
    return sampleSetObs[setIndex].defectItem?.indexOf(defectItem) ?? -1;
  }

  void onTextChange({
    required String value,
    required int setIndex,
    required int rowIndex,
    required String fieldName,
    required BuildContext context,
  }) {
    bool isError = false;
    int sampleSize =
        int.tryParse(sampleSetObs[setIndex].sampleValue ?? "0") ?? 0;
    String dropDownValue =
        sampleSetObs[setIndex].defectItem?[rowIndex].name ?? "";
    if ((int.tryParse(value) ?? 0) > sampleSize) {
      isError = true;
      AppAlertDialog.validateAlerts(
        context,
        AppStrings.alert,
        '${AppStrings.defect} - $dropDownValue${AppStrings.cannotBeGreaterThenTheSampleSize} $sampleSize, ${AppStrings.pleaseEnterValidDefectCount}',
      );
    }

    switch (fieldName) {
      case AppStrings.injury:
        // do nothing
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .injuryTextEditingController
              ?.text = '0';
        }
        sampleSetObs.refresh();
      case AppStrings.damage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = isError ? '0' : value;
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .damageTextEditingController
              ?.text = isError ? '0' : value;
        }
        sampleSetObs.refresh();
      case AppStrings.seriousDamage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = isError ? '0' : value;
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .sDamageTextEditingController
              ?.text = isError ? '0' : value;
        }
        sampleSetObs.refresh();
      case AppStrings.verySeriousDamage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .sDamageTextEditingController
            ?.text = isError ? '0' : value;
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .vsDamageTextEditingController
              ?.text = isError ? '0' : value;
        }

      case AppStrings.decay:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .sDamageTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .vsDamageTextEditingController
            ?.text = isError ? '0' : value;
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .decayTextEditingController
              ?.text = isError ? '0' : value;
        }
      default:
      // do nothing
    }
  }

  void onDropDownChange({
    required String value,
    required int setIndex,
    required int rowIndex,
  }) {
    sampleSetObs[setIndex].defectItem?[rowIndex].name = value;
    sampleSetObs.refresh();
  }

  void onCommentAdd({
    required String value,
    required int setIndex,
    required int rowIndex,
  }) {
    sampleSetObs[setIndex].defectItem?[rowIndex].instruction = value;
    sampleSetObs.refresh();
  }

  void getDropDownValues() {
    List<CommodityItem>? commodityItemsList = AppStorage.instance.commodityList;
    debugPrint("commodity ${commodityItemsList}");
  }

  removeSampleSets(int index) {
    sampleSetObs.removeAt(index);
  }

  void openPDFFile(BuildContext context, String type) async {
    String filename;
    if (type == "Inspection Instructions") {
      filename =
          "II_${AppStorage.instance.commodityVarietyData?.commodityId.toString()}.pdf";
    } else {
      filename =
          "GRADE_${AppStorage.instance.commodityVarietyData?.commodityId.toString()}.pdf";
    }

    var storagePath = await Utils().getExternalStoragePath();
    String path = "$storagePath/${FileManString.COMMODITYDOCS}/$filename";

    File file = File(path);

    if (await file.exists()) {
      try {
        final Uri data2 = Uri.file(path);
        await _grantPermissions(data2);
        await openFile(path);
      } catch (e) {
        AppSnackBar.getCustomSnackBar("Error", "Error opening PDF file: $e",
            isSuccess: false);
      }
    } else {
      if (type == "Inspection Instructions") {
        AppSnackBar.getCustomSnackBar("Error", "No Inspection Instructions",
            isSuccess: false);
      } else {
        AppSnackBar.getCustomSnackBar("Error", "No Grade", isSuccess: false);
      }
    }
  }

  Future<void> _grantPermissions(Uri uri) async {
    final permissions = <Permission>[Permission.storage];
    for (final permission in permissions) {
      if (await permission.status.isGranted) continue;
      await permission.request();
    }
  }

  Future<bool> openFile(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      OpenResult resultType = await OpenFile.open(filePath);
      return resultType.type == ResultType.done;
    } else {
      return false;
    }
  }
}
