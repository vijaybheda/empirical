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
import 'package:pverify/models/severity_defect.dart';
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

  Map<int, String>? defectCategoriesHashMap;

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

    Future.delayed(const Duration(milliseconds: 10)).then((value) async {
      await setInit();
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
      update();
    });
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
          defectDataMap[temp.name] = defectList;
          sampleList[i] = sampleList[i].copyWith(defectItems: defectList);
          SampleData sampleDummyData = sampleList[i];
          setInitValuesToTextFields(sampleDummyData);
        }
        // loadDataIfNotEmpty(i, temp);
      }
    }
    if (hasDefects) {
      getDefectCategories();
      // setTabSelected(tableTabSelected);
    }
    update();
  }

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
    // int id = sampleList.isNotEmpty ? (sampleList.length + 1) : 1;

    final int index;
    final int pos = (sampleList.length - 1);
    if (sampleList.isNotEmpty) {
      index = sampleList.elementAt(pos).setNumber + 1;
    } else {
      index = sampleList.length + 1;
    }

    final String name = "$setsValue Samples Set #$index";
    final int timeStamp = DateTime.now().millisecondsSinceEpoch;
    SampleData sampleData = SampleData(
      sampleSize: setsValue,
      name: name,
      setNumber: index,
      timeCreated: timeStamp,
      // sampleId: id,
      // lotNumber: 0,
      // packDate: "",
      complete: false,
      sampleNameUser: name,
    );
    sampleList.add(sampleData);
    sizeOfNewSetTextController.text = "";

    String dataName = sampleList.elementAt(sampleList.length - 1).name;
    List<InspectionDefect> defectList = [];
    if (defectDataMap.containsKey(dataName)) {
      defectList = defectDataMap[dataName]!;
    } else {
      defectList = [];
    }

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

  void addDefectRow(BuildContext context, {required int sampleIndex}) {
    SampleData sampleData = sampleList.elementAt(sampleIndex);
    String dataName = sampleData.name;
    List<InspectionDefect> defectList;

    if (defectDataMap.containsKey(dataName)) {
      defectList = defectDataMap[dataName]!;

      InspectionDefect inspectionDefect = InspectionDefect(
        createdTime: DateTime.now().millisecondsSinceEpoch,
        comment: "",
        attachmentIds: [],
        defectCategory: '',
        damageCnt: 0,
        decayCnt: 0,
        defectId: 0,
        injuryCnt: 0,
        // inspectionDefectId: 0,
        // sampleId: sampleData.defectItems.length,
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
      defectDataMap[dataName] = defectList;
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

      InspectionDefect inspectionDefect = InspectionDefect(
        createdTime: DateTime.now().millisecondsSinceEpoch,
        comment: "",
        attachmentIds: [],
        defectCategory: '',
        damageCnt: 0,
        decayCnt: 0,
        defectId: 0,
        injuryCnt: 0,
        // inspectionDefectId: 0,
        // sampleId: sampleData.sampleId,
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
      defectDataMap[dataName] = defectList;
    }
    final int pos = (sampleList.length - 1);
    loadDefectData((defectList.length - 1), defectList, dataName, pos);

    int defectItemIndex = (sampleList[sampleIndex].defectItems.length - 1);
    String dropDownValue = sampleList[sampleIndex]
            .defectItems
            .elementAtOrNull(defectItemIndex)
            ?.spinnerSelection ??
        defectSpinnerNames.first;

    onDropDownChange(
      selected: dropDownValue,
      sampleIndex: sampleIndex,
      defectItemIndex: defectItemIndex,
    );

    // sampleDataMap[sampleIndex]?.defectItems = defectList;

    hideKeypad(context);
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

    // sampleList[sampleIndex].defectItems.removeAt(defectIndex);
    // sampleList.refresh();

    update();
  }

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

    String dataName = sampleList[sampleIndex].name;

    if (value > sampleSize) {
      isError = true;
      AppAlertDialog.validateAlerts(
        context,
        AppStrings.alert,
        '$fieldName - $dropDownValue ${AppStrings.cannotBeGreaterThenTheSampleSize} $sampleSize, ${AppStrings.pleaseEnterValidDefectCount}',
      );
    }

    InspectionDefect defectItem =
        sampleList[sampleIndex].defectItems[defectIndex];
    if (!isError) {
      switch (fieldName) {
        case AppStrings.injury:
          defectItem.injuryCnt = value;
          defectItem.injuryTextEditingController.text = value.toString();
          break;
        case AppStrings.damage:
          defectItem.injuryCnt = value;
          defectItem.damageCnt = value;
          defectItem.damageTextEditingController.text = value.toString();
          defectItem.injuryTextEditingController.text = value.toString();
          break;
        case AppStrings.seriousDamage:
          defectItem.injuryCnt = value;
          defectItem.damageCnt = value;
          defectItem.seriousDamageCnt = value;
          defectItem.sDamageTextEditingController.text = value.toString();
          defectItem.damageTextEditingController.text = value.toString();
          defectItem.injuryTextEditingController.text = value.toString();
          break;
        case AppStrings.verySeriousDamage:
          defectItem.injuryCnt = value;
          defectItem.damageCnt = value;
          defectItem.seriousDamageCnt = value;
          defectItem.verySeriousDamageCnt = value;
          defectItem.vsDamageTextEditingController.text = value.toString();
          defectItem.sDamageTextEditingController.text = value.toString();
          defectItem.damageTextEditingController.text = value.toString();
          defectItem.injuryTextEditingController.text = value.toString();
          break;
        case AppStrings.decay:
          defectItem.decayCnt = value;
          break;
      }

      sampleList[sampleIndex].defectItems[defectIndex] = defectItem;
      // Update the map only if no error
      defectDataMap[dataName] = sampleList[sampleIndex].defectItems;
    } else {
      resetErrorState(defectItem);
    }

    // Refresh the UI or data structures if needed
    sampleList.refresh();
    update();
  }

  void resetErrorState(InspectionDefect defectItem) {
    defectItem.injuryTextEditingController.text = '0';
    defectItem.damageTextEditingController.text = '0';
    defectItem.sDamageTextEditingController.text = '0';
    defectItem.vsDamageTextEditingController.text = '0';
    defectItem.injuryCnt = 0;
    defectItem.damageCnt = 0;
    defectItem.seriousDamageCnt = 0;
    defectItem.verySeriousDamageCnt = 0;
  }

  void onDropDownChange({
    required String selected,
    required int sampleIndex,
    required int defectItemIndex,
  }) {
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
      String dataName = sampleList[sampleIndex].name;
      sampleList[sampleIndex].defectItems[defectItemIndex].comment = value;
      defectDataMap[dataName] = sampleList[sampleIndex].defectItems;
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

    sampleList.removeAt(index);

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
    }
    update();
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

      for (SeverityDefect severityDefect in item.severityDefectList) {
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
    passingData[Consts.FOR_DEFECT_ATTACHMENT] = true;
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    await Get.to(() => InspectionPhotos(tag: tag), arguments: passingData);
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
    defectCategoriesHashMap = {};

    for (var i = 0; i < defectCategoriesList.length; i++) {
      if (defectCategoriesList[i].name == "Condition") {
        List<DefectItem>? defectItemList = defectCategoriesList[i].defectList;

        if (defectItemList != null) {
          for (var defectItem in defectItemList) {
            if (defectItem.name?.contains("Total Condition") ?? false) {
              totalConditionDefectId = defectItem.id;
            } else {
              defectCategoriesHashMap![defectItem.id!] = "Condition";
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
              defectCategoriesHashMap![defectItem.id!] = "Quality";
            }
          }
        }
      } else if (defectCategoriesList[i].name == "Size") {
        List<DefectItem>? defectItemList = defectCategoriesList[i].defectList;

        if (defectItemList != null) {
          for (var defectItem in defectItemList) {
            defectCategoriesHashMap![defectItem.id!] = "Size";
          }
        }
      } else if (defectCategoriesList[i].name == "Color") {
        List<DefectItem>? defectItemList = defectCategoriesList[i].defectList;

        if (defectItemList != null) {
          for (var defectItem in defectItemList) {
            defectCategoriesHashMap![defectItem.id!] = "Color";
          }
        }
      }
    }
  }

  List<DefectCategories> get defectCategoriesList =>
      appStorage.defectCategoriesList ?? [];

  Future<void> saveDefectEntriesAndContinue(BuildContext context) async {
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
    hideKeypad(context);
  }

  Future<void> saveAsDraftAndGotoMyInspectionScreen() async {
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
          sample = sample.copyWith(sampleId: sampleId);
          int ind =
              sampleList.indexWhere((element) => element.name == sampleName);
          sampleList[ind] = sample;
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

        String defectCategory = '';

        if (defectCategoriesHashMap != null) {
          if (defectCategoriesHashMap?.containsKey(defectId) ?? false) {
            defectCategory = defectCategoriesHashMap![defectId] ?? '';
          }
        }

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

  String getKeyFromIndex(int index, int samples) {
    return "$samples Samples Set #${index + 1}";
  }

  int getIndexFromKey(String name) {
    return extractNumberFromBeginning(name);
  }

  int extractNumberFromBeginning(String input) {
    RegExp regExp = RegExp(r'^(\d+)');

    Match? match = regExp.firstMatch(input);

    if (match != null) {
      return int.parse(match.group(1)!);
    } else {
      return -1;
    }
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

  void hideKeypad(BuildContext context) {
    // unFocus();
    FocusScope.of(context).unfocus();
  }

  void loadDefectData(int i, List<InspectionDefect> defectList, String dataName,
      int sampleListPosition) {
    populateDefectSpinnerList();
  }

  Future<void> navigateToCameraScreen({
    required int sampleIndex,
    required int defectItemIndex,
    required InspectionDefect inspectionDefect,
  }) async {
    Map<String, dynamic> passingData = {};
    passingData[Consts.PARTNER_NAME] = partnerName;
    passingData[Consts.PARTNER_NAME] = partnerName;
    passingData[Consts.PARTNER_ID] = partnerID;
    passingData[Consts.CARRIER_NAME] = carrierName;
    passingData[Consts.CARRIER_ID] = carrierID;
    passingData[Consts.COMMODITY_NAME] = commodityName;
    passingData[Consts.COMMODITY_ID] = commodityID;
    passingData[Consts.VARIETY_NAME] = varietyName;
    passingData[Consts.VARIETY_SIZE] = varietySize;
    passingData[Consts.VARIETY_ID] = varietyId;

    int? sampleId = inspectionDefect.sampleId;
    int? inspectionDefectId = inspectionDefect.inspectionDefectId;
    List<int>? attachmentIds = inspectionDefect.attachmentIds;
    if (sampleId != null) {
      passingData[Consts.SAMPLE_ID] = sampleId;
    }
    if (inspectionDefectId != null) {
      passingData[Consts.DEFECT_ID] = sampleId;
    }
    if (attachmentIds != null && attachmentIds.isNotEmpty) {
      passingData[Consts.HAS_INSPECTION_IDS] = true;
      appStorage.attachmentIds = attachmentIds;
    }

    passingData[Consts.FOR_DEFECT_ATTACHMENT] = true;

    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    var result =
        await Get.to(() => InspectionPhotos(tag: tag), arguments: passingData);
    if (result != null) {
      try {
        String dataName = sampleList.elementAt(sampleIndex).name;
        List<InspectionDefect>? inspection = defectDataMap[dataName];
        inspection![defectItemIndex].attachmentIds = appStorage.attachmentIds;
        defectDataMap[dataName] = inspection;
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
        // complete: false,
        // setNumber: sampleList[j].setNumber,
        // timeCreated: sampleList[j].timeCreated,
        // sampleId: sampleList[j].sampleId,
      );
      sampleDataMap[getIndexFromKey(sampleList[j].name)] = data;
    }

    defectDataMap.forEach((key, value) {
      bool hasDefects = false;
      int? sampleSize = getSampleSize(key);
      SampleData data = SampleData(
        sampleSize: sampleSize ?? 0,
        name: key,
        // complete: false,
        // setNumber: 0,
        // timeCreated: DateTime.now().millisecondsSinceEpoch,
        // sampleId: 0,
      );

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

          if (defectCategoriesHashMap?.containsKey(defectId) ?? false) {
            if (defectCategoriesHashMap![defectId] == "Condition") {
              totalConditionInjury += value[i].injuryCnt!;
              totalConditionDamage += value[i].damageCnt!;
              totalConditionSeriousDamage += value[i].seriousDamageCnt!;
              totalConditionVerySeriousDamage += value[i].verySeriousDamageCnt!;
              totalConditionDecay += value[i].decayCnt!;
            } else if (defectCategoriesHashMap![defectId] == "Quality") {
              totalQualityInjury += value[i].injuryCnt!;
              totalQualityDamage += value[i].damageCnt!;
              totalQualitySeriousDamage += value[i].seriousDamageCnt!;
              totalQualityVerySeriousDamage += value[i].verySeriousDamageCnt!;
              totalQualityDecay += value[i].decayCnt!;
            } else if (defectCategoriesHashMap![defectId] == "Size") {
              totalSizeInjury += value[i].injuryCnt!;
              totalSizeDamage += value[i].damageCnt!;
              totalSizeSeriousDamage += value[i].seriousDamageCnt!;
              totalSizeVerySeriousDamage += value[i].verySeriousDamageCnt!;
              totalSizeDecay += value[i].decayCnt!;
            } else if (defectCategoriesHashMap![defectId] == "Color") {
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
            if (defectCategoriesHashMap?.containsKey(defectId) ?? false) {
              if (!(defectCategoriesHashMap![defectId] == "Size") &&
                  !(defectCategoriesHashMap![defectId] == "Color")) {
                if (seriousDefectCountMap.containsKey(defectName)) {
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

    print(
        'totalInjury: $totalInjury totalDamage: $totalDamage totalSeriousDamage: $totalSeriousDamage totalVerySeriousDamage: $totalVerySeriousDamage totalDecay: $totalDecay');
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

  String? getComment(int sampleIndex) {
    int index = sampleDataMapIndexList[sampleIndex];
    return getCommentsForSample(sampleDataMap[index]!.name);
  }

  void setInitValuesToTextFields(SampleData sampleDummyData) {
    for (InspectionDefect inspectionDefect in sampleDummyData.defectItems) {
      if (inspectionDefect.injuryCnt != 0) {
        inspectionDefect.injuryTextEditingController.text =
            inspectionDefect.injuryCnt.toString();
      }
      if (inspectionDefect.damageCnt != 0) {
        inspectionDefect.damageTextEditingController.text =
            inspectionDefect.damageCnt.toString();
      }
      if (inspectionDefect.seriousDamageCnt != 0) {
        inspectionDefect.sDamageTextEditingController.text =
            inspectionDefect.seriousDamageCnt.toString();
      }

      if (inspectionDefect.verySeriousDamageCnt != 0) {
        inspectionDefect.vsDamageTextEditingController.text =
            inspectionDefect.verySeriousDamageCnt.toString();
      }
      if (inspectionDefect.decayCnt != 0) {
        inspectionDefect.decayTextEditingController.text =
            inspectionDefect.decayCnt.toString();
      }

      if (inspectionDefect.spinnerSelection?.isNotEmpty ?? false) {
        // inspectionDefect.defectSpinne =
        //     getDefectSpinnerName(inspectionDefect.spinnerSelection);
      }
    }
  }
}
