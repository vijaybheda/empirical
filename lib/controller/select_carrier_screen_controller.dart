import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/utils.dart';

class SelectCarrierScreenController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  final ApplicationDao dao = ApplicationDao();
  final JsonFileOperations jsonFileOperations = JsonFileOperations.instance;

  RxList<CarrierItem> filteredCarrierList = <CarrierItem>[].obs;
  RxList<CarrierItem> carriersList = <CarrierItem>[].obs;

  RxBool listAssigned = false.obs;

  final TextEditingController searchController = TextEditingController();

  double get listHeight => 195.h;

  String? callerActivity;
  String? carrierName;
  int? carrierID;

  @override
  void onInit() {
    Map? args = Get.arguments;

    callerActivity = args?[Consts.CALLER_ACTIVITY] ?? '';
    carrierName = args?[Consts.CARRIER_NAME] ?? '';
    carrierID = args?[Consts.CARRIER_ID] ?? 0;

    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    await dao.deleteRowsTempTrailerTable();
    await dao.deleteTempTrailerTemperatureDetails();
    //clear out temporary selected ItemSKUs
    appStorage.selectedItemSKUList.clear();
    await dao.deleteSelectedItemSKUList();

    List<CarrierItem>? storedCarriersList = appStorage.getCarrierList();
    if (storedCarriersList == null) {
      await jsonFileOperations.offlineLoadCarriersData();
      carriersList.value = [];
      filteredCarrierList.value = [];
      listAssigned.value = true;
      update(['carrierList']);
    } else {
      carriersList.value = [];
      filteredCarrierList.value = [];

      carriersList.addAll(storedCarriersList);
      carriersList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredCarrierList.addAll(storedCarriersList);
      filteredCarrierList.sort((a, b) => a.name!.compareTo(b.name!));
      listAssigned.value = true;
      update(['carrierList']);

      if (filteredCarrierList.length == 1) {
        // FIXME: Demo purpose only: This is a temporary fix to navigate to QC Header if only one carrier is available
        // navigateToQcHeader(filteredCarrierList.first);
      }
    }
  }

  void searchAndAssignCarrier(String searchValue) {
    filteredCarrierList.clear();
    if (searchValue.isEmpty) {
      filteredCarrierList.addAll(carriersList);
    } else {
      List<CarrierItem> data = carriersList
          .where((element) =>
              element.name!.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();

      filteredCarrierList.addAll(data);
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

  void navigateToQcHeader(CarrierItem carrier) {
    Future.delayed(const Duration(milliseconds: 10), () {
      Get.off(() => QualityControlHeader(/*carrier: carrier*/), arguments: {
        Consts.CALLER_ACTIVITY: 'TrendingReportActivity',
        Consts.CARRIER_NAME: carrier.name,
        Consts.CARRIER_ID: carrier.id
      });
    });
  }

  void clearSearch() {
    searchController.clear();
    searchAndAssignCarrier('');
    unFocus();
  }
}
