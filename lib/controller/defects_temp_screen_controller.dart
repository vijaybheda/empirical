import 'package:get/get.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/sample_data.dart';
import 'package:pverify/utils/const.dart';

class DefectsScreenController extends GetxController {
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

  List<SampleData> sampleList = [];
  List<String> defectSpinnerNames = [];
  List<int> defectSpinnerIds = [];
  Map<String, List<InspectionDefect>> defectDataMap =
      <String, List<InspectionDefect>>{};
  Map<int, SampleData> sampleDataMap = <int, SampleData>{};
  List<int> sampleDataMapIndexList = [];
  List<String> seriousDefectList = [];
  Map<String, int> seriousDefectCountMap = <String, int>{};
  Map<int, String>? defectCategoriesMap;

  String poNumber = '', sealNumber = '';

  String? lotNo, itemSku, packDate, itemUniqueId, lotSize;
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

  @override
  void onInit() {
    Map<String, dynamic>? extras = Get.arguments;
    if (extras == null) {
      Get.back();
      throw Exception('Arguments required!');
    }

    serverInspectionID = extras[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = extras[Consts.PARTNER_NAME] ?? '';
    partnerID = extras[Consts.PARTNER_ID];
    carrierName = extras[Consts.CARRIER_NAME];
    carrierID = extras[Consts.CARRIER_ID];
    commodityName = extras[Consts.COMMODITY_NAME] ?? '';
    commodityID = extras[Consts.COMMODITY_ID] ?? 0;
    sampleSizeByCount = extras[Consts.SAMPLE_SIZE_BY_COUNT] ?? 0;
    varietyName = extras[Consts.VARIETY_NAME];
    serverInspectionID = extras[Consts.SERVER_INSPECTION_ID] ?? -1;
    partnerName = extras[Consts.PARTNER_NAME] ?? '';
    partnerID = extras[Consts.PARTNER_ID];
    carrierName = extras[Consts.CARRIER_NAME];
    carrierID = extras[Consts.CARRIER_ID];
    commodityName = extras[Consts.COMMODITY_NAME] ?? '';
    commodityID = extras[Consts.COMMODITY_ID] ?? 0;
    sampleSizeByCount = extras[Consts.SAMPLE_SIZE_BY_COUNT] ?? 0;
    varietyName = extras[Consts.VARIETY_NAME];
    varietySize = extras[Consts.VARIETY_SIZE];
    varietyId = extras[Consts.VARIETY_ID];
    completed = extras[Consts.COMPLETED] ?? false;
    inspectionResult = extras[Consts.INSPECTION_RESULT] ?? '';
    selectedSpecification = extras[Consts.SPECIFICATION_NAME];
    poNumber = extras[Consts.PO_NUMBER] ?? '';
    sealNumber = extras[Consts.SEAL_NUMBER] ?? '';
    gradeId = extras[Consts.GRADE_ID];
    itemSku = extras[Consts.ITEM_SKU] ?? '';
    itemSkuId = extras[Consts.ITEM_SKU_ID] ?? 0;
    itemSkuName = extras[Consts.ITEM_SKU_NAME] ?? '';
    specificationNumber = extras[Consts.SPECIFICATION_NUMBER];
    specificationVersion = extras[Consts.SPECIFICATION_VERSION];
    specificationTypeName = extras[Consts.SPECIFICATION_TYPE_NAME];
    isMyInspectionScreen = extras[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
    lotNo = extras[Consts.LOT_NO] ?? '';
    gtin = extras[Consts.GTIN] ?? '';
    packDate = extras[Consts.PACK_DATE] ?? '';
    itemUniqueId = extras[Consts.ITEM_UNIQUE_ID] ?? '';
    lotSize = extras[Consts.LOT_SIZE] ?? '';
    poLineNo = extras[Consts.PO_LINE_NO] ?? 0;
    productTransfer = extras[Consts.PRODUCT_TRANSFER] ?? '';
    callerActivity = extras[Consts.CALLER_ACTIVITY] ?? '';
    varietySize = extras[Consts.VARIETY_SIZE];
    varietyId = extras[Consts.VARIETY_ID];
    completed = extras[Consts.COMPLETED] ?? false;
    inspectionResult = extras[Consts.INSPECTION_RESULT] ?? '';
    selectedSpecification = extras[Consts.SPECIFICATION_NAME];
    poNumber = extras[Consts.PO_NUMBER] ?? '';
    sealNumber = extras[Consts.SEAL_NUMBER] ?? '';
    gradeId = extras[Consts.GRADE_ID];
    itemSku = extras[Consts.ITEM_SKU] ?? '';
    itemSkuId = extras[Consts.ITEM_SKU_ID] ?? 0;
    itemSkuName = extras[Consts.ITEM_SKU_NAME] ?? '';
    specificationNumber = extras[Consts.SPECIFICATION_NUMBER];
    specificationVersion = extras[Consts.SPECIFICATION_VERSION];
    specificationTypeName = extras[Consts.SPECIFICATION_TYPE_NAME];
    isMyInspectionScreen = extras[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
    lotNo = extras[Consts.LOT_NO] ?? '';
    gtin = extras[Consts.GTIN] ?? '';
    packDate = extras[Consts.PACK_DATE] ?? '';
    itemUniqueId = extras[Consts.ITEM_UNIQUE_ID] ?? '';
    lotSize = extras[Consts.LOT_SIZE] ?? '';
    poLineNo = extras[Consts.PO_LINE_NO] ?? 0;
    productTransfer = extras[Consts.PRODUCT_TRANSFER] ?? '';
    callerActivity = extras[Consts.CALLER_ACTIVITY] ?? '';

    super.onInit();
  }
}
