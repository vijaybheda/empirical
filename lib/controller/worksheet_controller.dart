import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/ui/worksheet/defects_data.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';

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

  removeSampleSets(int index) {
    sampleSetObs.removeAt(index);
  }

 /* void openPDFFile(BuildContext context) async {
    String filename = "II_${AppStorage.instance.commodityVarietyData.getCommodityId()}.pdf";

    Directory storageDirectory = await getExternalStorageDirectory();
    String path = storageDirectory.path + "/${StorageConstants.COMMODITYDOCS}/$filename";

    File file = File(path);
    if (await file.exists()) {
      try {
        await launch(path, forceSafariVC: false, forceWebView: false);
      } catch (e) {
        debugPrint("Error opening PDF file: $e");
       *//* ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error opening PDF file'),
        ));*//*
      }
    } else {
      *//*ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('No Inspection Instructions'),
      ));*//*
    }
  }*/
}
