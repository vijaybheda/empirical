// ignore_for_file: file_names

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class SetupController extends GetxController {
  var dateformats = [];
  final banner1TextController = TextEditingController().obs;
  final banner2TextController = TextEditingController().obs;
  final banner3TextController = TextEditingController().obs;
  var selectetdDateFormat = 'mm-dd-yyyy'.obs;

  @override
  void onInit() {
    super.onInit();
    dateformats = [
      'mm-dd-yyyy',
      'dd-mm-yyyy',
      'yyyy-mm-dd',
    ];
  }
}
