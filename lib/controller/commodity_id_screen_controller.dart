import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/utils/app_storage.dart';

class CommodityIDScreenController extends GetxController {
  final PartnerItem partner;
  CommodityIDScreenController({required this.partner});

  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  RxList<CommodityItem> filteredCommodityList = <CommodityItem>[].obs;
  RxList<CommodityItem> commodityList = <CommodityItem>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 180.h;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  void assignInitialData() {
    List<CommodityItem>? _commoditiesList = appStorage.getCommodityList();
    if (_commoditiesList == null) {
      commodityList.value = [];
      filteredCommodityList.value = [];
      listAssigned.value = true;
      update(['commodityList']);
    } else {
      commodityList.value = [];
      filteredCommodityList.value = [];

      commodityList.addAll(_commoditiesList);

      commodityList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredCommodityList.addAll(_commoditiesList);
      filteredCommodityList.sort((a, b) => a.name!.compareTo(b.name!));
      listAssigned.value = true;
      update(['commodityList']);
    }
  }

  void searchAndAssignPartner(String searchValue) {
    filteredCommodityList.clear();
    if (searchValue.isEmpty) {
      filteredCommodityList.addAll(commodityList);
    } else {
      filteredCommodityList.value = commodityList
          .where((element) => element.keywords!
              .toLowerCase()
              .contains(searchValue.toLowerCase()))
          .toList();
    }
    update(['commodityList']);
  }

  List<String> getListOfAlphabets() {
    Set<String> uniqueAlphabets = {};

    for (CommodityItem supplier in commodityList) {
      if (supplier.name!.isNotEmpty &&
          supplier.name![0].toUpperCase().contains(RegExp(r'[A-Z0-9]'))) {
        uniqueAlphabets.add(supplier.name![0].toUpperCase());
      }
    }

    return uniqueAlphabets.toList();
  }

  void scrollToSection(String letter, int index) {
    int targetIndex = filteredCommodityList
        .indexWhere((supplier) => supplier.name!.startsWith(letter));
    if (targetIndex != -1) {
      scrollController.animateTo(
        (targetIndex * listHeight) + (index * (listHeight * .45)),
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeIn,
      );
    }
  }
}
