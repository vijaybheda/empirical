// ignore_for_file: prefer_final_fields, unused_field, non_constant_identifier_names, unnecessary_this, unrelated_type_equality_checks

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/utils.dart';

class HomeController extends GetxController {
  PageController pageController = PageController();

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  List<String> bannerImages = [AppImages.img_banner, AppImages.img_banner];
  List<Map<String, String>> listOfInspection = [
    {
      "ID": "1",
      "PO": "ee",
      "Item": "6443101",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organicfsdfsfdsfsd",
      "Status": "Done"
    },
    {
      "ID": "2",
      "PO": "ee",
      "Item": "6443102",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organicfsdfsfdsfsd",
      "Status": "Done"
    },
    {
      "ID": "3",
      "PO": "ee",
      "Item": "6443108",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
    {
      "ID": "4",
      "PO": "ee",
      "Item": "6443104",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
    {
      "ID": "5",
      "PO": "ee",
      "Item": "6443103",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
  ].obs;
  var bannersCurrentPage = 0.obs;
  List selectedIDsInspection = [].obs;
  List expandContents = [].obs;
  var sortType = ''.obs;

  selectInspectionForDownload(String id, bool isSelectAll) {
    if (isSelectAll) {
      if (selectedIDsInspection.length != listOfInspection.length) {
        selectedIDsInspection.clear();
        List list1 = listOfInspection.map((array) => array['ID']).toList();
        selectedIDsInspection.addAll(list1);
      } else {
        selectedIDsInspection.clear();
      }
    } else {
      if (selectedIDsInspection.contains(id)) {
        selectedIDsInspection.remove(id);
      } else {
        selectedIDsInspection.add(id);
      }
    }
  }

  sortArray_Item() {
    if (sortType == 'asc') {
      sortType.value = 'dsc';
      listOfInspection
          .sort((b, a) => a['Item'].toString().compareTo(b['Item'].toString()));
    } else {
      sortType.value = 'asc';
      listOfInspection
          .sort((a, b) => a['Item'].toString().compareTo(b['Item'].toString()));
    }
    update(['inspectionsList']);
  }

  @override
  void onInit() {
    // Get.put(() => InspectionController(), permanent: true);
    super.onInit();
    int days = Utils().checkCacheDays();
    if (days >= 7) {
      if (globalConfigController.hasStableInternet.value) {
        Future.delayed(const Duration(seconds: 1)).then((value) =>
            UpdateDataAlert.showUpdateDataDialog(Get.context!, onOkPressed: () {
              debugPrint('Ok button tap.');
              Get.off(() => const CacheDownloadScreen());
            }, message: AppStrings().getDayMessage(days)));
      } else {
        Future.delayed(const Duration(seconds: 1)).then((value) =>
            UpdateDataAlert.showUpdateDataDialog(Get.context!, onOkPressed: () {
              debugPrint('Ok button tap.');
              Get.off(() => const CacheDownloadScreen());
            }, message: AppStrings().getDayMessage1(days)));
      }
    }
  }
}
