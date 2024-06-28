import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pverify/controller/new_purchase_order_details_controller.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/inspection_attachment.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/new_purchase_order_item.dart';
import 'package:pverify/models/overridden_result_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/quality_control_item.dart';
import 'package:pverify/models/result_rejection_details.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_analytical_request_item.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/inspection_photos/inspection_photos_screen.dart';
import 'package:pverify/ui/overridden_result/overridden_result_screen.dart';
import 'package:pverify/ui/qc_short_form/qc_details_short_form_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/extensions/int_extension.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class NewPurchaseOrderListViewItem extends StatefulWidget {
  const NewPurchaseOrderListViewItem({
    super.key,
    required this.goodsItem,
    required this.onRatingChanged,
    required this.onQuantityShippedChanged,
    required this.onQuantityRejectedChanged,
    required this.onInspectPressed,
    required this.onInfoPressed,
    required this.onBrandedChanged,
    required this.partnerID,
    required this.position,
    required this.poNumber,
    required this.commodityID,
    required this.carrierID,
    required this.carrierName,
    required this.commodityName,
    required this.sealNumber,
    required this.controller,
  });

  final Function(double) onRatingChanged;
  final Function(int) onQuantityShippedChanged;
  final Function(int) onQuantityRejectedChanged;
  final Function() onInspectPressed;
  final Function() onInfoPressed;
  final Function(bool) onBrandedChanged;
  final NewPurchaseOrderDetailsController controller;

  final int partnerID;
  final String poNumber;
  final String sealNumber;
  final String carrierName;
  final String commodityName;
  final int position;
  final int carrierID;
  final int commodityID;

  final NewPurchaseOrderItem goodsItem;

  @override
  State<NewPurchaseOrderListViewItem> createState() =>
      _NewPurchaseOrderListViewItemState();
}

class _NewPurchaseOrderListViewItemState
    extends State<NewPurchaseOrderListViewItem> {
  List<InspectionAttachment>? picsFromDB;

  String comply = "Y";

  Color layoutPurchaseOrderColor = Colors.transparent;

  bool editPencilEnabled = false;
  bool qtyRejectedEnabled = false;

  bool hasComment = false;

  final List<int> flexList = [1, 4, 1, 2];

  NewPurchaseOrderDetailsController get controller => widget.controller;

  AppStorage get appStorage => controller.appStorage;
  List<bool> isCheckedList = [];

  ApplicationDao get dao => controller.dao;
  PartnerItemSKUInspections? partnerItemSKU;
  int inspectionId = -1;
  bool isComplete = false;

  bool isPartialComplete = false;
  FocusNode qtyRejectedFocusNode = FocusNode();

  String get poNumber => widget.poNumber;

  String get carrierName => widget.carrierName;

  String get commodityName => widget.commodityName;

  int get commodityID => widget.commodityID;

  int get carrierID => widget.carrierID;
  late int poLineNo;

  Inspection? inspection;
  bool informationIconEnabled = false;
  bool layoutQuantityRejectedVisibility = false;
  String poNumberString = '';
  bool poNumberVisibility = true;
  String isBranded = '';

  Icon inspectButtonIcon = Icon(
    Icons.play_arrow_rounded,
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
  int? sampleSizeByCount;
  RxBool valueAssigned = false.obs;
  bool fromSetState = false;

  late TextEditingController _qtyShippedController;
  late TextEditingController _qtyRejectedController;

  int? serverInspectionID;

  @override
  void initState() {
    poLineNo = currentInspectionsItem.poLineNo ?? 0;
    isCheckedList = List<bool>.filled(controller.originalData.length, false);
    _qtyShippedController = TextEditingController();
    _qtyRejectedController = TextEditingController();

    if (controller.originalData.elementAtOrNull(position)?.ftl == '1') {
      poNumberVisibility = true;
      poNumberString = "FTL";
    } else {
      poNumberVisibility = false;
    }

    etQtyShippedEnabled = false;
    asyncTask();
    super.initState();
    _qtyShippedController.addListener(_onQtyShippedChanged);
    _qtyRejectedController.addListener(_onQtyRejectedChanged);
  }

  @override
  void dispose() {
    // _lotNumberController.dispose();
    // _packDateController.dispose();
    _qtyShippedController.dispose();
    _qtyRejectedController.dispose();
    super.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!valueAssigned.value) {
        return buildShimmer();
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: layoutPurchaseOrderColor,
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: flexList[0],
                  child: GestureDetector(
                    onTap: () async {
                      await onSkuTap();
                    },
                    child: Text(
                      widget.goodsItem.sku ?? '',
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontSize: 16, decoration: TextDecoration.underline),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: flexList[1],
                  child: Text(
                    widget.goodsItem.description ?? '',
                    textAlign: TextAlign.start,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: flexList[2],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: "Yes",
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            groupValue: isBranded,
                            onChanged: (value) {
                              onRadioButtonChange("Yes");
                              widget.onBrandedChanged(value == "Yes");
                            },
                            activeColor: AppColors.white,
                            fillColor:
                                MaterialStateProperty.all(AppColors.white),
                            focusColor: AppColors.white,
                            hoverColor: AppColors.white,
                            overlayColor:
                                MaterialStateProperty.all(AppColors.white),
                          ),
                          const Text('Y'),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Radio<String>(
                            value: "No",
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                            groupValue: isBranded,
                            onChanged: (value) {
                              onRadioButtonChange("No");
                              widget.onBrandedChanged(value == "No");
                            },
                            activeColor: AppColors.white,
                            fillColor:
                                MaterialStateProperty.all(AppColors.white),
                            focusColor: AppColors.white,
                            hoverColor: AppColors.white,
                            overlayColor:
                                MaterialStateProperty.all(AppColors.white),
                          ),
                          const Text('N'),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  flex: flexList[3],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RatingBar.builder(
                        initialRating: ratings,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 30,
                        itemBuilder: (context, _) => Icon(
                          Icons.star,
                          color: AppColors.yellow,
                        ),
                        onRatingUpdate: (value) async {
                          onRatingUpdate(value);
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.camera_alt,
                          color: AppColors.white,
                          size: 35,
                        ),
                        onPressed: cameraIconTap,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          if (layoutQuantityRejectedVisibility)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text('Qty Shipped *',
                            style: Get.textTheme.bodyMedium?.copyWith(
                              fontSize: 28.sp,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            )),
                        Expanded(
                          child: SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _qtyShippedController,
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
                                suffixIcon: _qtyShippedController.text
                                        .trim()
                                        .isEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.info_outlined,
                                            color: Colors.red),
                                        onPressed: () {
                                          Utils.showSnackBar(
                                            context: Get.overlayContext!,
                                            message:
                                                'Please enter a valid value',
                                            backgroundColor: Colors.red,
                                            duration:
                                                const Duration(seconds: 2),
                                          );
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text('Qty Rejected *',
                            style: Get.textTheme.bodyMedium?.copyWith(
                              fontSize: 28.sp,
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                            )),
                        Expanded(
                          child: SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _qtyRejectedController,
                              textAlign: TextAlign.center,
                              keyboardType: TextInputType.number,
                              style: Get.textTheme.bodyMedium?.copyWith(
                                fontSize: 28.sp,
                                color: AppColors.white,
                                fontWeight: FontWeight.normal,
                              ),
                              onChanged: (value) =>
                                  widget.onQuantityRejectedChanged(
                                      int.tryParse(value) ?? 0),
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
                                suffixIcon: _qtyRejectedController.text
                                        .trim()
                                        .isEmpty
                                    ? IconButton(
                                        icon: const Icon(Icons.info_outlined,
                                            color: Colors.red),
                                        onPressed: () {
                                          Utils.showSnackBar(
                                            context: Get.overlayContext!,
                                            message:
                                                'Please enter a valid value',
                                            backgroundColor: Colors.red,
                                            duration:
                                                const Duration(seconds: 2),
                                          );
                                        },
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await onComment();
                          },
                          child: Image.asset(
                            hasComment
                                ? AppImages.ic_specCommentsAdded
                                : AppImages.ic_specComments,
                            width: 80.w,
                            fit: BoxFit.contain,
                          ),
                        ),
                        IconButton(
                          icon: Icon(
                            Icons.edit,
                            color: AppColors.white,
                            size: 40,
                          ),
                          onPressed: () async {
                            await onEditPressed();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          if (etQtyShippedEnabled) const SizedBox(height: 4),
        ],
      );
    });
  }

  Future<void> onEditPressed() async {
    inspection = await dao.findInspectionByID(inspectionId);
    if (inspection != null && inspection?.result != null) {
      Map<String, dynamic> arguments = {
        Consts.SERVER_INSPECTION_ID: inspection?.inspectionId,
        Consts.PARTNER_NAME:
            appStorage.selectedItemSKUList.elementAt(position).partnerName,
        Consts.PARTNER_ID:
            appStorage.selectedItemSKUList.elementAt(position).partnerId,
        Consts.CARRIER_NAME: carrierName,
        Consts.CARRIER_ID: carrierID,
        Consts.COMMODITY_NAME:
            appStorage.selectedItemSKUList.elementAt(position).commodityName,
        Consts.COMMODITY_ID:
            appStorage.selectedItemSKUList.elementAt(position).commodityID,
        Consts.INSPECTION_RESULT: inspection?.result,
        Consts.ITEM_SKU: currentNewPurchaseItem.sku,
        Consts.PO_NUMBER: poNumberString,
      };

      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTable(
        currentNewPurchaseItem.partnerId!,
        currentNewPurchaseItem.sku!,
        currentNewPurchaseItem.sku!,
      );

      if (appStorage.specificationByItemSKUList != null &&
          (appStorage.specificationByItemSKUList ?? []).isNotEmpty) {
        specificationNumber = appStorage.specificationByItemSKUList
            ?.elementAt(0)
            .specificationNumber;
        specificationVersion = appStorage.specificationByItemSKUList
            ?.elementAt(0)
            .specificationVersion;
        specificationName = appStorage.specificationByItemSKUList
            ?.elementAt(0)
            .specificationName;
        specificationTypeName = appStorage.specificationByItemSKUList
            ?.elementAt(0)
            .specificationTypeName;
      }

      arguments[Consts.SPECIFICATION_NUMBER] = specificationNumber;
      arguments[Consts.SPECIFICATION_VERSION] = specificationVersion;
      arguments[Consts.SPECIFICATION_NAME] = specificationName;
      arguments[Consts.SPECIFICATION_TYPE_NAME] = specificationTypeName;

      arguments[Consts.CALLER_ACTIVITY] = "NewPurchaseOrderDetailsActivity";
      await Get.to(() => const OverriddenResultScreen(), arguments: arguments);
      controller.onResume();
    }
  }

  int get position => widget.position;

  double _ratings = 0.0;

  double get ratings => _ratings;

  // double get ratings => (inspection?.rating ?? 0).toInt().toDouble();

  set ratings(double ratings) {
    _ratings = ratings;
    inspection?.rating = ratings.toInt();
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
        if (editPencilVisibility)
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {},
                child: Icon(
                  Icons.comment,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              if (editPencilVisibility)
                IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.edit_outlined,
                    size: 40,
                    color: AppColors.white,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  NewPurchaseOrderItem get currentNewPurchaseItem =>
      controller.originalData.elementAt(position);

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

  Future<void> onComment() async {
    QualityControlItem? qualityControlItems =
        await dao.findQualityControlDetails(inspectionId);
    String commentStr = qualityControlItems?.qcComments ?? '';
    hasComment = commentStr.trim().isNotEmpty;
    AppAlertDialog.textfiAlert(
      context,
      AppStrings.enterComment,
      '',
      value: hasComment ? commentStr : null,
      onYesTap: (value) async {
        String newComment = (value ?? '').trim();

        if (commentStr != newComment) {
          QualityControlItem? qualityControlItems2 =
              await dao.findQualityControlDetails(inspectionId);

          if (qualityControlItems2 != null) {
            await dao.updateQualityControlComment(inspectionId, newComment);
          }
          hasComment = newComment.trim().isNotEmpty;
        }
        setState(() {});
      },
      windowWidth: MediaQuery.of(context).size.width * 0.9,
      isMultiLine: true,
    );
  }

  Future<void> _onQtyShippedChanged() async {
    String tempQty = _qtyShippedController.text.trim();

    if (tempQty.isNotEmpty) {
      int qtyShipped = int.tryParse(tempQty) ?? 0;

      if (qtyShipped > 0) {
        if (partnerItemSKU != null) {
          QualityControlItem? qualityControlItems = await dao
              .findQualityControlDetails(partnerItemSKU!.inspectionId!);

          int qtyReceived = 0;
          if (qualityControlItems != null) {
            qtyReceived = qtyShipped - qualityControlItems.qtyRejected!;
          }
          await dao.updateQuantityShipped(
              inspectionId, qtyShipped, qtyReceived);

          if (ratings > 0 && qtyShipped > 0) {
            await dao.updateItemSKUInspectionComplete(inspectionId, true);
            await dao.updateInspectionComplete(inspectionId, true);

            await dao.updateSelectedItemSKU(
              inspectionId,
              appStorage.selectedItemSKUList[position].partnerId!,
              appStorage.selectedItemSKUList[position].id!,
              appStorage.selectedItemSKUList[position].sku!,
              appStorage.selectedItemSKUList[position].uniqueItemId!,
              true,
              false,
            );

            setState(() {
              isComplete = true;
              isPartialComplete = false;
            });

            Utils.setInspectionUploadStatus(
                inspectionId, Consts.INSPECTION_UPLOAD_READY);
          }
        }
      }
    }
  }

  Future<void> _onQtyRejectedChanged() async {
    String tempQty = _qtyRejectedController.text;

    if (partnerItemSKU != null) {
      QualityControlItem? qualityControlItems =
          await dao.findQualityControlDetails(partnerItemSKU!.inspectionId!);

      if (tempQty.isNotEmpty) {
        int qtyRejected = int.tryParse(tempQty) ?? 0;
        int qtyReceived = 0;
        if (qualityControlItems != null) {
          qtyReceived = qualityControlItems.qtyShipped! - qtyRejected;
        }
        await dao.updateQuantityRejected(
            inspectionId, qtyRejected, qtyReceived);
      } else {
        if (qualityControlItems != null) {
          await dao.updateQuantityRejected(
              inspectionId, 0, qualityControlItems.qtyShipped!);
        }
      }
    }
  }

  Future<void> asyncTask([bool s = false]) async {
    if (s && fromSetState /*&& valueAssigned.value*/) {
      fromSetState = true;
      return;
    }
    List<InspectionAttachment> picsFromDB =
        await dao.findInspectionAttachmentsByInspectionId(inspectionId);
    this.picsFromDB = picsFromDB;

    fromSetState = true;

    FinishedGoodsItemSKU? selectedItem =
        appStorage.selectedItemSKUList.elementAtOrNull(position);
    if (selectedItem != null) {
      partnerItemSKU = await dao.findPartnerItemSKUPOLine(
          selectedItem.partnerId!,
          selectedItem.sku!,
          selectedItem.poLineNo,
          poNumber);

      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTable(
        selectedItem.partnerId!,
        selectedItem.sku!,
        selectedItem.sku!,
      );
    }

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
    }

    if (partnerItemSKU != null && partnerItemSKU!.inspectionId != null) {
      inspectionId = partnerItemSKU!.inspectionId!;

      QualityControlItem? qualityControlItems =
          await dao.findQualityControlDetails(partnerItemSKU!.inspectionId!);
      if (qualityControlItems != null) {
        layoutQuantityRejectedVisibility = true;
        editPencilEnabled = true;
        if (qualityControlItems.qcComments.isNullOrEmpty()) {
          hasComment = false;
        } else {
          hasComment = true;
        }

        _qtyShippedController.text =
            (qualityControlItems.qtyShipped ?? 0).toString();
        _qtyShippedController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyShippedController.text.length),
        );
        _qtyRejectedController.text =
            (qualityControlItems.qtyRejected ?? 0).toString();
      }

      String? lot_no = await dao.getLotNoFromQCDetails(inspectionId);
      if (lot_no != null) {
        appStorage.selectedItemSKUList.elementAt(position).lotNo = lot_no;
        await dao.updateLotNoPartnerItemSKU(inspectionId, lot_no);
      }

      int time = await dao.getPackDateFromQCDetails(inspectionId);
      if (time != 0) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(time);

        String formattedDateString = DateFormat('MM-dd-yyyy').format(date);

        appStorage.selectedItemSKUList.elementAt(position).packDate =
            formattedDateString;
        await dao.updatePackdatePartnerItemSKU(
            inspectionId, formattedDateString);
        // packDateString = formattedDateString;
        // _packDateController.text = formattedDateString;
      }

      inspection = await dao.findInspectionByID(partnerItemSKU!.inspectionId!);

      if (inspection != null) {
        ratings = (inspection?.rating ?? 0).toDouble();
        _ratings = (inspection?.rating ?? 0).toInt().toDouble();
        informationIconEnabled = true;
        editPencilEnabled = true;

        if (inspection?.result != null &&
            (inspection?.result.equals("RJ") ?? false)) {
          layoutPurchaseOrderColor = AppColors.shareifyGold;
        } else if ((inspection?.result.equals("AC") ?? false) ||
            (inspection?.result.equals("A-") ?? false)) {
          layoutPurchaseOrderColor = AppColors.shareifyGreen;
        } else {
          layoutPurchaseOrderColor = Colors.transparent;
        }

        if (inspection?.result != null) {
          layoutQuantityRejectedVisibility = true;
        }
      }

      isComplete = await dao.isInspectionComplete(
          currentNewPurchaseItem.partnerId!,
          currentNewPurchaseItem.sku!,
          partnerItemSKU!.uniqueId);
      isPartialComplete = await dao.isInspectionPartialComplete(
        currentNewPurchaseItem.partnerId!,
        currentNewPurchaseItem.sku!,
        partnerItemSKU!.uniqueId!,
      );

      if (isComplete || (inspection != null && inspection?.complete == '1')) {
        inspectButtonIcon = Icon(
          Icons.check_circle_outlined,
          color: AppColors.white,
          size: 40,
        );
      } else if (isPartialComplete) {
        inspectButtonIcon = const Icon(
          Icons.pause_circle_outline_outlined,
          size: 40,
        );
      }

      valueAssigned.value = true;
      setState(() {});
    }

    appStorage.specificationAnalyticalList =
        await dao.getSpecificationAnalyticalFromTable(
            specificationNumber!, specificationVersion!);

    for (final SpecificationAnalytical item
        in (appStorage.specificationAnalyticalList ?? [])) {
      if (item.analyticalName?.contains("Branded") ?? false) {
        final SpecificationAnalyticalRequest? dbobj =
            await dao.findSpecAnalyticalObj(inspectionId, item.analyticalID!);

        if (dbobj != null) {
          if (dbobj.sampleTextValue.equals("Yes")) {
            isBranded = "Yes";
            comply = dbobj.comply ?? 'Y';
          } else {
            isBranded = "No";
            comply = dbobj.comply ?? 'N';
          }
        }
        break;
      }
    }

    String inspectionResult = "";
    int overriddenQtyRejected = 0;
    int overriddenQtyReceived = 0;

// Assuming dao is an instance of your DAO class
    inspection = await dao.findInspectionByID(inspectionId);
    if (inspection != null) {
      OverriddenResult? overriddenResult =
          await dao.getOverriddenResult(inspectionId);

      if (overriddenResult != null) {
        inspectionResult = overriddenResult.overriddenResult ?? '';
        overriddenQtyRejected = overriddenResult.newQtyRejected!;
        await dao.updateInspectionResult(
            inspection!.inspectionId!, inspectionResult);

        QualityControlItem? qualityControlItems =
            await dao.findQualityControlDetails(inspection!.inspectionId!);
        if (qualityControlItems != null) {
          overriddenQtyReceived =
              qualityControlItems.qtyShipped! - overriddenQtyRejected;
        }
        await dao.updateQuantityRejected(inspection!.inspectionId!,
            overriddenQtyRejected, overriddenQtyReceived);

        _qtyRejectedController.text = overriddenQtyRejected.toString();
      } else {
        inspectionResult = inspection?.result ?? '';
      }

      if (inspectionResult.isNotEmpty) {
        if (inspectionResult == "RJ" || inspectionResult == AppStrings.reject) {
          layoutPurchaseOrderColor = AppColors.shareifyGold;
        } else if (inspectionResult == "AC" ||
            inspectionResult == AppStrings.accept) {
          layoutPurchaseOrderColor = AppColors.shareifyGreen;
        } else if (inspectionResult == "A-") {
          layoutPurchaseOrderColor = AppColors.shareifyGreen;
        } else if (inspectionResult == "AW" ||
            inspectionResult.equalsIgnoreCase(AppStrings.acceptCondition)) {
          layoutPurchaseOrderColor = AppColors.shareifyGreen;
        }
      }
    }

    if (picsFromDB.isEmpty) {
    } else {}

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

  Color _getBackgroundColor() {
    if (ratings > 0 && ratings <= 2) {
      return Colors.amber.shade200;
    } else if (ratings >= 3 && ratings <= 5) {
      return Colors.green.shade200;
    }
    return Colors.transparent;
  }

  Future<void> createNewInspection(
    String itemSKU,
    int itemSKUId,
    String? lotNo,
    String? packDate,
    String specificationNumber,
    String specificationVersion,
    String specificationName,
    String specificationTypeName,
    int sampleSizeByCount,
    String gtin,
    String poNumber,
    int ratings,
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
      carrierId: carrierID,
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
      rating: ratings,
      poLineNo: poLineNo,
      partnerName: partnerName,
      itemSkuName: itemSkuName,
    );

    try {
      int inspectionId =
          await dao.createInspection(appStorage.currentInspection!);
      appStorage.currentInspection!.inspectionId = inspectionId;
      serverInspectionID = inspectionId;
      return;
    } catch (e) {
      print(e);
    }
    return;
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

  Future<void> onRatingUpdate(double value) async {
    //
    String brandedResult = "";
    ratings = value.ceilToDouble();
    _ratings = value.ceilToDouble();
    appStorage.specificationByItemSKUList =
        await dao.getSpecificationByItemSKUFromTable(
      appStorage.selectedItemSKUList[position].partnerId!,
      appStorage.selectedItemSKUList[position].sku!,
      appStorage.selectedItemSKUList[position].sku!,
    );
    List<SpecificationByItemSKU> specificationByItemSKUList =
        appStorage.specificationByItemSKUList ?? [];
    if (specificationByItemSKUList.isNotEmpty) {
      specificationNumber = specificationByItemSKUList[0].specificationNumber;
      specificationVersion = specificationByItemSKUList[0].specificationVersion;
      specificationName = specificationByItemSKUList[0].specificationName;
      specificationTypeName =
          specificationByItemSKUList[0].specificationTypeName;
      sampleSizeByCount = specificationByItemSKUList[0].sampleSizeByCount;

      if (inspectionId <= 0) {
        // we're creating a new inspection
        if (!isComplete && !isPartialComplete) {
          await createNewInspection(
            currentNewPurchaseItem.sku!,
            appStorage.selectedItemSKUList.elementAt(position).id!,
            currentNewPurchaseItem.lotNumber,
            currentNewPurchaseItem.packDate,
            specificationNumber!,
            specificationVersion!,
            specificationName!,
            specificationTypeName!,
            sampleSizeByCount!,
            "",
            poNumber,
            ratings.toInt(),
            appStorage.selectedItemSKUList.elementAt(position).commodityID!,
            appStorage.selectedItemSKUList.elementAt(position).commodityName!,
            poLineNo,
            appStorage.selectedItemSKUList.elementAt(position).partnerId!,
            appStorage.selectedItemSKUList.elementAt(position).partnerName!,
            currentNewPurchaseItem.description ?? '',
          );

          inspectionId = serverInspectionID!;
        }
      } else {
        await dao.updateInspection(
          serverInspectionID: inspectionId,
          commodityID:
              appStorage.selectedItemSKUList.elementAt(position).commodityID,
          commodityName:
              appStorage.selectedItemSKUList.elementAt(position).commodityName,
          varietyId: null,
          varietyName: "",
          gradeId: 0,
          specificationNumber: specificationNumber,
          specificationVersion: specificationVersion,
          specificationName: specificationName,
          specificationTypeName: specificationTypeName,
          sampleSizeByCount: sampleSizeByCount,
          itemSKU: currentNewPurchaseItem.sku,
          itemSKUId: appStorage.selectedItemSKUList.elementAt(position).id,
          poNumber: poNumber,
          cteType: "",
          itemSkuName: currentNewPurchaseItem.description,
          lotNo: appStorage.selectedItemSKUList[position].lotNo,
          rating: ratings.toInt(),
        );
      }

      if (ratings > 0) {
        informationIconEnabled = true;
        layoutQuantityRejectedVisibility = true;
        editPencilEnabled = true;

        QualityControlItem? qualityControlItems =
            await dao.findQualityControlDetails(inspectionId);
        if (qualityControlItems != null) {
          if (qualityControlItems.qcComments.isNullOrEmpty()) {
            hasComment = false;
          } else {
            hasComment = true;
          }
        }
      }

      appStorage.specificationAnalyticalList =
          await dao.getSpecificationAnalyticalFromTable(
              specificationNumber!, specificationVersion!);
      SpecificationAnalytical? specAnalyticalItem;

      if (appStorage.specificationAnalyticalList != null) {
        for (final SpecificationAnalytical item
            in (appStorage.specificationAnalyticalList ?? [])) {
          if (item.analyticalName?.contains("Quality Check") ?? false) {
            specAnalyticalItem = item;

            if (picsFromDB == null || (picsFromDB ?? []).isEmpty) {
              if ((item.isPictureRequired ?? false) &&
                  (ratings > 0 && ratings <= 2)) {
                AppAlertDialog.confirmationAlert(Get.context!, AppStrings.alert,
                    "At least one picture is required", onYesTap: () {
                  Get.back();
                });
              }
            }

            //dao.deleteSpecAttributesByInspectionId(inspectionId!);
            final SpecificationAnalyticalRequest? dbobj = await dao
                .findSpecAnalyticalObj(inspectionId, item.analyticalID!);
            if (ratings >= 0 && ratings <= 2) {
              if (dbobj != null) {
                await dao.updateSpecificationAttributeNumValue(
                    inspectionId, item.analyticalID!, ratings.toInt(), "N");
              } else {
                await dao.createSpecificationAttributes(
                    inspectionId,
                    item.analyticalID!,
                    "No",
                    ratings.toInt(),
                    "N",
                    "",
                    item.analyticalName!,
                    (item.isPictureRequired ?? false),
                    item.inspectionResult!);
              }
            } else {
              if (dbobj != null) {
                await dao.updateSpecificationAttributeNumValue(
                    inspectionId, item.analyticalID!, ratings.toInt(), "Y");
              } else {
                await dao.createSpecificationAttributes(
                    inspectionId,
                    item.analyticalID!,
                    "Yes",
                    ratings.toInt(),
                    "Y",
                    "",
                    item.analyticalName!,
                    (item.isPictureRequired ?? false),
                    item.inspectionResult!);
              }
            }
          } else if (item.analyticalName?.contains("Branded") ?? false) {
            final SpecificationAnalyticalRequest? dbobj = await dao
                .findSpecAnalyticalObj(inspectionId, item.analyticalID!);

            comply = "Y";
            if (comply.equals("Y")) {
              comply = "Y";
            } else {
              comply = "N";
            }

            if (item.inspectionResult!.equals("Y") && comply.equals("N")) {
              brandedResult = "RJ";
            }

            if (isBranded.isNotEmpty) {
              if (dbobj != null) {
                await dao.updateSpecificationAttributeBrandedValue(
                    inspectionId, item.analyticalID!, isBranded, comply);
              } else {
                await dao.createSpecificationAttributes(
                    inspectionId,
                    item.analyticalID!,
                    isBranded,
                    0,
                    comply,
                    "",
                    item.analyticalName!,
                    (item.isPictureRequired ?? false),
                    item.inspectionResult!);
              }
            }
          } else {
            final SpecificationAnalyticalRequest? dbobj = await dao
                .findSpecAnalyticalObj(inspectionId, item.analyticalID!);
            if (dbobj != null) {
              //dao.updateSpecificationAttributeNumValue(inspectionId!, item.analyticalID!, (int) ratings, "Y");
            } else {
              if (item.specTargetTextDefault.equals("Y")) {
                await dao.createSpecificationAttributes(
                    inspectionId,
                    item.analyticalID!,
                    "Yes",
                    0,
                    "Y",
                    "",
                    item.analyticalName!,
                    (item.isPictureRequired ?? false),
                    item.inspectionResult!);
              } else if (item.specTargetTextDefault.equals("N")) {
                await dao.createSpecificationAttributes(
                    inspectionId,
                    item.analyticalID!,
                    "No",
                    0,
                    "Y",
                    "",
                    item.analyticalName!,
                    (item.isPictureRequired ?? false),
                    item.inspectionResult!);
              } else if (item.specTargetTextDefault.equals("N/A")) {
                await dao.createSpecificationAttributes(
                    inspectionId,
                    item.analyticalID!,
                    "N/A",
                    0,
                    "N/A",
                    "",
                    item.analyticalName!,
                    (item.isPictureRequired ?? false),
                    item.inspectionResult!);
              }
            }
          }
        }
      }
      await dao.createOrUpdateInspectionSpecification(inspectionId,
          specificationNumber, specificationVersion, specificationName);

      await dao.createPartnerItemSKU(
          appStorage.selectedItemSKUList.elementAt(position).partnerId!,
          appStorage.selectedItemSKUList.elementAt(position).sku!,
          currentNewPurchaseItem.lotNumber,
          "",
          inspectionId,
          "",
          appStorage.selectedItemSKUList.elementAt(position).uniqueItemId!,
          appStorage.selectedItemSKUList.elementAt(position).poLineNo ??
              poLineNo,
          poNumber);

      await dao
          .copyTempTrailerTemperaturesToInspectionTrailerTemperatureTableByPartnerID(
              inspectionId, carrierID, poNumber);
      await dao
          .copyTempTrailerTemperaturesDetailsToInspectionTrailerTemperatureDetailsTableByPartnerID(
              inspectionId, carrierID, poNumber);

      int? qcID;
      int qtyRejected = 0;
      int qtyReceived = 0;
      int qtyShipped = 0;

      QualityControlItem? qualityControlItems =
          await dao.findQualityControlDetails(inspectionId);
      if (qualityControlItems != null) {
        qcID = qualityControlItems.qcID;
        qtyShipped = qualityControlItems.qtyShipped!;
        qtyRejected = qualityControlItems.qtyRejected!;
        qtyReceived = qualityControlItems.qtyReceived!;
      }
      // No quality control id, create a new one in the database.
      if (qcID == null) {
        if ((appStorage.selectedItemSKUList.elementAt(position).quantity ?? 0) >
            0) {
          qtyShipped =
              appStorage.selectedItemSKUList.elementAt(position).quantity!;

          if (ratings >= 0 && ratings <= 2) {
            qtyRejected = qtyShipped;
            qtyReceived = 0;
          } else {
            qtyRejected = 0;
            qtyReceived = qtyShipped;
          }

          qcID = await dao.createQualityControl(
            inspectionId: inspectionId,
            brandID: 0,
            originID: 0,
            qtyShipped: qtyShipped,
            uomQtyShippedID:
                appStorage.selectedItemSKUList.elementAt(position).quantityUOM!,
            poNumber: poNumber,
            pulpTempMin: 0,
            pulpTempMax: 0,
            recorderTempMin: 0,
            recorderTempMax: 0,
            rpc: "",
            claimFiledAgainst: "",
            qtyRejected: qtyRejected,
            uomQtyRejectedID:
                appStorage.selectedItemSKUList.elementAt(position).quantityUOM!,
            reasonID: 0,
            qcComments: "",
            qtyReceived: qtyReceived,
            uomQtyReceivedID:
                appStorage.selectedItemSKUList.elementAt(position).quantityUOM!,
            specificationName: specificationName!,
            packDate: 0,
            seal_no: appStorage.currentSealNumber!,
            lot_no: currentNewPurchaseItem.lotNumber!,
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

          await dao.updateItemSKUInspectionComplete(inspectionId, true);
          await dao.updateInspectionComplete(inspectionId, true);
          await dao.updateSelectedItemSKU(
              inspectionId,
              appStorage.selectedItemSKUList.elementAt(position).partnerId!,
              appStorage.selectedItemSKUList.elementAt(position).id!,
              appStorage.selectedItemSKUList.elementAt(position).sku!,
              appStorage.selectedItemSKUList.elementAt(position).uniqueItemId!,
              true,
              false);

          Utils.setInspectionUploadStatus(
              inspectionId, Consts.INSPECTION_UPLOAD_READY);

          isComplete = true;
          isPartialComplete = false;

          _qtyShippedController.text = qtyShipped.toString();
          _qtyRejectedController.text = qtyRejected.toString();
        } else {
          String qtyShippedString = _qtyShippedController.text.toString();
          String qtyRejectedString = _qtyRejectedController.text.toString();

          if (qtyShippedString != null && !qtyShippedString.equals("")) {
            qtyShipped = int.parse(qtyShippedString);
            qtyReceived = qtyShipped;
          }

          if (qtyRejectedString != null && !qtyRejectedString.equals("")) {
            qtyRejected = int.parse(qtyRejectedString);
            qtyReceived = qtyShipped - qtyRejected;
          }

          qcID = await dao.createQualityControl(
            inspectionId: inspectionId,
            brandID: 0,
            originID: 0,
            qtyShipped: qtyShipped,
            uomQtyShippedID: 0,
            poNumber: poNumber,
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
            lot_no: currentNewPurchaseItem.lotNumber ?? '',
            qcdOpen1: null,
            qcdOpen2: "",
            qcdOpen3: "",
            qcdOpen4: "",
            workDate: 0,
            gtin: null,
            lot_size: 0,
            shipDate: 0,
            dateType: "",
            glnType: '',
            gln: '',
          );

          await dao.updateItemSKUInspectionComplete(inspectionId, false);
          await dao.updateInspectionComplete(inspectionId, false);
          await dao.updateSelectedItemSKU(
              inspectionId,
              appStorage.selectedItemSKUList.elementAt(position).partnerId!,
              appStorage.selectedItemSKUList.elementAt(position).id!,
              appStorage.selectedItemSKUList.elementAt(position).sku!,
              appStorage.selectedItemSKUList.elementAt(position).uniqueItemId!,
              false,
              true);
          isPartialComplete = true;
          isComplete = false;

          _qtyShippedController.text = qtyShipped.toString();
          _qtyRejectedController.text = qtyRejected.toString();
        }
      } else {
        await dao.updateItemSKUInspectionComplete(inspectionId, true);
        await dao.updateInspectionComplete(inspectionId, true);

        await dao.updateSelectedItemSKU(
            inspectionId,
            appStorage.selectedItemSKUList.elementAt(position).partnerId!,
            appStorage.selectedItemSKUList.elementAt(position).id!,
            appStorage.selectedItemSKUList.elementAt(position).sku!,
            appStorage.selectedItemSKUList.elementAt(position).uniqueItemId!,
            true,
            false);

        isComplete = true;
        isPartialComplete = false;

        Utils.setInspectionUploadStatus(
            inspectionId, Consts.INSPECTION_UPLOAD_READY);
      }

      inspection = await dao.findInspectionByID(inspectionId);

      if (ratings >= 0 && ratings <= 2) {
        if (inspection != null &&
            inspection?.result != null &&
            (inspection?.result.equals("RJ") ?? false)) {
          ResultRejectionDetail? resultRejectionDetail =
              await dao.getResultRejectionDetails(inspectionId);
          String rejectReason = resultRejectionDetail?.resultReason ?? '';
          if (rejectReason.isNotEmpty &&
              !rejectReason.contains("Quality Check")) {
            rejectReason += "\nQuality Check = N";
            await dao.createOrUpdateResultReasonDetails(
                inspectionId, "RJ", rejectReason, "");
          }
          if (rejectReason.isEmpty) {
            rejectReason += "Quality Check = N";
            await dao.createOrUpdateResultReasonDetails(
                inspectionId, "RJ", rejectReason, "");
          }
        } else {
          await dao.updateInspectionResult(inspectionId, "RJ");
          if (specAnalyticalItem != null) {
            await dao.createOrUpdateResultReasonDetails(
                inspectionId, "RJ", "Quality Check = N", "");
          }
        }

        if (specAnalyticalItem != null) {
          //dao.createIsPictureReqSpecAttribute(inspectionId!, "RJ", specAnalyticalItem.analyticalName!, specAnalyticalItem.isPictureRequired());
        }
        qtyRejectedEnabled = true;
        await dao.updateQuantityRejected(inspectionId, qtyShipped, 0);
        _qtyRejectedController.text = qtyShipped.toString();
        layoutPurchaseOrderColor = AppColors.shareifyGold;
      } else if (ratings >= 3 && ratings <= 5) {
        String rejectReason = "";

        ResultRejectionDetail? resultRejectionDetail =
            await dao.getResultRejectionDetails(inspectionId);
        if (resultRejectionDetail != null) {
          rejectReason = resultRejectionDetail.resultReason ?? '';
        }

        if (brandedResult == "RJ") {
          if (inspection != null &&
              inspection?.result != null &&
              (inspection?.result.equals("RJ") ?? false)) {
            if (rejectReason.isNotEmpty &&
                !rejectReason.contains("Branded = N")) {
              rejectReason += "\nBranded = N";
              await dao.createOrUpdateResultReasonDetails(
                  inspectionId, "RJ", rejectReason, "");
            }
          } else {
            await dao.updateInspectionResult(inspectionId, "RJ");
            if (specAnalyticalItem != null) {
              await dao.createOrUpdateResultReasonDetails(
                  inspectionId, "RJ", "Branded " + "= N", "");
            }
          }

          if (specAnalyticalItem != null) {}
          qtyRejectedEnabled = true;
          await dao.updateQuantityRejected(inspectionId, qtyShipped, 0);
          _qtyRejectedController.text = qtyShipped.toString();
          layoutPurchaseOrderColor = AppColors.shareifyGold;
        } else {
          if (inspection != null && inspection?.result != null) {
            if (inspection?.result.equals("RJ") ?? false) {
              if (rejectReason.isNotEmpty &&
                  rejectReason.contains("Quality Check")) {
                String inputString = rejectReason;
                String targetSubstring = "\u25BA";
                int occurrences =
                    countOccurrences(inputString, targetSubstring);

                if (occurrences < 2) {
                  await dao.updateInspectionResult(inspectionId, "AC");
                  await dao.createOrUpdateResultReasonDetails(
                      inspectionId, "AC", "", "");
                  qtyRejectedEnabled = false;
                  await dao.updateQuantityRejected(inspectionId, 0, qtyShipped);
                  _qtyRejectedController.text = '0';
                  layoutPurchaseOrderColor = AppColors.shareifyGreen;
                }
              }
            }

            if (!inspection!.result.equals("RJ") || rejectReason.equals("")) {
              await dao.updateInspectionResult(inspectionId, "AC");
              qtyRejectedEnabled = false;
              await dao.updateQuantityRejected(inspectionId, 0, qtyShipped);
              _qtyRejectedController.text = '0';
              layoutPurchaseOrderColor = AppColors.shareifyGreen;
            }
          } else {
            await dao.updateInspectionResult(inspectionId, "AC");
            qtyRejectedEnabled = false;
            await dao.updateQuantityRejected(inspectionId, 0, qtyShipped);
            _qtyRejectedController.text = 0.toString();
            layoutPurchaseOrderColor = AppColors.shareifyGreen;
          }
        }
      } else {
        layoutPurchaseOrderColor = Colors.transparent;
      }
    } else {
      AppAlertDialog.validateAlerts(
        context,
        AppStrings.alert,
        'No specification found for item ${controller.filteredInspectionsList[position].sku}',
      );
    }
    //
    widget.onRatingChanged(value);
    setState(() {});
  }

  void cameraIconTap() {
    Map<String, dynamic> arguments = {
      Consts.PARTNER_NAME: appStorage.selectedItemSKUList[position].partnerName,
      Consts.PARTNER_ID: appStorage.selectedItemSKUList[position].partnerId,
      Consts.CARRIER_NAME: carrierName,
      Consts.CARRIER_ID: carrierID,
      Consts.COMMODITY_NAME: commodityName,
      Consts.COMMODITY_ID: commodityID,
      Consts.VIEW_ONLY_MODE: false,
      Consts.INSPECTION_ID: inspectionId,
      Consts.PO_NUMBER: poNumber,
      Consts.CALLER_ACTIVITY: "NewPurchaseOrderDetailsActivity",
    };
    final String tag = DateTime.now().millisecondsSinceEpoch.toString();
    Get.to(() => InspectionPhotos(tag: tag), arguments: arguments);
  }

  Future<void> onRadioButtonChange(String selectedValue) async {
    isCheckedList[position] = (selectedValue == "Yes");

    // find which radio button is selected
    appStorage.specificationAnalyticalList =
        await dao.getSpecificationAnalyticalFromTable(
            specificationNumber!, specificationVersion!);

    if (selectedValue == "Yes") {
      isBranded = "Yes";
      comply = "Y";
    }
    //
    else if (selectedValue == "No") {
      isBranded = "No";
      comply = "N";
    }

    if (inspectionId > 0) {
      appStorage.specificationByItemSKUList =
          await dao.getSpecificationByItemSKUFromTable(
        appStorage.selectedItemSKUList.elementAt(position).partnerId!,
        appStorage.selectedItemSKUList.elementAt(position).sku!,
        appStorage.selectedItemSKUList.elementAt(position).sku!,
      );

      if (appStorage.specificationByItemSKUList != null &&
          (appStorage.specificationByItemSKUList ?? []).isNotEmpty) {
        specificationNumber = appStorage.specificationByItemSKUList
            ?.elementAt(0)
            .specificationNumber;
        specificationVersion = appStorage.specificationByItemSKUList
            ?.elementAt(0)
            .specificationVersion;
      }
      //appStorage.specificationAnalyticalList = dao.getSpecificationAnalyticalFromTable(specificationNumber, specificationVersion);

      if (appStorage.specificationAnalyticalList != null) {
        for (final SpecificationAnalytical item
            in (appStorage.specificationAnalyticalList ?? [])) {
          if (item.analyticalName?.contains("Branded") ?? false) {
            inspection = await dao.findInspectionByID(inspectionId);

            final SpecificationAnalyticalRequest? dbobj = await dao
                .findSpecAnalyticalObj(inspectionId, item.analyticalID!);

            if (dbobj != null) {
              await dao.updateSpecificationAttributeBrandedValue(
                  inspectionId, item.analyticalID!, isBranded, comply);
            } else {
              await dao.createSpecificationAttributes(
                  inspectionId,
                  item.analyticalID!,
                  isBranded,
                  0,
                  comply,
                  "",
                  item.analyticalName!,
                  (item.isPictureRequired ?? false),
                  item.inspectionResult ?? '');
            }

            if (item.inspectionResult.equals("Y") && comply.equals("N")) {
              if (inspection != null &&
                  inspection?.result != null &&
                  (inspection!.result.equals("RJ") ?? false)) {
                ResultRejectionDetail? resultRejectionDetail =
                    await dao.getResultRejectionDetails(inspectionId);
                String? rejectReason = resultRejectionDetail?.resultReason;
                if (rejectReason != null &&
                    rejectReason.isNotEmpty &&
                    !rejectReason.contains("Branded = N")) {
                  rejectReason += "\n Branded = N";
                  await dao.createOrUpdateResultReasonDetails(
                      inspectionId, "RJ", rejectReason, "");
                }
              } else {
                await dao.updateInspectionResult(inspectionId, "RJ");
                await dao.createOrUpdateResultReasonDetails(
                    inspectionId, "RJ", "Branded = N", "");
              }

              //dao.createIsPictureReqSpecAttribute(inspectionId, "RJ", specAnalyticalItem.getAnalyticalName(), specAnalyticalItem.isPictureRequired());
              QualityControlItem? qualityControlItems =
                  await dao.findQualityControlDetails(inspectionId);

              qtyRejectedEnabled = true;
              if (qualityControlItems != null) {
                await dao.updateQuantityRejected(
                    inspectionId, qualityControlItems.qtyShipped!, 0);
                _qtyRejectedController.text =
                    (qualityControlItems.qtyShipped ?? '').toString();
              }
              layoutPurchaseOrderColor = AppColors.shareifyGold;
            } else if (item.inspectionResult.equals("Y") &&
                comply.equals("Y")) {
              String result = "";

              if (inspection != null &&
                  inspection?.result != null &&
                  (inspection?.result.equals("RJ") ?? false)) {
                ResultRejectionDetail? resultRejectionDetail =
                    await dao.getResultRejectionDetails(inspectionId);

                if (resultRejectionDetail?.resultReason.equals("Branded = N") ??
                    false) {
                  result = "AC";
                  await dao.updateInspectionResult(inspectionId, "AC");
                  await dao.createOrUpdateResultReasonDetails(
                      inspectionId, "AC", "", "");
                } else {
                  result = "RJ";
                }
              }

              if (!result.equals("RJ")) {
                qtyRejectedEnabled = false;
                QualityControlItem? qualityControlItems =
                    await dao.findQualityControlDetails(inspectionId);

                if (qualityControlItems != null) {
                  await dao.updateQuantityRejected(
                      inspectionId, 0, qualityControlItems.qtyShipped!);
                  _qtyRejectedController.text = '0';
                }
                layoutPurchaseOrderColor = AppColors.shareifyGreen;
              }
            }
            break;
          }
        }
      }
    }
    setState(() {});
  }

  Future<void> onSkuTap() async {
    bool checkItemSKUAndLot = false;
    bool isValid = true;

    inspection = await dao.findInspectionByID(inspectionId);

    if (inspection != null) {
      if (appStorage.specificationAnalyticalList != null) {
        for (final SpecificationAnalytical item
            in (appStorage.specificationAnalyticalList ?? [])) {
          if (item.analyticalName?.contains("Branded") ?? false) {
            final SpecificationAnalyticalRequest? dbobj = await dao
                .findSpecAnalyticalObj(inspectionId, item.analyticalID!);

            if (dbobj == null) {
              isValid = false;

              AppAlertDialog.validateAlerts(
                  Get.context!,
                  AppStrings.alert,
                  "The inspected row require Branded Y/N. " +
                      "\n\nIs the product in a PFG private label box?" +
                      "\n(White box for Peak or Brown box for Growers Choice)");
            }
            break;
          }
        }
      }
    }

    if (isValid) {
      if (isComplete || isPartialComplete || !checkItemSKUAndLot) {
        String? current_lot_number = currentInspectionsItem.lotNumber;
        String? current_Item_SKU = currentInspectionsItem.sku;
        String? current_Item_SKU_Name = currentInspectionsItem.description;
        String? current_pack_Date = currentInspectionsItem.packDate;
        int? current_Item_SKU_Id = appStorage.selectedItemSKUList[position].id;
        String? current_unique_id =
            appStorage.selectedItemSKUList[position].uniqueItemId;
        int? current_commodity_id =
            appStorage.selectedItemSKUList[position].commodityID;
        String? current_commodity_name =
            appStorage.selectedItemSKUList[position].commodityName;
        String? current_gtin = appStorage.selectedItemSKUList[position].gtin;
        int? poLineNo = appStorage.selectedItemSKUList[position].poLineNo;

        Map<String, dynamic> bundle = {
          "current_lot_number": current_lot_number,
          "current_Item_SKU": current_Item_SKU,
          "current_Item_SKU_Name": current_Item_SKU_Name,
          "current_pack_Date": current_pack_Date,
          "current_Item_SKU_Id": current_Item_SKU_Id,
          // "current_lot_size": current_lot_size,
          "current_unique_id": current_unique_id,
          "current_gtin": current_gtin,
          Consts.COMMODITY_ID: current_commodity_id,
          Consts.COMMODITY_NAME: current_commodity_name
        };

        if (!isComplete && !isPartialComplete) {
          appStorage.selectedItemSKUList[position].lotNo = current_lot_number;
          appStorage.selectedItemSKUList[position].poNo =
              currentInspectionsItem.poNumber;
        }

        appStorage.specificationByItemSKUList =
            await dao.getSpecificationByItemSKUFromTable(
                currentInspectionsItem.partnerId!,
                currentInspectionsItem.sku!,
                currentInspectionsItem.sku!);

        if (appStorage.specificationByItemSKUList != null &&
            (appStorage.specificationByItemSKUList ?? []).isNotEmpty) {
          specificationNumber = appStorage.specificationByItemSKUList
              ?.elementAt(0)
              .specificationNumber;
          specificationVersion = appStorage.specificationByItemSKUList
              ?.elementAt(0)
              .specificationVersion;
          specificationName = appStorage.specificationByItemSKUList
              ?.elementAt(0)
              .specificationName;
          specificationTypeName = appStorage.specificationByItemSKUList
              ?.elementAt(0)
              .specificationTypeName;

          sampleSizeByCount = appStorage.specificationByItemSKUList
              ?.elementAt(0)
              .sampleSizeByCount;
        }

        if (appStorage.specificationByItemSKUList != null &&
            (appStorage.specificationByItemSKUList ?? []).isNotEmpty) {
          bool isComplete = await dao.isInspectionComplete(
              currentInspectionsItem.partnerId!,
              current_Item_SKU!,
              current_unique_id);
          bool ispartialComplete = await dao.isInspectionPartialComplete(
              currentInspectionsItem.partnerId!,
              current_Item_SKU,
              current_unique_id!);

          Map<String, dynamic> bundle = {};
          if (inspectionId <= 0) {
            bundle[Consts.SERVER_INSPECTION_ID] = -1;
          } else {
            bundle[Consts.SERVER_INSPECTION_ID] = inspectionId;
            bundle[Consts.SPECIFICATION_NUMBER] = specificationNumber;
            bundle[Consts.SPECIFICATION_VERSION] = specificationVersion;
            bundle[Consts.SPECIFICATION_NAME] = specificationName;
            bundle[Consts.SPECIFICATION_TYPE_NAME] = specificationTypeName;
          }
          bundle[Consts.PO_NUMBER] = poNumber;
          bundle[Consts.SEAL_NUMBER] = widget.sealNumber;
          bundle[Consts.PARTNER_NAME] =
              appStorage.selectedItemSKUList[position].partnerName;
          bundle[Consts.PARTNER_ID] =
              appStorage.selectedItemSKUList[position].partnerId;
          bundle[Consts.CARRIER_NAME] = carrierName;
          bundle[Consts.CARRIER_ID] = carrierID;
          bundle[Consts.LOT_NO] = current_lot_number;
          bundle[Consts.ITEM_SKU] = current_Item_SKU;
          bundle[Consts.ITEM_SKU_NAME] = current_Item_SKU_Name;
          bundle[Consts.ITEM_SKU_ID] = current_Item_SKU_Id;
          bundle[Consts.PACK_DATE] = current_pack_Date;
          bundle[Consts.COMPLETED] = isComplete;
          bundle[Consts.PARTIAL_COMPLETED] = ispartialComplete;
          //bundle[Consts.LOT_SIZE] = current_lot_size;
          bundle[Consts.COMMODITY_ID] = current_commodity_id;
          bundle[Consts.COMMODITY_NAME] = current_commodity_name;
          bundle[Consts.ITEM_UNIQUE_ID] = current_unique_id;
          bundle[Consts.GTIN] = current_gtin;
          bundle[Consts.PO_LINE_NO] = poLineNo;

          bundle[Consts.CALLER_ACTIVITY] = "NewPurchaseOrderDetailsActivity";
          bundle[Consts.IS1STTIMEACTIVITY] = "PurchaseOrderDetailsActivity";

          final String tag = DateTime.now().millisecondsSinceEpoch.toString();
          await Get.to(
            () => QCDetailsShortFormScreen(tag: tag),
            arguments: bundle,
          );
          controller.onResume();
        }
        //
        else {
          AppAlertDialog.validateAlerts(
            context,
            AppStrings.alert,
            'No specification found for item ${controller.filteredInspectionsList[position].sku}',
          );
        }
      }
    }
  }

  NewPurchaseOrderItem get currentInspectionsItem =>
      controller.filteredInspectionsList[position];
}
