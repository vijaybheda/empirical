// ignore_for_file: curly_braces_in_flow_control_structures, non_constant_identifier_names, prefer_const_constructors, unnecessary_null_comparison, unrelated_type_equality_checks, unused_local_variable, unused_element, collection_methods_unrelated_type

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/defect_instruction_attachment.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/defects_data.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/sample_data.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/defects/special_instructions.dart';
import 'package:pverify/ui/defects/table_dialog.dart';
import 'package:pverify/ui/inspection_photos/inspection_photos_screen.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/utils.dart';

class DefectsScreenController extends GetxController {
  final AppStorage appStorage = AppStorage.instance;
  final sizeOfNewSetTextController = TextEditingController().obs;
  var isFirstTime = true;
  var isDefectEntry = true;

  RxInt activeTabIndex = 1.obs;

  var sampleSetObs = <SampleSetObject>[].obs;
  SampleSetObject tempSampleObj = SampleSetObject();
  final ApplicationDao dao = ApplicationDao();

  int serverInspectionID = -1;
  String partnerName = "";
  int? partnerID;
  String carrierName = "";
  int? carrierID;
  String commodityName = "";
  int? commodityID;
  int sampleSizeByCount = 0;
  String varietyName = "";
  String varietySize = "";
  int? varietyId;
  bool completed = false;
  String selectedSpecification = "";
  String inspectionResult = "";

  String? specificationNumber;
  String? specificationVersion;
  String? specificationTypeName;

  String? currentAttachPhotosDataName;
  int? currentAttachPhotosPosition;

  bool isViewOnlyMode = false;
  bool hasDamage = false;
  bool hasSeriousDamage = false;
  bool dataEntered = false;
  bool dataSaved = false;
  bool hasSeverityInjury = false;
  bool hasSeverityDamage = false;
  bool hasSeveritySeriousDamage = false;
  bool hasSeverityVerySeriousDamage = false;
  bool hasSeverityDecay = false;

  int? inspectionId;

  final int tableTabSelected = 0;
  final int entryTabSelected = 1;
  int tabSelected = 0;
  int numberSamples = 0;
  int totalSamples = 0;
  int totalInjury = 0;
  int totalDamage = 0;
  int totalSeriousDamage = 0;
  int totalVerySeriousDamage = 0;
  int totalDecay = 0;

  int totalConditionInjury = 0;
  int totalConditionDamage = 0;
  int totalConditionSeriousDamage = 0;
  int totalConditionVerySeriousDamage = 0;
  int totalConditionDecay = 0;

  int totalQualityInjury = 0;
  int totalQualityDamage = 0;
  int totalQualitySeriousDamage = 0;
  int totalQualityVerySeriousDamage = 0;
  int totalQualityDecay = 0;

  int totalSizeInjury = 0;
  int totalSizeDamage = 0;
  int totalSizeSeriousDamage = 0;
  int totalSizeVerySeriousDamage = 0;
  int totalSizeDecay = 0;

  int totalColorInjury = 0;
  int totalColorDamage = 0;
  int totalColorSeriousDamage = 0;
  int totalColorVerySeriousDamage = 0;
  int totalColorDecay = 0;

  int numberSeriousDefects = 1;
  double? injurySpec;
  double? damageSpec;
  double? seriousDamageSpec;
  double? verySeriousDamageSpec;
  double? decaySpec;

  double? injuryQualitySpec;
  double? damageQualitySpec;
  double? seriousDamageQualitySpec;
  double? verySeriousDamageQualitySpec;
  double? decayQualitySpec;

  double? injuryConditionSpec;
  double? damageConditionSpec;
  double? seriousDamageConditionSpec;
  double? verySeriousDamageConditionSpec;
  double? decayConditionSpec;

  int? gradeId;
  bool isMyInspectionScreen = false;

  Map<String, List<InspectionDefect>> defectDataMap =
      <String, List<InspectionDefect>>{};
  Map<int, SampleData> sampleDataMap = <int, SampleData>{};
  List<int> sampleDataMapIndexList = [];
  List<String> seriousDefectList = [];
  Map<String, int> seriousDefectCountMap = <String, int>{};
  Map<int, String>? defectCategoriesMap;

  String poNumber = '', sealNumber = '';

  String? lotNo, itemSku, itemUniqueId, lotSize;
  DateTime? packDate;
  int? itemSkuId;
  String? gtin;
  String? itemSkuName;

  double? totalQualityPercent;
  double? totalConditionPercent;

  double? totalSeverityPercent;
  int? totalQualityDefectId;
  int? totalConditionDefectId;
  String callerActivity = '';
  int poLineNo = 0;
  String productTransfer = '';
  String specificationName = '';

  List<String> defectSpinnerNames = <String>[].obs;
  List<int> defectSpinnerIds = <int>[].obs;
  RxBool informationIconEnabled = false.obs;
  var isVisibleInfoPopup = false.obs;
  var visisblePopupIndex = 0.obs;
  var isVisibleSpecificationPopup = false.obs;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      throw Exception('Arguments not allowed');
    }
    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? 0;
    completed = args[Consts.COMPLETED] ?? false;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? '';
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    varietyName = args[Consts.VARIETY_NAME] ?? '';
    varietySize = args[Consts.VARIETY_SIZE] ?? '';
    varietyId = args[Consts.VARIETY_ID] ?? 0;
    specificationNumber = args[Consts.SPECIFICATION_NUMBER] ?? '';
    specificationVersion = args[Consts.SPECIFICATION_VERSION] ?? '';
    sampleSizeByCount = args[Consts.SAMPLE_SIZE_BY_COUNT] ?? 0;
    specificationName = args[Consts.SPECIFICATION_NAME] ?? '';
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME] ?? '';
    isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
    itemSku = args[Consts.ITEM_SKU] ?? '';
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    lotNo = args[Consts.Lot_No] ?? '';
    gtin = args[Consts.GTIN] ?? '';
    packDate = args[Consts.PACK_DATE];
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    lotSize = args[Consts.LOT_SIZE] ?? '';
    itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    poLineNo = args[Consts.PO_LINE_NO] ?? 0;
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';

    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME];
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? '';
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    sampleSizeByCount = args[Consts.SAMPLE_SIZE_BY_COUNT] ?? 0;
    varietyName = args[Consts.VARIETY_NAME] ?? '';
    varietySize = args[Consts.VARIETY_SIZE] ?? '';
    varietyId = args[Consts.VARIETY_ID];
    completed = args[Consts.COMPLETED] ?? false;
    inspectionResult = args[Consts.INSPECTION_RESULT] ?? '';
    selectedSpecification = args[Consts.SPECIFICATION_NAME] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    //gradeId = args[Consts.GRADE_ID] ?? '';
    itemSku = args[Consts.ITEM_SKU] ?? '';
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
    specificationNumber = args[Consts.SPECIFICATION_NUMBER] ?? '';
    specificationVersion = args[Consts.SPECIFICATION_VERSION] ?? '';
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME] ?? '';
    isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
    lotNo = args[Consts.Lot_No] ?? '';
    gtin = args[Consts.GTIN] ?? '';
    packDate = args[Consts.PACK_DATE] ?? '';
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    lotSize = args[Consts.LOT_SIZE] ?? '';
    poLineNo = args[Consts.PO_LINE_NO] ?? 0;
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
    // appStorage.getCommodityList();
    populateDefectSpinnerList();
    super.onInit();
  }

  // LOGIN SCREEN VALIDATION'S

  bool isValid(BuildContext context) {
    if (sizeOfNewSetTextController.value.text.trim().isEmpty) {
      AppAlertDialog.validateAlerts(
          context, AppStrings.error, AppStrings.errorEnterSize);
      return false;
    }
    return true;
  }

  addSampleSets(String setsValue) {
    int id = sampleSetObs.isNotEmpty
        ? (int.tryParse(sampleSetObs.reversed.last.sampleId ?? "1") ?? 1) + 1
        : 1;
    tempSampleObj = SampleSetObject();

    String? index = sampleSetObs.isNotEmpty
        ? ((int.tryParse(sampleSetObs.reversed.last.sampleId ?? "1") ?? 1) + 1)
            .toString()
        : "1";
    final String name = "Set #$index";

    tempSampleObj.sampleSize = int.tryParse(setsValue);
    tempSampleObj.sampleId = id.toString();
    tempSampleObj.name = name;
    tempSampleObj.setNumber = sampleSetObs.length + 1;
    tempSampleObj.timeCreated =
        DateTime.now().millisecondsSinceEpoch.toDouble();
    tempSampleObj.lotNumber = 0;
    tempSampleObj.packDate = "";
    tempSampleObj.complete = false;

    sampleSetObs.insert(0, tempSampleObj);
    sizeOfNewSetTextController.value.text = "";
  }

  void addDefectRow({required int setIndex}) {
    DefectItem emptyDefectItem = DefectItem(
      injuryTextEditingController: TextEditingController(text: '0'),
      damageTextEditingController: TextEditingController(text: '0'),
      sDamageTextEditingController: TextEditingController(text: '0'),
      vsDamageTextEditingController: TextEditingController(text: '0'),
      decayTextEditingController: TextEditingController(text: '0'),
    );

    sampleSetObs[setIndex].defectItem == null
        ? sampleSetObs[setIndex].defectItem = [emptyDefectItem]
        : sampleSetObs[setIndex].defectItem?.add(emptyDefectItem);
    sampleSetObs.refresh();
  }

  void removeDefectRow({required int setIndex, required int rowIndex}) {
    sampleSetObs[setIndex].defectItem?.removeAt(rowIndex);
    sampleSetObs.refresh();
  }

  int getDefectItemIndex(
      {required int setIndex, required DefectItem defectItem}) {
    return sampleSetObs[setIndex].defectItem?.indexOf(defectItem) ?? -1;
  }

  void onTextChange({
    required String value,
    required int setIndex,
    required int rowIndex,
    required String fieldName,
    required BuildContext context,
  }) {
    bool isError = false;
    int sampleSize =
        int.tryParse(sampleSetObs[setIndex].sampleValue ?? "0") ?? 0;
    String dropDownValue =
        sampleSetObs[setIndex].defectItem?[rowIndex].name ?? "";
    if ((int.tryParse(value) ?? 0) > sampleSize) {
      isError = true;
      AppAlertDialog.validateAlerts(
        context,
        AppStrings.alert,
        '${AppStrings.defect} - $dropDownValue${AppStrings.cannotBeGreaterThenTheSampleSize} $sampleSize, ${AppStrings.pleaseEnterValidDefectCount}',
      );
    }

    switch (fieldName) {
      case AppStrings.injury:
        // do nothing
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .injuryTextEditingController
              ?.text = '0';
        }
        sampleSetObs.refresh();
      case AppStrings.damage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = isError ? '0' : value;
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .damageTextEditingController
              ?.text = isError ? '0' : value;
        }
        sampleSetObs.refresh();
      case AppStrings.seriousDamage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = isError ? '0' : value;
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .sDamageTextEditingController
              ?.text = isError ? '0' : value;
        }
        sampleSetObs.refresh();
      case AppStrings.verySeriousDamage:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .sDamageTextEditingController
            ?.text = isError ? '0' : value;
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .vsDamageTextEditingController
              ?.text = isError ? '0' : value;
        }

      case AppStrings.decay:
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .injuryTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .damageTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .sDamageTextEditingController
            ?.text = isError ? '0' : value;
        sampleSetObs[setIndex]
            .defectItem?[rowIndex]
            .vsDamageTextEditingController
            ?.text = isError ? '0' : value;
        if (isError) {
          sampleSetObs[setIndex]
              .defectItem?[rowIndex]
              .decayTextEditingController
              ?.text = isError ? '0' : value;
        }
      default:
      // do nothing
    }
  }

  void onDropDownChange({
    required int id,
    required String value,
    required int setIndex,
    required int rowIndex,
  }) {
    sampleSetObs[setIndex].defectItem?[rowIndex].name = value;
    sampleSetObs[setIndex].defectItem?[rowIndex].id = id;
    sampleSetObs.refresh();
  }

  void onCommentAdd({
    required String value,
    required int setIndex,
    required int rowIndex,
  }) {
    sampleSetObs[setIndex].defectItem?[rowIndex].instruction = value;
    sampleSetObs.refresh();
  }

  void getDropDownValues() {
    List<CommodityItem>? commodityItemsList = AppStorage.instance.commodityList;
    debugPrint("commodity $commodityItemsList");
  }

  removeSampleSets(int index) {
    sampleSetObs.removeAt(index);
  }

  void openPDFFile(BuildContext context, String type) async {
    String filename;
    if (type == "Inspection Instructions") {
      filename =
          "II_${AppStorage.instance.commodityVarietyData?.commodityId.toString()}.pdf";
    } else {
      filename =
          "GRADE_${AppStorage.instance.commodityVarietyData?.commodityId.toString()}.pdf";
    }

    var storagePath = await Utils().getExternalStoragePath();
    String path = "$storagePath/${FileManString.COMMODITYDOCS}/$filename";

    File file = File(path);

    if (await file.exists()) {
      try {
        final Uri data2 = Uri.file(path);
        await _grantPermissions(data2);
        await openFile(path);
      } catch (e) {
        AppSnackBar.getCustomSnackBar("Error", "Error opening PDF file: $e",
            isSuccess: false);
      }
    } else {
      if (type == "Inspection Instructions") {
        AppSnackBar.getCustomSnackBar("Error", "No Inspection Instructions",
            isSuccess: false);
      } else {
        AppSnackBar.getCustomSnackBar("Error", "No Grade", isSuccess: false);
      }
    }
  }

  Future<void> _grantPermissions(Uri uri) async {
    final permissions = <Permission>[Permission.storage];
    for (final permission in permissions) {
      if (await permission.status.isGranted) continue;
      await permission.request();
    }
  }

  Future<bool> openFile(String filePath) async {
    File file = File(filePath);
    if (await file.exists()) {
      OpenResult resultType = await OpenFile.open(filePath);
      return resultType.type == ResultType.done;
    } else {
      return false;
    }
  }

  void populateDefectSpinnerList() {
    int commodityId;
    if (serverInspectionID > -1)
      commodityId = commodityID ?? 0;
    else if (appStorage.currentInspection != null) {
      commodityId = appStorage.currentInspection?.commodityId ?? 0;
    } else {
      commodityId = commodityID ?? 0;
    }

    CommodityItem? item;
    defectSpinnerIds.clear();
    defectSpinnerNames.clear();

    // Get the list of defects for the commodity
    if (appStorage.getCommodityList() != null &&
        appStorage.getCommodityList()!.isNotEmpty) {
      item = appStorage.getCommodityList()?.firstWhere(
            (commodity) => commodity.id == commodityId,
          );
    } else {
      // Populate with default list if commodity list is empty
      // populateWithDefaultList();
    }

    // If we found our item, populate the lists
    if (item != null &&
        item.defectList != null &&
        item.defectList!.isNotEmpty) {
      item.defectList?.sort((a, b) => a.name!.compareTo(b.name ?? ''));

      for (DefectItem defect in item.defectList ?? []) {
        if (!defect.name!.contains("Total Quality") &&
            !defect.name!.contains("Total Condition")) {
          defectSpinnerIds.add(defect.id ?? 0);
          defectSpinnerNames.add(defect.name ?? '');
        }
      }
      // defectSpinnerIds.insert(0, 0);
      // defectSpinnerNames.insert(0, 'Select');
    }
  }

  void defectsSelect_Action(DefectItem? defectItem) {
    CommodityItem? item;
    String instruction = "";

    if (appStorage.getCommodityList() != null &&
        appStorage.getCommodityList()!.isNotEmpty) {
      for (int i = 0; i < appStorage.getCommodityList()!.length; i++) {
        if (appStorage.getCommodityList()?[i].id == commodityID) {
          item = appStorage.getCommodityList()![i];
          break;
        }
      }
    }

    if (item?.defectList != null && item!.defectList!.isNotEmpty) {
      for (int i = 0; i < item.defectList!.length; i++) {
        if (item.defectList?[i].id == defectItem?.id) {
          instruction = item.defectList?[i].instruction ?? '';
          break;
        }
      }
    }
    if (instruction != null && instruction.isNotEmpty) {
      informationIconEnabled.value = true;
    } else {
      informationIconEnabled.value = false;
    }
  }

  void showPopup() {
    isVisibleInfoPopup.value = true;
  }

  void hidePopup() {
    isVisibleInfoPopup.value = false;
  }

  Future onSpecialInstrMenuTap() async {
    List<Map<String, String>> exceptionCollection = [];
    Map<String, String> map;
    if (AppStorage.instance.commodityVarietyData?.exceptions != null) {
      for (var item in AppStorage.instance.commodityVarietyData!.exceptions) {
        map = {
          'KEY_TITLE': item.shortDescription.toString(),
          'KEY_DETAIL': item.longDescription.toString(),
        };
        exceptionCollection.add(map);
      }
    }
    Get.to(
        () => SpecialInstructions(
              exceptionCollection: exceptionCollection,
            ),
        transition: Transition.downToUp);
  }

  Future onSpecificationTap(BuildContext context) async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return tableDialog(context);
        });
  }

  Future onCameraMenuTap() async {
    Map<String, dynamic> passingData = {
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VIEW_ONLY_MODE: false,
      Consts.INSPECTION_ID: inspectionId,
      Consts.PO_NUMBER: poNumber,
    };
    await Get.to(() => const InspectionPhotos(), arguments: passingData);
  }

  Future saveAsDraftAndGotoMyInspectionScreen() async {}

  Future deleteInspectionAndGotoMyInspectionScreen(BuildContext context) async {
    if (serverInspectionID > -1) {
      dao.deleteInspection(serverInspectionID);

      Map<String, dynamic> bundle = {
        Consts.SERVER_INSPECTION_ID: -1,
        Consts.PARTNER_NAME: partnerName,
        Consts.PARTNER_ID: partnerID,
        Consts.CARRIER_NAME: carrierName,
        Consts.CARRIER_ID: carrierID,
        Consts.COMMODITY_NAME: commodityName,
        Consts.COMMODITY_ID: commodityID,
        Consts.SPECIFICATION_NUMBER: specificationNumber,
        Consts.SPECIFICATION_VERSION: specificationVersion,
        Consts.SPECIFICATION_NAME: selectedSpecification,
        Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
        Consts.ITEM_SKU: itemSku,
        Consts.ITEM_SKU_NAME: itemSkuName,
        Consts.ITEM_SKU_ID: itemSkuId,
        Consts.ITEM_UNIQUE_ID: itemUniqueId,
        Consts.Lot_No: lotNo,
        Consts.GTIN: gtin,
        Consts.PACK_DATE: packDate,
        Consts.LOT_SIZE: lotSize,
        Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
        Consts.PO_NUMBER: poNumber,
        Consts.PRODUCT_TRANSFER: productTransfer,
        Consts.DATETYPE: '',
      };

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) {
            //if (isMyInspectionScreen) {
            return Home();
            //}
            // else {
            //   if (callerActivity == "NewPurchaseOrderDetailsActivity") {
            //     return NewPurchaseOrderDetailsActivity(
            //         callerActivity: "NewPurchaseOrderDetailsActivity");
            //   } else {
            //     return PurchaseOrderDetailsActivity();
            //   }
            // }
          },
          settings: RouteSettings(arguments: bundle),
        ),
      );
    }

    Future infoActionTap(int position) async {
      List<DefectInstructionAttachment> attachments = [];
      String instruction = '';
      CommodityItem? item;
      String? defectId = defectDataMap[position]?[0].defectId;

// Get the commodity item
      item = appStorage
          .getCommodityList()
          ?.firstWhereOrNull((commodity) => commodity.id == commodityID);
      if (item != null &&
          item.defectList != null &&
          item.defectList!.isNotEmpty) {
        var defect = item.defectList!
            .firstWhereOrNull((defect) => defect.id == defectId);
        if (defect != null) {
          instruction = defect.instruction ?? '';
          attachments = defect.attachments ?? [];
        }
      }
    }
  }

  bool isValidDefects() {
    bool isValidValue = true;
    for (SampleSetObject element in sampleSetObs) {
      bool isAnyErrorInDefect = false;
      for (DefectItem defectItem in element.defectItem ?? []) {
        bool isError = false;
        if ((defectItem.injuryTextEditingController?.text.trim().isNotEmpty ??
                false) &&
            defectItem.injuryTextEditingController?.text.trim() == "0") {
          isError = true;
        }
        if ((defectItem.damageTextEditingController?.text.trim().isNotEmpty ??
                false) &&
            defectItem.damageTextEditingController?.text.trim() == "0") {
          isError = true;
        }
        if ((defectItem.sDamageTextEditingController?.text.trim().isNotEmpty ??
                false) &&
            defectItem.sDamageTextEditingController?.text.trim() == "0") {
          isError = true;
        }
        if ((defectItem.vsDamageTextEditingController?.text.trim().isNotEmpty ??
                false) &&
            defectItem.vsDamageTextEditingController?.text.trim() == "0") {
          isError = true;
        }
        if ((defectItem.decayTextEditingController?.text.trim().isNotEmpty ??
                false) &&
            defectItem.decayTextEditingController?.text.trim() == "0") {
          isError = true;
        }
        if (isError) {
          isAnyErrorInDefect = true;
          isValidValue = false;
          break;
        }
      }
      if (isAnyErrorInDefect) {
        break;
      }
    }
    return isValidValue;
  }

  bool validateSameDefects() {
    for (SampleSetObject element in sampleSetObs) {
      List<String> defectNames = [];
      for (DefectItem defectItem in element.defectItem ?? []) {
        if (defectNames.contains(defectItem.name)) {
          return false;
        }
        defectNames.add(defectItem.name ?? '');
      }
    }
    return true;
  }

  Future<void> saveSamplesToDB() async {
    hasDamage = false;
    hasSeriousDamage = false;

    // Save all the samples
    for (SampleSetObject sample in sampleSetObs) {
      var sampleId = sample.sampleId;
      var sampleSize = ''; //sample.sampleSize;
      var sampleName = sample.name;
      var setNumber = sample.setNumber;
      var timeCreated = sample.timeCreated;
      var sampleNameUser = sample.name;

      // If the sample has not been saved yet, save it
      if (sampleId == null) {
        try {
          sampleId = (await dao.createInspectionSample(
            inspectionId ?? 0,
            int.parse(sampleSize),
            sampleName ?? '',
            setNumber ?? 0,
            timeCreated?.toInt() ?? 0,
            0,
            sampleNameUser!,
          )) as String?;
          sample.sampleId = sampleId;
        } catch (e) {
          debugPrint(e.toString());
        }
      } else {
        try {
          await dao.updateInspectionSample(
              int.parse(sampleId), sampleNameUser ?? '');
        } catch (e) {
          debugPrint(e.toString());
        }
      }
    }

    // Save all the defects

    for (SampleSetObject element in sampleSetObs) {
      var sampleSize = getSampleSize(element.sampleValue);
      var sampleId = getSampleID(element.sampleValue);

      for (DefectItem defect in element.defectItem ?? []) {
        var inspectionDefectId = defect.inspectionId;
        var defectId = defect.defectId;
        var injuryCnt = defect.injuryCnt;
        var damageCnt = defect.damageCnt;
        var seriousDamageCnt = defect.seriousDamageCnt;
        var veryseriousDamageCnt = defect.verySeriousDamageCnt;
        var decayCnt = defect.decayCnt;
        var defectName = defect.spinnerSelection;
        var defectComment = defect.comment;
        var timestamp = defect.createdTime;
        var attachmentIds = defect.attachmentIds;
        var severityInjuryId = defect.severityInjuryId;
        var severityDamageId = defect.severityDamageId;
        var severitySeriousDamageId = defect.severitySeriousDamageId;
        var severityVerySeriousDamageId = defect.severityVerySeriousDamageId;
        var severityDecayId = defect.severityDecayId;

        String defectCategory = "";

        if (defectCategoriesMap != null &&
            defectCategoriesMap!.containsKey(defectId)) {
          String? category = defectCategoriesMap![defectId];

          if (category == "Condition") {
            defectCategory = "condition";
          } else if (category == "Quality") {
            defectCategory = "quality";
          } else if (category == "Size") {
            defectCategory = "size";
          } else if (category == "Color") {
            defectCategory = "color";
          }
        }

        if (defectId != 0) {
          if (inspectionDefectId == null) {
            // The inspection Defect has not been saved yet, save it.
            try {
              inspectionDefectId = (await dao.createInspectionDefect(
                  inspectionId: inspectionId ?? 0,
                  sampleId: sampleId ?? 0,
                  defectId: int.parse(defectId.toString()),
                  defectName: defectName ?? '',
                  injuryCnt: injuryCnt ?? 0,
                  damageCnt:
                      int.parse(defect.damageTextEditingController?.text ?? ''),
                  seriousDamageCnt: int.parse(
                      defect.sDamageTextEditingController?.text ?? ''),
                  comments: defectComment,
                  timestamp: timestamp ?? 0,
                  verySeriousDamageCnt: int.parse(
                      defect.vsDamageTextEditingController?.text ?? ''),
                  decayCnt:
                      int.parse(defect.decayTextEditingController?.text ?? ''),
                  severityInjuryId: severityInjuryId ?? 0,
                  severityDamageId: severityDamageId ?? 0,
                  severitySeriousDamageId: severityVerySeriousDamageId ?? 0,
                  severityVerySeriousDamageId: severityVerySeriousDamageId ?? 0,
                  severityDecayId: severityDecayId ?? 0,
                  defectCategory: defectCategory)) as int?;
              defect.inspectionDefectId = inspectionDefectId;
              defect.sampleId = sampleId;
            } catch (e) {
              debugPrint(e.toString());
            }
          } else {
            // The inspection defect is already saved, update it.
            try {
              await dao.updateInspectionDefect(
                  inspectionDefectId: inspectionId ?? 0,
                  defectId: int.parse(defectId.toString()),
                  defectName: defectName ?? '',
                  injuryCnt: injuryCnt ?? 0,
                  damageCnt:
                      int.parse(defect.damageTextEditingController?.text ?? ''),
                  seriousDamageCnt: int.parse(
                      defect.sDamageTextEditingController?.text ?? ''),
                  comments: defectComment ?? '',
                  verySeriousDamageCnt: int.parse(
                      defect.vsDamageTextEditingController?.text ?? ''),
                  decayCnt:
                      int.parse(defect.decayTextEditingController?.text ?? ''),
                  severityInjuryId: severityInjuryId ?? 0,
                  severityDamageId: severityDamageId ?? 0,
                  severitySeriousDamageId: severitySeriousDamageId ?? 0,
                  severityVerySeriousDamageId: severityVerySeriousDamageId ?? 0,
                  severityDecayId: severityDecayId ?? 0,
                  defectCategory: defectCategory);
              defect.inspectionDefectId = inspectionDefectId;
            } catch (e) {
              debugPrint(e.toString());
            }
          }
        }

        // Update any defect attachments to associate the sampleId and defectId with the attachment.
        if (attachmentIds != null && attachmentIds.isNotEmpty) {
          for (var attachmentId in attachmentIds) {
            await dao.updateDefectAttachment(
              attachmentId,
              sampleId,
              inspectionDefectId,
            );
          }
        }
        if ((damageCnt ?? 0) > 2) {
          hasDamage = true;
        }
        if ((seriousDamageCnt ?? 0) > 0) {
          hasSeriousDamage = true;
        }
      }
    }
    dataEntered = false;
    dataSaved = true;
  }

  int? getSampleSize(String? name) {
    for (var sample in sampleSetObs) {
      if (name == sample.name) {
        return sample.sampleSize;
      }
    }
    return null;
  }

  int? getSampleID(String? name) {
    for (var sample in sampleSetObs) {
      if (name == sample.name) {
        return int.tryParse(sample.sampleId ?? '');
      }
    }
    return null;
  }
}
