import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/dialog_progress_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/commodity_data.dart';
import 'package:pverify/models/commodity_keywords.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/user_data.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/cache_download_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_screen.dart';
import 'package:pverify/ui/purchase_order_cte/purchase_order_screen_cte.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/update_data_dialog.dart';
import 'package:pverify/utils/utils.dart';

class CommodityIDScreenController extends GetxController {
  late final int partnerID;
  late final String partnerName;
  late final String sealNumber;
  late final String poNumber;
  late final String carrierName;
  late final int carrierID;
  late final String cteType;
  late final String callerActivity;

  final TextEditingController searchController = TextEditingController();

  CommodityIDScreenController();

  final ScrollController scrollController = ScrollController();
  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<Commodity> filteredCommodityList = <Commodity>[].obs;
  RxList<Commodity> commodityList = <Commodity>[].obs;
  RxBool listAssigned = false.obs;

  double get listHeight => 130.h;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }

    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    cteType = args[Consts.CTEType] ?? '';
    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    UserData? currentUser = appStorage.getUserData();
    if (currentUser == null) {
      return;
    }
    int enterpriseId =
        await dao.getEnterpriseIdByUserId(currentUser.userName!.toLowerCase());

    List<Commodity>? commoditiesList = await dao.getCommodityByPartnerFromTable(
        partnerID,
        enterpriseId,
        currentUser.supplierId!,
        currentUser.headquarterSupplierId!);
    appStorage.saveMainCommodityList(commoditiesList ?? []);

    if (commoditiesList == null) {
      commodityList.value = [];
      filteredCommodityList.value = [];
      listAssigned.value = true;
      update(['commodityList']);
    } else {
      commodityList.value = [];
      filteredCommodityList.value = [];

      if (appStorage.mainCommodityList!.isEmpty) {
        print('Error loading Commodity List');
        listAssigned.value = true;
        update(['commodityList']);
        return;
      }

      for (int i = 0; i < appStorage.mainCommodityList!.length; i++) {
        List<CommodityKeywords> keywords =
            await dao.getCommodityKeywordsFromTable(
                appStorage.mainCommodityList![i].id!);

        List<String> list = [];
        for (int j = 0; j < keywords.length; j++) {
          list.add(keywords[j].keywords!);
        }
        String result = list.join(', ');

        appStorage.mainCommodityList![i].keywords = result;
      }
      List<Commodity> _commodityList = appStorage.mainCommodityList ?? [];

      List<Commodity> commodityList1 = [];

      for (Commodity commodity in _commodityList) {
        commodity.keywordName = commodity.name;
        commodityList1.add(commodity);
      }

      for (Commodity commodity1 in _commodityList) {
        List<String> keywordsArray = commodity1.keywords!.split(',');
        for (int i = 0; i < keywordsArray.length; i++) {
          if (keywordsArray[i] != 'null' && keywordsArray[i].isNotEmpty) {
            Commodity newcommodity = Commodity(
              name: commodity1.name,
              id: commodity1.id,
              keywords: commodity1.keywords?.trim(),
            );
            String upperString =
                keywordsArray[i].trim().substring(0, 1).toUpperCase() +
                    keywordsArray[i].trim().substring(1).toLowerCase();
            newcommodity.keywordName = upperString;

            commodityList1.add(newcommodity);
          }
        }
      }

      commodityList1.sort((Commodity car1, Commodity car2) {
        return car1.keywordName!
            .toLowerCase()
            .compareTo(car2.keywordName!.toLowerCase());
      });

      commodityList.clear();
      commodityList.addAll(commodityList1);
      commodityList.sort((a, b) => a.keywordName!.compareTo(b.keywordName!));

      filteredCommodityList.clear();
      filteredCommodityList.addAll(commodityList);
      filteredCommodityList
          .sort((a, b) => a.keywordName!.compareTo(b.keywordName!));
      listAssigned.value = true;
      update(['commodityList']);
    }
    listAssigned.value = true;
    update(['commodityList']);
  }

  void searchAndAssignCommodity(String searchValue) {
    filteredCommodityList.clear();
    if (searchValue.isEmpty) {
      filteredCommodityList.addAll(commodityList);
    } else {
      var items = commodityList.where((element) {
        String? keywords = element.keywords;
        String? name = element.name;
        String searchKey = searchValue.trim().toLowerCase();
        return (keywords != null &&
                keywords.toLowerCase().contains(searchKey)) ||
            (name != null && name.toLowerCase().contains(searchKey));
      }).toList();
      filteredCommodityList.addAll(items);
    }
    update(['commodityList']);
  }

  List<String> getListOfAlphabets() {
    Set<String> uniqueAlphabets = {};

    for (Commodity supplier in filteredCommodityList) {
      if (supplier.keywordName!.isNotEmpty &&
          supplier.keywordName![0]
              .toUpperCase()
              .contains(RegExp(r'[A-Z0-9]'))) {
        uniqueAlphabets.add(supplier.keywordName!.trim()[0].toUpperCase());
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

  void navigateToPurchaseOrderScreen(Commodity commodity) {
    Map<String, dynamic> passingData = {
      Consts.PARTNER_ID: partnerID,
      Consts.PARTNER_NAME: partnerName,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_ID: commodity.id,
      Consts.COMMODITY_NAME: commodity.name,
      Consts.PO_NUMBER: poNumber,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.CTEType: cteType,
      Consts.CALLER_ACTIVITY: callerActivity,
    };
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();

    if (cteType == "Shipping") {
      Get.to(() => PurchaseOrderScreenCTE(tag: tag), arguments: passingData);
    } else {
      Get.to(() => PurchaseOrderScreen(tag: tag), arguments: passingData);
    }
  }

  Future<void> onDownloadTap() async {
    if (globalConfigController.hasStableInternet.value) {
      bool hasValue = await dao.checkInspections();
      if (hasValue) {
        UpdateDataAlert.showUpdateDataDialog(Get.context!,
            onOkPressed: () async {
          await uploadAllInspections();
        }, message: AppStrings.updateDataMessage);
      } else {
        Get.to(() => const CacheDownloadScreen());
      }
    } else {
      UpdateDataAlert.showUpdateDataDialog(Get.context!,
          onOkPressed: () async {}, message: AppStrings.downloadWifiError);
    }
  }

  Future<void> uploadAllInspections() async {
    List<int> uploadCheckedList = await dao.findReadyToUploadInspectionIDs();
    if (uploadCheckedList.isNotEmpty) {
      List<int> failedList = [];

      for (int i = 0; i < uploadCheckedList.length; i++) {
        Inspection? inspection =
            await dao.findInspectionByID(uploadCheckedList[i]);

        if (inspection?.commodityId == 0) {
          uploadCheckedList.removeAt(i);
          failedList.add(uploadCheckedList[i]);
        }
      }

      final progressController = Get.put(ProgressController());

      Utils.showLinearProgressWithMessage(
          message: AppStrings.uploadMessage,
          progressController: progressController);

      int numberOfInspections = uploadCheckedList.length;
      int listIndex = 0;
      int progressDialogStatus = 0;
      while (progressDialogStatus < numberOfInspections) {
        try {
          await uploadInspection(uploadCheckedList[listIndex]);
        } catch (e) {
          AppSnackBar.error(message: AppStrings.uploadError);
          Utils.hideLoadingDialog();
        }

        progressDialogStatus = ++listIndex;

        // Update the progress bar
        progressController.updateProgress(progressDialogStatus);

        if (progressDialogStatus >= numberOfInspections) {
          await Future.delayed(const Duration(seconds: 1));
          Utils.hideLoadingDialog();
        }
      }
    } else {
      List<int> incompleteInspectionList =
          await dao.getAllIncompleteInspectionIDs();

      for (int i = 0; i < incompleteInspectionList.length; i++) {
        await dao.deleteInspection(incompleteInspectionList.elementAt(i));
      }

      Get.to(() => const CacheDownloadScreen());
    }
  }

  Future<void> uploadInspection(int inspectionId) async {
    Inspection? inspection = await dao.findInspectionByID(inspectionId);
    if (inspection != null) {
      QCHeaderDetails? qcHeaderDetails =
          await dao.findTempQCHeaderDetails(inspection.poNumber!);
      if (qcHeaderDetails != null &&
          qcHeaderDetails.cteType != null &&
          qcHeaderDetails.cteType != "") {
        // TODO: Implement the below code for (WSUploadInspectionCTE, WSUploadMobileFilesCTE)
        /*// Start the webservice to upload the inspection
        Map<String, dynamic>? jsonObject =
            await WSUploadInspectionCTE.RequestUploadCTE(
                inspectionId, qcHeaderDetails.cteType);

        if (jsonObject != null) {
          WSUploadMobileFilesCTE.RequestUploadMobileFiles(
              null, jsonObject, inspectionId);
        }*/
      } else {
        // Start the webservice to upload the inspection

        // TODO: Implement the below code for (WSUploadInspection, WSUploadMobileFiles)
        /*Map<String, dynamic>? jsonObject =
            await requestUploadInspection(inspectionId);

        if (jsonObject != null) {
          List<InspectionDefectAttachment>? attachments =
              await dao.findDefectAttachmentsByInspectionId(inspectionId);

          requestUploadMobileFiles(attachments, jsonObject, inspectionId);
        }*/
      }
    }
  }

  void clearSearch() {
    searchController.clear();
    searchAndAssignCommodity('');
    unFocus();
  }
}
