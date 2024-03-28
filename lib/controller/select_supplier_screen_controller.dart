import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/utils/app_storage.dart';

class SelectSupplierScreenController extends GetxController {
  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;

  RxList<PartnerItem> filteredPartnerList = <PartnerItem>[].obs;
  RxList<PartnerItem> partnersList = <PartnerItem>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 180.h;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  void assignInitialData() {
    List<PartnerItem>? _partnersList = appStorage.getPartnerList();
    if (_partnersList == null) {
      partnersList.value = [];
      filteredPartnerList.value = [];
      listAssigned.value = true;
      update(['partnerList']);
    } else {
      partnersList.value = [];
      filteredPartnerList.value = [];

      partnersList.addAll(_partnersList);
      partnersList.sort((a, b) => a.name!.compareTo(b.name!));

      filteredPartnerList.addAll(_partnersList);
      filteredPartnerList.sort((a, b) => a.name!.compareTo(b.name!));
      listAssigned.value = true;
      update(['partnerList']);
    }
  }

  void searchAndAssignPartner(String searchValue) {
    filteredPartnerList.clear();
    if (searchValue.isEmpty) {
      filteredPartnerList.addAll(partnersList);
    } else {
      filteredPartnerList.value = partnersList
          .where((element) =>
              element.name!.toLowerCase().contains(searchValue.toLowerCase()))
          .toList();
    }
    update(['partnerList']);
  }

  List<String> getListOfAlphabets() {
    Set<String> uniqueAlphabets = {};

    for (PartnerItem supplier in filteredPartnerList) {
      if (supplier.name!.isNotEmpty &&
          supplier.name![0].toUpperCase().contains(RegExp(r'[A-Z0-9]'))) {
        uniqueAlphabets.add(supplier.name![0].toUpperCase());
      }
    }

    return uniqueAlphabets.toList();
  }

  void scrollToSection(String letter, int index) {
    int targetIndex = filteredPartnerList
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
