// ignore_for_file: camel_case_types

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/app_strings.dart';

class QualityControl_Controller extends GetxController {
  final orderNoTextController = TextEditingController().obs;
  final commentTextController = TextEditingController().obs;
  final sealTextController = TextEditingController().obs;
  final certificateDepartureTextController = TextEditingController().obs;
  final factoryReferenceTextController = TextEditingController().obs;
  final usdaReferenceTextController = TextEditingController().obs;
  final containerTextController = TextEditingController().obs;
  final totalQuantityTextController = TextEditingController().obs;
  final transportConditionTextController = TextEditingController().obs;

  final isShortForm = false.obs;
  List truckTempOk = AppStrings.truckTempOk;
  List type = AppStrings.types;
  List loadType = AppStrings.stowage;

  var selectetdloadType = 'Internal Managed'.obs;
  var selectetdTruckTempOK = 'Yes'.obs;
  var selectetdTypes = 'Quality Assurance'.obs;
  var spacingBetweenFields = 10;

  void setSelected(String value, String type) {
    if (type == 'TruckTempOK') {
      // TruckTempOK
      selectetdTruckTempOK.value = value;
    } else if (type == 'Type') {
      // Types
      selectetdTypes.value = value;
    } else {
      // Load Types
      selectetdloadType.value = value;
    }
  }
}
