import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/utils.dart';

class PurchaseOrderListViewItem extends StatefulWidget {
  const PurchaseOrderListViewItem({
    super.key,
    required this.goodsItem,
    required this.infoTap,
    required this.inspectTap,
    required this.onTapEdit,
    required this.partnerID,
    required this.position,
    required this.productTransfer,
    required this.po_number,
    required this.seal_number,
  });
  final Function(
    Inspection? inspection,
    PartnerItemSKUInspections? partnerItemSKU,
  )? infoTap;
  final Function(
    Inspection? inspection,
    PartnerItemSKUInspections? partnerItemSKU,
    String lotNo,
    String packDate,
    bool isComplete,
    bool ispartialComplete,
    int inspectionId,
    String po_number,
    String seal_number,
  )? inspectTap;
  final Function(
    Inspection? inspection,
    PartnerItemSKUInspections? partnerItemSKU,
  )? onTapEdit;
  final int partnerID;
  final String po_number;
  final String seal_number;
  final int position;
  final String productTransfer;

  final PurchaseOrderItem goodsItem;

  @override
  State<PurchaseOrderListViewItem> createState() =>
      _PurchaseOrderListViewItemState();
}

class _PurchaseOrderListViewItemState extends State<PurchaseOrderListViewItem> {
  late TextEditingController lotNumberController;

  late TextEditingController qtyRejectedController;

  late TextEditingController qtyShippedController;
  late TextEditingController packDateController;

  PartnerItemSKUInspections? partnerItemSKU;
  int? inspectionId;
  final ApplicationDao dao = ApplicationDao();
  final AppStorage appStorage = AppStorage.instance;
  bool isComplete = false;

  bool isPartialComplete = false;
  String inspectButtonImagePath = '';
  FocusNode qtyRejectedFocusNode = FocusNode();

  Inspection? inspection;
  bool informationIconEnabled = true;
  String? result_button = null;
  Color result_buttonColor = Colors.white;
  AssetImage informationImagePath =
      AssetImage('assets/images/info_purple_48.png');

  bool editPencilVisibility = false;
  bool layoutQtyRejectedVisibility = false;
  bool et_qtyShippedEnabled = false;

  String? specificationNumber;
  String? specificationVersion;
  String? specificationName;
  String? specificationTypeName;

  @override
  void initState() {
    lotNumberController = TextEditingController();
    qtyRejectedController = TextEditingController();
    qtyShippedController = TextEditingController();
    packDateController = TextEditingController();
    packDateController.text = widget.goodsItem.packDate ?? '';
    lotNumberController.text = widget.goodsItem.lotNumber ?? '';
    inspectButtonImagePath = 'assets/images/play_circle.png';
    et_qtyShippedEnabled = false;
    asyncTask();
    super.initState();
  }

  Future<void> getSpecifications() async {
    if (widget.productTransfer == "Transfer") {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTableForTransfer(
              widget.partnerID, widget.goodsItem.sku!, widget.goodsItem.sku!);
    } else {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTable(
              widget.partnerID, widget.goodsItem.sku!, widget.goodsItem.sku!);
    }
  }

  @override
  void dispose() {
    lotNumberController.dispose();
    qtyRejectedController.dispose();
    qtyShippedController.dispose();
    packDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: Column(
        children: [
          _InspectionNameIdInfo(),
          Text(
            getPoNumber(widget.position),
            style: Get.textTheme.bodyLarge,
          ),
          Text(
            getPackDate(widget.position),
            style: Get.textTheme.bodyLarge,
          ),
          const SizedBox(
            height: 8,
          ),
          _InspectionStatusInfo(),
          const SizedBox(
            height: 8,
          ),
          if (layoutQtyRejectedVisibility) _InspectionQuantity(),
        ],
      ),
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

  Widget _InspectionNameIdInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 6,
          child: Text(
            widget.goodsItem.description ?? '-',
            // style: style,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Expanded(
          flex: 1,
          child: SizedBox(),
        ),
        Expanded(
          flex: 3,
          child: Text(
            widget.goodsItem.sku ?? '-',
            // style: style.copyWith(color: Colors.grey[500]),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(
            // widget.goodsItem.isCompleted
            // Random().nextBool()
            true ? Icons.check_circle_outline : Icons.play_circle_outline,
            size: 36,
            color: Colors.black,
          ),
          onPressed: () {
            if (widget.inspectTap != null) {
              widget.inspectTap!(
                inspection,
                partnerItemSKU,
                lotNumberController.text,
                packDateController.text,
                isComplete,
                isPartialComplete,
                inspectionId!,
                widget.po_number,
                widget.seal_number,
              );
            }
          },
        ),
        IconButton(
          // onPressed: widget.goodsItem.showInfo ? controller.onTapInfo() : null,
          onPressed: () {
            if (!informationIconEnabled) {
              return;
            }
            if (widget.infoTap != null) {
              widget.infoTap!(inspection, partnerItemSKU);
            }
          },
          icon: Icon(
            Icons.info,
            size: 32,
            // color: widget.goodsItem.showInfo
            color: /*Random().nextBool()*/
                true ? Colors.purple[600] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _InspectionStatusInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 2,
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Lot No. ',
                  // style: style.copyWith(color: Colors.black87),
                ),
                if (widget.goodsItem.lotNumber != null)
                  TextSpan(
                    text: widget.goodsItem.lotNumber.toString(),
                    // style: style.copyWith(
                    //   color: Colors.grey[500],
                    //   fontWeight: FontWeight.normal,
                    // ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 4,
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Pack Date ',
                  // style: style.copyWith(color: Colors.black87),
                ),
                if (widget.goodsItem.packDate != null)
                  TextSpan(
                    // text: controller.formatDate(widget.goodsItem.packDate!),
                    text: (widget.goodsItem.packDate!),
                    // style: style.copyWith(
                    //   color: Colors.grey[500],
                    //   fontWeight: FontWeight.normal,
                    // ),
                  ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 3,
          // child: widget.goodsItem.isInspectionDone
          child: /*Random().nextBool()*/
              true
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (result_button != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 26, vertical: 2),
                            decoration: BoxDecoration(
                              color: result_buttonColor,
                              borderRadius: BorderRadius.circular(32),
                            ),
                            child: Text(
                              result_button ?? '',
                              // style: style,
                            ),
                          ),
                        const SizedBox(
                          width: 12,
                        ),
                        if (editPencilVisibility)
                          IconButton(
                            onPressed: () {
                              if (widget.onTapEdit != null) {
                                widget.onTapEdit!(inspection, partnerItemSKU);
                              }
                            },
                            icon: const Icon(
                              Icons.edit_outlined,
                              size: 24,
                              color: Colors.white,
                            ),
                          ),
                      ],
                    )
                  : const SizedBox(),
        ),
      ],
    );
  }

  Widget _InspectionQuantity() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Qty Shipped * ',
                  // style: style.copyWith(color: Colors.black87),
                ),
                // if (widget.goodsItem.quantityShipped != null)
                TextSpan(
                  text: lotNumberController.text,
                  // style: style.copyWith(
                  //   color: Colors.grey[500],
                  //   fontWeight: FontWeight.normal,
                  // ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: RichText(
            text: TextSpan(
              children: [
                const TextSpan(
                  text: 'Qty Rejected * ',
                  // style: style.copyWith(color: Colors.black87),
                ),
                if (widget.goodsItem.packDate != null)
                  const TextSpan(
                    text: '200',
                    // style: style.copyWith(
                    //   color: Colors.grey[500],
                    //   fontWeight: FontWeight.normal,
                    // ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> asyncTask() async {
    partnerItemSKU = await dao.findPartnerItemSKU(
        widget.partnerID,
        widget.goodsItem.sku!,
        appStorage.selectedItemSKUList.elementAt(widget.position).uniqueItemId);

    await getSpecifications();
    if (partnerItemSKU == null) {
      return;
    }
    if (partnerItemSKU?.inspectionId == null) {
      return;
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

      if (isComplete ||
          (inspection != null && (inspection?.complete ?? false))) {
        inspectButtonImagePath = 'assets/images/check_circle.png';
      } else if (isPartialComplete) {
        inspectButtonImagePath = 'assets/images/pause.png';
      }

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
            result_buttonColor = Colors.red;
            result_button = AppStrings.reject;
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

            qtyRejectedController.addListener(() {
              if (!qtyRejectedFocusNode.hasFocus) {
                String tempQty = qtyRejectedController.text;

                if (tempQty.isNotEmpty) {
                  int qtyRejected = int.parse(tempQty);
                  int qtyReceived = 0;
                  if (qualityControlItems != null) {
                    qtyReceived = qualityControlItems.qtyShipped! - qtyRejected;
                  }
                  dao.updateQuantityRejected(
                      inspection!.inspectionId!, qtyRejected, qtyReceived);
                } else {
                  if (qualityControlItems != null) {
                    dao.updateQuantityRejected(inspection!.inspectionId!, 0,
                        qualityControlItems.qtyShipped!);
                  }
                }
              }
            });
          } else if (inspectionResult == "AC" ||
              inspectionResult == AppStrings.accept) {
            result_buttonColor = Colors.green;
            result_button = AppStrings.accept;
            layoutQtyRejectedVisibility = false;
            // TODO: setting up the color
          } else if (inspectionResult == "A-") {
            // TODO: setting up the color
            result_buttonColor = Colors.yellow;
            result_button = "A-";
            layoutQtyRejectedVisibility = false;
          } else if (inspectionResult == "AW" ||
              inspectionResult.toLowerCase() == AppStrings.acceptCondition) {
            // TODO: setting up the color
            result_buttonColor = Colors.orange;
            result_button = "AW";
            layoutQtyRejectedVisibility = false;
          }
        }

        String finalInspectionResult = inspectionResult;
        // TODO: implement below
        /*editPencil.onPressed = () {
          // Assuming OverriddenResultActivity is a Flutter route
          Get.to(() => const OverriddenResultScreen(), arguments: {
            Consts.SERVER_INSPECTION_ID: inspection.inspectionId,
            Consts.PARTNER_NAME: partnerName,
            Consts.PARTNER_ID: partnerID,
            Consts.CARRIER_NAME: carrierName,
            Consts.CARRIER_ID: carrierID,
            Consts.COMMODITY_NAME:
                appStorage.selectedItemSKUList[widget.position].commodityName,
            Consts.COMMODITY_ID:
                appStorage.selectedItemSKUList[widget.position].commodityID,
            Consts.INSPECTION_RESULT: finalInspectionResult,
            Consts.ITEM_SKU: widget.goodsItem.sku,
            Consts.PO_NUMBER: poNumber,
            Consts.SPECIFICATION_NUMBER: specificationNumber,
            Consts.SPECIFICATION_VERSION: specificationVersion,
            Consts.SPECIFICATION_NAME: specificationName,
            Consts.SPECIFICATION_TYPE_NAME: specificationTypeName,
            Consts.PRODUCT_TRANSFER: productTransfer,
          });
        };*/
      }
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
        informationImagePath = AssetImage('assets/images/info_purple_48.png');
        informationIconEnabled = true;
      } else {
        informationImagePath = AssetImage('assets/images/info_48.png');
        informationIconEnabled = false;
      }
    }
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
}

// TODO: implement above UI based on existing app logic
