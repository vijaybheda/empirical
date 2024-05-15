import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/defect_categories.dart';
import 'package:pverify/models/defect_instruction_attachment.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/defects_data.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/inspection_sample.dart';
import 'package:pverify/models/sample_data.dart';
import 'package:pverify/models/severity.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/Home/home.dart';
import 'package:pverify/ui/defects/table_dialog.dart';
import 'package:pverify/ui/inspection_photos/inspection_photos_screen.dart';
import 'package:pverify/ui/purchase_order/new_purchase_order_details_screen.dart';
import 'package:pverify/ui/purchase_order/purchase_order_details_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/dialogs/custom_listview_dialog.dart';
import 'package:pverify/utils/utils.dart';

class DefectsScreenController extends GetxController {
  final AppStorage appStorage = AppStorage.instance;
  final ApplicationDao dao = ApplicationDao();
  final JsonFileOperations jsonFileOperations = JsonFileOperations.instance;
  final TextEditingController sizeOfNewSetTextController =
      TextEditingController();
  bool isFirstTime = true;

  bool isDefectEntry = true;

  RxInt activeTabIndex = 1.obs;
  RxList<SampleSetsObject> sampleSetObs = <SampleSetsObject>[].obs;
  SampleSetsObject tempSampleObj = SampleSetsObject();

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

  int tableTabSelected = 0;
  int entryTabSelected = 1;
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
  List<SampleData> sampleList = [];
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
  RxBool isVisibleInfoPopup = false.obs;
  RxInt visisblePopupIndex = 0.obs;
  RxBool isVisibleSpecificationPopup = false.obs;

  Map<int, String> defectCategoriesHashMap = {};

  String get packDateString =>
      packDate != null ? Utils().dateFormat.format(packDate!) : '';

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      throw Exception('Arguments required!');
    }

    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    lotSize = args[Consts.LOT_SIZE] ?? '';
    itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    poLineNo = args[Consts.PO_LINE_NO] ?? 0;
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';

    serverInspectionID = args[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = args[Consts.PARTNER_NAME] ?? '';
    partnerID = args[Consts.PARTNER_ID] ?? 0;
    carrierName = args[Consts.CARRIER_NAME] ?? '';
    carrierID = args[Consts.CARRIER_ID] ?? 0;
    commodityName = args[Consts.COMMODITY_NAME] ?? '';
    commodityID = args[Consts.COMMODITY_ID] ?? 0;
    sampleSizeByCount = args[Consts.SAMPLE_SIZE_BY_COUNT] ?? 0;
    varietyName = args[Consts.VARIETY_NAME] ?? '';
    varietySize = args[Consts.VARIETY_SIZE] ?? '';
    varietyId = args[Consts.VARIETY_ID] ?? 0;
    completed = args[Consts.COMPLETED] ?? false;
    inspectionResult = args[Consts.INSPECTION_RESULT] ?? '';
    selectedSpecification = args[Consts.SPECIFICATION_NAME] ?? '';
    specificationName = args[Consts.SPECIFICATION_NAME] ?? '';
    poNumber = args[Consts.PO_NUMBER] ?? '';
    sealNumber = args[Consts.SEAL_NUMBER] ?? '';
    gradeId = args[Consts.GRADE_ID] ?? 0;
    itemSku = args[Consts.ITEM_SKU] ?? '';
    itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
    itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
    specificationNumber = args[Consts.SPECIFICATION_NUMBER] ?? '';
    specificationVersion = args[Consts.SPECIFICATION_VERSION] ?? '';
    specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME] ?? '';
    isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
    lotNo = args[Consts.LOT_NO] ?? '';
    gtin = args[Consts.GTIN] ?? '';
    String packDateString = args[Consts.PACK_DATE] ?? '';
    if (packDateString.isNotEmpty) {
      packDate = Utils().dateFormat.parse(packDateString);
    }
    itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
    lotSize = args[Consts.LOT_SIZE] ?? '';
    poLineNo = args[Consts.PO_LINE_NO] ?? 0;
    productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';
    callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';

    if (serverInspectionID > -1) {
      inspectionId = serverInspectionID;
    }

    populateDefectSpinnerList();
    appStorage.getCommodityList();
    super.onInit();

    if (appStorage.severityList != null) {
      for (var severity in appStorage.severityList!) {
        if (severity.name == "Injury" || severity.name == "Lesión") {
          hasSeverityInjury = true;
        } else if (severity.name == "Damage" || severity.name == "Daño") {
          hasSeverityDamage = true;
        } else if (severity.name == "Serious Damage" ||
            severity.name == "Daño Serio") {
          hasSeveritySeriousDamage = true;
        } else if (severity.name == "Very Serious Damage" ||
            severity.name == "Daño Muy Serio") {
          hasSeverityVerySeriousDamage = true;
        } else if (severity.name == "Decay" || severity.name == "Pudrición") {
          hasSeverityDecay = true;
        }
      }
    }

    setInit();
  }

  Future<void> setInit() async {
    await jsonFileOperations.offlineLoadSeverities(commodityID.toString());
    jsonFileOperations.offlineLoadDefectCategories();
    appStorage.specificationGradeToleranceList =
        await dao.getSpecificationGradeTolerance(
            specificationNumber!, specificationVersion!);
    getDefectCategories();

    loadSamplesAndDefectsFromDB();
  }

  void loadSamplesAndDefectsFromDB() async {
    bool hasDefects = false;

    // Load samples from DB
    List<InspectionSample> samples =
        await dao.findInspectionSamples(inspectionId!);
    if (samples.isNotEmpty) {
      numberSamples = samples.length;
      for (int i = 0; i < samples.length; i++) {
        SampleData temp = SampleData(
          sampleId: samples[i].sampleId,
          setNumber: samples[i].setNumber!,
          sampleSize: samples[i].setSize!,
          name: samples[i].setName!,
          timeCreated: samples[i].createdTime,
          complete: samples[i].isComplete ?? false,
          sampleNameUser: samples[i].sampleName,
        );

        sampleList.add(temp);

        List<InspectionDefect> defectList =
            await dao.findInspectionDefects(temp.sampleId!);
        if (defectList.isNotEmpty) {
          hasDefects = true;
          defectDataMap[temp.name] = defectList;
        }
        // loadDataIfNotEmpty(i, temp);
      }
    }
    if (hasDefects) {
      getDefectCategories();
      // setTabSelected(tableTabSelected);
    }
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

  void addSample(String setsValue) {
    int id = sampleSetObs.isNotEmpty
        ? (int.tryParse(sampleSetObs.reversed.last.sampleId ?? "1") ?? 1) + 1
        : 1;
    tempSampleObj = SampleSetsObject();
    tempSampleObj.sampleValue = setsValue;
    tempSampleObj.sampleId = id.toString();
    sampleSetObs.insert(0, tempSampleObj);
    sizeOfNewSetTextController.text = "";

    populateSeverityList();

    if (appStorage.severityList != null) {
      for (Severity severity in appStorage.severityList!) {
        if (severity.name == "Injury" || severity.name == "Lesión") {
          hasSeverityInjury = true;
        } else if (severity.name == "Damage" || severity.name == "Daño") {
          hasSeverityDamage = true;
        } else if (severity.name == "Serious Damage" ||
            severity.name == "Daño Serio") {
          hasSeveritySeriousDamage = true;
        } else if (severity.name == "Very Serious Damage" ||
            severity.name == "Daño Muy Serio") {
          hasSeverityVerySeriousDamage = true;
        } else if (severity.name == "Decay" || severity.name == "Pudrición") {
          hasSeverityDecay = true;
        }
      }
    }

    sampleSetObs.refresh();
  }

  void addDefectRow({required int setIndex}) {
    DefectItem emptyDefectItem = DefectItem(
      injuryTextEditingController: TextEditingController(text: '0'),
      damageTextEditingController: TextEditingController(text: '0'),
      sDamageTextEditingController: TextEditingController(text: '0'),
      vsDamageTextEditingController: TextEditingController(text: '0'),
      decayTextEditingController: TextEditingController(text: '0'),
      name: 'Select',
      attachments: [],
    );

    if (sampleSetObs[setIndex].defectItem == null) {
      sampleSetObs[setIndex].defectItem = [emptyDefectItem];
    } else {
      sampleSetObs[setIndex].defectItem?.add(emptyDefectItem);
    }
    sampleSetObs.refresh();
  }

  void removeDefectRow({required int setIndex, required int rowIndex}) {
    sampleSetObs[setIndex].defectItem?.removeAt(rowIndex);
    sampleSetObs.refresh();
  }

  int getDefectItemIndex({
    required int setIndex,
    required DefectItem defectItem,
  }) {
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
        // not in current requirement
        /* sampleSetObs[setIndex]
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
            ?.text = isError ? '0' : value; */

        // do nothing
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
    if (serverInspectionID > -1) {
      commodityId = commodityID ?? 0;
    } else if (appStorage.currentInspection != null) {
      commodityId = appStorage.currentInspection?.commodityId ?? 0;
    } else {
      commodityId = commodityID ?? 0;
    }

    CommodityItem? item;
    defectSpinnerIds.clear();
    defectSpinnerNames.clear();
    defectSpinnerNames.add('Select');

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

  void populateSeverityList() {
    int commodityId;

    if (serverInspectionID > -1) {
      commodityId = commodityID ?? 0;
    } else if (appStorage.currentInspection != null) {
      commodityId = appStorage.currentInspection!.commodityId ?? 0;
    } else {
      commodityId = commodityID ?? 0;
    }

    CommodityItem? item;

    if (appStorage.getCommodityList() != null &&
        appStorage.getCommodityList()!.isNotEmpty) {
      item = appStorage.getCommodityList()?.firstWhere(
            (commodity) => commodity.id == commodityId,
          );
    } else {
      // Populate with default list if commodity list is empty
      // populateWithDefaultList();
    }

    if (item != null &&
        item.severityDefectList != null &&
        item.severityDefectList.isNotEmpty) {
      List<Severity> list = [];

      for (var severityDefect in item.severityDefectList) {
        Severity listItem = Severity(
          severityDefect.id ?? 0,
          severityDefect.name ?? '',
          '',
          '',
          0,
        );
        list.add(listItem);
      }

      appStorage.severityList = list;
      log("Here Is Severity List $list");
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
    CustomListViewDialog customDialog = CustomListViewDialog(
      // Get.context!,
      (selectedValue) {},
    );
    customDialog.setCanceledOnTouchOutside(false);
    customDialog.show();
  }

  Future onSpecificationTap() async {
    appStorage.specificationGradeToleranceTable =
        await dao.getSpecificationGradeToleranceTable(
            specificationNumber!, specificationVersion!);
    showDialog(
        context: Get.context!,
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

  // FIXME: Implement this method
  Future saveAsDraftAndGotoMyInspectionScreen() async {}

  Future deleteInspectionAndGotoMyInspectionScreen(BuildContext context) async {
    if (serverInspectionID > -1) {
      await dao.deleteInspection(serverInspectionID);

      Map<String, dynamic> passingData = {};
      passingData[Consts.SERVER_INSPECTION_ID] = -1;
      passingData[Consts.PARTNER_NAME] = partnerName;
      passingData[Consts.PARTNER_ID] = partnerID;
      passingData[Consts.CARRIER_NAME] = carrierName;
      passingData[Consts.CARRIER_ID] = carrierID;
      passingData[Consts.PO_NUMBER] = poNumber;
      passingData[Consts.COMMODITY_NAME] = commodityName;
      passingData[Consts.COMMODITY_ID] = commodityID;
      passingData[Consts.VARIETY_NAME] = varietyName;
      passingData[Consts.VARIETY_ID] = varietyId;
      passingData[Consts.GRADE_ID] = gradeId;
      passingData[Consts.SPECIFICATION_NUMBER] = specificationNumber;
      passingData[Consts.SPECIFICATION_VERSION] = specificationVersion;
      passingData[Consts.SPECIFICATION_NAME] = selectedSpecification;
      passingData[Consts.SPECIFICATION_TYPE_NAME] = specificationTypeName;
      passingData[Consts.ITEM_SKU] = itemSku;
      passingData[Consts.ITEM_SKU_ID] = itemSkuId;
      passingData[Consts.ITEM_SKU_NAME] = itemSkuName;
      passingData[Consts.LOT_NO] = lotNo;
      passingData[Consts.GTIN] = gtin;
      passingData[Consts.PACK_DATE] = packDateString;
      passingData[Consts.LOT_SIZE] = lotSize;
      passingData[Consts.ITEM_UNIQUE_ID] = itemUniqueId;
      passingData[Consts.IS_MY_INSPECTION_SCREEN] = isMyInspectionScreen;
      passingData[Consts.PRODUCT_TRANSFER] = productTransfer;

      final String tag = DateTime.now().millisecondsSinceEpoch.toString();

      if (callerActivity == "TrendingReportActivity") {
        passingData[Consts.CALLER_ACTIVITY] = "TrendingReportActivity";
        Get.offAll(() => Home(tag: tag), arguments: passingData);
      } else if (callerActivity == "NewPurchaseOrderDetailsActivity") {
        passingData[Consts.CALLER_ACTIVITY] = "NewPurchaseOrderDetailsActivity";
        Get.off(() => const NewPurchaseOrderDetailsScreen(),
            arguments: passingData);
      } else {
        passingData[Consts.CALLER_ACTIVITY] = "PurchaseOrderDetailsActivity";
        Get.off(() => PurchaseOrderDetailsScreen(tag: tag),
            arguments: passingData);
      }
    }

    Future infoActionTap(int position) async {
      List<DefectInstructionAttachment> attachments = [];
      String instruction = '';
      CommodityItem? item;
      int? defectId = defectDataMap[position]?[0].defectId;

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
    for (SampleSetsObject element in sampleSetObs) {
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
    for (SampleSetsObject element in sampleSetObs) {
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

  void getDefectCategories() {
    Map<int, String> defectCategoriesHashMap = {};

    for (var i = 0; i < defectCategoriesList.length; i++) {
      if (defectCategoriesList[i].name == "Condition") {
        List<DefectItem>? defectItemList = defectCategoriesList[i].defectList;

        if (defectItemList != null) {
          for (var defectItem in defectItemList) {
            if (defectItem.name?.contains("Total Condition") ?? false) {
              totalConditionDefectId = defectItem.id;
            } else {
              defectCategoriesHashMap[defectItem.id!] = "Condition";
            }
          }
        }
      } else if (defectCategoriesList[i].name == "Quality") {
        List<DefectItem>? defectItemList = defectCategoriesList[i].defectList;

        if (defectItemList != null) {
          for (var defectItem in defectItemList) {
            if (defectItem.name?.contains("Total Quality") ?? false) {
              totalQualityDefectId = defectItem.id;
            } else {
              defectCategoriesHashMap[defectItem.id!] = "Quality";
            }
          }
        }
      } else if (defectCategoriesList[i].name == "Size") {
        List<DefectItem>? defectItemList = defectCategoriesList[i].defectList;

        if (defectItemList != null) {
          for (var defectItem in defectItemList) {
            defectCategoriesHashMap[defectItem.id!] = "Size";
          }
        }
      } else if (defectCategoriesList[i].name == "Color") {
        List<DefectItem>? defectItemList = defectCategoriesList[i].defectList;

        if (defectItemList != null) {
          for (var defectItem in defectItemList) {
            defectCategoriesHashMap[defectItem.id!] = "Color";
          }
        }
      }
    }
  }

  List<DefectCategories> get defectCategoriesList =>
      appStorage.defectCategoriesList ?? [];

  Future<void> saveSamplesToDB() async {
    hasDamage = false;
    hasSeriousDamage = false;

    // Save all the samples
    for (SampleSetsObject sample in sampleSetObs) {
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
    for (var entry in defectDataMap.entries) {
      var sampleSize = getSampleSize(entry.key);
      var sampleId = getSampleID(entry.key);

      for (InspectionDefect defect in entry.value) {
        int? inspectionDefectId = defect.inspectionDefectId;
        int? defectId = defect.defectId;
        int? injuryCnt = defect.injuryCnt;
        int? damageCnt = defect.damageCnt;
        int? seriousDamageCnt = defect.seriousDamageCnt;
        int? veryseriousDamageCnt = defect.verySeriousDamageCnt;
        int? decayCnt = defect.decayCnt;
        String? defectName = defect.spinnerSelection;
        String? defectComment = defect.comment;
        int? timestamp = defect.createdTime;
        List<int>? attachmentIds = defect.attachmentIds;
        int? severityInjuryId = defect.severityInjuryId;
        int? severityDamageId = defect.severityDamageId;
        int? severitySeriousDamageId = defect.severitySeriousDamageId;
        int? severityVerySeriousDamageId = defect.severityVerySeriousDamageId;
        int? severityDecayId = defect.severityDecayId;

        String defectCategory = defectCategoriesHashMap != null
            ? defectCategoriesHashMap[defectId] ?? ''
            : '';

        if (defectId != 0) {
          if (inspectionDefectId == null) {
            // The inspection Defect has not been saved yet, save it.
            try {
              inspectionDefectId = await dao.createInspectionDefect(
                inspectionId: inspectionId ?? 0,
                sampleId: sampleId!,
                defectId: int.parse(defectId.toString()),
                defectName: defectName!,
                injuryCnt: injuryCnt!,
                damageCnt: damageCnt!,
                seriousDamageCnt: seriousDamageCnt!,
                comments: defectComment,
                timestamp: timestamp!,
                verySeriousDamageCnt: veryseriousDamageCnt!,
                decayCnt: decayCnt!,
                severityInjuryId: severityInjuryId!,
                severityDamageId: severityDamageId!,
                severitySeriousDamageId: severityVerySeriousDamageId!,
                severityVerySeriousDamageId: severityVerySeriousDamageId,
                severityDecayId: severityDecayId!,
                defectCategory: defectCategory,
              );
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
                  defectName: defectName!,
                  injuryCnt: injuryCnt!,
                  damageCnt: damageCnt!,
                  seriousDamageCnt: seriousDamageCnt!,
                  comments: defectComment!,
                  verySeriousDamageCnt: veryseriousDamageCnt!,
                  decayCnt: decayCnt!,
                  severityInjuryId: severityInjuryId!,
                  severityDamageId: severityDamageId!,
                  severitySeriousDamageId: severitySeriousDamageId!,
                  severityVerySeriousDamageId: severityVerySeriousDamageId!,
                  severityDecayId: severityDecayId!,
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
        if (damageCnt != null && damageCnt > 2) {
          hasDamage = true;
        }
        if (seriousDamageCnt != null && seriousDamageCnt > 0) {
          hasSeriousDamage = true;
        }
      }
    }
    dataEntered = false;
    dataSaved = true;
  }

  int? getSampleSize(String name) {
    for (var i = 0; i < sampleList.length; i++) {
      if (name == sampleList[i].name) {
        return sampleList[i].sampleSize;
      }
    }
    return null;
  }

  int? getSampleID(String name) {
    for (var i = 0; i < sampleList.length; i++) {
      if (name == sampleList[i].name) {
        return sampleList[i].sampleId;
      }
    }
    return null;
  }

  void populateDefectData(List<InspectionDefect> defectList, String dataName,
      int sampleListPosition) {
    for (int i = 0; i < defectList.length; i++) {
      loadDefectData(i, defectList, dataName, sampleListPosition);
    }
  }

  void hideKeypad() {
    unFocus();
  }

  void loadDefectData(int i, List<InspectionDefect> defectList, String dataName,
      int sampleListPosition) {
    populateDefectSpinnerList();
  }
}
