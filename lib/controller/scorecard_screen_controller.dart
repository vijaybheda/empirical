import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/last_inspections_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/services/network_request_service/ws_last_inspections.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/enumeration.dart';

class ScorecardScreenController extends GetxController {
  ScorecardScreenController(this.partner);

  late final bool isPartnerActivity;
  late final String scorecardName;
  late final int scorecardID;
  late final double redPercentage;
  late final double greenPercentage;
  late final double yellowPercentage;
  late final double orangePercentage;

  List<LastInspectionsItem>? itemsList = <LastInspectionsItem>[].obs;

  final PartnerItem partner;

  final AppStorage _appStorage = AppStorage.instance;

  RxBool isLoading = false.obs;
  RxBool isShowDateIcon = true.obs;
  RxBool isShowCommodityIcon = true.obs;
  RxBool isResultIcon = true.obs;
  RxBool isReasonIcon = true.obs;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }

    isPartnerActivity = args[Consts.IS_PARTNER_ACTIVITY] ?? false;
    scorecardName = args[Consts.SCORECARD_NAME] ?? '';
    scorecardID = args[Consts.SCORECARD_ID] ?? 0;
    redPercentage = args[Consts.REDPERCENTAGE] ?? 0.0;
    greenPercentage = args[Consts.GREENPERCENTAGE] ?? 0.0;
    yellowPercentage = args[Consts.YELLOWPERCENTAGE] ?? 0.0;
    orangePercentage = args[Consts.ORANGEPERCENTAGE] ?? 0.0;

    itemsList = <LastInspectionsItem>[].obs;
    _appStorage.lastInspectionsList = null;

    fetchLastInspections(scorecardID);
    super.onInit();
  }

  Future<void> fetchLastInspections(int id) async {
    isLoading.value = true;
    WSLastInspections lastInspectionsWebservice =
        WSLastInspections(Get.context!);
    try {
      await lastInspectionsWebservice.requestLastInspections(id);
      itemsList = _appStorage.lastInspectionsList;
      update(["scoreboardItemList"]);
    } catch (e) {
      debugPrint("🔴 fetchLastInspections $e ");
    } finally {
      isLoading.value = false;
    }
  }

  var sortType = ''.obs;

  DateSort dateSort = DateSort.asc;
  CommoditySort commoditySort = CommoditySort.none;
  ResultSort resultSort = ResultSort.none;
  ReasonSort reasonSort = ReasonSort.none;

  void sortByDate() {
    if (dateSort == DateSort.asc) {
      isShowDateIcon.value = true;
      dateSort = DateSort.desc;
      itemsList!.sort((a, b) => b.createdDate!.compareTo(a.createdDate!));
    } else {
      dateSort = DateSort.asc;
      isShowDateIcon.value = false;
      itemsList!.sort((a, b) => a.createdDate!.compareTo(b.createdDate!));
    }
    update(["scoreboardItemList"]);
  }

  void sortByCommodity() {
    if (commoditySort == CommoditySort.asc) {
      isShowCommodityIcon.value = true;
      commoditySort = CommoditySort.desc;
      itemsList!.sort((a, b) => b.commodityName!.compareTo(a.commodityName!));
    } else {
      isShowCommodityIcon.value = false;
      commoditySort = CommoditySort.asc;
      itemsList!.sort((a, b) => a.commodityName!.compareTo(b.commodityName!));
    }
    update(["scoreboardItemList"]);
  }

  void sortByResult() {
    if (resultSort == ResultSort.asc) {
      isResultIcon.value = true;
      resultSort = ResultSort.desc;
      itemsList!
          .sort((a, b) => b.inspectionResult!.compareTo(a.inspectionResult!));
    } else {
      isResultIcon.value = false;
      resultSort = ResultSort.asc;
      itemsList!
          .sort((a, b) => a.inspectionResult!.compareTo(b.inspectionResult!));
    }
    update(["scoreboardItemList"]);
  }

  void sortByReason() {
    if (reasonSort == ReasonSort.asc) {
      isReasonIcon.value = true;
      reasonSort = ReasonSort.desc;
      itemsList!
          .sort((a, b) => b.inspectionReason!.compareTo(a.inspectionReason!));
    } else {
      isReasonIcon.value = false;
      reasonSort = ReasonSort.asc;
      itemsList!
          .sort((a, b) => a.inspectionReason!.compareTo(b.inspectionReason!));
    }
    update(["scoreboardItemList"]);
  }
}
