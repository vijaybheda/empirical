import 'package:get/get.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';

class SpecificationAttributesController extends GetxController {
  int? partnerID;
  int? carrierID;
  int? commodityID;
  int? poLineNo, varietyId, gradeId, itemSkuId;
  int? inspectionId;
  int? serverInspectionId;
  int sampleSizeByCount = 0;
  int? qcID;

  String? partnerName;
  String? carrierName;
  String? commodityName;
  String? inspectionResult;
  String? itemSKU, itemSkuName, lotNo;
  String? poNumber;
  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;
  String? selectedSpecification;
  String? productTransfer;
  String? callerActivity;
  String? is1stTimeActivity;
  String? gtin,
      gln,
      sealNumber,
      varietyName,
      varietySize,
      itemUniqueId,
      lotSize,
      packDate;
  String? footerLeftButtonText,
      footerMiddleButtonText,
      footerMiddle2ButtonText,
      footerMiddle3ButtonText;
  String? headerText, varietyText, commodityText;
  String dateTypeDesc = '';
  String tag = 'SpecificationAttributesActivity';

  bool? isMyInspectionScreen;
  bool? partialCompleted;
  bool? completed;
  bool hasError2 = false;
  RxBool hasInitialised = false.obs;

  RxList<SpecificationAnalytical> listSpecAnalyticals =
      <SpecificationAnalytical>[].obs;
  List<SpecificationAnalyticalRequest> listSpecAnalyticalsRequest = [];
  List<String> operatorList = ['Select', 'Yes', 'No', 'N/A'];
  List<SpecificationAnalyticalRequest?> dbobjList = [];

  final AppStorage _appStorage = AppStorage.instance;
  final ApplicationDao dao = ApplicationDao();
  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments required!');
    }
    if (args.isNotEmpty) {
      serverInspectionId = args[Consts.SERVER_INSPECTION_ID] ?? -1;
      inspectionId = args[Consts.SERVER_INSPECTION_ID] ?? -1;
      partnerName = args[Consts.PARTNER_NAME] ?? '';
      partnerID = args[Consts.PARTNER_ID] ?? 0;
      carrierName = args[Consts.CARRIER_NAME] ?? '';
      carrierID = args[Consts.CARRIER_ID] ?? 0;
      commodityName = args[Consts.COMMODITY_NAME] ?? '';
      commodityID = args[Consts.COMMODITY_ID] ?? 0;
      completed = args[Consts.COMPLETED] ?? false;

      specificationNumber = args[Consts.SPECIFICATION_NUMBER] ?? '';
      specificationVersion = args[Consts.SPECIFICATION_VERSION] ?? '';

      selectedSpecification = args[Consts.SELECTEDSPECIFICATION] ?? '';
      specificationTypeName = args[Consts.SPECIFICATION_TYPE_NAME] ?? '';

      poNumber = args[Consts.PO_NUMBER] ?? '';

      lotNo = args[Consts.LOT_NO] ?? '';
      itemSKU = args[Consts.ITEM_SKU];
      dateTypeDesc = args[Consts.DATETYPE] ?? '';
      callerActivity = args[Consts.CALLER_ACTIVITY] ?? '';
      varietyName = args[Consts.VARIETY_NAME] ?? '';
      varietySize = args[Consts.VARIETY_SIZE] ?? '';
      varietyId = args[Consts.VARIETY_ID] ?? 0;
      isMyInspectionScreen = args[Consts.IS_MY_INSPECTION_SCREEN] ?? false;
      itemSkuId = args[Consts.ITEM_SKU_ID] ?? 0;
      itemSkuName = args[Consts.ITEM_SKU_NAME] ?? '';
      gtin = args[Consts.GTIN] ?? '';
      packDate = args[Consts.PACK_DATE] ?? '';
      itemUniqueId = args[Consts.ITEM_UNIQUE_ID] ?? '';
      lotSize = args[Consts.LOT_SIZE] ?? '';
      poNumber = args[Consts.PO_NUMBER] ?? '';
      callerActivity = args["callerActivity"] ?? '';
      poLineNo = args[Consts.PO_LINE_NO] ?? 0;
      productTransfer = args[Consts.PRODUCT_TRANSFER] ?? '';
      dateTypeDesc = args[Consts.DATETYPE] ?? '';
    }

    if (serverInspectionId! > -1) {
      inspectionId = serverInspectionId;
    } else if (_appStorage.currentInspection != null) {
      inspectionId = _appStorage.currentInspection?.inspectionId;
    }

    headerText = partnerName;
    if (commodityName!.isEmpty) {
      commodityText = "";
    } else {
      commodityText = commodityName;
      varietyText = itemSKU;
      getSpecTable();
    }

    super.onInit();
  }

  Future<void> getSpecTable() async {
    _appStorage.specificationAnalyticalList =
        await dao.getSpecificationAnalyticalFromTable(
      specificationNumber!,
      specificationVersion!,
    );
    await setSpecAnalyticalTable();
    hasInitialised.value = true;
  }

  Future<void> setSpecAnalyticalTable() async {
    if (_appStorage.specificationAnalyticalList == null) {
      update();
      return;
    }
    listSpecAnalyticals.value = _appStorage.specificationAnalyticalList ?? [];
    for (var specAnalytical in listSpecAnalyticals) {
      if (specAnalytical.specTargetTextDefault == "Y") {
        specAnalytical.specTargetTextDefault = "Yes";
      } else if (specAnalytical.specTargetTextDefault == "N") {
        specAnalytical.specTargetTextDefault = "No";
      }
    }

    listSpecAnalyticals.sort((a, b) => a.order!.compareTo(b.order!));

    for (final item in listSpecAnalyticals) {
      SpecificationAnalyticalRequest reqobj = SpecificationAnalyticalRequest(
        analyticalID: item.analyticalID,
        analyticalName: item.description,
        specTypeofEntry: item.specTypeofEntry,
        isPictureRequired: item.isPictureRequired,
        specMin: item.specMin,
        specMax: item.specMax,
        description: item.description,
        inspectionResult: item.inspectionResult,
      );

      final SpecificationAnalyticalRequest? dbobj =
          await dao.findSpecAnalyticalObj(inspectionId, item.analyticalID!);

      if (dbobj != null) {
        if (dbobj.comment != null && dbobj.comment!.isNotEmpty) {
          reqobj = reqobj.copyWith(comment: dbobj.comment);
        }
        reqobj = reqobj.copyWith(comply: dbobj.comply);

        if (item.specTypeofEntry == 1) {
          reqobj = reqobj.copyWith(sampleNumValue: dbobj.sampleNumValue);
        } else if (item.specTypeofEntry == 2) {
          for (int i = 0; i < operatorList.length; i++) {
            if (dbobj.sampleTextValue == operatorList[i]) {
              reqobj = reqobj.copyWith(sampleTextValue: operatorList[i]);
            }
          }
        } else if (item.specTypeofEntry == 3) {
          reqobj = reqobj.copyWith(sampleNumValue: dbobj.sampleNumValue);
          for (int i = 0; i < operatorList.length; i++) {
            if (dbobj.sampleTextValue == operatorList[i]) {
              reqobj = reqobj.copyWith(sampleTextValue: operatorList[i]);
            }
          }
        }
      } else {
        reqobj = reqobj.copyWith(comply: "N/A");
      }
      listSpecAnalyticalsRequest.add(reqobj);
      dbobjList.add(dbobj);
    }

    Future.delayed(const Duration(milliseconds: 100)).then((value) {
      update();
    });
  }
}
