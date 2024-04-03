// ignore_for_file: non_constant_identifier_names, unused_field, unnecessary_overrides, prefer_interpolation_to_compose_strings

import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/trailer_temp.dart';
import 'package:pverify/ui/trailer_temp/trailerTempClass.dart';
import 'package:pverify/utils/app_strings.dart';

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

  final FocusNode pallet1_top_FocusNode = FocusNode();
  final FocusNode pallet1_middle_FocusNode = FocusNode();
  final FocusNode pallet1_bottom_FocusNode = FocusNode();
  final FocusNode pallet2_top_FocusNode = FocusNode();
  final FocusNode pallet2_middle_FocusNode = FocusNode();
  final FocusNode pallet2_bottom_FocusNode = FocusNode();
  final FocusNode pallet3_top_FocusNode = FocusNode();
  final FocusNode pallet3_middle_FocusNode = FocusNode();
  final FocusNode pallet3_bottom_FocusNode = FocusNode();

  final commentTextController = TextEditingController().obs;
  final String CELSIUS_SYMBOL = "°";

  var selectetdTruckArea = AppStrings.nose.obs;
  trailerTempItem1? trailerNoseDetails;
  trailerTempItem2? trailerMiddleDetails;
  trailerTempItem1? trailerTailDetails;
  TrailerTempClass tailerTempData = TrailerTempClass();

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
          pallet2_middle_TextController.value, pallet2_bottom_FocusNode);
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
  }

  void _textFieldListener(TextEditingController value, FocusNode node) {
    if (value.text.isNotEmpty && node.hasFocus) {
      value.text = value.text.replaceAll(RegExp(CELSIUS_SYMBOL), '');
    }
  }
}
