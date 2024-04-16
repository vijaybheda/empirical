import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/ui/worksheet/defects_data.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class WorksheetController extends GetxController {
  final sizeOfNewSetTextController = TextEditingController().obs;
  var isFirstTime = true;
  var isDefectEntry = true;

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
    tempSampleObj = SampleSetsObject();
    tempSampleObj.sampleValue = setsValue;
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
  }) {
    switch (fieldName) {
      case AppStrings.injury:
      // do nothing
      case AppStrings.damage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = value;
        sampleSetObs.refresh();
      case AppStrings.seriousDamage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = value;
        sampleSetObs.refresh();
      case AppStrings.verySeriousDamage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .sDamageTextEditingController
            ?.text = value;
      case AppStrings.decay:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .sDamageTextEditingController
            ?.text = value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .vsDamageTextEditingController
            ?.text = value;
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

  void openPDFFile(BuildContext context) async {
    String filename =
        "II_${AppStorage.instance.commodityVarietyData?.commodityId.toString()}.pdf";

    var storagePath = await Utils().getExternalStoragePath();
    String path = "$storagePath/${FileManString.COMMODITYDOCS}/$filename";

    File file = File(path);

    if (await file.exists()) {
      try {} catch (e) {
        AppSnackBar.getCustomSnackBar("Error", "Error opening PDF file: $e",
            isSuccess: false);
      }
    } else {
      AppSnackBar.getCustomSnackBar("Error", "No Inspection Instructions",
          isSuccess: false);
    }
  }
}
