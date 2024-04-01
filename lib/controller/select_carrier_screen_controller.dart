import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/quality_control_header/quality_control_controller.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';
import 'package:pverify/utils/app_storage.dart';

class SelectCarrierScreenController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  final ApplicationDao dao = ApplicationDao();

  RxList<CarrierItem> filteredCarrierList = <CarrierItem>[].obs;
  RxList<CarrierItem> carriersList = <CarrierItem>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 190.h;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  void assignInitialData() {
    List<CarrierItem>? _carriersList = appStorage.getCarrierList();
    if (_carriersList == null) {
      carriersList.value = [];
      filteredCarrierList.value = [];
      listAssigned.value = true;
      update(['carrierList']);
    } else {
      carriersList.value = [];
      filteredCarrierList.value = [];

      carriersList.addAll(_carriersList);
      carriersList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredCarrierList.addAll(_carriersList);
      filteredCarrierList.sort((a, b) => a.name!.compareTo(b.name!));
      listAssigned.value = true;
      update(['carrierList']);
    }
    checkCarrierData();
  }

  void searchAndAssignCarrier(String searchValue) {
    filteredCarrierList.clear();
    if (searchValue.isEmpty) {
      filteredCarrierList.addAll(carriersList);
    } else {
      filteredCarrierList.value = carriersList
          .where((element) =>
              element.name!.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();
    }
    update(['carrierList']);
  }

  List<String> getListOfAlphabets() {
    Set<String> uniqueAlphabets = {};

    for (CarrierItem supplier in filteredCarrierList) {
      if (supplier.name!.isNotEmpty &&
          supplier.name![0].toUpperCase().contains(RegExp(r'[A-Z0-9]'))) {
        uniqueAlphabets.add(supplier.name![0].toUpperCase());
      }
    }

    return uniqueAlphabets.toList();
  }

  void scrollToSection(String letter, int index) {
    int targetIndex = filteredCarrierList
        .indexWhere((supplier) => supplier.name!.startsWith(letter));
    if (targetIndex != -1) {
      scrollController.animateTo(
        (targetIndex * listHeight) + (index * (listHeight * .45)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }

  checkCarrierData() {
    if (filteredCarrierList.length == 1) {
      Timer(Duration(seconds: 1), () {
        Get.to(QualityControlHeader(
            carreerName: filteredCarrierList[0].name ?? '',
            careerID: filteredCarrierList[0].id ?? 0));
      });
    }
  }
}
