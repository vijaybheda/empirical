import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/purchase_order_details.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/dialogs/custom_listview_dialog.dart';
import 'package:pverify/utils/utils.dart';

class QCDetailsShortFormScreenController extends GetxController {
  final PartnerItem partner;

  late final int serverInspectionID;
  late final bool completed;
  late final bool partial_completed;
  late final String partnerName;
  late final int partnerID;
  late final String carrierName;
  late final int carrierID;
  late final String commodityName;
  late final int commodityID;
  late final int sampleSizeByCount;
  late final String inspectionResult;
  late final String itemSKU, itemSkuName, lot_No;
  late final String poNumber;
  late final String specificationNumber;
  late final String specificationVersion;
  late final String specificationName;
  late final String specificationTypeName;
  late final String selectedSpecification;
  late final String productTransfer;
  late final String callerActivity;
  late final String is1stTimeActivity;
  late final bool isMyInspectionScreen;
  late String gtin,
      gln,
      sealNumber,
      varietyName,
      varietySize,
      itemUniqueId,
      lot_size;
  late int poLineNo, varietyId, gradeId, item_Sku_Id;

  final ApplicationDao dao = ApplicationDao();

  int? inspectionId;

  final TextEditingController gtinController = TextEditingController();
  final TextEditingController glnController = TextEditingController();
  final TextEditingController lotNoController = TextEditingController();
  final TextEditingController packDateController = TextEditingController();
  final TextEditingController qtyShippedController = TextEditingController();

  DateTime? packDate;

  UOMItem? uom;

  List<UOMItem> uomList = <UOMItem>[].obs;

  RxList<SpecificationAnalytical> listSpecAnalyticals =
      <SpecificationAnalytical>[].obs;

  int? qcID;

  String dateTypeDesc = '';

  QCDetailsShortFormScreenController({
    required this.partner,
  });

  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  final AppStorage _appStorage = AppStorage.instance;

  RxBool hasInitialised = false.obs;

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments not allowed');
    }

    serverInspectionID = args['serverInspectionID'] ?? -1;
    partnerName = args['partnerName'] ?? '';
    partnerID = args['partnerID'] ?? 0;
    carrierName = args['carrierName'] ?? '';
    carrierID = args['carrierID'] ?? 0;
    commodityName = args['commodityName'] ?? '';
    commodityID = args['commodityID'] ?? 0;
    sampleSizeByCount = args['sampleSizeByCount'] ?? 0;
    inspectionResult = args['inspectionResult'] ?? '';
    itemSKU = args['itemSKU'] ?? '';
    poNumber = args['poNumber'] ?? '';
    specificationNumber = args['specificationNumber'] ?? '';
    specificationVersion = args['specificationVersion'] ?? '';
    specificationName = args['specificationName'] ?? '';
    specificationTypeName = args['specificationTypeName'] ?? '';
    selectedSpecification = args['selectedSpecification'] ?? '';
    productTransfer = args['productTransfer'] ?? '';
    callerActivity = args['callerActivity'] ?? '';
    is1stTimeActivity = args['is1stTimeActivity'] ?? '';
    isMyInspectionScreen = args['isMyInspectionScreen'] ?? false;
    completed = args['completed'] ?? false;
    partial_completed = args['partial_completed'] ?? false;

    gtin = args['gtin'] ?? '';
    itemSkuName = args['item_Sku_Name'] ?? '';
    lot_size = args['lot_size'] ?? '';
    sealNumber = args['seal_number'] ?? '';
    varietyName = args['varietyName'] ?? '';
    varietySize = args['varietySize'] ?? '';
    varietyId = args['varietyId'] ?? 0;
    gradeId = args['gradeId'] ?? 0;
    itemUniqueId = args['item_unique_id'] ?? '';
    poLineNo = args['poLineNo'] ?? 0;
    item_Sku_Id = args['item_Sku_Id'] ?? 0;

    setUOMSpinner();
    super.onInit();
    unawaited(
      () async {
        await specificationSelection();

        if (serverInspectionID < 0) {
          if (!completed && !partial_completed) {
            createNewInspection(
                itemSKU,
                item_Sku_Id,
                lot_No,
                packDate,
                specificationNumber,
                specificationVersion,
                specificationName,
                specificationTypeName,
                sampleSizeByCount,
                gtin,
                poNumber,
                poLineNo,
                itemSkuName);
          }
        } else {
          if (callerActivity != "NewPurchaseOrderDetailsActivity") {
            await dao.updateInspection(
                serverInspectionID,
                commodityID,
                commodityName,
                varietyId,
                varietyName,
                gradeId,
                specificationNumber,
                specificationVersion,
                specificationName,
                specificationTypeName,
                sampleSizeByCount,
                itemSKU,
                item_Sku_Id,
                poNumber,
                0,
                "",
                itemSkuName);
          }
          inspectionId = serverInspectionID;
        }

        hasInitialised.value = true;
        loadFieldsFromDB();
        _appStorage.specificationAnalyticalList =
            await dao.getSpecificationAnalyticalFromTable(
                specificationNumber, specificationVersion);
        setSpecAnalyticalTable();
      }(),
    );
  }

  Future<void> specificationSelection() async {
    bool isOnline = globalConfigController.hasStableInternet.value;
    if (callerActivity == "TrendingReportActivity" || isMyInspectionScreen) {
      await Utils().offlineLoadCommodityVarietyDocuments(
          specificationNumber, specificationVersion);

      if (_appStorage.commodityVarietyData != null &&
          _appStorage.commodityVarietyData!.exceptions.isNotEmpty) {
        if (is1stTimeActivity != "") {
          if (is1stTimeActivity == "PurchaseOrderDetailsActivity") {
            CustomListViewDialog customDialog = CustomListViewDialog(
              Get.context!,
              (selectedValue) {},
            );
            customDialog.setCanceledOnTouchOutside(false);
            customDialog.show();
          }
        }
      }
    } else {
      if (_appStorage.specificationByItemSKUList != null &&
          _appStorage.specificationByItemSKUList!.isNotEmpty) {
        SpecificationByItemSKU? specificationByItemSKU =
            _appStorage.specificationByItemSKUList!.first;
        specificationNumber = specificationByItemSKU.specificationNumber!;
        specificationVersion = specificationByItemSKU.specificationVersion!;
        specificationName = specificationByItemSKU.specificationName!;
        selectedSpecification = specificationByItemSKU.specificationName!;
        specificationTypeName = specificationByItemSKU.specificationTypeName!;
        sampleSizeByCount = specificationByItemSKU.sampleSizeByCount ?? 0;

        await Utils().offlineLoadCommodityVarietyDocuments(
            specificationNumber, specificationVersion);

        if (_appStorage.commodityVarietyData != null &&
            _appStorage.commodityVarietyData!.exceptions.isNotEmpty) {
          if (is1stTimeActivity != "") {
            if (is1stTimeActivity == "PurchaseOrderDetailsActivity") {
              CustomListViewDialog customDialog =
                  CustomListViewDialog(Get.context!, (selectedValue) {});
              customDialog.setCanceledOnTouchOutside(false);
              customDialog.show();
            }
          }
        }
      }
    }
  }

  Future<void> scanBarcode(
      {required Function(String scanResult)? onScanResult}) async {
    // TODO: Implement scanBarcode
  }

  Future selectDate(BuildContext context,
      {DateTime? firstDate,
      DateTime? lastDate,
      required Function(DateTime selectedDate) onDateSelected}) async {
    DateTime now = DateTime.now();
    // show Adaptive Date Picker
    DateTime? selectedDate = await showDatePicker(
      context: context,
      firstDate: firstDate ?? now,
      initialDate: packDate ?? now,
      currentDate: now,
      lastDate: lastDate ?? now.add(const Duration(days: 365)),
    );

    if (selectedDate != null) {
      packDate = selectedDate;
      onDateSelected(selectedDate);
    }
    return selectedDate;
  }

  Future<void> setUOMSpinner() async {
    _appStorage.uomList = await JsonFileOperations.parseUOMJson() ?? [];

    uomList = _appStorage.uomList;
    uomList.sort((a, b) => a.uomName!.compareTo(b.uomName!));

    SchedulerBinding.instance.addPostFrameCallback((_) {
      update();
    });
  }

  Future<void> createNewInspection(
      item_sku,
      item_sku_id,
      lot_no,
      pack_date,
      String specificationNumber,
      String specificationVersion,
      String specificationName,
      String specificationTypeName,
      int sampleSizeByCount,
      gtin,
      po_number,
      poLineNo,
      item_sku_name) async {
    try {
      _appStorage.currentInspection = Inspection(
        userId: _appStorage.getLoginData()!.id,
        partnerId: partnerID,
        carrierId: carrierID,
        createdTime: DateTime.now().millisecondsSinceEpoch,
        complete: false,
        downloadId: -1,
        commodityId: commodityID,
        itemSKU: itemSKU,
        specificationName: specificationName,
        specificationNumber: specificationNumber,
        specificationVersion: specificationVersion,
        specificationTypeName: specificationTypeName,
        sampleSizeByCount: sampleSizeByCount,
        packDate: pack_date,
        itemSKUId: item_sku_id,
        commodityName: commodityName,
        lotNo: lot_no,
        poNumber: po_number,
        partnerName: partnerName,
        itemSkuName: item_sku_name,
        poLineNo: poLineNo,
        rating: 0,
      );
      inspectionId = await dao.createInspection(_appStorage.currentInspection!);
      _appStorage.currentInspection?.inspectionId = inspectionId;
      serverInspectionID = inspectionId!;
    } catch (e) {
      print(e.toString());
      return;
    }
  }

  Future<void> setSpecAnalyticalTable() async {
    if (_appStorage.specificationAnalyticalList == null) {
      return;
    }
    listSpecAnalyticals.value = _appStorage.specificationAnalyticalList ?? [];

    listSpecAnalyticals.sort((a, b) => a.order!.compareTo(b.order!));

    int row_no = 1;
    for (SpecificationAnalytical item in listSpecAnalyticals) {
      final SpecificationAnalyticalRequest reqobj =
          SpecificationAnalyticalRequest();

      final SpecificationAnalyticalRequest? dbobj =
          await dao.findSpecAnalyticalObj(inspectionId!, item.analyticalID!);

      reqobj.copyWith(
        analyticalID: item.analyticalID,
        analyticalName: item.description,
        specTypeofEntry: item.specTypeofEntry,
        isPictureRequired: item.isPictureRequired,
        specMin: item.specMin,
        specMax: item.specMax,
        description: item.description,
        inspectionResult: item.inspectionResult,
      );

      /*comment.setOnClickListener((v) {
        AlertDialog.Builder alert = AlertDialog.Builder(QC_Details_short_form.this);
        EditText edittext = EditText(QC_Details_short_form.this);
        edittext.setHorizontallyScrolling(false);
        edittext.setMaxLines(int.maxValue);

        if (reqobj.comment != null) {
          edittext.setText(reqobj.comment);
        }
        alert.setTitle(getString(R.string.comments));
        alert.setView(edittext);
        alert.setPositiveButton(getString(R.string.save), (dialog, whichButton) {
          String commentvalue = edittext.text.toString();
          reqobj.comment = commentvalue;
          if (commentvalue != "")
            comment.setImageDrawable(getResources().getDrawable(R.drawable.spec_comment_added));
          else
            comment.setImageDrawable(getResources().getDrawable(R.drawable.spec_comment));
        });
        alert.setNegativeButton(getString(R.string.cancel), (dialog, whichButton) {
          dialog.dismiss();
        });
        alert.show();
      });*/

      row_no++;
    }
  }

  void loadFieldsFromDB() async {
    ApplicationDao dao = ApplicationDao();

    QualityControlItem? qualityControlItems =
        await dao.findQualityControlDetails(inspectionId!);

    if (_appStorage.getLoginData() != null) {
      List<PurchaseOrderDetails> purchaseOrderDetails =
          await dao.getPODetailsFromTable(
              poNumber, _appStorage.getLoginData()!.supplierId!);

      if (purchaseOrderDetails.isNotEmpty) {
        for (var i = 0; i < purchaseOrderDetails.length; i++) {
          if (item_Sku_Id == purchaseOrderDetails[i].itemSkuId) {
            qtyShippedController.text =
                purchaseOrderDetails[i].quantity.toString();
          }
        }
      }
    }

    if (qualityControlItems != null) {
      qcID = qualityControlItems.qcID;
      qtyShippedController.text = qualityControlItems.qtyShipped.toString();
      if (qualityControlItems.dateType != "") {
        dateTypeDesc = getDateTypeDesc(qualityControlItems.dateType);
        packDateController.text = dateTypeDesc;
      }
      if (qualityControlItems.packDate != null &&
          qualityControlItems.packDate! > 0) {
        packDateController.text =
            getDateStingFromTime(qualityControlItems.packDate ?? 0);
      } else {
        packDateController.text = "";
      }

      lotNoController.text = qualityControlItems.lot ?? '';
      gtinController.text = qualityControlItems.gtin ?? '';
    }
  }

  String getDateTypeDesc(String? dateType) {
    switch (dateType) {
      case '11':
        return 'Production Date';
      case '12':
        return 'Due Date';
      case '13':
        return 'Pack Date';
      case '15':
        return 'Best Before Date';
      case '16':
        return 'Sell By Date';
      case '17':
        return 'Expiration Date';
      default:
        return 'Unknown Date Type';
    }
  }

  String getDateStingFromTime(int timestamp) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('yyyy-MM-dd').format(date);
  }
}
