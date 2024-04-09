import 'dart:async';

import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
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
  late final String itemSKU;
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

  final ApplicationDao dao = ApplicationDao();

  int? inspectionId;

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

    super.onInit();
    unawaited(
      () async {
        await specificationSelection();

        /*if (serverInspectionID < 0) {
          if (!completed && !partial_completed) {
            createNewInspection(
                item_Sku,
                item_Sku_Id,
                lot_No,
                pack_Date,
                specificationNumber,
                specificationVersion,
                specificationName,
                specificationTypeName,
                sampleSizeByCount,
                gtin,
                po_number,
                poLineNo,
                item_Sku_Name);
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
                item_Sku,
                item_Sku_Id,
                po_number,
                0,
                "",
                item_Sku_Name);
          }
          inspectionId = serverInspectionID;
        }

        hasInitialised.value = true;
        _appStorage.specificationAnalyticalList =
            await dao.getSpecificationAnalyticalFromTable(
                specificationNumber, specificationVersion);
        setSpecAnalyticalTable();*/
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

  /*Future<void> createNewInspection(
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

  void setSpecAnalyticalTable() {
    if (AppInfo.specificationAnalyticalList == null) {
      return;
    }
    listSpecAnalyticals = AppInfo.specificationAnalyticalList;

    listSpecAnalyticals.sort((a, b) => a.order.compareTo(b.order));

    TableLayout tableLayoutSpecAttributes =
    findViewById(R.id.tablelayout_spec_attributes);
    LayoutInflater inflater = getSystemService(Context.LAYOUT_INFLATER_SERVICE);

    int row_no = 1;
    for (SpecificationAnalytical item in listSpecAnalyticals) {
      final SpecificationAnalyticalRequest reqobj = SpecificationAnalyticalRequest();

      final SpecificationAnalyticalRequest? dbobj =
      dao.findSpecAnalyticalObj(inspectionId, item.analyticalID);

      reqobj.analyticalID = item.analyticalID;
      reqobj.analyticalName = item.description;
      reqobj.specTypeofEntry = item.specTypeofEntry;
      reqobj.pictureRequired = item.pictureRequired;
      reqobj.specMin = item.specMin;
      reqobj.specMax = item.specMax;
      reqobj.description = item.description;
      reqobj.inspectionResult = item.inspectionResult;

      TableRow row = inflater.inflate(R.layout.tablerow_specattributes_shortform, null) as TableRow;

      TextView? textViewName = row.findViewById(R.id.textview_name);
      if (textViewName != null) {
        textViewName.text = item.description;
        textViewName.setTextColor(getResources().getColor(R.color.black));
      }

      final ImageView comment = row.findViewById(R.id.imageview_comment) as ImageView;

      if (dbobj != null) {
        if (dbobj.comment != null && dbobj.comment != "") {
          reqobj.comment = dbobj.comment;
          comment.setImageDrawable(getResources().getDrawable(R.drawable.spec_comment_added));
        }
      } else {
        comment.setImageDrawable(getResources().getDrawable(R.drawable.spec_comment));
      }

      comment.setOnClickListener((v) {
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
      });

      // Rest of the code...

      tableLayoutSpecAttributes.addView(row);
      row_no++;
    }
  }
*/
}
