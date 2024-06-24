import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/new_purchase_order_details_controller.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/new_purchase_order_item.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/result_rejection_details.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/extensions/int_extension.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class NewPurchaseOrderListViewItem extends StatefulWidget {
  const NewPurchaseOrderListViewItem({
    super.key,
    required this.goodsItem,
    required this.onRatingChanged,
    required this.onLotNumberChanged,
    required this.onPackDateChanged,
    required this.onQuantityShippedChanged,
    required this.onQuantityRejectedChanged,
    required this.onInspectPressed,
    required this.onInfoPressed,
    required this.onBrandedChanged,
    required this.partnerID,
    required this.position,
    required this.poNumber,
    required this.sealNumber, 
    required this.controller,
  });

  final Function(double) onRatingChanged;
  final Function(String) onLotNumberChanged;
  final Function(String) onPackDateChanged;
  final Function(int) onQuantityShippedChanged;
  final Function(int) onQuantityRejectedChanged;
  final Function() onInspectPressed;
  final Function() onInfoPressed;
  final Function(bool) onBrandedChanged;
  final NewPurchaseOrderDetailsController controller;

  final int partnerID;
  final String poNumber;
  final String sealNumber;
  final int position;

  final NewPurchaseOrderItem goodsItem;

  @override
  State<NewPurchaseOrderListViewItem> createState() =>
      _NewPurchaseOrderListViewItemState();
}

class _NewPurchaseOrderListViewItemState
    extends State<NewPurchaseOrderListViewItem> {
  late TextEditingController lotNumberController;

  late TextEditingController qtyRejectedController;

  late TextEditingController qtyShippedController;
  late TextEditingController packDateController;

  NewPurchaseOrderDetailsController get controller => widget.controller; 
  AppStorage get appStorage => controller.appStorage;
  ApplicationDao get dao => controller.dao;
  PartnerItemSKUInspections? partnerItemSKU;
  int? inspectionId;
  bool isComplete = false;

  bool isPartialComplete = false;
  FocusNode qtyRejectedFocusNode = FocusNode();

  Inspection? inspection;
  bool informationIconEnabled = true;
  String? resultButton;
  Color resultButtonColor = AppColors.white;

  Icon informationIcon = Icon(
    Icons.info_rounded,
    color: AppColors.white,
    size: 40,
  );

  bool editPencilVisibility = false;
  bool layoutQtyRejectedVisibility = false;
  bool etQtyShippedEnabled = false;

  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;
  RxBool valueAssigned = false.obs;
  bool fromSetState = false;

  late TextEditingController _lotNumberController;
  late TextEditingController _packDateController;
  late TextEditingController _qtyShippedController;
  late TextEditingController _qtyRejectedController;

  int? serverInspectionID;

  @override
  void dispose() {
    _lotNumberController.dispose();
    _packDateController.dispose();
    _qtyShippedController.dispose();
    _qtyRejectedController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    lotNumberController = TextEditingController();
    qtyRejectedController = TextEditingController();
    qtyShippedController = TextEditingController();
    packDateController = TextEditingController();
    packDateController.text = widget.goodsItem.packDate ?? '';
    lotNumberController.text = widget.goodsItem.lotNumber ?? '';

    _lotNumberController =
        TextEditingController(text: widget.goodsItem.lotNumber);
    _packDateController =
        TextEditingController(text: widget.goodsItem.packDate);
    _qtyShippedController = TextEditingController();
    _qtyRejectedController = TextEditingController();

    etQtyShippedEnabled = false;
    asyncTask();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      asyncTask(true);
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    asyncTask();
    super.didChangeDependencies();
  }

  Future<void> getSpecifications() async {
    appStorage.specificationByItemSKUList =
        await dao.getSpecificationByItemSKUFromTable(
            widget.partnerID, widget.goodsItem.sku!, widget.goodsItem.sku!);
    return;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
      child: Obx(() {
        if (!valueAssigned.value) {
          return buildShimmer();
        }
        return Card(
          color: _getBackgroundColor(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.goodsItem.description ?? '',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'SKU: ${widget.goodsItem.sku}',
                  style: TextStyle(
                      fontSize: 16, decoration: TextDecoration.underline),
                ),
                if (widget.goodsItem.ftl == "1")
                  Text('FTL', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lotNumberController,
                        decoration: InputDecoration(labelText: 'Lot Number'),
                        onChanged: widget.onLotNumberChanged,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _packDateController,
                        decoration: InputDecoration(labelText: 'Pack Date'),
                        onChanged: widget.onPackDateChanged,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtyShippedController,
                        decoration: InputDecoration(labelText: 'Qty Shipped'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => widget
                            .onQuantityShippedChanged(int.tryParse(value) ?? 0),
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _qtyRejectedController,
                        decoration: InputDecoration(labelText: 'Qty Rejected'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => widget.onQuantityRejectedChanged(
                            int.tryParse(value) ?? 0),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RatingBar.builder(
                      initialRating: widget.goodsItem.rating,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 30,
                      itemBuilder: (context, _) => Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) async {
                        //
                        String brandedResult = "";
                        rating = rating.ceilToDouble();

                        List<SpecificationByItemSKU>
                            specificationByItemSKUList =
                            await dao.getSpecificationByItemSKUFromTable(
                          appStorage
                              .selectedItemSKUList[widget.position].partnerId!,
                          appStorage.selectedItemSKUList[widget.position].sku!,
                          appStorage.selectedItemSKUList[widget.position].sku!,
                        );

                        if (specificationByItemSKUList != null &&
                            specificationByItemSKUList.isNotEmpty) {
                          // ratingBar.setIsIndicator(false);
                          String? specificationNumber =
                              specificationByItemSKUList[0].specificationNumber;
                          String? specificationVersion =
                              specificationByItemSKUList[0]
                                  .specificationVersion;
                          String? specificationName =
                              specificationByItemSKUList[0].specificationName;
                          String? specificationTypeName =
                              specificationByItemSKUList[0]
                                  .specificationTypeName;
                          int? sampleSizeByCount =
                              specificationByItemSKUList[0].sampleSizeByCount;

                          if (inspectionId!= null && inspectionId! <= 0) {

                            // we're creating a new inspection
                            if (!isComplete && !isPartialComplete) {
                              await createNewInspection(
                                controller.inspectionsList.elementAt(widget.position).sku!,
                                appStorage.selectedItemSKUList.elementAt(widget.position).id!,
                                controller.inspectionsList.elementAt(widget.position).lotNumber!,
                                controller.inspectionsList.elementAt(widget.position).packDate!,
                                specificationNumber!,
                                specificationVersion!,
                                specificationName!,
                                specificationTypeName!,
                                sampleSizeByCount!,
                                "",
                                po_number!,
                                rating!,
                                appStorage.selectedItemSKUList.elementAt(widget.position).commodityID!,
                                appStorage.selectedItemSKUList.elementAt(widget.position).commodityName!,
                                poLineNo,
                                appStorage.selectedItemSKUList.elementAt(widget.position).partnerId!,
                                appStorage.selectedItemSKUList.elementAt(widget.position).partnerName!,
                                controller.inspectionsList.elementAt(widget.position).description!,
                              );

                              inspectionId = serverInspectionID;

                            }
                          } else {
                            await dao.updateInspection(
                              serverInspectionID: inspectionId!,
                              commodityID: appStorage.selectedItemSKUList.elementAt(widget.position).commodityID,
                              commodityName: appStorage.selectedItemSKUList.elementAt(widget.position).commodityName,
                              varietyId: null,
                              varietyName: "",
                              gradeId: 0,
                              specificationNumber: specificationNumber,
                              specificationVersion: specificationVersion,
                              specificationName: specificationName,
                              specificationTypeName: specificationTypeName,
                              sampleSizeByCount: sampleSizeByCount,
                              itemSKU: controller.inspectionsList.elementAt(widget.position).sku,
                              itemSKUId: appStorage.selectedItemSKUList.elementAt(widget.position).id,
                              po_number: po_number,
                              cteType: "",
                              itemSkuName: controller.inspectionsList.elementAt(widget.position).description,
                              lotNo: appStorage.selectedItemSKUList[widget.position].lotNo,
                              rating: rating,
                            );
                          }

                          if (rating > 0) {
                            informationIcon.setEnabled(true);
                            layoutQuantityRejected.setVisibility(View.VISIBLE);
                            edit_pencil.setEnabled(true);

                            QualityControlItem? qualityControlItems = await dao.findQualityControlDetails(inspectionId!);
                            if (qualityControlItems != null) {

                              if (StringUtil.isNullOrEmpty(qualityControlItems.qcComments)) {
                                //comment.setText("");
                                icon_comment.setImageDrawable(context.getDrawable(R.drawable.spec_comment));
                              } else {
                                //comment.setText(defectList.elementAt(position).getComment());
                                icon_comment.setImageDrawable(context.getDrawable(R.drawable.spec_comment_added));
                              }
                            }
                          }

                          appStorage.specificationAnalyticalList = await dao.getSpecificationAnalyticalFromTable(specificationNumber, specificationVersion);
                          SpecificationAnalytical? specAnalyticalItem;

                          if (appStorage.specificationAnalyticalList != null) {

                            for (final SpecificationAnalytical item in (appStorage.specificationAnalyticalList ?? [])) {

                              if (item.analyticalName?.contains("Quality Check") ?? false) {

                                specAnalyticalItem = item;

                                if (picsFromDB == null || picsFromDB.isEmpty()) {

                                  if ((item.isPictureRequired ?? false) && (rating > 0 && rating <= 2)) {

                                    AlertDialog.Builder alertDialogBuilder = new AlertDialog.Builder(context);
                                    alertDialogBuilder.setTitle(R.string.alert);
                                    alertDialogBuilder.setMessage("At least one picture is required");
                                    alertDialogBuilder.setCancelable(false);
                                    alertDialogBuilder.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
                                    @Override
                                    public void onClick(DialogInterface dialog, int which) {
                                    //hasErrors2 = false;
                                    dialog.dismiss();
                                    }
                                    });
                                    AlertDialog dialog = alertDialogBuilder.create();
                                    dialog.show();
                                  }
                                }

                                //dao.deleteSpecAttributesByInspectionId(inspectionId!);
                                final SpecificationAnalyticalRequest? dbobj = await dao.findSpecAnalyticalObj(inspectionId!, item.analyticalID);
                                if (rating >= 0 && rating <= 2) {

                                  if (dbobj != null) {
                                  await dao.updateSpecificationAttributeNumValue(inspectionId!, item.analyticalID, (int) rating, "N");
                                  } else {
                                  await dao.createSpecificationAttributes(inspectionId!, item.analyticalID, "No", (int) rating,
                                        "N", "", item.analyticalName, item.isPictureRequired, item.inspectionResult);
                                  }
                                } else {
                                  if (dbobj != null) {
                                  await dao.updateSpecificationAttributeNumValue(inspectionId!, item.analyticalID, (int) rating, "Y");
                                  } else {
                                  await dao.createSpecificationAttributes(inspectionId!, item.analyticalID, "Yes", (int) rating,
                                        "Y", "", item.analyticalName, item.isPictureRequired, item.inspectionResult);
                                  }
                                }
                              } else if (item.analyticalName.contains("Branded")) {
                                final SpecificationAnalyticalRequest dbobj = await dao.findSpecAnalyticalObj(inspectionId!, item.analyticalID);

                                String comply = "Y";
                                if (comply.equals("Y")) {
                                  comply = "Y";
                                } else {
                                  comply = "N";
                                }

                                if (item.inspectionResult!.equals("Y") && comply.equals("N")) {
                                  brandedResult = "RJ";
                                }

                                if (isBranded != null) {
                                  if (dbobj != null) {
                                  await dao.updateSpecificationAttributeBrandedValue(inspectionId!, item.analyticalID, isBranded, comply);
                                  } else {
                                  await dao.createSpecificationAttributes(inspectionId!, item.analyticalID, isBranded, 0,
                                        comply, "", item.analyticalName, item.isPictureRequired, item.inspectionResult);
                                  }
                                }
                              } else {
                                final SpecificationAnalyticalRequest? dbobj = await dao.findSpecAnalyticalObj(inspectionId!, item.analyticalID);
                                if (dbobj != null) {
                                  //dao.updateSpecificationAttributeNumValue(inspectionId!, item.analyticalID, (int) rating, "Y");
                                } else {

                                  if (item.specTargetTextDefault.equals("Y")) {

                                  await dao.createSpecificationAttributes(inspectionId!, item.analyticalID, "Yes", 0,
                                        "Y", "", item.analyticalName, item.isPictureRequired, item.inspectionResult);

                                  } else if (item.specTargetTextDefault.equals("N")) {

                                  await dao.createSpecificationAttributes(inspectionId!, item.analyticalID, "No", 0,
                                        "Y", "", item.analyticalName, item.isPictureRequired, item.inspectionResult);

                                  } else if (item.specTargetTextDefault.equals("N/A")) {

                                  await dao.createSpecificationAttributes(inspectionId!, item.analyticalID, "N/A", 0,
                                        "N/A", "", item.analyticalName, item.isPictureRequired, item.inspectionResult);
                                  }
                                }
                              }
                            }
                          }
                          await dao.createOrUpdateInspectionSpecification(inspectionId!, specificationNumber,
                              specificationVersion, specificationName);

                          await dao.createPartnerItemSKU(
                              appStorage.selectedItemSKUList.elementAt(widget.position).partnerId,
                              appStorage.selectedItemSKUList.elementAt(widget.position).sku,
                              controller.inspectionsList.elementAt(widget.position).lotNumber,
                              "",
                              inspectionId!,
                              "",
                              appStorage.selectedItemSKUList.elementAt(widget.position).uniqueItemId,
                              appStorage.selectedItemSKUList.elementAt(widget.position).poLineNo,
                              po_number);

                          await dao.copyTempTrailerTemperaturesToInspectionTrailerTemperatureTableByPartnerID(inspectionId!, carrierID, po_number);
                          await dao.copyTempTrailerTemperaturesDetailsToInspectionTrailerTemperatureDetailsTableByPartnerID(inspectionId!, carrierID, po_number);

                          int? qcID;
                          int qtyRejected = 0;
                          int qtyReceived = 0;
                          int qtyShipped = 0;

                          QualityControlItem? qualityControlItems = await dao.findQualityControlDetails(inspectionId!);
                          if (qualityControlItems != null) {
                            qcID = qualityControlItems.qcID;
                            qtyShipped = qualityControlItems.qtyShipped!;
                            qtyRejected = qualityControlItems.qtyRejected!;
                            qtyReceived = qualityControlItems.qtyReceived!;
                          }
                          // No quality control id, create a new one in the database.
                          if (qcID == null) {

                            if (appStorage.selectedItemSKUList.elementAt(widget.position).quantity! > 0) {

                              qtyShipped = appStorage.selectedItemSKUList.elementAt(widget.position).quantity!;

                              if (rating >= 0 && rating <= 2) {
                                qtyRejected = qtyShipped;
                                qtyReceived = 0;

                              } else {
                                qtyRejected = 0;
                                qtyReceived = qtyShipped;
                              }

                              qcID = await dao.createQualityControl(
                                inspectionId: inspectionId!,
                                brandID: 0,
                                originID: 0,
                                qtyShipped: qtyShipped,
                                uomQtyShippedID: appStorage.selectedItemSKUList.elementAt(widget.position).getQuantityUOM(),
                                poNumber: po_number,
                                pulpTempMin: 0,
                               pulpTempMax: 0,
                               recorderTempMin: 0,
                               recorderTempMax: 0,
                               rpc: "",
                               claimFiledAgainst: "",
                               qtyRejected: qtyRejected,
                               uomQtyRejectedID: appStorage.selectedItemSKUList.elementAt(widget.position).getQuantityUOM(),
                               reasonID: 0,
                               qcComments: "",
                               qtyReceived: qtyReceived,
                               uomQtyReceivedID: appStorage.selectedItemSKUList.elementAt(widget.position).getQuantityUOM(),
                               specificationName: specificationName,
                               packDate: 0,
                               seal_no: appStorage.current_seal_number,
                               lot_no: controller.inspectionsList.elementAt(widget.position).lotNumber,
                               qcdOpen1: null,
                               qcdOpen2: "",
                               qcdOpen3: "",
                               qcdOpen4: "",
                               workDate: 0,
                               gtin: null,
                               lot_size: 0,
                               shipDate: 0,
                                dateType: "",
                                gln: '',
                                glnType: '',
                              );

                            await dao.updateItemSKUInspectionComplete(inspectionId!, true);
                            await dao.updateInspectionComplete(inspectionId!, true);
                            await dao.updateSelectedItemSKU(inspectionId!,
                                appStorage.selectedItemSKUList.elementAt(widget.position).partnerId,
                                  appStorage.selectedItemSKUList.elementAt(widget.position).id,
                                  appStorage.selectedItemSKUList.elementAt(widget.position).sku,
                                  appStorage.selectedItemSKUList.elementAt(widget.position).uniqueItemId, true, false);

                              Utils.setInspectionUploadStatus(inspectionId!, Consts.INSPECTION_UPLOAD_READY);

                              isComplete = true;
                              isPartialComplete = false;

                              et_qtyShipped.setText(String.valueOf(qtyShipped));
                              et_qtyRejected.setText(String.valueOf(qtyRejected));

                            } else {

                              String qtyShippedString = et_qtyShipped.getText().toString();
                              String qtyRejectedString = et_qtyRejected.getText().toString();

                              if (qtyShippedString != null && !qtyShippedString.equals("")) {
                                qtyShipped = int.parse(qtyShippedString);
                                qtyReceived = qtyShipped;
                              }

                              if (qtyRejectedString != null && !qtyRejectedString.equals("")) {
                                qtyRejected = int.parse(qtyRejectedString);
                                qtyReceived = qtyShipped - qtyRejected;
                              }

                              qcID = await dao.createQualityControl(
                                  inspectionId: inspectionId!, 
                                  brandID: 0, 
                                  originID: 0,
                                  qtyShipped: qtyShipped,
                                  uomQtyShippedID: 0, 
                                  poNumber: po_number,
                                  pulpTempMin: 0, 
                                  pulpTempMax: 0, 
                                  recorderTempMin: 0, 
                                  recorderTempMax: 0, 
                                  rpc: "", 
                                  claimFiledAgainst: "",
                                  qtyRejected: qtyRejected,
                                  uomQtyRejectedID: 0, 
                                  reasonID: 0, 
                                  qcComments: "", 
                                  qtyReceived: qtyReceived,
                                  uomQtyReceivedID: 0, 
                                  specificationName: specificationName ?? '',
                                  packDate: 0, 
                                  seal_no: appStorage.currentSealNumber!, 
                                  lot_no: controller.inspectionsList.elementAt(widget.position).lotNumber ?? '', 
                                  qcdOpen1: null,
                                  qcdOpen2: "",
                                  qcdOpen3: "",
                                  qcdOpen4: "",
                                  workDate: 0, 
                                  gtin: null, 
                                  lot_size: 0, 
                                  shipDate: 0, 
                                  dateType: "",
                              );

                            await dao.updateItemSKUInspectionComplete(inspectionId!, false);
                            await dao.updateInspectionComplete(inspectionId!, false);
                            await dao.updateSelectedItemSKU(inspectionId!,
                                  int.parse(appStorage.selectedItemSKUList.elementAt(widget.position).partnerId),
                                  appStorage.selectedItemSKUList.elementAt(widget.position).id,
                                  appStorage.selectedItemSKUList.elementAt(widget.position).sku,
                                  appStorage.selectedItemSKUList.elementAt(widget.position).uniqueItemId, false, true);
                              isPartialComplete = true;
                              isComplete = false;

                              et_qtyShipped.setText(String.valueOf(qtyShipped));
                              et_qtyRejected.setText(String.valueOf(qtyRejected));

                            }
                          } else {
                          await dao.updateItemSKUInspectionComplete(inspectionId!, true);
                          await dao.updateInspectionComplete(inspectionId!, true);

                          await dao.updateSelectedItemSKU(inspectionId!,
                                int.parse(appStorage.selectedItemSKUList.elementAt(widget.position).partnerId),
                                appStorage.selectedItemSKUList.elementAt(widget.position).id!,
                                appStorage.selectedItemSKUList.elementAt(widget.position).sku!,
                                appStorage.selectedItemSKUList.elementAt(widget.position).uniqueItemId!, true, false);

                            isComplete = true;
                            isPartialComplete = false;

                            Utils.setInspectionUploadStatus(inspectionId!, Consts.INSPECTION_UPLOAD_READY);
                          }

                          Inspection? inspection = await dao.findInspectionByID(inspectionId!);

                          if (rating >= 0 && rating <= 2) {
//                          await dao.updateInspectionResult(inspectionId!, "RJ");

                            if (inspection != null && inspection.result != null && inspection.result.equals("RJ")) {

                              ResultRejectionDetail resultRejectionDetail = await dao.getResultRejectionDetail(inspectionId!);
                              String rejectReason = resultRejectionDetail.getResultReason();
                              if (rejectReason != null && !rejectReason.isEmpty() && !rejectReason.contains("Quality Check")) {
                                rejectReason += "\nQuality Check = N";
                              await dao.createOrUpdateResultReasonDetails(inspectionId!, "RJ", rejectReason , "");
                              }
                              if (rejectReason == null || rejectReason.isEmpty()) {
                                rejectReason += "Quality Check = N";
                              await dao.createOrUpdateResultReasonDetails(inspectionId!, "RJ", rejectReason , "");

                              }

                            } else {
                            await dao.updateInspectionResult(inspectionId!, "RJ");
                              if (specAnalyticalItem != null) {

                              await dao.createOrUpdateResultReasonDetails(inspectionId!, "RJ", "Quality Check = N", "");
                              }
                            }

                            if (specAnalyticalItem != null) {
                              //dao.createIsPictureReqSpecAttribute(inspectionId!, "RJ", specAnalyticalItem.analyticalName, specAnalyticalItem.isPictureRequired());
                            }
                            et_qtyRejected.setEnabled(true);
                          await dao.updateQuantityRejected(inspectionId!, qtyShipped, 0);
                            et_qtyRejected.setText(String.valueOf(qtyShipped));
                            layoutPurchaseOrder.setBackgroundColor(activity.getResources().getColor(R.color.shareifyGold));

                          }

                          else if (rating >= 3 && rating <= 5) {
                            String rejectReason = "";

                            ResultRejectionDetail? resultRejectionDetail = await dao.getResultRejectionDetails(inspectionId!);
                            if (resultRejectionDetail != null) {
                              rejectReason = resultRejectionDetail.resultReason ?? '';
                            }
//                                if (rejectReason != null && !rejectReason.isEmpty() && rejectReason.contains("Quality Check")) {
//                                    String originalString = rejectReason;
//                                    String substringToRemove = "Quality Check = N";
//                                    rejectReason = originalString.replaceFirst(substringToRemove, "");
//                                  await dao.createOrUpdateResultReasonDetails(inspectionId!, "RJ", rejectReason , "");
//                                }
//                            }

                            if (brandedResult == "RJ") {

                              if (inspection != null && inspection.result != null && inspection.result.equals("RJ")) {
                                if (rejectReason != null && !rejectReason.isEmpty() && !rejectReason.contains("Branded = N")) {
                                  rejectReason += "\nBranded = N";
                                await dao.createOrUpdateResultReasonDetails(inspectionId!, "RJ", rejectReason , "");
                                }
                              } else {
                              await dao.updateInspectionResult(inspectionId!, "RJ");
                                if (specAnalyticalItem != null) {
                                await dao.createOrUpdateResultReasonDetails(inspectionId!, "RJ", "Branded " + "= N", "");
                                }
                              }

                              if (specAnalyticalItem != null) {
                                //dao.createOrUpdateResultReasonDetails(inspectionId!, "RJ", "Branded " + "= N", "");
                                //dao.createIsPictureReqSpecAttribute(inspectionId!, "RJ", specAnalyticalItem.analyticalName, specAnalyticalItem.isPictureRequired());
                              }
                              et_qtyRejected.setEnabled(true);
                            await dao.updateQuantityRejected(inspectionId!, qtyShipped, 0);
                              et_qtyRejected.setText(String.valueOf(qtyShipped));
                              layoutPurchaseOrder.setBackgroundColor(activity.getResources().getColor(R.color.shareifyGold));

                            }
                            else {
                              if (inspection != null && inspection.result != null ) {

                                if (inspection.result.equals("RJ")) {

                                  if (rejectReason != null && rejectReason.isNotEmpty && rejectReason.contains("Quality Check")) {

                                    String inputString = rejectReason;
                                    String targetSubstring = "\u25BA";
                                    int occurrences = countOccurrences(inputString, targetSubstring);

                                    if (occurrences < 2) {

                                    await dao.updateInspectionResult(inspectionId!, "AC");
                                    await dao.createOrUpdateResultReasonDetails(inspectionId!, "AC", "", "");
                                      et_qtyRejected.setEnabled(false);
                                    await dao.updateQuantityRejected(inspectionId!, 0, qtyShipped);
                                      et_qtyRejected.setText(String.valueOf(0));
                                      layoutPurchaseOrder.setBackgroundColor(activity.getResources().getColor(R.color.shareifyGreen));
                                    }
                                  }

                                }

                                if (!inspection.result.equals("RJ") || rejectReason.equals("")) {

                                await dao.updateInspectionResult(inspectionId!, "AC");
                                  et_qtyRejected.setEnabled(false);
                                await dao.updateQuantityRejected(inspectionId!, 0, qtyShipped);
                                  et_qtyRejected.setText(String.valueOf(0));
                                  layoutPurchaseOrder.setBackgroundColor(activity.getResources().getColor(R.color.shareifyGreen));
                                }

                              } else {

                              await dao.updateInspectionResult(inspectionId!, "AC");
                                et_qtyRejected.setEnabled(false);
                              await dao.updateQuantityRejected(inspectionId!, 0, qtyShipped);
                                et_qtyRejected.setText(String.valueOf(0));
                                layoutPurchaseOrder.setBackgroundColor(activity.getResources().getColor(R.color.shareifyGreen));

                              }
                            }
                          }

                          else {
                            layoutPurchaseOrder.setBackgroundColor(Color.TRANSPARENT);
                          }
                          
                        } else {
                          // ratingBar.setRating(0);
                          // layoutQuantityRejected.setVisibility(View.GONE);

                          AppAlertDialog.validateAlerts(
                            context,
                            AppStrings.alert,
                            'No specification found for item ${controller.inspectionsList[position].sku}',
                          );
                        }
                        //
                        widget.onRatingChanged(value);
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.camera_alt),
                          onPressed: widget.onInfoPressed,
                        ),
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: widget.onInspectPressed,
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Text('Branded: '),
                    Radio<bool>(
                      value: true,
                      groupValue: widget.goodsItem.isBranded,
                      onChanged: (value) => widget.onBrandedChanged(value!),
                    ),
                    Text('Yes'),
                    Radio<bool>(
                      value: false,
                      groupValue: widget.goodsItem.isBranded,
                      onChanged: (value) => widget.onBrandedChanged(value!),
                    ),
                    Text('No'),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Column buildShimmer() {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: 200.w,
                    height: 20.h,
                    color: AppColors.lightGrey,
                  ),
                  Container(
                    width: 100.w,
                    height: 20.h,
                    color: AppColors.lightGrey,
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {},
              icon: informationIcon,
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 100.w,
              height: 20.h,
              color: AppColors.lightGrey,
            ),
            Container(
              width: 100.w,
              height: 20.h,
              color: AppColors.lightGrey,
            ),
            Container(
              width: 100.w,
              height: 20.h,
              color: AppColors.lightGrey,
            ),
          ],
        ),
        if (resultButton != null || editPencilVisibility)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              if (resultButton != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: resultButtonColor,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Text(
                    resultButton ?? '',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontSize: 28.sp,
                    ),
                  ),
                ),
              const SizedBox(width: 12),
              if (editPencilVisibility)
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 30,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  String getPackDateType() {
    String dateTypeDesc = "Pack Date";
    String dateType = widget.goodsItem.packDate ?? '';
    if (dateType == "11") {
      dateTypeDesc = "Production Date";
    } else if (dateType == "12") {
      dateTypeDesc = "Due Date";
    } else if (dateType == "13") {
      dateTypeDesc = "Pack Date";
    } else if (dateType == "15") {
      dateTypeDesc = "Best Before Date";
    } else if (dateType == "16") {
      dateTypeDesc = "Sell By Date";
    } else if (dateType == "17") {
      dateTypeDesc = "Expiration Date";
    }
    return dateTypeDesc;
  }

  Widget _inspectionNameIdInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Expanded(
          flex: 4,
          child: Text(
            (widget.goodsItem.description ?? '-'),
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            (widget.goodsItem.sku ?? '-'),
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _inspectionStatusInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Lot No. ',
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 28.sp,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // if (widget.goodsItem.lotNumber != null)
              Text(
                widget.goodsItem.lotNumber ?? '',
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontSize: 22.sp, color: AppColors.white),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Pack Date ',
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 28.sp,
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              // if (widget.goodsItem.packDate != null)
              Text(
                (widget.goodsItem.packDate ?? ''),
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 22.sp,
                  color: AppColors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget orderStatusWidget() {
    if (resultButton != null || editPencilVisibility) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (resultButton != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: resultButtonColor,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Text(
                resultButton ?? '',
                textAlign: TextAlign.center,
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 28.sp,
                ),
              ),
            ),
          const SizedBox(width: 8),
          if (editPencilVisibility)
            IconButton(
              onPressed: () {
                if (widget.onTapEdit != null) {
                  widget.onTapEdit!(inspection, partnerItemSKU);
                }
              },
              icon: Icon(
                Icons.edit_outlined,
                size: 30,
                color: AppColors.white,
              ),
            ),
        ],
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _inspectionQuantity() {
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Row(children: [
              Text('Qty Shipped * ',
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontSize: 28.sp,
                    color: AppColors.white,
                    fontWeight: FontWeight.w600,
                  )),
              SizedBox(
                width: 80,
                child: TextField(
                  controller: qtyShippedController,
                  textAlign: TextAlign.center,
                  keyboardType: TextInputType.number,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    fontSize: 28.sp,
                    color: AppColors.white,
                    fontWeight: FontWeight.normal,
                  ),
                  decoration: InputDecoration(
                    enabled: etQtyShippedEnabled,
                    isDense: true,
                    border: const UnderlineInputBorder(),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    disabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    errorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    suffixIcon: qtyShippedController.text.trim().isEmpty
                        ? IconButton(
                            icon: const Icon(Icons.info_outlined,
                                color: Colors.red),
                            onPressed: () {
                              Utils.showSnackBar(
                                context: Get.overlayContext!,
                                message: 'Please enter a valid value',
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              );
                            },
                          )
                        : null,
                  ),
                ),
              ),
            ])),
        if (widget.goodsItem.packDate != null)
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Text('Qty Rejected * ',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontSize: 28.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    )),
                SizedBox(
                  width: 80,
                  child: TextField(
                    controller: qtyRejectedController,
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontSize: 28.sp,
                      color: AppColors.white,
                      fontWeight: FontWeight.normal,
                    ),
                    onChanged: (value) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      isDense: true,
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      disabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      errorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      suffixIcon: qtyRejectedController.text.trim().isEmpty
                          ? IconButton(
                              icon: const Icon(Icons.info_outlined,
                                  color: Colors.red),
                              onPressed: () {
                                Utils.showSnackBar(
                                  context: Get.overlayContext!,
                                  message: 'Please enter a valid value',
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                );
                              },
                            )
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        // const Spacer(),
      ],
    );
  }

  Future<void> asyncTask([bool s = false]) async {
    if (s && fromSetState /*&& valueAssigned.value*/) {
      fromSetState = true;
      return;
    }
    fromSetState = true;
    partnerItemSKU = await dao.findPartnerItemSKU(
        widget.partnerID,
        widget.goodsItem.sku!,
        appStorage.selectedItemSKUList.elementAt(widget.position).uniqueItemId);

    await getSpecifications();
    if (partnerItemSKU == null) {
      valueAssigned.value = true;
      setState(() {});
      // return;
    }
    if (partnerItemSKU?.inspectionId == null) {
      valueAssigned.value = true;
      setState(() {});
      // return;
    }
    if (partnerItemSKU != null) {
      inspectionId = partnerItemSKU!.inspectionId;

      String? lotNo = await dao.getLotNoFromQCDetails(inspectionId!);
      if (lotNo != null) {
        appStorage.selectedItemSKUList[widget.position].lotNo = lotNo;
        await dao.updateLotNoPartnerItemSKU(inspectionId!, lotNo);
        lotNumberController.text = lotNo;
      }

      String? dateType = await dao.getDateTypeFromQCDetails(inspectionId!);

      if (dateType != null) {
        appStorage.selectedItemSKUList[widget.position].dateType = dateType;

        getPackDateType();
      }

      int time = await dao.getPackDateFromQCDetails(inspectionId!);
      if (time != 0) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(time);

        String formattedDateString = Utils().dateFormat.format(date);

        appStorage.selectedItemSKUList[widget.position].packDate =
            formattedDateString;
        await dao.updatePackdatePartnerItemSKU(
            inspectionId!, formattedDateString);
        packDateController.text = formattedDateString;
      }

      inspection = await dao.findInspectionByID(partnerItemSKU!.inspectionId!);

      isComplete = await dao.isInspectionComplete(
          widget.partnerID, widget.goodsItem.sku!, partnerItemSKU!.uniqueId);
      isPartialComplete = await dao.isInspectionPartialComplete(
          widget.partnerID,
          widget.goodsItem.sku!,
          partnerItemSKU!.uniqueId.toString());
      bool isC = (inspection?.complete == '1'.toString());
      if ((inspection != null && isC)) {
      } else if (isPartialComplete) {}

      String inspectionResult = "";
      if (inspection != null) {
        inspectionResult = inspection!.result ?? '';

        OverriddenResult? overriddenResult =
            await dao.getOverriddenResult(inspection!.inspectionId!);

        if (overriddenResult != null) {
          inspectionResult = overriddenResult.overriddenResult!;
          await dao.updateInspectionResult(
              inspection!.inspectionId!, inspectionResult);
        }
        if (inspectionResult.isNotEmpty) {
          // TODO: implement below
          // resultButtonVisibility = true;
          editPencilVisibility = true;

          if (inspectionResult == "RJ" ||
              inspectionResult == AppStrings.reject) {
            resultButtonColor = Colors.red;
            resultButton = AppStrings.reject;
            layoutQtyRejectedVisibility = true;

            QualityControlItem? qualityControlItems = await dao
                .findQualityControlDetails(partnerItemSKU!.inspectionId!);

            if (qualityControlItems != null) {
              qtyShippedController.text =
                  qualityControlItems.qtyShipped.toString();
              if (qualityControlItems.qtyRejected == 0) {
                if (overriddenResult != null &&
                    (overriddenResult.overriddenResult == "RJ" ||
                        overriddenResult.overriddenResult == "Reject")) {
                  qtyRejectedController.text = '0';
                } else {
                  qtyRejectedController.text =
                      qualityControlItems.qtyShipped.toString();
                }
              } else {
                qtyRejectedController.text =
                    qualityControlItems.qtyRejected.toString();
              }
              int qtyRejected = int.parse(qtyRejectedController.text);
              int qtyReceived = qualityControlItems.qtyShipped! - qtyRejected;

              await dao.updateQuantityRejected(
                  inspection!.inspectionId!, qtyRejected, qtyReceived);
            }

            qtyRejectedController.selection = TextSelection.fromPosition(
                TextPosition(offset: qtyRejectedController.text.length));

            qtyRejectedController.addListener(() async {
              if (!qtyRejectedFocusNode.hasFocus) {
                String tempQty = qtyRejectedController.text;

                if (tempQty.isNotEmpty) {
                  int qtyRejected = int.parse(tempQty);
                  int qtyReceived = 0;
                  if (qualityControlItems != null) {
                    qtyReceived = qualityControlItems.qtyShipped! - qtyRejected;
                  }
                  await dao.updateQuantityRejected(
                      inspection!.inspectionId!, qtyRejected, qtyReceived);
                } else {
                  if (qualityControlItems != null) {
                    await dao.updateQuantityRejected(inspection!.inspectionId!,
                        0, qualityControlItems.qtyShipped!);
                  }
                }
              }
            });
          } else if (inspectionResult == "AC" ||
              inspectionResult == AppStrings.accept) {
            resultButtonColor = Colors.green;
            resultButton = AppStrings.accept;
            layoutQtyRejectedVisibility = false;
            // TODO: setting up the color
          } else if (inspectionResult == "A-") {
            // TODO: setting up the color
            resultButtonColor = Colors.yellow;
            resultButton = "A-";
            layoutQtyRejectedVisibility = false;
          } else if (inspectionResult == "AW" ||
              inspectionResult.toLowerCase() == AppStrings.acceptCondition) {
            // TODO: setting up the color
            resultButtonColor = AppColors.orange;
            resultButton = "AW";
            layoutQtyRejectedVisibility = false;
          }
        }
      }

      valueAssigned.value = true;
      setState(() {});
    }

    await getSpecifications();

    if (appStorage.specificationByItemSKUList != null &&
        appStorage.specificationByItemSKUList!.isNotEmpty) {
      specificationNumber =
          appStorage.specificationByItemSKUList?.first.specificationNumber;
      specificationVersion =
          appStorage.specificationByItemSKUList?.first.specificationVersion;
      specificationName =
          appStorage.specificationByItemSKUList?.first.specificationName;
      specificationTypeName =
          appStorage.specificationByItemSKUList?.first.specificationTypeName;

      await Utils().offlineLoadCommodityVarietyDocuments(
          specificationNumber!, specificationVersion!);

      if (appStorage.commodityVarietyData != null &&
          (appStorage.commodityVarietyData!.exceptions.isNotEmpty)) {
        informationIcon = Icon(
          Icons.info_rounded,
          color: AppColors.primary,
          size: 40,
        );
        informationIconEnabled = true;
      } else {
        informationIcon = Icon(
          Icons.info_rounded,
          color: AppColors.white,
          size: 40,
        );
        informationIconEnabled = false;
      }
    }
    valueAssigned.value = true;
    setState(() {});
  }

  String getPoNumber(int position) {
    if (appStorage.selectedItemSKUList[position].poNo != null) {
      return appStorage.selectedItemSKUList[position].poNo ?? '-';
    } else {
      String? poNo = widget.goodsItem.poNumber;
      appStorage.selectedItemSKUList[position].poNo = poNo;
      return poNo ?? '-';
    }
  }

  String getPackDate(int position) {
    return packDateController.text;
  }

  Color _getBackgroundColor() {
    if (widget.goodsItem.rating > 0 && widget.goodsItem.rating <= 2) {
      return Colors.amber.shade200;
    } else if (widget.goodsItem.rating >= 3 && widget.goodsItem.rating <= 5) {
      return Colors.green.shade200;
    }
    return Colors.transparent;
  }

  Future<void> createNewInspection(
      String itemSKU,
      int itemSKUId,
      String lotNo,
      String packDate,
      String specificationNumber,
      String specificationVersion,
      String specificationName,
      String specificationTypeName,
      int sampleSizeByCount,
      String gtin,
      String poNumber,
      int rating,
      int commodityID,
      String commodityName,
      int poLineNo,
      int partnerId,
      String partnerName,
      String itemSkuName,
      ) async {
    appStorage.currentInspection = Inspection(
      userId: appStorage.getUserData()!.id,
      partnerId: partnerId,
      carrierId: 0,
      createdTime: DateTime.now().millisecondsSinceEpoch,
      complete: '0',
      downloadId: -1,
      commodityId: commodityID,
      itemSKU: itemSKU,
      specificationName: specificationName,
      specificationNumber: specificationNumber,
      specificationVersion: specificationVersion,
      specificationTypeName: specificationTypeName,
      sampleSizeByCount: sampleSizeByCount,
      packDate: packDate,
      itemSKUId: itemSKUId,
      commodityName: commodityName,
      lotNo: lotNo,
      poNumber: poNumber,
      rating: rating,
      poLineNo: poLineNo,
      partnerName: partnerName,
      itemSkuName: itemSkuName,
    );

    try {
      int inspectionId = await dao.createInspection(appStorage.currentInspection!);
      appStorage.currentInspection!.inspectionId = inspectionId;
      serverInspectionID = inspectionId;
    } catch (e) {
      print(e);
    }
  }

  int countOccurrences(String inputString, String targetSubstring) {
    int count = 0;
    int index = inputString.indexOf(targetSubstring);
    while (index != -1) {
      count++;
      index = inputString.indexOf(targetSubstring, index + 1);
    }
    return count;
  }

}
