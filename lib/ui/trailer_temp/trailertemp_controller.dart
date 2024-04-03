// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/trailer_temp.dart';
import 'package:pverify/utils/app_strings.dart';

class TrailerTempController extends GetxController {
  final nose_pallet1_top_TextController = TextEditingController().obs;
  final nose_pallet1_middle_TextController = TextEditingController().obs;
  final nose_pallet1_bottom_TextController = TextEditingController().obs;

  final nose_pallet2_top_TextController = TextEditingController().obs;
  final nose_pallet2_middle_TextController = TextEditingController().obs;
  final nose_pallet2_bottom_TextController = TextEditingController().obs;

  final nose_pallet3_top_TextController = TextEditingController().obs;
  final nose_pallet3_middle_TextController = TextEditingController().obs;
  final nose_pallet3_bottom_TextController = TextEditingController().obs;

  final middle_pallet1_top_TextController = TextEditingController().obs;
  final middle_pallet1_middle_TextController = TextEditingController().obs;
  final middle_pallet1_bottom_TextController = TextEditingController().obs;

  final middle_pallet2_top_TextController = TextEditingController().obs;
  final middle_pallet2_middle_TextController = TextEditingController().obs;
  final middle_pallet2_bottom_TextController = TextEditingController().obs;

  final middle_pallet3_top_TextController = TextEditingController().obs;
  final middle_pallet3_middle_TextController = TextEditingController().obs;
  final middle_pallet3_bottom_TextController = TextEditingController().obs;

  final tail_pallet1_top_TextController = TextEditingController().obs;
  final tail_pallet1_middle_TextController = TextEditingController().obs;
  final tail_pallet1_bottom_TextController = TextEditingController().obs;

  final tail_pallet2_top_TextController = TextEditingController().obs;
  final tail_pallet2_middle_TextController = TextEditingController().obs;
  final tail_pallet2_bottom_TextController = TextEditingController().obs;

  final tail_pallet3_top_TextController = TextEditingController().obs;
  final tail_pallet3_middle_TextController = TextEditingController().obs;
  final tail_pallet3_bottom_TextController = TextEditingController().obs;

  final commentTextController = TextEditingController().obs;

  var selectetdTruckArea = AppStrings.nose.obs;
  trailerTempItem1? trailerNoseDetails;
  trailerTempItem2? trailerMiddleDetails;
  trailerTempItem1? trailerTailDetails;
}
