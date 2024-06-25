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
    required this.commodityID,
    required this.carrierID,
    required this.carrierName,
    required this.commodityName,
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

  String lotNoString = '';

  bool editPencilEnabled = false;
  bool qtyRejectedEnabled = false;

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
  String? resultButton;
  bool resultButtonVisibility = false;
  bool layoutQuantityRejectedVisibility = false;
  String packDateString = '';
  String poNumberString = '';
  bool poNumberVisibility = true;
  String isBranded = '';

  Color resultButtonColor = AppColors.white;

  Icon informationIcon = Icon(
    Icons.info_rounded,
    color: AppColors.white,
    size: 40,
  );
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
  RxBool valueAssigned = false.obs;
  bool fromSetState = false;

  late TextEditingController _lotNumberController;
  late TextEditingController _packDateController;
  late TextEditingController _qtyShippedController;
  late TextEditingController _qtyRejectedController;

  int? serverInspectionID;

  @override
  void initState() {
    poLineNo = controller.filteredInspectionsList[position].poLineNo ?? 0;
    packDateString = controller.filteredInspectionsList[position].packDate ??
        DateTime.now().toIso8601String();
    isCheckedList = List<bool>.filled(controller.originalData.length, false);
    _lotNumberController =
        TextEditingController(text: widget.goodsItem.lotNumber);
    lotNoString = (widget.goodsItem.lotNumber ?? '').toString();
    _packDateController =
        TextEditingController(text: widget.goodsItem.packDate);
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
    _lotNumberController.dispose();
    _packDateController.dispose();
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
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'SKU: ${widget.goodsItem.sku}',
                  style: const TextStyle(
                      fontSize: 16, decoration: TextDecoration.underline),
                ),
                if (widget.goodsItem.ftl == "1")
                  const Text('FTL', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _lotNumberController,
                        decoration:
                            const InputDecoration(labelText: 'Lot Number'),
                        onChanged: widget.onLotNumberChanged,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _packDateController,
                        decoration:
                            const InputDecoration(labelText: 'Pack Date'),
                        onChanged: widget.onPackDateChanged,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _qtyShippedController,
                        decoration:
                            const InputDecoration(labelText: 'Qty Shipped'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => widget
                            .onQuantityShippedChanged(int.tryParse(value) ?? 0),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _qtyRejectedController,
                        decoration:
                            const InputDecoration(labelText: 'Qty Rejected'),
                        keyboardType: TextInputType.number,
                        onChanged: (value) => widget.onQuantityRejectedChanged(
                            int.tryParse(value) ?? 0),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    RatingBar.builder(
                      initialRating: ratings,
                      minRating: 0,
                      direction: Axis.horizontal,
                      allowHalfRating: false,
                      itemCount: 5,
                      itemSize: 30,
                      itemBuilder: (context, _) => const Icon(
                        Icons.star,
                        color: Colors.amber,
                      ),
                      onRatingUpdate: (value) async {
                        onRatingUpdate(value);
                      },
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: widget.onInfoPressed,
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: widget.onInspectPressed,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Branded: '),
                    Radio<bool>(
                      value: isBranded == "Yes",
                      groupValue: true,
                      onChanged: (value) => widget.onBrandedChanged(value!),
                    ),
                    const Text('Yes'),
                    Radio<bool>(
                      value: isBranded == "No",
                      groupValue: false,
                      onChanged: (value) => widget.onBrandedChanged(value!),
                    ),
                    const Text('No'),
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  int get position => widget.position;

  double get ratings => (inspection?.rating ?? 0).toInt().toDouble();

  set ratings(double ratings) {
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
                  onPressed: () async {
                    Inspection? inspection =
                        await dao.findInspectionByID(inspectionId);
                    if (inspection != null && inspection.result != null) {
                      Map<String, dynamic> arguments = {
                        Consts.SERVER_INSPECTION_ID: inspection.inspectionId,
                        Consts.PARTNER_NAME: appStorage.selectedItemSKUList
                            .elementAt(position)
                            .partnerName,
                        Consts.PARTNER_ID: appStorage.selectedItemSKUList
                            .elementAt(position)
                            .partnerId,
                        Consts.CARRIER_NAME: carrierName,
                        Consts.CARRIER_ID: carrierID,
                        Consts.COMMODITY_NAME: appStorage.selectedItemSKUList
                            .elementAt(position)
                            .commodityName,
                        Consts.COMMODITY_ID: appStorage.selectedItemSKUList
                            .elementAt(position)
                            .commodityID,
                        Consts.INSPECTION_RESULT: inspection.result,
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
                          (appStorage.specificationByItemSKUList ?? [])
                              .isNotEmpty) {
                        specificationNumber = appStorage
                            .specificationByItemSKUList
                            ?.elementAt(0)
                            .specificationNumber;
                        specificationVersion = appStorage
                            .specificationByItemSKUList
                            ?.elementAt(0)
                            .specificationVersion;
                        specificationName = appStorage
                            .specificationByItemSKUList
                            ?.elementAt(0)
                            .specificationName;
                        specificationTypeName = appStorage
                            .specificationByItemSKUList
                            ?.elementAt(0)
                            .specificationTypeName;
                      }

                      arguments[Consts.SPECIFICATION_NUMBER] =
                          specificationNumber;
                      arguments[Consts.SPECIFICATION_VERSION] =
                          specificationVersion;
                      arguments[Consts.SPECIFICATION_NAME] = specificationName;
                      arguments[Consts.SPECIFICATION_TYPE_NAME] =
                          specificationTypeName;

                      arguments[Consts.CALLER_ACTIVITY] =
                          "NewPurchaseOrderDetailsActivity";
                      Get.to(() => const OverriddenResultScreen(),
                          arguments: arguments);
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

  void onComment() {
    // todo: implement below
    String comment = '';
    bool hasComment = false;
    AppAlertDialog.textfiAlert(
      context,
      AppStrings.enterComment,
      '',
      value: hasComment ? comment : null,
      onYesTap: (value) async {
        String commentStr = (value ?? '').trim();

        QualityControlItem? qualityControlItems2 =
            await dao.findQualityControlDetails(inspectionId);

        if (qualityControlItems2 != null) {
          await dao.updateQualityControlComment(inspectionId, commentStr);
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
          selectedItem.poLineNo!,
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

    /// change
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
    if (partnerItemSKU != null && partnerItemSKU!.inspectionId != null) {
      inspectionId = partnerItemSKU!.inspectionId!;

      QualityControlItem? qualityControlItems =
          await dao.findQualityControlDetails(partnerItemSKU!.inspectionId!);
      if (qualityControlItems != null) {
        layoutQuantityRejectedVisibility = true;
        editPencilEnabled = true;
        if (qualityControlItems.qcComments.isNullOrEmpty()) {
          // todo: set comment icon based on the path
          // icon_comment.setImageDrawable(
          //     context.getDrawable(
          //         R.drawable.spec_comment_added));
          // icon_comment.setImageDrawable(context.getDrawable(R.drawable.spec_comment));
        } else {
          // todo: set comment icon based on the path
          // icon_comment.setImageDrawable(
          //     context.getDrawable(
          //         R.drawable.spec_comment_added));
          // icon_comment.setImageDrawable(context.getDrawable(R.drawable.spec_comment_added));
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
        lotNoString = lot_no;
      }

      int time = await dao.getPackDateFromQCDetails(inspectionId);
      if (time != 0) {
        DateTime date = DateTime.fromMillisecondsSinceEpoch(time);

        String formattedDateString = DateFormat('MM-dd-yyyy').format(date);

        appStorage.selectedItemSKUList.elementAt(position).packDate =
            formattedDateString;
        dao.updatePackdatePartnerItemSKU(inspectionId, formattedDateString);
        packDateString = formattedDateString;
        _packDateController.text = formattedDateString;
      }

      Inspection? inspection =
          await dao.findInspectionByID(partnerItemSKU!.inspectionId!);

      if (inspection != null) {
        ratings = inspection.rating.toDouble();
        informationIconEnabled = true;
        editPencilEnabled = true;

        if (inspection.result != null && inspection.result.equals("RJ")) {
          layoutPurchaseOrderColor = AppColors.shareifyGold;
        } else if (inspection.result.equals("AC") ||
            inspection.result.equals("A-")) {
          layoutPurchaseOrderColor = AppColors.shareifyGreen;
        } else {
          layoutPurchaseOrderColor = Colors.transparent;
        }

        if (inspection.result != null) {
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

      if (isComplete || (inspection != null && inspection.complete == '1')) {
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
    Inspection? inspection = await dao.findInspectionByID(inspectionId);
    if (inspection != null) {
      OverriddenResult? overriddenResult =
          await dao.getOverriddenResult(inspectionId);

      if (overriddenResult != null) {
        inspectionResult = overriddenResult.overriddenResult ?? '';
        overriddenQtyRejected = overriddenResult.newQtyRejected!;
        await dao.updateInspectionResult(
            inspection.inspectionId!, inspectionResult);

        QualityControlItem? qualityControlItems =
            await dao.findQualityControlDetails(inspection.inspectionId!);
        if (qualityControlItems != null) {
          overriddenQtyReceived =
              qualityControlItems.qtyShipped! - overriddenQtyRejected;
        }
        await dao.updateQuantityRejected(inspection.inspectionId!,
            overriddenQtyRejected, overriddenQtyReceived);

        _qtyRejectedController.text = overriddenQtyRejected.toString();
      } else {
        inspectionResult = inspection.result ?? '';
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
      informationIcon = Icon(
        Icons.camera_alt,
        color: AppColors.white,
        size: 40,
      );
    } else {
      informationIcon = Icon(
        Icons.photo_size_select_actual_outlined,
        color: AppColors.white,
        size: 40,
      );
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
    String lotNo,
    String packDate,
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

    List<SpecificationByItemSKU> specificationByItemSKUList =
        await dao.getSpecificationByItemSKUFromTable(
      appStorage.selectedItemSKUList[position].partnerId!,
      appStorage.selectedItemSKUList[position].sku!,
      appStorage.selectedItemSKUList[position].sku!,
    );

    if (specificationByItemSKUList.isNotEmpty) {
      String? specificationNumber =
          specificationByItemSKUList[0].specificationNumber;
      String? specificationVersion =
          specificationByItemSKUList[0].specificationVersion;
      String? specificationName =
          specificationByItemSKUList[0].specificationName;
      String? specificationTypeName =
          specificationByItemSKUList[0].specificationTypeName;
      int? sampleSizeByCount = specificationByItemSKUList[0].sampleSizeByCount;

      if (inspectionId <= 0) {
        // we're creating a new inspection
        if (!isComplete && !isPartialComplete) {
          await createNewInspection(
            currentNewPurchaseItem.sku!,
            appStorage.selectedItemSKUList.elementAt(position).id!,
            currentNewPurchaseItem.lotNumber!,
            currentNewPurchaseItem.packDate!,
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
            currentNewPurchaseItem.description!,
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
            // todo: set comment icon based on the path
            // comment.trim().isNotEmpty
            //     ? AppImages.ic_specCommentsAdded
            //     : AppImages.ic_specComments
            // icon_comment.setImageDrawable(context
            //     .getDrawable(R.drawable.spec_comment));
          } else {
            // todo: set comment icon based on the path
            // icon_comment.setImageDrawable(
            //     context.getDrawable(
            //         R.drawable.spec_comment_added));
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

            if (isBranded != null) {
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
          currentNewPurchaseItem.lotNumber!,
          "",
          inspectionId,
          "",
          appStorage.selectedItemSKUList.elementAt(position).uniqueItemId!,
          appStorage.selectedItemSKUList.elementAt(position).poLineNo!,
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
        if (appStorage.selectedItemSKUList.elementAt(position).quantity! > 0) {
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

      Inspection? inspection = await dao.findInspectionByID(inspectionId);

      if (ratings >= 0 && ratings <= 2) {
        if (inspection != null &&
            inspection.result != null &&
            inspection.result.equals("RJ")) {
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
              inspection.result != null &&
              inspection.result.equals("RJ")) {
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
          if (inspection != null && inspection.result != null) {
            if (inspection.result.equals("RJ")) {
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

            if (!inspection.result.equals("RJ") || rejectReason.equals("")) {
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
        'No specification found for item ${controller.originalData[position].sku}',
      );
    }
    //
    widget.onRatingChanged(value);
  }

  void informationIconTap() {
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
    } else if (selectedValue == "No") {
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
            Inspection? inspection = await dao.findInspectionByID(inspectionId);

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
                  inspection.result != null &&
                  inspection.result.equals("RJ")) {
                ResultRejectionDetail? resultRejectionDetail =
                    await dao.getResultRejectionDetails(inspectionId);
                String? rejectReason = resultRejectionDetail?.resultReason;
                if (rejectReason != null &&
                    rejectReason.isNotEmpty &&
                    !rejectReason.contains("Branded = N")) {
                  rejectReason += "\n Branded = N";
                  dao.createOrUpdateResultReasonDetails(
                      inspectionId, "RJ", rejectReason, "");
                }
              } else {
                dao.updateInspectionResult(inspectionId, "RJ");
                dao.createOrUpdateResultReasonDetails(
                    inspectionId, "RJ", "Branded = N", "");
              }

              //dao.createIsPictureReqSpecAttribute(inspectionId, "RJ", specAnalyticalItem.getAnalyticalName(), specAnalyticalItem.isPictureRequired());
              QualityControlItem? qualityControlItems =
                  await dao.findQualityControlDetails(inspectionId);

              qtyRejectedEnabled = true;
              if (qualityControlItems != null) {
                dao.updateQuantityRejected(
                    inspectionId, qualityControlItems.qtyShipped!, 0);
                _qtyRejectedController.text =
                    (qualityControlItems.qtyShipped ?? '').toString();
              }
              layoutPurchaseOrderColor = AppColors.shareifyGold;
            } else if (item.inspectionResult.equals("Y") &&
                comply.equals("Y")) {
              String result = "";

              if (inspection != null &&
                  inspection.result != null &&
                  inspection.result.equals("RJ")) {
                ResultRejectionDetail? resultRejectionDetail =
                    await dao.getResultRejectionDetails(inspectionId);

                if (resultRejectionDetail?.resultReason.equals("Branded = N") ??
                    false) {
                  result = "AC";
                  dao.updateInspectionResult(inspectionId, "AC");
                  dao.createOrUpdateResultReasonDetails(
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
  }
}
