import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/controller/qc_details_short_form_screen_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/ui/components/drawer_header_content_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/ui/qc_short_form/spec_analytical_table.dart';
import 'package:pverify/ui/side_drawer.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class QCDetailsShortFormScreen
    extends GetWidget<QCDetailsShortFormScreenController> {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;
  final PurchaseOrderItem purchaseOrderItem;
  const QCDetailsShortFormScreen({
    super.key,
    required this.partner,
    required this.carrier,
    required this.commodity,
    this.qcHeaderDetails,
    required this.purchaseOrderItem,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<QCDetailsShortFormScreenController>(
      init: QCDetailsShortFormScreenController(
          partner: partner,
          carrier: carrier,
          commodity: commodity,
          qcHeaderDetails: qcHeaderDetails),
      builder: (controller) {
        if (!controller.hasInitialised.value) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                    child: SizedBox(
                        height: 25, width: 25, child: ProgressAdaptive())),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            toolbarHeight: 150.h,
            leadingWidth: 0,
            automaticallyImplyLeading: false,
            leading: const Offstage(),
            centerTitle: false,
            backgroundColor: Theme.of(context).primaryColor,
            titleSpacing: 0,
            title: DrawerHeaderContentView(
              title: AppStrings.title_activity_q_c__details_short_form,
            ),
          ),
          drawer: SideDrawer(
            onDefectSaveAndCompleteTap: () async {
              await controller.saveAsDraftAndGotoMyInspectionScreen();
            },
            onDiscardTap: () async {
              await controller.deleteInspectionAndGotoMyInspectionScreen();
            },
            onCameraTap: () async {
              await controller.onCameraMenuTap();
            },
            onSpecInstructionTap: () async {
              await controller.onSpecialInstrMenuTap();
            },
            onSpecificationTap: () async {
              await controller.onSpecificationTap();
            },
            onGradeTap: () async {
              await JsonFileOperations.instance.viewGradePdf();
            },
            onInspectionTap: () async {
              await JsonFileOperations.instance.viewSpecInsPdf();
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: AppColors.textFieldText_Color,
                width: double.infinity,
                child: Text(
                  partner.name ?? '-',
                  textAlign: TextAlign.start,
                  maxLines: 3,
                  style: GoogleFonts.poppins(
                      fontSize: 38.sp,
                      fontWeight: FontWeight.w600,
                      textStyle: TextStyle(color: AppColors.white)),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 10),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              orderItemHeading(),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      AppStrings.gtin,
                                                      style: Get
                                                          .textTheme.bodyLarge!
                                                          .copyWith(
                                                        fontSize: 26.sp,
                                                      ),
                                                    ),
                                                  ),
                                                  gtinSuffix(controller),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Divider(
                                              color: AppColors.darkSkyBlue,
                                              height: 1,
                                            ),
                                          ],
                                        ),
                                        TextField(
                                          controller: controller.gtinController,
                                          decoration: InputDecoration(
                                            hintText: AppStrings.gtin,
                                            hintStyle: Get.textTheme.bodyLarge!
                                                .copyWith(
                                              fontSize: 26.sp,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            border: const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                          ),
                                        ),
                                        Divider(
                                          color: AppColors.lightGrey,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      AppStrings.gln,
                                                      style: Get
                                                          .textTheme.bodyLarge!
                                                          .copyWith(
                                                        fontSize: 26.sp,
                                                      ),
                                                    ),
                                                  ),
                                                  glnSuffix(controller),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Divider(
                                              color: AppColors.darkSkyBlue,
                                              height: 1,
                                            ),
                                          ],
                                        ),
                                        TextField(
                                          controller: controller.glnController,
                                          decoration: InputDecoration(
                                            hintText: AppStrings.gln,
                                            hintStyle: Get.textTheme.bodyLarge!
                                                .copyWith(
                                              fontSize: 26.sp,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            border: const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10),
                                          ),
                                        ),
                                        Divider(
                                          color: AppColors.lightGrey,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      AppStrings.lotnumber,
                                                      style: Get
                                                          .textTheme.bodyLarge!
                                                          .copyWith(
                                                        fontSize: 26.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Divider(
                                              color: AppColors.darkSkyBlue,
                                              height: 1,
                                            ),
                                          ],
                                        ),
                                        TextField(
                                          controller:
                                              controller.lotNoController,
                                          decoration: InputDecoration(
                                            hintText: AppStrings.lotnumber,
                                            hintStyle: Get.textTheme.bodyLarge!
                                                .copyWith(
                                              fontSize: 26.sp,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            border: const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                          ),
                                        ),
                                        Divider(
                                          color: AppColors.lightGrey,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      AppStrings.packdate,
                                                      style: Get
                                                          .textTheme.bodyLarge!
                                                          .copyWith(
                                                        fontSize: 26.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Divider(
                                              color: AppColors.darkSkyBlue,
                                              height: 1,
                                            ),
                                          ],
                                        ),
                                        TextField(
                                          controller:
                                              controller.packDateController,
                                          readOnly: true,
                                          autofocus: false,
                                          focusNode:
                                              controller.packDateFocusNode,
                                          decoration: InputDecoration(
                                            hintText: AppStrings.packdate,
                                            hintStyle: Get.textTheme.bodyLarge!
                                                .copyWith(
                                              fontSize: 26.sp,
                                            ),
                                            suffixIcon: GestureDetector(
                                                onTap: () async {
                                                  await selectPackDate(
                                                      context, controller);
                                                },
                                                child: const Icon(Icons
                                                    .calendar_month_outlined)),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            border: const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10),
                                          ),
                                        ),
                                        Divider(
                                          color: AppColors.lightGrey,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      AppStrings.qcQtyShipped,
                                                      style: Get
                                                          .textTheme.bodyLarge!
                                                          .copyWith(
                                                        fontSize: 26.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Divider(
                                              color: AppColors.darkSkyBlue,
                                              height: 1,
                                            ),
                                          ],
                                        ),
                                        TextField(
                                          controller:
                                              controller.qtyShippedController,
                                          decoration: InputDecoration(
                                            hintText: AppStrings.qcQtyShipped,
                                            hintStyle: Get.textTheme.bodyLarge!
                                                .copyWith(
                                              fontSize: 26.sp,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            border: const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                          ),
                                        ),
                                        Divider(
                                          color: AppColors.lightGrey,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 5),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      AppStrings.uom,
                                                      style: Get
                                                          .textTheme.bodyLarge!
                                                          .copyWith(
                                                        fontSize: 26.sp,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 5),
                                            Divider(
                                              color: AppColors.darkSkyBlue,
                                              height: 1,
                                            ),
                                          ],
                                        ),
                                        DropdownButtonFormField<UOMItem>(
                                          value: controller.selectedUOM,
                                          onChanged: (UOMItem? value) {
                                            controller.selectedUOM = value;
                                            controller.update();
                                          },
                                          items: controller.uomList
                                              .map((UOMItem value) {
                                            return DropdownMenuItem<UOMItem>(
                                              value: value,
                                              child: Text(value.uomName ?? '-',
                                                  style:
                                                      Get.textTheme.bodyLarge!),
                                            );
                                          }).toList(),
                                          decoration: InputDecoration(
                                            hintText: AppStrings.uom,
                                            hintStyle: Get.textTheme.bodyLarge!
                                                .copyWith(
                                              fontSize: 26.sp,
                                            ),
                                            enabledBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            focusedBorder:
                                                const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            border: const UnderlineInputBorder(
                                              borderSide: BorderSide.none,
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 10),
                                          ),
                                          dropdownColor:
                                              AppColors.textFieldText_Color,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 0),
                                        ),
                                        Divider(
                                          color: AppColors.lightGrey,
                                          height: 1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SpecAnalyticalTable(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 20.h,
                        top: 20.h,
                      ),
                      color: AppColors.primaryColor,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customButton(
                                (controller.specificationTypeName !=
                                            "Finished Goods Produce" &&
                                        controller.specificationTypeName !=
                                            "Raw Produce")
                                    ? AppColors.grey2
                                    : AppColors.white,
                                AppStrings.inspectionWorksheet,
                                (MediaQuery.of(context).size.width / 2.5),
                                115,
                                GoogleFonts.poppins(
                                    fontSize: 35.sp,
                                    fontWeight: FontWeight.w600,
                                    textStyle: TextStyle(
                                        color: AppColors.textFieldText_Color)),
                                onClickAction: () async {
                              await controller.onInspectionWorksheetClick();
                            }),
                            SizedBox(
                              width: 38.w,
                            ),
                            customButton(
                                AppColors.white,
                                AppStrings.detailedForm,
                                (MediaQuery.of(context).size.width / 2.5),
                                115,
                                GoogleFonts.poppins(
                                    fontSize: 35.sp,
                                    fontWeight: FontWeight.w600,
                                    textStyle: TextStyle(
                                        color: AppColors.textFieldText_Color)),
                                onClickAction: () async {
                              await controller.onLongFormClick();
                            }),
                            SizedBox(
                              width: 20.w,
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.camera_alt_rounded,
                                size: 50,
                              ),
                              onPressed: () {
                                controller.onCameraMenuTap();
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 20.h,
                        top: 20.h,
                      ),
                      color: AppColors.grey2,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            customButton(
                                AppColors.white,
                                AppStrings.defectDiscard,
                                (MediaQuery.of(context).size.width / 2.3),
                                115,
                                GoogleFonts.poppins(
                                    fontSize: 35.sp,
                                    fontWeight: FontWeight.w600,
                                    textStyle: TextStyle(
                                        color: AppColors.textFieldText_Color)),
                                onClickAction: () async {
                              await controller
                                  .deleteInspectionAndGotoMyInspectionScreen();
                            }),
                            SizedBox(
                              width: 38.w,
                            ),
                            customButton(
                                AppColors.white,
                                AppStrings.saveAndContinue,
                                (MediaQuery.of(context).size.width / 2.3),
                                115,
                                GoogleFonts.poppins(
                                    fontSize: 35.sp,
                                    fontWeight: FontWeight.w600,
                                    textStyle: TextStyle(
                                        color: AppColors.textFieldText_Color)),
                                onClickAction: () async {
                              await controller.saveContinue(context);
                            }),
                          ],
                        ),
                      ),
                    ),
                    FooterContentView()
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> selectPackDate(
    BuildContext context,
    QCDetailsShortFormScreenController controller,
  ) async {
    await controller.selectDate(context,
        onDateSelected: (DateTime selectedDate) {
      controller.packDateController.text = Utils.formatDate(selectedDate);
      controller.packDate = selectedDate;
      controller.update();
    }, firstDate: controller.packDate, lastDate: DateTime(2100));
  }

  GestureDetector gtinSuffix(QCDetailsShortFormScreenController controller) {
    return GestureDetector(
      onTap: () async {
        await controller.scanBarcode(onScanResult: (scanResult) {
          controller.gtinController.text = scanResult;
          controller.update();
        });
      },
      child: const Icon(
        Icons.barcode_reader,
        size: 30,
      ),
    );
  }

  GestureDetector glnSuffix(QCDetailsShortFormScreenController controller) {
    return GestureDetector(
      onTap: () async {
        await controller.scanBarcode(onScanResult: (scanResult) {
          controller.glnController.text = scanResult;
          controller.update();
        });
      },
      child: const Icon(
        Icons.barcode_reader,
        size: 30,
      ),
    );
  }

  Widget orderItemHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          purchaseOrderItem.description ?? '-',
          textAlign: TextAlign.start,
          maxLines: 3,
          style: GoogleFonts.poppins(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        Text(
          purchaseOrderItem.sku ?? '-',
          textAlign: TextAlign.start,
          maxLines: 3,
          style: GoogleFonts.poppins(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
              textStyle: TextStyle(color: AppColors.white)),
        ),
      ],
    );
  }
}
