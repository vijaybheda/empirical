// ignore_for_file: prefer_final_fields, unused_field, non_constant_identifier_names, unnecessary_this, unrelated_type_equality_checks

import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/images.dart';

class HomeController extends GetxController {
  PageController pageController = PageController();

  List<String> bannerImages = [
    AppImages.img_banner,
    AppImages.img_banner
  ];
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
    update();
  }
}
