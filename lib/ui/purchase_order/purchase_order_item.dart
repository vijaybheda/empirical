import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
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
    required this.poNumber,
    required this.sealNumber,
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
    int? inspectionId,
    String poNumber,
    String sealNumber,
  )? inspectTap;
  final Function(
    Inspection? inspection,
    PartnerItemSKUInspections? partnerItemSKU,
  )? onTapEdit;
  final int partnerID;
  final String poNumber;
  final String sealNumber;
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
  Icon inspectButtonImagePath = const Icon(
    Icons.play_circle_outline_outlined,
    size: 40,
  );
  FocusNode qtyRejectedFocusNode = FocusNode();

  Inspection? inspection;
  bool informationIconEnabled = true;
  String? resultButton;
  Color resultButtonColor = AppColors.white;
  AssetImage informationImagePath =
      const AssetImage(AppImages.ic_informationDisabled);

  bool editPencilVisibility = false;
  bool layoutQtyRejectedVisibility = false;
  bool etQtyShippedEnabled = false;

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
    inspectButtonImagePath = const Icon(
      Icons.play_circle_outline_outlined,
      size: 40,
    );
    etQtyShippedEnabled = false;
    asyncTask();
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      asyncTask();
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    asyncTask();
    super.didChangeDependencies();
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
          _inspectionNameIdInfo(),
          const SizedBox(height: 8),
          _inspectionStatusInfo(),
          const SizedBox(height: 8),
          if (layoutQtyRejectedVisibility) _inspectionQuantity(),
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

  Widget _inspectionNameIdInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Text(
                widget.goodsItem.description ?? '-',
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 28.sp,
                  color: AppColors.lightGrey,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                widget.goodsItem.sku ?? '-',
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontSize: 28.sp,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        IconButton(
          iconSize: 40,
          icon: inspectButtonImagePath,
          onPressed: () {
            if (widget.inspectTap != null) {
              widget.inspectTap!(
                inspection,
                partnerItemSKU,
                lotNumberController.text,
                packDateController.text,
                isComplete,
                isPartialComplete,
                inspectionId,
                widget.poNumber,
                widget.sealNumber,
              );
            }
          },
        ),
        IconButton(
          onPressed: () {
            if (!informationIconEnabled) {
              return;
            }
            if (widget.infoTap != null) {
              widget.infoTap!(inspection, partnerItemSKU);
            }
          },
          icon: Image.asset(
            informationImagePath.assetName,
            width: 40,
            height: 40,
          ),
        ),
      ],
    );
  }

  Widget _inspectionStatusInfo() {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (widget.goodsItem.lotNumber != null)
          Expanded(
            flex: 4,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Lot No. ',
                    style: Get.textTheme.bodyMedium
                        ?.copyWith(fontSize: 28.sp, color: AppColors.white),
                  ),
                  if (widget.goodsItem.lotNumber != null)
                    TextSpan(
                      text: widget.goodsItem.lotNumber.toString(),
                      style: Get.textTheme.bodyMedium
                          ?.copyWith(fontSize: 28.sp, color: AppColors.white),
                    ),
                ],
              ),
            ),
          ),
        if (widget.goodsItem.packDate != null)
          Expanded(
            flex: 4,
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Pack Date ',
                    style: Get.textTheme.bodyMedium?.copyWith(
                      fontSize: 28.sp,
                    ),
                  ),
                  if (widget.goodsItem.packDate != null)
                    TextSpan(
                      text: (widget.goodsItem.packDate!),
                      style: Get.textTheme.bodyMedium?.copyWith(
                        fontSize: 28.sp,
                      ),
                    ),
                ],
              ),
            ),
          ),
        if (resultButton != null || editPencilVisibility)
          Expanded(
            flex: 3,
            child: Row(
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
            ),
          ),
      ],
    );
  }

  Widget _inspectionQuantity() {
    return Row(
      children: [
        Text(
          'Qty Shipped * ',
          style: Get.textTheme.bodyMedium?.copyWith(
            fontSize: 28.sp,
          ),
        ),
        // if (widget.goodsItem.quantityShipped != null)
        Expanded(
          child: TextField(
            controller: qtyShippedController,
            style: Get.textTheme.bodyMedium
                ?.copyWith(fontSize: 28.sp, color: AppColors.white),
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
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        if (widget.goodsItem.packDate != null)
          Text(
            'Qty Rejected * ',
            style: Get.textTheme.bodyMedium?.copyWith(
              fontSize: 28.sp,
            ),
          ),
        // if (qtyRejectedController.text.isNotEmpty)
        Expanded(
          child: TextField(
            controller: qtyRejectedController,
            style: Get.textTheme.bodyMedium
                ?.copyWith(fontSize: 28.sp, color: AppColors.white),
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
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
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
      bool isC = (inspection != null && inspection!.complete == null)
          ? false
          : (inspection?.complete == true.toString());
      if (isComplete || (inspection != null && isC)) {
        inspectButtonImagePath = const Icon(
          Icons.check_circle_outlined,
          size: 40,
        );
      } else if (isPartialComplete) {
        inspectButtonImagePath = const Icon(
          Icons.pause_circle_outline_outlined,
          size: 40,
        );
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
            resultButtonColor = Colors.orange;
            resultButton = "AW";
            layoutQtyRejectedVisibility = false;
          }
        }

        // String finalInspectionResult = inspectionResult;
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
        informationImagePath = const AssetImage(AppImages.ic_information);
        informationIconEnabled = true;
      } else {
        informationImagePath =
            const AssetImage(AppImages.ic_informationDisabled);
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
