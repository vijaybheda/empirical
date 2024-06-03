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
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
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
  bool isViewOnlyMode = false;

  RxInt activeTabIndex = 1.obs;
  RxList<SampleData> sampleList = <SampleData>[].obs;

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

  // List<SampleData> sampleList = [];
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

  // RxBool isVisibleInfoPopup = false.obs;
  // RxInt visisblePopupIndex = 0.obs;
  RxBool isVisibleSpecificationPopup = false.obs;

  Map<int, String> defectCategoriesHashMap = {};

  bool defectTableAddSampleVisible = false;

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
      packDate = DateTime.fromMillisecondsSinceEpoch(int.parse(packDateString));
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
    await jsonFileOperations.offlineLoadDefectCategories();
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
          defectDataMap.putIfAbsent(temp.name, () => defectList);
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

  void addSample() {
    int setsValue = int.tryParse(sizeOfNewSetTextController.text) ?? 0;
    int id = sampleList.isNotEmpty
        ? (sampleList.reversed.last.sampleId ?? 1) + 1
        : 1;
    // SampleData tempSampleObj = SampleData();
    // tempSampleObj.sampleValue = setsValue;
    // tempSampleObj.sampleId = id.toString();
    // sampleSetObs.insert(0, tempSampleObj);

    final int index;
    final int pos = (sampleList.length - 1);
    if (sampleList.isNotEmpty) {
      index = sampleList.elementAt(pos).setNumber + 1;
    } else {
      index = sampleList.length + 1;
    }

    final String name = "Set #$index";
    final int timeStamp = DateTime.now().millisecondsSinceEpoch;
    SampleData sampleData = SampleData(
        sampleSize: setsValue,
        name: name,
        setNumber: index,
        timeCreated: timeStamp,
        sampleId: id,
        // lotNumber: 0,
        // packDate: "",
        complete: false);
    sampleList.add(sampleData);
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

    sampleList.refresh();
    update();
  }

  void addDefectRow({required int sampleIndex}) {
    SampleData sampleData = sampleList.elementAt(sampleIndex);
    String dataName = sampleData.name;
    List<InspectionDefect> defectList;

    if (defectDataMap.containsKey(dataName)) {
      defectList = defectDataMap[dataName]!;

      // FIXME: remove static data
      InspectionDefect inspectionDefect = InspectionDefect(
        createdTime: DateTime.now().millisecondsSinceEpoch,
        comment: "",
        attachmentIds:
            sampleData.defectItems.elementAt(sampleIndex).attachmentIds,
        defectCategory: '',
        damageCnt: 0,
        decayCnt: sampleData.dCnt,
        defectId: 0,
        injuryCnt: sampleData.iCnt,
        inspectionDefectId: 0,
        sampleId: sampleData.defectItems.length,
        seriousDamageCnt: sampleData.sdCnt,
        severityDamageId: 0,
        severityDecayId: 0,
        severityInjuryId: 0,
        severitySeriousDamageId: 0,
        severityVerySeriousDamageId: 0,
        verySeriousDamageCnt: sampleData.vsdCnt,
        // spinnerSelection: 'Color',
      );
      defectList.add(inspectionDefect);
      sampleList[sampleIndex] =
          sampleList[sampleIndex].copyWith(defectItems: defectList);
      defectDataMap.putIfAbsent(dataName, () => defectList);
    } else {
      // legendLayout.visible = true;
      if (!hasSeverityInjury) {
        // injuryLayout.visible = false;
      } else {
        // injuryLayout.visible = true;
      }

      if (!hasSeverityDamage) {
        // damageLayout.visible = false;
      } else {
        // damageLayout.visible = true;
      }

      if (!hasSeveritySeriousDamage) {
        // seriousDamageLayout.visible = false;
      } else {
        // seriousDamageLayout.visible = true;
      }

      if (!hasSeverityVerySeriousDamage) {
        // verySeriousDamageLayoutVisible = false;
      } else {
        // verySeriousDamageLayoutVisible = true;
      }

      if (!hasSeverityDecay) {
        // decayLayoutVisible = false;
      } else {
        // decayLayoutVisible = true;
      }

      // sampleLine1Visible = true;
      // sampleLine2Visible = true;
      // defectsListview.visible = true;
      defectList = [];

      // FIXME: remove static data
      InspectionDefect inspectionDefect = InspectionDefect(
        createdTime: DateTime.now().millisecondsSinceEpoch,
        comment: "",
        attachmentIds: [],
        defectCategory: '',
        damageCnt: 0,
        decayCnt: 0,
        defectId: 0,
        injuryCnt: 0,
        inspectionDefectId: 0,
        sampleId: sampleData.defectItems.length,
        seriousDamageCnt: 0,
        severityDamageId: 0,
        severityDecayId: 0,
        severityInjuryId: 0,
        severitySeriousDamageId: 0,
        severityVerySeriousDamageId: 0,
        verySeriousDamageCnt: 0,
        // spinnerSelection: 'Color',
      );

      defectList.add(inspectionDefect);
      sampleList[sampleIndex] =
          sampleList[sampleIndex].copyWith(defectItems: defectList);
      defectDataMap.putIfAbsent(dataName, () => defectList);
    }
    final int pos = (sampleList.length - 1);
    loadDefectData((defectList.length - 1), defectList, dataName, pos);

    sampleDataMap[sampleIndex]?.defectItems = defectList;

    hideKeypad();
    update();
  }

  Future<void> removeDefectRow({
    required InspectionDefect inspectionDefect,
    required String dataName,
    required int sampleIndex,
    required int defectIndex,
  }) async {
    ///
    List<InspectionDefect> defectList = [];
    if (defectDataMap.containsKey(dataName)) {
      defectList = defectDataMap[dataName]!;

      int? defectId = inspectionDefect.inspectionDefectId;
      List<int>? attachmentIds = inspectionDefect.attachmentIds;

      defectList.remove(inspectionDefect);
      if (defectList.isEmpty) {
        defectDataMap.remove(dataName);
      }

      if (defectId != null) {
        await dao.deleteInspectionDefectByDefectId(defectId);
        await dao.deleteDefectAttachmentsByDefectId(defectId);

        if (attachmentIds != null && attachmentIds.isNotEmpty) {
          for (int j = 0; j < attachmentIds.length; j++) {
            await dao.deleteDefectAttachmentByAttachmentId(attachmentIds[j]);
          }
        }
      }
    }

    // defectsView.parent.remove(defectsView);

    if (defectList.isNotEmpty) {
      // legendLayout.visible = true;
      if (!hasSeverityInjury) {
        // injuryLayout.visible = false;
      } else {
        // injuryLayoutVisible = true;
      }

      // sampleLine1Visible = true;
      // sampleLine2Visible = true;
      // defectsListviewVisible = true;
    } else {
      // legendLayoutVisible = false;
      // sampleLine1Visible = false;
      // sampleLine2Visible = false;
      // defectsListviewVisible = false;
    }

    sampleList[sampleIndex].defectItems.removeAt(defectIndex);
    sampleList.refresh();

    update();
  }

  // FIXME:
  /*int getDefectItemIndex({
    required int setIndex,
    required DefectItem defectItem,
  }) {
    return sampleList[setIndex].defectItem?.indexOf(defectItem) ?? -1;
  }*/

  void onTextChange({
    required String textData,
    required int sampleIndex,
    required int defectIndex,
    required String fieldName,
    required BuildContext context,
  }) {
    bool isError = false;
    int value = int.tryParse(textData) ?? 0;
    int sampleSize = sampleList[sampleIndex].sampleSize;
    String dropDownValue = sampleList[sampleIndex]
            .defectItems
            .elementAtOrNull(defectIndex)
            ?.spinnerSelection ??
        defectSpinnerNames.first;

    if (value > sampleSize) {
      isError = true;
      AppAlertDialog.validateAlerts(
        context,
        AppStrings.alert,
        '$fieldName - $dropDownValue ${AppStrings.cannotBeGreaterThenTheSampleSize} $sampleSize, ${AppStrings.pleaseEnterValidDefectCount}',
      );
    }

    switch (fieldName) {
      case AppStrings.injury:
        // do nothing
        if (isError) {
          sampleList[sampleIndex].defectItems[defectIndex].injuryCnt =
              isError ? 0 : value;
          sampleList[sampleIndex]
              .defectItems[defectIndex]
              .injuryTextEditingController
              .text = (isError ? 0 : value).toString();
        }

      case AppStrings.damage:
        sampleList[sampleIndex].defectItems[defectIndex].injuryCnt =
            isError ? 0 : value;
        sampleList[sampleIndex]
            .defectItems[defectIndex]
            .injuryTextEditingController
            .text = value.toString();
        if (isError) {
          sampleList[sampleIndex].defectItems[defectIndex].damageCnt =
              isError ? 0 : value;
          sampleList[sampleIndex]
              .defectItems[defectIndex]
              .damageTextEditingController
              .text = value.toString();
        }

      case AppStrings.seriousDamage:
        sampleList[sampleIndex].defectItems[defectIndex].injuryCnt =
            isError ? 0 : value;

        sampleList[sampleIndex]
            .defectItems[defectIndex]
            .injuryTextEditingController
            .text = value.toString();

        sampleList[sampleIndex]
            .defectItems[defectIndex]
            .damageTextEditingController
            .text = value.toString();

        sampleList[sampleIndex].defectItems[defectIndex].damageCnt =
            isError ? 0 : value;
        if (isError) {
          sampleList[sampleIndex].defectItems[defectIndex].seriousDamageCnt =
              isError ? 0 : value;

          sampleList[sampleIndex]
              .defectItems[defectIndex]
              .sDamageTextEditingController
              .text = value.toString();
        }

      case AppStrings.verySeriousDamage:
        sampleList[sampleIndex].defectItems[defectIndex].injuryCnt =
            isError ? 0 : value;
        sampleList[sampleIndex].defectItems[defectIndex].damageCnt =
            isError ? 0 : value;
        sampleList[sampleIndex].defectItems[defectIndex].seriousDamageCnt =
            isError ? 0 : value;

        sampleList[sampleIndex]
            .defectItems[defectIndex]
            .injuryTextEditingController
            .text = value.toString();
        sampleList[sampleIndex]
            .defectItems[defectIndex]
            .damageTextEditingController
            .text = value.toString();
        sampleList[sampleIndex]
            .defectItems[defectIndex]
            .sDamageTextEditingController
            .text = value.toString();
        if (isError) {
          sampleList[sampleIndex]
              .defectItems[defectIndex]
              .verySeriousDamageCnt = isError ? 0 : value;

          sampleList[sampleIndex]
              .defectItems[defectIndex]
              .vsDamageTextEditingController
              .text = value.toString();
        }

      case AppStrings.decay:
        // not in current requirement
        /*sampleDataMap[sampleIndex]!.defectItems[defectIndex].injuryCnt =
            isError ? 0 : value;
        sampleDataMap[sampleIndex]!.defectItems[defectIndex].damageCnt =
            isError ? 0 : value;
        sampleDataMap[sampleIndex]!.defectItems[defectIndex].seriousDamageCnt =
            isError ? 0 : value;

        sampleDataMap[sampleIndex]!
            .defectItems[defectIndex]
            .injuryTextEditingController
            ?.text = value;
        sampleDataMap[sampleIndex]!
            .defectItems[defectIndex]
            .damageTextEditingController
            ?.text = value;
        sampleDataMap[sampleIndex]!
            .defectItems[defectIndex]
            .sDamageTextEditingController
            ?.text = value;

        sampleDataMap[sampleIndex]!
            .defectItems[defectIndex]
            .verySeriousDamageCnt = isError ? 0 : value;

        sampleDataMap[sampleIndex]!
            .defectItems[defectIndex]
            .vsDamageTextEditingController
            ?.text = value;

        // do nothing
        if (isError) {
          sampleList[sampleIndex].defectItems[defectIndex].decayCnt =
              isError ? 0 : value;

          sampleList[sampleIndex]
              .defectItems[defectIndex]
              .decayTextEditingController
              ?.text = value;
        }*/

        try {
          if (value <= sampleSize) {
            sampleList[sampleIndex].defectItems[defectIndex].decayCnt = value;
          }
        } catch (e) {
          // Handle exception
        }

      default:
      // do nothing
    }

    sampleList.refresh();
    update();
  }

  void onDropDownChange({
    required String value,
    required int sampleIndex,
    required int defectItemIndex,
  }) {
    String selected = value;

    sampleList[sampleIndex].defectItems[defectItemIndex].spinnerSelection =
        selected;

    sampleList[sampleIndex].defectItems[defectItemIndex].defectId =
        getDefectSpinnerId(selected);

    CommodityItem? item;
    String instruction = "";

    if (appStorage.commodityList != null &&
        appStorage.commodityList!.isNotEmpty) {
      for (int i = 0; i < appStorage.commodityList!.length; i++) {
        if (appStorage.commodityList![i].id == commodityID) {
          item = appStorage.commodityList![i];
          break;
        }
      }
    }

    if (item != null &&
        item.defectList != null &&
        item.defectList!.isNotEmpty) {
      for (int i = 0; i < item.defectList!.length; i++) {
        if (item.defectList![i].id ==
            sampleList[sampleIndex].defectItems[defectItemIndex].defectId) {
          instruction = item.defectList![i].inspectionInstruction ?? '';
          break;
        }
      }
    }

    // TODO: uncomment this
    /*if (instruction != null && instruction.isNotEmpty) {
      informationIcon.backgroundImage =
          const AssetImage(AppImages.ic_information);
      informationIcon.enabled = true;
    } else {
      informationIcon.backgroundImage =
          const AssetImage(AppImages.ic_informationDisabled);
      informationIcon.enabled = false;
    }*/
    update();
  }

  void onCommentAdd({
    required String value,
    required int sampleIndex,
    required int defectItemIndex,
  }) {
    if (!isViewOnlyMode) {
      sampleList[sampleIndex].defectItems[defectItemIndex].comment = value;
      sampleList.refresh();
      update();
    }

    /*showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isViewOnlyMode ? 'View Defect Comment' : 'Add Comment'),
          content: TextField(
            controller: commentController,
            decoration:
                const InputDecoration(hintText: "Enter your comment here"),
            enabled: !isViewOnlyMode,
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {

              },
            ),
            if (!isViewOnlyMode)
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Get.back();
                },
              ),
          ],
        );
      },
    );*/
  }

  String getCommentsForSample(String key) {
    String allComments = "";
    try {
      List<InspectionDefect>? inspection = defectDataMap[key];
      if (inspection != null && inspection.isNotEmpty) {
        for (int i = 0; i < inspection.length; i++) {
          String? comment = inspection[i].comment;
          if (comment != null && comment.isNotEmpty) {
            if (i > 0 && allComments.isNotEmpty) {
              allComments = "$allComments\n\n";
            }
            allComments = allComments + comment;
          }
        }
      }
    } catch (e) {
      print(e);
    }

    return allComments;
  }

  void getDropDownValues() {
    List<CommodityItem>? commodityItemsList = AppStorage.instance.commodityList;
    debugPrint("commodity $commodityItemsList");
  }

  Future<void> removeSampleSets(int index) async {
    SampleData sampleData = sampleList.elementAt(index);
    String dataName = sampleData.name;
    int? sampleId = sampleData.sampleId;

    if (sampleId != null) {
      await dao.deleteInspectionSamplesBySampleId(sampleId);
      await dao.deleteInspectionDefectBySampleId(sampleId);
      await dao.deleteDefectAttachmentsBySampleId(sampleId);
    }

    sampleList.remove(sampleData);

    if (defectDataMap.containsKey(dataName)) {
      defectDataMap.remove(dataName);
    }

    sampleList.refresh();
    update();
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
    // defectSpinnerNames.add('Select');

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

  bool isInformationIconEnabled(
      {required int sampleIndex, required int defectItemIndex}) {
    CommodityItem? item;
    String? instruction;

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
        if (item.defectList?[i].id ==
            sampleList[sampleIndex].defectItems[defectItemIndex].defectId) {
          instruction = item.defectList?[i].inspectionInstruction ?? '';
          break;
        }
      }
    }
    if (instruction != null && instruction.isNotEmpty) {
      informationIconEnabled.value = true;
      return true;
    } else {
      informationIconEnabled.value = false;
      return false;
    }
  }

  void showPopup() {
    // isVisibleInfoPopup.value = true;
  }

  void hidePopup() {
    // isVisibleInfoPopup.value = false;
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
          instruction = defect.inspectionInstruction ?? '';
          attachments = defect.attachments ?? [];
        }
      }
    }
  }

  void checkForUnsavedData() {
    for (var i = 0; i < sampleList.length; i++) {
      int? sampleId = sampleList[i].sampleId;

      if (sampleId == null) {
        dataEntered = true;
      }
    }

    for (var entry in defectDataMap.entries) {
      for (var i = 0; i < entry.value.length; i++) {
        int? inspectionDefectId = entry.value[i].inspectionDefectId;
        if (inspectionDefectId == null) {
          dataEntered = true;
        }
      }
    }
  }

  bool validateDefects() {
    for (var entry in defectDataMap.entries) {
      for (var i = 0; i < entry.value.length; i++) {
        int? injuryCnt = entry.value[i].injuryCnt;
        int? damageCnt = entry.value[i].damageCnt;
        int? seriousDamageCnt = entry.value[i].seriousDamageCnt;
        int? verySeriousDamageCnt = entry.value[i].verySeriousDamageCnt;
        int? decayCnt = entry.value[i].decayCnt;

        if (injuryCnt == null ||
            damageCnt == null ||
            seriousDamageCnt == null ||
            verySeriousDamageCnt == null ||
            decayCnt == null) {
          return false;
        }

        if (injuryCnt == 0 &&
            damageCnt == 0 &&
            seriousDamageCnt == 0 &&
            verySeriousDamageCnt == 0 &&
            decayCnt == 0) {
          return false;
        }
      }
    }
    return true;
  }

  /*bool validateSameDefects() {
    for (SampleData element in sampleList) {
      List<String> defectNames = [];
      for (DefectItem defectItem in element.defectItem ?? []) {
        if (defectNames.contains(defectItem.name)) {
          return false;
        }
        defectNames.add(defectItem.name ?? '');
      }
    }
    return true;
  }*/

  bool validateSameDefects() {
    for (var entry in defectDataMap.entries) {
      List<String> defectNames = [];

      for (var i = 0; i < entry.value.length; i++) {
        if (defectNames.contains(entry.value[i].spinnerSelection)) {
          return false;
        }
        if (entry.value[i].spinnerSelection != null) {
          defectNames.add(entry.value[i].spinnerSelection!);
        }
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

  Future<void> saveDefectEntriesAndContinue() async {
    if (sampleList.isEmpty) {
      AppAlertDialog.validateAlerts(
        Get.context!,
        AppStrings.alert,
        AppStrings.alertSample,
      );
    } else {
      if (validateDefects()) {
        if (validateSameDefects()) {
          await saveSamplesToDB();
          Map<String, dynamic> bundle = {
            Consts.SERVER_INSPECTION_ID: serverInspectionID,
            Consts.SEAL_NUMBER: sealNumber,
            Consts.PO_NUMBER: poNumber,
            Consts.COMPLETED: completed,
            Consts.PARTNER_NAME: partnerName,
            Consts.PARTNER_ID: partnerID,
            Consts.CARRIER_NAME: carrierName,
            Consts.CARRIER_ID: carrierID,
            Consts.COMMODITY_NAME: commodityName,
            Consts.COMMODITY_ID: commodityID,
            Consts.VARIETY_NAME: varietyName,
            Consts.VARIETY_SIZE: varietySize,
            Consts.VARIETY_ID: varietyId,
            Consts.GRADE_ID: gradeId,
            Consts.SPECIFICATION_NUMBER: specificationNumber,
            Consts.SPECIFICATION_VERSION: specificationVersion,
            Consts.SPECIFICATION_NAME: selectedSpecification,
            Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
            Consts.LOT_NO: lotNo,
            Consts.GTIN: gtin,
            Consts.PACK_DATE: packDate,
            Consts.LOT_SIZE: lotSize,
            Consts.ITEM_UNIQUE_ID: itemUniqueId,
            Consts.ITEM_SKU: itemSku,
            Consts.ITEM_SKU_ID: itemSkuId,
            Consts.ITEM_SKU_NAME: itemSkuName,
            Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
            Consts.PO_LINE_NO: poLineNo,
            Consts.PRODUCT_TRANSFER: productTransfer,
          };

          if (callerActivity == 'NewPurchaseOrderDetailsActivity') {
            bundle['callerActivity'] = 'NewPurchaseOrderDetailsActivity';
          } else {
            bundle['callerActivity'] = 'PurchaseOrderDetailsActivity';
          }

          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.to(() => QCDetailsShortFormScreen(tag: tag), arguments: bundle);
        } else {
          AppAlertDialog.validateAlerts(
            Get.context!,
            AppStrings.alert,
            AppStrings.sameDefectEntryAlert,
          );
        }
      } else {
        AppAlertDialog.validateAlerts(
          Get.context!,
          AppStrings.alert,
          AppStrings.defectEntryAlert,
        );
      }
    }
    hideKeypad();
  }

  void saveAsDraftAndGotoMyInspectionScreen() {
    if (sampleList.isEmpty) {
      AppAlertDialog.validateAlerts(
        Get.context!,
        AppStrings.alert,
        AppStrings.alertSample,
      );
    } else {
      if (validateDefects()) {
        if (validateSameDefects()) {
          saveSamplesToDB();
          Map<String, dynamic> bundle = {
            Consts.SERVER_INSPECTION_ID: serverInspectionID,
            Consts.PARTNER_NAME: partnerName,
            Consts.PARTNER_ID: partnerID,
            Consts.CARRIER_NAME: carrierName,
            Consts.CARRIER_ID: carrierID,
            Consts.PO_NUMBER: poNumber,
            Consts.COMMODITY_NAME: commodityName,
            Consts.COMMODITY_ID: commodityID,
            Consts.VARIETY_NAME: varietyName,
            Consts.VARIETY_ID: varietyId,
            Consts.GRADE_ID: gradeId,
            Consts.SPECIFICATION_NUMBER: specificationNumber,
            Consts.SPECIFICATION_VERSION: specificationVersion,
            Consts.SPECIFICATION_NAME: selectedSpecification,
            Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
            Consts.ITEM_SKU: itemSku,
            Consts.ITEM_SKU_ID: itemSkuId,
            Consts.LOT_NO: lotNo,
            Consts.GTIN: gtin,
            Consts.PACK_DATE: packDate,
            Consts.ITEM_UNIQUE_ID: itemUniqueId,
            Consts.LOT_SIZE: lotSize,
            Consts.ITEM_SKU_NAME: itemSkuName,
            Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
            Consts.PRODUCT_TRANSFER: productTransfer,
          };

          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          Get.off(() => PurchaseOrderDetailsScreen(tag: tag),
              arguments: bundle);
        } else {
          AppAlertDialog.validateAlerts(
            Get.context!,
            AppStrings.alert,
            AppStrings.sameDefectEntryAlert,
          );
        }
      } else {
        AppAlertDialog.validateAlerts(
          Get.context!,
          AppStrings.alert,
          AppStrings.defectEntryAlert,
        );
      }
    }
  }

  Future<void> saveSamplesToDB() async {
    hasDamage = false;
    hasSeriousDamage = false;

    // Save all the samples
    for (SampleData sample in sampleList) {
      int? sampleId = sample.sampleId;
      // TODO:
      var sampleSize = '1'; //sample.sampleSize;
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
            sampleName,
            setNumber,
            timeCreated?.toInt() ?? 0,
            0,
            sampleNameUser,
          ));
          sample.sampleId = sampleId;
        } catch (e) {
          debugPrint(e.toString());
        }
      } else {
        try {
          await dao.updateInspectionSample(sampleId, sampleNameUser);
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

  String getKeyFromIndex(int index) {
    return "Set #${index + 1}";
  }

  int getIndexFromKey(String name) {
    String numString = name.replaceAll("Set #", "");
    return int.parse(numString) - 1;
  }

  /*int getSampleSize(String name, List<SampleData> sampleList) {
    for (int i = 0; i < sampleList.length; i++) {
      if (name == sampleList[i].name) {
        return sampleList[i].sampleSize;
      }
    }
    return -1;
  }*/

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

  Future<void> navigateToCameraScreen({
    required int sampleIndex,
    required int defectItemIndex,
  }) async {
    String dataName = 'Set #${sampleIndex + 1}';

    Map<String, dynamic> passingData = {};
    passingData.putIfAbsent(Consts.PARTNER_NAME, () => partnerName);
    passingData.putIfAbsent(Consts.PARTNER_NAME, () => partnerName);
    passingData.putIfAbsent(Consts.PARTNER_ID, () => partnerID);
    passingData.putIfAbsent(Consts.CARRIER_NAME, () => carrierName);
    passingData.putIfAbsent(Consts.CARRIER_ID, () => carrierID);
    passingData.putIfAbsent(Consts.COMMODITY_NAME, () => commodityName);
    passingData.putIfAbsent(Consts.COMMODITY_ID, () => commodityID);
    passingData.putIfAbsent(Consts.VARIETY_NAME, () => varietyName);
    passingData.putIfAbsent(Consts.VARIETY_SIZE, () => varietySize);
    passingData.putIfAbsent(Consts.VARIETY_ID, () => varietyId);
    int? sampleId =
        sampleDataMap[sampleIndex]?.defectItems[defectItemIndex].sampleId;
    // int? sampleId = getSampleID(sampleDataMap[sampleIndex]!.name);
    if (sampleId != null) {
      passingData.putIfAbsent(Consts.SAMPLE_ID, () => sampleId);
    }

    currentAttachPhotosDataName = dataName;
    currentAttachPhotosPosition = sampleIndex;
    var result =
        await Get.to(() => const InspectionPhotos(), arguments: passingData);
    if (result != null) {
      try {
        List<InspectionDefect>? inspection =
            defectDataMap[currentAttachPhotosDataName];
        inspection![currentAttachPhotosPosition!].attachmentIds =
            appStorage.attachmentIds;
        defectDataMap[currentAttachPhotosDataName!] = inspection;
      } catch (e) {
        print(e);
      }
    }
  }

  void setSampleAndDefectCounts() {
    sampleDataMap.clear();
    sampleDataMapIndexList.clear();
    numberSamples = 0;

    seriousDefectList.clear();
    seriousDefectCountMap.clear();
    totalSamples = 0;
    totalInjury = 0;
    totalDamage = 0;
    totalSeriousDamage = 0;
    totalVerySeriousDamage = 0;
    totalDecay = 0;

    totalConditionInjury = 0;
    totalConditionDamage = 0;
    totalConditionSeriousDamage = 0;
    totalConditionVerySeriousDamage = 0;
    totalConditionDecay = 0;

    totalQualityInjury = 0;
    totalQualityDamage = 0;
    totalQualitySeriousDamage = 0;
    totalQualityVerySeriousDamage = 0;
    totalQualityDecay = 0;

    totalSizeInjury = 0;
    totalSizeDamage = 0;
    totalSizeSeriousDamage = 0;
    totalSizeVerySeriousDamage = 0;
    totalSizeDecay = 0;

    totalColorInjury = 0;
    totalColorDamage = 0;
    totalColorSeriousDamage = 0;
    totalColorVerySeriousDamage = 0;
    totalColorDecay = 0;

    for (int j = 0; j < sampleList.length; j++) {
      totalSamples += sampleList[j].sampleSize;
      numberSamples++;
      sampleDataMapIndexList.add(getIndexFromKey(sampleList[j].name));

      SampleData data = SampleData(
          sampleSize: sampleList[j].sampleSize,
          name: sampleList[j].name,
          complete: false,
          setNumber: sampleList[j].setNumber,
          timeCreated: sampleList[j].timeCreated,
          sampleId: sampleList[j].sampleId);
      sampleDataMap[getIndexFromKey(sampleList[j].name)] = data;
    }

    defectDataMap.forEach((key, value) {
      bool hasDefects = false;
      int? sampleSize = getSampleSize(key);
      SampleData data = SampleData(
          sampleSize: sampleSize ?? 0,
          name: key,
          complete: false,
          setNumber: 0,
          timeCreated: DateTime.now().millisecondsSinceEpoch,
          sampleId: 0);

      for (int i = 0; i < value.length; i++) {
        // Check the counts for each defect entry
        if (value[i].injuryCnt! > 0 ||
            value[i].damageCnt! > 0 ||
            value[i].seriousDamageCnt! > 0 ||
            value[i].verySeriousDamageCnt! > 0 ||
            value[i].decayCnt! > 0) {
          hasDefects = true;
          data.sampleId = value[i].sampleId;
          data.iCnt += value[i].injuryCnt!;
          data.dCnt += value[i].damageCnt!;
          data.sdCnt += value[i].seriousDamageCnt!;
          data.vsdCnt += value[i].verySeriousDamageCnt!;
          data.dcCnt += value[i].decayCnt!;

          //Mob-285
          totalSeriousDamage += value[i].seriousDamageCnt!;

          int defectId = value[i].defectId!;

          if (defectCategoriesHashMap.containsKey(defectId)) {
            if (defectCategoriesHashMap[defectId] == "Condition") {
              totalConditionInjury += value[i].injuryCnt!;
              totalConditionDamage += value[i].damageCnt!;
              totalConditionSeriousDamage += value[i].seriousDamageCnt!;
              totalConditionVerySeriousDamage += value[i].verySeriousDamageCnt!;
              totalConditionDecay += value[i].decayCnt!;
            } else if (defectCategoriesHashMap[defectId] == "Quality") {
              totalQualityInjury += value[i].injuryCnt!;
              totalQualityDamage += value[i].damageCnt!;
              totalQualitySeriousDamage += value[i].seriousDamageCnt!;
              totalQualityVerySeriousDamage += value[i].verySeriousDamageCnt!;
              totalQualityDecay += value[i].decayCnt!;
            } else if (defectCategoriesHashMap[defectId] == "Size") {
              totalSizeInjury += value[i].injuryCnt!;
              totalSizeDamage += value[i].damageCnt!;
              totalSizeSeriousDamage += value[i].seriousDamageCnt!;
              totalSizeVerySeriousDamage += value[i].verySeriousDamageCnt!;
              totalSizeDecay += value[i].decayCnt!;
            } else if (defectCategoriesHashMap[defectId] == "Color") {
              totalColorInjury += value[i].injuryCnt!;
              totalColorDamage += value[i].damageCnt!;
              totalColorSeriousDamage += value[i].seriousDamageCnt!;
              totalColorVerySeriousDamage += value[i].verySeriousDamageCnt!;
              totalColorDecay += value[i].decayCnt!;
            }
          }

          // build out a list of serious defect names
          if (value[i].seriousDamageCnt! > 0) {
            String defectName = value[i].spinnerSelection!;

            if (seriousDefectList.isEmpty ||
                !seriousDefectList.contains(defectName)) {
              seriousDefectList.add(defectName);
              seriousDefectCountMap[defectName] = 0;
            }
            if (defectCategoriesHashMap.containsKey(defectId)) {
              if (defectCategoriesHashMap[defectId] != "Size" &&
                  defectCategoriesHashMap[defectId] != "Color") {
                if (seriousDefectCountMap.containsKey(defectName)) {
                  // seriousDefectCountMap[defectName] += data.sdCnt;
                  seriousDefectCountMap[defectName] =
                      (seriousDefectCountMap[defectName] ?? 0) + data.sdCnt;
                } else {
                  seriousDefectCountMap[defectName] = data.sdCnt;
                }
              }
            } else {
              if (seriousDefectCountMap.containsKey(defectName)) {
                seriousDefectCountMap[defectName] =
                    (seriousDefectCountMap[defectName] ?? 0) + data.sdCnt;
              } else {
                seriousDefectCountMap[defectName] = data.sdCnt;
              }
            }
          }
        }
      }

      if (hasDefects) {
        sampleDataMap[getIndexFromKey(key)] = data;
        totalInjury += data.iCnt;
        totalDamage += data.dCnt;
        totalVerySeriousDamage += data.vsdCnt;
        totalVerySeriousDamage =
            (totalVerySeriousDamage - totalSizeVerySeriousDamage) -
                totalColorVerySeriousDamage;
        totalDecay += data.dcCnt;
        totalDecay = (totalDecay - totalSizeDecay) - totalColorDecay;
      }
    });
    totalInjury = (totalInjury - totalSizeInjury) - totalColorInjury;
    totalDamage = (totalDamage - totalSizeDamage) - totalColorDamage;
    totalVerySeriousDamage =
        (totalVerySeriousDamage - totalSizeVerySeriousDamage) -
            totalColorVerySeriousDamage;

    numberSeriousDefects = 1;
    if (seriousDefectList.length > 1) {
      numberSeriousDefects = seriousDefectList.length;
    }
  }

  Container drawDefectsTable() {
    if (numberSamples > 0) {
      defectTableAddSampleVisible = false;
    } else {
      defectTableAddSampleVisible = true;
    }

    populateSeverityList();

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

    // Note: In Flutter, instead of using LayoutInflater, we typically create widgets directly.
    // Here's an example of creating a TableLayout widget:
    double borderBlack = 3;
    double borderGrey = 3;
    double borderOutside = 6;
    Column tableLayout = Column(
      // borderBlack: borderBlack,
      // borderGrey: borderGrey,
      // borderOutside: borderOutside,
      children: [],
    );

    // Create the table row
    // Row tableRow = Row(children: []);

// Label column
    Widget labelContainer = Container(
      margin: EdgeInsets.only(left: borderOutside, top: borderOutside),
      child: Text(
        'Type',
        style: TextStyle(fontSize: 20),
      ),
    );
    Widget? injuryColumn;
    Widget? damageColumn;
    Widget? seriousDamageColumn;
    Widget? verySeriousDamageColumn;
    Widget? decayColumn1;
    Widget? lableColumn2;
    Widget? picturesCommentsColumn;
    Widget? severityWidget;
    Widget? injuryColumn1;
    Widget? damageColumn1;
    Widget? seriousDamageColumn1;
    Widget? verySeriousDamageColumn1;
    Widget? decayColumn2;
    Widget? injuryColumn2;
    Widget? damageColumn2;
    Widget? seriousDamageColumn2;
    Widget? decayColumn3;
    Widget? totalQualityLabelColumn;
    Widget? totalQualityInjuryColumn;
    Widget? totalQualityDamageColumn;
    Widget? columnView1;
    Widget? verySeriousDamageColumn2;
    Widget? damageColumn3;

// Injury column
    if (hasSeverityInjury) {
      injuryColumn = Container(
        margin: EdgeInsets.only(left: borderGrey, top: borderOutside),
        color: Colors.blue,
        child: Text(
          'Defects',
          style: TextStyle(fontSize: 16),
        ), // or use your color from resources
      );
    }

// Damage column
    if (hasSeverityDamage) {
      damageColumn = Container(
        margin: EdgeInsets.only(left: borderGrey, top: borderOutside),
        color: Colors.green,
        child: Text(
          'Defects',
          style: TextStyle(fontSize: 16),
        ), // or use your color from resources
      );
    }

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      seriousDamageColumn = Container(
        margin: EdgeInsets.only(left: borderGrey, top: borderOutside),
        color: Colors.orange,
        child: Text(
          'Defects',
          style: TextStyle(fontSize: 16),
        ), // or use your color from resources
      );
    }

    // Very serious damage column
    if (hasSeverityVerySeriousDamage) {
      verySeriousDamageColumn = Container(
        margin: EdgeInsets.only(left: borderGrey, top: borderOutside),
        color: Colors.blue,
        child: Text(
          'Defects',
          style: TextStyle(fontSize: 16),
        ), // or use your color from resources
      );
    }

// Decay column
    if (hasSeverityDecay) {
      decayColumn1 = Container(
        margin: EdgeInsets.only(left: borderGrey, top: borderOutside),
        color: Colors.green,
        child: Text(
          'Defects',
          style: TextStyle(fontSize: 16),
        ), // or use your color from resources
      );
    }

// Add the constructed row to the table layout
//     tableLayout.children.add(tableRow);

    // Create the table row
    Row tableRow2 = Row(children: []);

    severityWidget = Container(
      margin: EdgeInsets.only(left: borderOutside, right: borderGrey),
      child: Text(
        'Severity',
        style: TextStyle(fontSize: 20),
      ),
    );

// Label column
    tableRow2.children.add(severityWidget);

// Injury column
    if (hasSeverityInjury) {
      injuryColumn1 = Container(
        margin: EdgeInsets.only(right: borderGrey, bottom: borderOutside),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(borderGrey),
              color: Colors.blue, // or use your color from resources
              child: Icon(Icons.circle, color: Colors.red),
            ),
            Positioned.fill(
              child: Center(
                child: Text('I', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
      tableRow2.children.add(injuryColumn1);
    }

// Damage column
    if (hasSeverityDamage) {
      damageColumn1 = Container(
        margin: EdgeInsets.only(right: borderGrey, bottom: borderOutside),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(borderGrey),
              color: Colors.green, // or use your color from resources
              child: Icon(Icons.circle, color: Colors.red),
            ),
            Positioned.fill(
              child: Center(
                child: Text('D', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
      tableRow2.children.add(damageColumn1);
    }

// Add the constructed row to the table layout
    tableLayout.children.add(tableRow2);

    // Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      seriousDamageColumn1 = Container(
        margin: EdgeInsets.only(
          left: borderGrey,
          right: i == numberSeriousDefects - 1 ? borderOutside : borderGrey,
          bottom: i == numberSeriousDefects - 1 ? borderOutside : 0,
        ),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(borderGrey),
              color: Colors.orange, // or use your color from resources
              child: Icon(Icons.circle, color: Colors.red),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  'SD',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );

      if (numberSeriousDefects > 1) {
        // Add subscript to indicate index
        int subscriptIndex = i + 1;
        seriousDamageColumn1 = GestureDetector(
          child: seriousDamageColumn1,
          onTap: () {
            showDialog(
              context: Get.context!,
              builder: (BuildContext context) {
                return AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Serious Defect $subscriptIndex'),
                      SizedBox(height: 10),
                      Text(seriousDefectList[subscriptIndex - 1]),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('OK'),
                    ),
                  ],
                );
              },
            );
          },
        );
      }

      if (hasSeveritySeriousDamage) {
        tableRow2.children.add(seriousDamageColumn1);
      }
    }

// Very serious damage column
    if (hasSeverityVerySeriousDamage) {
      verySeriousDamageColumn1 = Container(
        margin: EdgeInsets.only(
            left: borderGrey, right: borderGrey, bottom: borderOutside),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(borderGrey),
              color: Colors.blue, // or use your color from resources
              child: Icon(Icons.circle, color: Colors.red),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  'VSD',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
      tableRow2.children.add(verySeriousDamageColumn1);
    }

// Decay column
    if (hasSeverityDecay) {
      decayColumn2 = Container(
        margin: EdgeInsets.only(
            left: borderGrey, right: borderGrey, bottom: borderOutside),
        child: Stack(
          children: [
            Container(
              margin: EdgeInsets.all(borderGrey),
              color: Colors.green, // or use your color from resources
              child: Icon(Icons.circle, color: Colors.red),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  'DC',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      );
      tableRow2.children.add(decayColumn2);
    }

// Add the constructed row to the table layout
    tableLayout.children.add(tableRow2);

    // **************************
// Row - Sample(s)
// **************************
    for (int j = 0; j < numberSamples; j++) {
      Row tableRow = Row(children: []);

      final int index = sampleDataMapIndexList[j];

      // Label column
      lableColumn2 = Container(
        margin: EdgeInsets.only(
          left: borderOutside,
          right: j == numberSamples - 1 ? 0 : borderOutside,
          bottom: j == numberSamples - 1 ? borderOutside : 0,
        ),
        child: Text(
          sampleDataMap[index]!.sampleSize.toString(),
          style: TextStyle(fontSize: 20),
        ),
      );
      // tableRow.children.add();

      // Injury column
      injuryColumn2 = Container(
        margin: EdgeInsets.only(
          left: 0,
          right: j == numberSamples - 1 ? 0 : borderOutside,
          bottom: j == numberSamples - 1 ? borderOutside : 0,
        ),
        color: hasSeverityInjury ? Colors.blue : null,
        child: Text(
          sampleDataMap[index]!.iCnt.toString(),
          style: TextStyle(fontSize: 20),
        ),
      );
      tableRow.children.add(injuryColumn2);

      // Damage column
      damageColumn2 = Container(
        margin: EdgeInsets.only(
          left: 0,
          right: j == numberSamples - 1 ? 0 : borderOutside,
          bottom: j == numberSamples - 1 ? borderOutside : 0,
        ),
        color: hasSeverityDamage ? Colors.green : null,
        child: Text(
          sampleDataMap[index]!.dCnt.toString(),
          style: TextStyle(fontSize: 20),
        ),
      );
      tableRow.children.add(damageColumn2);

      // Serious damage column(s)
      for (int i = 0; i < numberSeriousDefects; i++) {
        int count = 0;
        final data = defectDataMap[getKeyFromIndex(index)];
        if (data != null) {
          for (int k = 0; k < data.length; k++) {
            if (seriousDefectList.isNotEmpty &&
                data[k].spinnerSelection == seriousDefectList[i]) {
              count += data[k].seriousDamageCnt!;
            }
          }
        }
        seriousDamageColumn2 = Container(
          margin: EdgeInsets.only(
            left: 0,
            right: i == numberSeriousDefects - 1 ? borderOutside : 0,
            bottom: j == numberSamples - 1 ? borderOutside : 0,
          ),
          color: hasSeveritySeriousDamage ? Colors.orange : null,
          child: Text(
            count.toString(),
            style: TextStyle(fontSize: 20),
          ),
        );
        tableRow.children.add(seriousDamageColumn2);
      }

      // Very serious damage column
      verySeriousDamageColumn2 = Container(
        margin: EdgeInsets.only(
          left: 0,
          right: 0,
          bottom: j == numberSamples - 1 ? borderOutside : 0,
        ),
        color: hasSeverityVerySeriousDamage ? Colors.blue : null,
        child: Text(
          sampleDataMap[index]!.vsdCnt.toString(),
          style: TextStyle(fontSize: 20),
        ),
      );
      tableRow.children.add(verySeriousDamageColumn2);

      // Decay column
      decayColumn3 = Container(
        margin: EdgeInsets.only(
          left: 0,
          right: 0,
          bottom: j == numberSamples - 1 ? borderOutside : 0,
        ),
        color: hasSeverityDecay ? Colors.green : null,
        child: Text(
          sampleDataMap[index]!.dcCnt.toString(),
          style: TextStyle(fontSize: 20),
        ),
      );
      tableRow.children.add(decayColumn3);

      // Pictures / Comments column
      picturesCommentsColumn = Container(
        margin: EdgeInsets.only(
          left: 0,
          right: borderOutside,
          bottom: j == numberSamples - 1 ? borderOutside : 0,
        ),
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.camera),
              onPressed: () {
                // Your onPressed function for camera button
              },
            ),
            IconButton(
              icon: Icon(Icons.comment),
              onPressed: () {
                // Your onPressed function for comment button
              },
            ),
          ],
        ),
      );
      // tableRow.children.add(picturesCommentsColumn);

      tableLayout.children.add(tableRow);
    }

// **********************************************************************************
// Row - Total Quality Defects
// ***********************************************************************************
    Row totalQualityRow = Row(children: []);

// Label column
    totalQualityLabelColumn = Container(
      margin: EdgeInsets.only(left: borderOutside),
      child: Text(
        'Total Quality Defects',
        style: TextStyle(fontSize: 20),
      ),
    );
    totalQualityRow.children.add(totalQualityLabelColumn);

// Injury column
    totalQualityInjuryColumn = Container(
      margin: EdgeInsets.only(left: 0),
      color: hasSeverityInjury ? Colors.blue : null,
      child: Text(
        totalQualityInjury.toString(),
        style: TextStyle(fontSize: 20),
      ),
    );
    totalQualityRow.children.add(totalQualityInjuryColumn);

// Damage column
    totalQualityDamageColumn = Container(
      margin: EdgeInsets.only(left: 0),
      color: hasSeverityDamage ? Colors.green : null,
      child: Text(
        totalQualityDamage.toString(),
        style: TextStyle(fontSize: 20),
      ),
    );
    totalQualityRow.children.add(totalQualityDamageColumn);

    tableLayout.children.add(totalQualityRow);

    List<Widget> columnViews = [];
    // Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      columnView1 = Container(
        margin: EdgeInsets.only(
          right: i == numberSeriousDefects - 1 ? borderOutside : 0,
        ),
        decoration: BoxDecoration(
          color: Colors.orange,
          border: Border(
            right: BorderSide(
              color: Colors.grey,
              width: borderGrey.toDouble(),
            ),
          ),
        ),
        child: Text(
          i == 0 ? totalQualitySeriousDamage.toString() : '',
          style: TextStyle(fontSize: 20),
        ),
      );

      if (hasSeveritySeriousDamage) {
        columnViews.add(columnView1);
      }
    }

    List<Widget?> dataList = [
      injuryColumn,
      damageColumn,
      seriousDamageColumn,
      verySeriousDamageColumn,
      decayColumn1,
      lableColumn2,
      picturesCommentsColumn,
      severityWidget,
      injuryColumn1,
      damageColumn1,
    ];
    Row tableRow = Row(
      children: dataList.where((element) => element != null).nonNulls.toList(),
    );
// Very serious damage column
    verySeriousDamageColumn2 = Container(
      margin: EdgeInsets.only(
        left: borderGrey.toDouble(),
        right: borderGrey.toDouble(),
      ),
      decoration: BoxDecoration(
        color: Colors.blue,
        border: Border.all(
          color: Colors.grey,
          width: borderGrey.toDouble(),
        ),
      ),
      child: Text(
        totalQualityVerySeriousDamage.toString(),
        style: TextStyle(fontSize: 20),
      ),
    );

    if (hasSeverityVerySeriousDamage) {
      tableRow.children.add(verySeriousDamageColumn2);
    }

// Damage column
    damageColumn3 = Container(
      margin: EdgeInsets.only(
        left: borderGrey.toDouble(),
        right: borderGrey.toDouble() + borderOutside.toDouble(),
      ),
      decoration: BoxDecoration(
        color: Colors.green,
        border: Border.all(
          color: Colors.grey,
          width: borderGrey.toDouble(),
        ),
      ),
      child: Text(
        totalQualityDecay.toString(),
        style: TextStyle(fontSize: 20),
      ),
    );

    if (hasSeverityDecay) {
      tableRow.children.add(damageColumn3);
    }

    tableLayout.children.add(tableRow);

    // Row - Total Quality Defects %
    Row tableRow1 = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(
              borderOutside.toDouble(), borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Quality Defects %",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalQualityInjury(),
            style: TextStyle(
                fontSize: 20,
                color: (injuryQualitySpec != null &&
                        ((totalQualityInjury / totalSamples) * 100) >
                            injuryQualitySpec!)
                    ? Colors.red
                    : Colors.black),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalQualityDamage(),
            style: TextStyle(
                fontSize: 20,
                color: (damageQualitySpec != null &&
                        ((totalQualityDamage / totalSamples) * 100) >
                            damageQualitySpec!)
                    ? Colors.red
                    : Colors.black),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      tableRow1.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(),
              i == numberSeriousDefects - 1 ? borderOutside.toDouble() : 0, 0),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalQualitySeriousDamage(i),
            style: TextStyle(
                fontSize: 20,
                color: (seriousDamageQualitySpec != null &&
                        ((totalQualitySeriousDamage / totalSamples) * 100) >
                            seriousDamageQualitySpec!)
                    ? Colors.red
                    : Colors.black),
          ),
        ),
      );
    }

// Very serious damage column
    tableRow1.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalQualityVerySeriousDamage(),
          style: TextStyle(
              fontSize: 20,
              color: (verySeriousDamageQualitySpec != null &&
                      ((totalQualityVerySeriousDamage / totalSamples) * 100) >
                          verySeriousDamageQualitySpec!)
                  ? Colors.red
                  : Colors.black),
        ),
      ),
    );

    // **************************
// Row - Total Condition Defects
// **************************
    Row conditionTableRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(
              borderOutside.toDouble(), borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Condition Defects",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "$totalConditionInjury",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "$totalConditionDamage",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      conditionTableRow.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(),
              i == numberSeriousDefects - 1 ? borderOutside.toDouble() : 0, 0),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            i == 0 ? "$totalConditionSeriousDamage" : "",
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

// Very serious damage column
    conditionTableRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          "$totalConditionVerySeriousDamage",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Decay column
    conditionTableRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          "$totalConditionDecay",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Add the row to the table layout
    tableLayout.children.add(conditionTableRow);

// **************************
// Row - Total Condition Defects %
// **************************
    Row conditionPercentageRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(
              borderOutside.toDouble(), borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Condition Defects %",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalConditionInjury(),
            style: TextStyle(fontSize: 20),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalConditionDamage(),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      conditionPercentageRow.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(),
              i == numberSeriousDefects - 1 ? borderOutside.toDouble() : 0, 0),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalConditionSeriousDamage(i),
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

// Very serious damage column
    conditionPercentageRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalConditionVerySeriousDamage(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Decay column
    conditionPercentageRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalConditionDecay(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Add the row to the table layout
    tableLayout.children.add(conditionPercentageRow);

    // **************************
// Row - Total Severity by Defect Type
// **************************
    Row severityTableRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(
              borderOutside.toDouble(), borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Severity by Defect Type",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "$totalInjury",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "$totalDamage",
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      int sdcount = seriousDefectList.isEmpty
          ? 0
          : seriousDefectCountMap[seriousDefectList[i]] ?? 0;
      severityTableRow.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(
              0,
              borderBlack.toDouble(),
              i == numberSeriousDefects - 1
                  ? borderOutside.toDouble()
                  : borderGrey.toDouble(),
              0),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "$sdcount",
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

// Very serious damage column
    severityTableRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          "$totalVerySeriousDamage",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Decay column
    severityTableRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          "$totalDecay",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Add the row to the table layout
    tableLayout.children.add(severityTableRow);

    // Row - Total Severity by Defect Type %
    Row defectTypePercentRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(borderOutside.toDouble(),
              borderBlack.toDouble(), 0, borderBlack.toDouble()),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Severity by Defect Type %",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(
              0, borderBlack.toDouble(), 0, borderBlack.toDouble()),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalInjury(),
            style: TextStyle(
                fontSize: 20,
                color: injurySpec != null &&
                        (totalInjury / totalSamples) * 100 > injurySpec!
                    ? Colors.red
                    : null),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(
              0, borderBlack.toDouble(), 0, borderBlack.toDouble()),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalDamage(),
            style: TextStyle(
                fontSize: 20,
                color: damageSpec != null &&
                        (totalDamage / totalSamples) * 100 > damageSpec!
                    ? Colors.red
                    : null),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      int sdcount = seriousDefectList.isEmpty
          ? 0
          : seriousDefectCountMap[seriousDefectList[i]] ?? 0;
      double percent = (sdcount == 0) ? 0.0 : (sdcount / totalSamples) * 100;
      defectTypePercentRow.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(
              0,
              borderBlack.toDouble(),
              i == numberSeriousDefects - 1
                  ? borderOutside.toDouble()
                  : borderGrey.toDouble(),
              borderBlack.toDouble()),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "${percent.round()}%",
            style: TextStyle(
                fontSize: 20,
                color: seriousDamageSpec != null && percent > seriousDamageSpec!
                    ? Colors.red
                    : null),
          ),
        ),
      );
    }

// Very serious damage column
    defectTypePercentRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(
            0, borderBlack.toDouble(), 0, borderBlack.toDouble()),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalVerySeriousDamage(),
          style: TextStyle(
              fontSize: 20,
              color: verySeriousDamageSpec != null &&
                      (totalVerySeriousDamage / totalSamples) * 100 >
                          verySeriousDamageSpec!
                  ? Colors.red
                  : null),
        ),
      ),
    );

// Decay column
    defectTypePercentRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(
            0, borderBlack.toDouble(), 0, borderBlack.toDouble()),
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalDecay(),
          style: TextStyle(
              fontSize: 20,
              color: decaySpec != null &&
                      (totalDecay / totalSamples) * 100 > decaySpec!
                  ? Colors.red
                  : null),
        ),
      ),
    );

// Add the row to the table layout
    tableLayout.children.add(defectTypePercentRow);

// Row - % by Severity Level
    Row severityLevelPercentRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(borderOutside.toDouble(),
              borderOutside.toDouble(), 0, borderOutside.toDouble()),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Percent by Severity Level",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(
              0, borderOutside.toDouble(), 0, borderOutside.toDouble()),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalInjury(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(
              0, borderOutside.toDouble(), 0, borderOutside.toDouble()),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalDamage(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );

// Add the row to the table layout
    tableLayout.children.add(severityLevelPercentRow);

    // Row - Total Size Defects
    Row totalSizeDefectsRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(
              borderOutside.toDouble(), borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Size Defects",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            totalSizeInjury.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            totalSizeDamage.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      totalSizeDefectsRow.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(),
              i == numberSeriousDefects - 1 ? borderOutside.toDouble() : 0, 0),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            i == 0 ? totalSizeSeriousDamage.toString() : '',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

// Very serious damage column
    totalSizeDefectsRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          totalSizeVerySeriousDamage.toString(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Decay column
    totalSizeDefectsRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          totalSizeDecay.toString(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Add the row to the table layout
    tableLayout.children.add(totalSizeDefectsRow);

    // **************************
// Row - Total Size Defects %
// **************************
    Row totalSizeDefectsPercentageRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(
              borderOutside.toDouble(), borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Size Defects Percentage",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalSizeInjury(),
            style: TextStyle(fontSize: 20),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalSizeDamage(),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      totalSizeDefectsPercentageRow.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(),
              i == numberSeriousDefects - 1 ? borderOutside.toDouble() : 0, 0),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalSizeSeriousDamage(i),
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

// Very serious damage column
    totalSizeDefectsPercentageRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalSizeVerySeriousDamage(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Decay column
    totalSizeDefectsPercentageRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalSizeDecay(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Add the row to the table layout
    tableLayout.children.add(totalSizeDefectsPercentageRow);

// **************************
// Row - Total Color Defects
// **************************
    Row totalColorDefectsRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(
              borderOutside.toDouble(), borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Color Defects",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            totalColorInjury.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            totalColorDamage.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      totalColorDefectsRow.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(),
              i == numberSeriousDefects - 1 ? borderOutside.toDouble() : 0, 0),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            i == 0 ? totalColorSeriousDamage.toString() : '',
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

// Very serious damage column
    totalColorDefectsRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          totalColorVerySeriousDamage.toString(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Decay column
    totalColorDefectsRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(0, borderBlack.toDouble(), 0, 0),
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          totalColorDecay.toString(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Add the row to the table layout
    tableLayout.children.add(totalColorDefectsRow);

// **************************
// Row - Total Color Defects %
// **************************
    Row totalColorDefectsPercentageRow = Row(
      children: [
        // label column
        Container(
          margin: EdgeInsets.fromLTRB(borderOutside.toDouble(),
              borderBlack.toDouble(), 0, borderOutside.toDouble()),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            "Total Color Defects Percentage",
            style: TextStyle(fontSize: 20),
          ),
        ),
        // injury column
        Container(
          margin: EdgeInsets.fromLTRB(
              0, borderBlack.toDouble(), 0, borderOutside.toDouble()),
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalColorInjury(),
            style: TextStyle(fontSize: 20),
          ),
        ),
        // damage column
        Container(
          margin: EdgeInsets.fromLTRB(
              0, borderBlack.toDouble(), 0, borderOutside.toDouble()),
          decoration: BoxDecoration(
            color: Colors.green,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalColorDamage(),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ],
    );

// Serious damage column(s)
    for (int i = 0; i < numberSeriousDefects; i++) {
      totalColorDefectsPercentageRow.children.add(
        Container(
          margin: EdgeInsets.fromLTRB(
              0,
              borderBlack.toDouble(),
              i == numberSeriousDefects - 1 ? borderOutside.toDouble() : 0,
              borderOutside.toDouble()),
          decoration: BoxDecoration(
            color: Colors.orange,
            border: Border(
              bottom: BorderSide(color: Colors.black),
              right: BorderSide(color: Colors.grey),
            ),
          ),
          child: Text(
            getTotalColorSeriousDamage(i),
            style: TextStyle(fontSize: 20),
          ),
        ),
      );
    }

// Very serious damage column
    totalColorDefectsPercentageRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(
            0, borderBlack.toDouble(), 0, borderOutside.toDouble()),
        decoration: BoxDecoration(
          color: Colors.blue,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalColorVerySeriousDamage(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Decay column
    totalColorDefectsPercentageRow.children.add(
      Container(
        margin: EdgeInsets.fromLTRB(
            0, borderBlack.toDouble(), 0, borderOutside.toDouble()),
        decoration: BoxDecoration(
          color: Colors.green,
          border: Border(
            bottom: BorderSide(color: Colors.black),
            right: BorderSide(color: Colors.grey),
          ),
        ),
        child: Text(
          getTotalColorDecay(),
          style: TextStyle(fontSize: 20),
        ),
      ),
    );

// Add the row to the table layout
    tableLayout.children.add(totalColorDefectsPercentageRow);

    Container defectsTableContainer = Container(
      child: tableLayout,
    );
    return defectsTableContainer;
  }

  String getTotalColorDecay() {
    if (totalColorDecay == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalColorDecay / totalSamples) * 100).toStringAsFixed(2)}%";
  }

  String getTotalColorVerySeriousDamage() {
    if (totalColorVerySeriousDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalColorVerySeriousDamage / totalSamples) * 100).toStringAsFixed(2)}%";
  }

  String getTotalColorSeriousDamage(int i) {
    if (totalColorSeriousDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return i == 0
        ? "${((totalColorSeriousDamage / totalSamples) * 100).toStringAsFixed(2)}%"
        : '';
  }

  String getTotalColorDamage() {
    if (totalColorDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalColorDamage / totalSamples) * 100).toStringAsFixed(2)}%";
  }

  String getTotalColorInjury() {
    if (totalColorInjury == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalColorInjury / totalSamples) * 100).toStringAsFixed(2)}%";
  }

  String getTotalSizeDecay() {
    if (totalSizeDecay == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalSizeDecay / totalSamples) * 100).toStringAsFixed(2)}%";
  }

  String getTotalSizeVerySeriousDamage() {
    if (totalSizeVerySeriousDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalSizeVerySeriousDamage / totalSamples) * 100).toStringAsFixed(2)}%";
  }

  String getTotalSizeSeriousDamage(int i) {
    if (totalSizeSeriousDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return i == 0
        ? "${((totalSizeSeriousDamage / totalSamples) * 100).toStringAsFixed(2)}%"
        : '';
  }

  String getTotalSizeDamage() {
    if (totalSizeDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalSizeDamage / totalSamples) * 100).toStringAsFixed(2)}%";
  }

  String getTotalSizeInjury() {
    if (totalSizeInjury == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalSizeInjury / totalSamples) * 100).toStringAsFixed(2)}%";
  }

  String getTotalDecay() {
    if (totalDecay == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalDecay / totalSamples) * 100).round()}%";
  }

  String getTotalVerySeriousDamage() {
    if (totalVerySeriousDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalVerySeriousDamage / totalSamples) * 100).round()}%";
  }

  String getTotalDamage() {
    if (totalDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalDamage / totalSamples) * 100).round()}%";
  }

  String getTotalInjury() {
    if (totalInjury == 0 || totalSamples == 0) {
      return '0';
    }

    return "${((totalInjury / totalSamples) * 100).round()}%";
  }

  String getTotalConditionDecay() {
    if (totalConditionDecay == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalConditionDecay / totalSamples) * 100).round()}%";
  }

  String getTotalConditionVerySeriousDamage() {
    if (totalConditionVerySeriousDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalConditionVerySeriousDamage / totalSamples) * 100).round()}%";
  }

  String getTotalConditionSeriousDamage(int i) {
    if (totalConditionSeriousDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return i == 0
        ? "${((totalConditionSeriousDamage / totalSamples) * 100).round()}%"
        : "";
  }

  String getTotalConditionDamage() {
    if (totalConditionDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalConditionDamage / totalSamples) * 100).round()}%";
  }

  String getTotalConditionInjury() {
    if (totalConditionInjury == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalConditionInjury / totalSamples) * 100).round()}%";
  }

  String getTotalQualityVerySeriousDamage() {
    if (totalQualityVerySeriousDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalQualityVerySeriousDamage / totalSamples) * 100).round()}%";
  }

  String getTotalQualityInjury() {
    if (totalQualityInjury == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalQualityInjury / totalSamples) * 100).round()}%";
  }

  String getTotalQualityDamage() {
    if (totalQualityDamage == 0 || totalSamples == 0) {
      return '0';
    }
    return "${((totalQualityDamage / totalSamples) * 100).round()}%";
  }

  String getTotalQualitySeriousDamage(int i) {
    if ((i != 0) || (totalQualitySeriousDamage == 0 || totalSamples == 0)) {
      return "";
    }
    return i == 0
        ? "${((totalQualitySeriousDamage / totalSamples) * 100).round()}%"
        : "";
  }

  void getToQCDetailShortForm() {
    Map<String, dynamic> args = {
      Consts.SERVER_INSPECTION_ID: serverInspectionID,
      Consts.SEAL_NUMBER: sealNumber,
      Consts.PO_NUMBER: poNumber,
      Consts.COMPLETED: completed,
      Consts.PARTNER_NAME: partnerName,
      Consts.PARTNER_ID: partnerID,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VARIETY_NAME: varietyName,
      Consts.VARIETY_SIZE: varietySize,
      Consts.VARIETY_ID: varietyId,
      Consts.GRADE_ID: gradeId,
      Consts.SPECIFICATION_NUMBER: specificationNumber,
      Consts.SPECIFICATION_VERSION: specificationVersion,
      Consts.SPECIFICATION_NAME: selectedSpecification,
      Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
      Consts.LOT_NO: lotNo,
      Consts.GTIN: gtin,
      Consts.PACK_DATE: packDateString,
      Consts.LOT_SIZE: lotSize,
      Consts.ITEM_UNIQUE_ID: itemUniqueId,
      Consts.ITEM_SKU: itemSku,
      Consts.ITEM_SKU_ID: itemSkuId,
      Consts.ITEM_SKU_NAME: itemSkuName,
      Consts.IS_MY_INSPECTION_SCREEN: isMyInspectionScreen,
      Consts.PO_LINE_NO: poLineNo,
      Consts.PRODUCT_TRANSFER: productTransfer,
      Consts.CALLER_ACTIVITY:
          (callerActivity == "NewPurchaseOrderDetailsActivity")
              ? "NewPurchaseOrderDetailsActivity"
              : "PurchaseOrderDetailsActivity",
    };

    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.off(() => QCDetailsShortFormScreen(tag: tag), arguments: args);
    return;
  }

  int getDefectSpinnerId(String name) {
    for (int i = 0; i < defectSpinnerNames.length; i++) {
      if (defectSpinnerNames.elementAt(i) == name) {
        return defectSpinnerIds.elementAt(i);
      }
    }
    return 0;
  }
}
