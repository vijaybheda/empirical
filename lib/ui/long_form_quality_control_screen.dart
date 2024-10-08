import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/long_form_quality_control_screen_controller.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class LongFormQualityControlScreen
    extends GetWidget<LongFormQualityControlScreenController> {
  final String tag;

  const LongFormQualityControlScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LongFormQualityControlScreenController>(
      init: LongFormQualityControlScreenController(),
      tag: tag,
      builder: (controller) {
        return WillPopScope(
          onWillPop: () async {
            await controller.backButtonClick();
            return Future.value(false);
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            appBar: AppBar(
              toolbarHeight: 150.h,
              leading: const Offstage(),
              leadingWidth: 0,
              centerTitle: false,
              backgroundColor: Theme.of(context).primaryColor,
              title: HeaderContentView(
                title: AppStrings.itemQualityControlDetails,
              ),
            ),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                _partnerNameWidget(controller),
                _commodityInfoWidget(controller),
                _bodyLongForm(controller, context),
                _specAttributeAndShortFormButtons(
                  context,
                  controller: controller,
                  onShortFormClick: () {
                    if (controller.isValidQuantityRejected.value) {
                      controller.shortFormClick();
                    } else {
                      controller.checkQuantityAlert();
                    }
                  },
                  onSpecAttribueClick: () {
                    controller.specAttributOnClick(context);
                    log("onSpecAttribueClick");
                  },
                ),
                FooterContentView(
                  onBackTap: () async {
                    controller.backButtonClick();
                  },
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // Long Form Body
  Widget _bodyLongForm(
      LongFormQualityControlScreenController controller, BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            children: [
              // 1st Row Spec Brand & Spec Origin
              Row(
                children: [
                  _commonQualityControllDropDown(
                    controller,
                    AppStrings.specBrandAndPrivateLabel,
                    controller.brandList,
                    controller.selectedBrand,
                    (value) {
                      controller.selectedBrand = value;
                      controller.update();
                    },
                    (item) => Text(
                      item.brandName ?? '-',
                      style: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 24.sp,
                      ),
                    ),
                    "Select One",
                  ),
                  SizedBox(width: 74.w),
                  _commonQualityControllDropDown(
                    controller,
                    AppStrings.qcSpecOrigin,
                    controller.originList,
                    controller.selectedOrigin,
                    (value) {
                      controller.selectedOrigin = value;
                      controller.update();
                    },
                    (item) => Text(
                      item.countryName ?? '-',
                      style: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 24.sp,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    "Select One",
                  ),
                ],
              ),
              // 2nd Row Quantity Shipped & UOM
              SizedBox(height: 90.h),
              Row(
                children: [
                  _commonQualityControllTextField(
                    onSubmitted: (p0) {
                      controller.updateQtyApproved();
                    },
                    controller: controller,
                    labelText: AppStrings.qcQtyShipped,
                    textEditingController: controller.qtyShippedController,
                  ),
                  SizedBox(width: 74.w),
                  _commonQualityControllDropDown(
                    controller,
                    AppStrings.uom,
                    controller.uomList,
                    controller.selectedUOM,
                    (value) {
                      controller.selectedUOM = value;
                      controller.update();
                    },
                    (item) => Text(
                      item.uomName ?? '-',
                      style: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 24.sp,
                      ),
                    ),
                    "Select One",
                  ),
                ],
              ),
              // 3rd Row Lot No & Quantity Rejected
              SizedBox(height: 90.h),
              Row(
                children: [
                  _commonQualityControllTextField(
                    controller: controller,
                    labelText: AppStrings.lotnumber,
                    textEditingController: controller.lotNoController,
                    keyboardType: TextInputType.text,
                  ),
                  SizedBox(width: 74.w),
                  _commonQualityControllTextField(
                    onSubmitted: (p0) {
                      controller.updateQtyApproved();
                    },
                    controller: controller,
                    labelText: AppStrings.qtyRejected,
                    textEditingController: controller.qtyRejectedController,
                  ),
                ],
              ),

              // 4th row Qty inspected & Qty approved
              SizedBox(height: 90.h),
              Row(
                children: [
                  _commonQualityControllTextField(
                    controller: controller,
                    labelText: AppStrings.QCDOPEN5,
                    textEditingController: controller.qtyInspectedOkController,
                  ),
                  SizedBox(width: 74.w),
                  _commonQualityControllTextField(
                    readOnly: true,
                    controller: controller,
                    labelText: AppStrings.qtyApproved,
                    textEditingController: controller.qtyAprrovedController,
                  ),
                ],
              ),
              // 5th row Sensitech Serial No & Work Date
              SizedBox(height: 90.h),
              Row(
                children: [
                  sensitechSerialNoWidget(controller),
                  SizedBox(width: 74.w),
                  workDateWidget(controller, context),
                ],
              ),

              //6th row temp recorder & pack date
              SizedBox(height: 90.h),
              Row(
                children: [
                  _staticDropDownWidget(
                    context,
                    AppStrings.QCDOPEN1,
                    controller.tempRecorderList,
                    controller.selectedTempRecorder.value,
                    (newValue) {
                      controller.selectedTempRecorder.value = newValue!;
                      controller.update();
                    },
                  ),
                  SizedBox(width: 74.w),
                  packDateWidget(controller, context)
                ],
              ),
              //7th row Recorder temp & Pulp temp
              SizedBox(height: 90.h),
              Row(
                children: [
                  _minMaxTextfiledWidget(
                    controller: controller,
                    labelText: AppStrings.qcRecorderTemperature,
                    minTextEditingController:
                        controller.recorderTempMinController,
                    maxTextEditingController:
                        controller.recorderTempMaxController,
                  ),
                  SizedBox(width: 74.w),
                  _minMaxTextfiledWidget(
                    controller: controller,
                    labelText: AppStrings.qcPulpTemperature,
                    minTextEditingController: controller.pulpTempMinController,
                    maxTextEditingController: controller.pulpTempMaxController,
                  ),
                ],
              ),
              //8th row RPC & claim Field Against
              SizedBox(height: 90.h),
              Row(
                children: [
                  _staticDropDownWidget(
                    context,
                    AppStrings.qcRpc,
                    controller.rpcList,
                    controller.selectedRpc.value,
                    (newValue) {
                      controller.selectedRpc.value = newValue!;
                      controller.update();
                    },
                  ),
                  SizedBox(width: 74.w),
                  _staticDropDownWidget(
                    context,
                    AppStrings.qcClaimfiled,
                    controller.claimFieldList,
                    controller.selectedClaimField.value,
                    (newValue) {
                      controller.selectedClaimField.value = newValue!;
                      controller.update();
                    },
                  ),
                ],
              ),
              //9th row Reason & Comments
              SizedBox(height: 90.h),
              Row(
                children: [
                  _commonQualityControllDropDown(
                    controller,
                    AppStrings.qcReason,
                    controller.reasonList,
                    controller.selectedReason,
                    (value) {
                      controller.selectedReason = value;
                      controller.update();
                    },
                    (item) => Text(
                      item.reasonName ?? '-',
                      style: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 24.sp,
                      ),
                    ),
                    "Select One",
                  ),
                  SizedBox(width: 74.w),
                  _commonQualityControllTextField(
                    controller: controller,
                    labelText: AppStrings.comments,
                    textEditingController: controller.commentsController,
                    keyboardType: TextInputType.text,
                  ),
                ],
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  // Partner Name Widget
  Widget _partnerNameWidget(LongFormQualityControlScreenController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.textFieldText_Color,
      width: double.infinity,
      child: Text(
        controller.partnerName ?? '-',
        textAlign: TextAlign.start,
        maxLines: 3,
        style: Get.textTheme.titleLarge!
            .copyWith(fontSize: 38.sp, fontWeight: FontWeight.w600),
      ),
    );
  }

  //Commodity Info Widget
  Widget _commodityInfoWidget(
      LongFormQualityControlScreenController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.orange,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.commodityName ?? '',
            textAlign: TextAlign.start,
            maxLines: 3,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            controller.itemSKU ?? '',
            textAlign: TextAlign.start,
            maxLines: 3,
            style: Get.textTheme.titleLarge!
                .copyWith(fontSize: 38.sp, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  // Spec Attribue and Short Form Button
  Widget _specAttributeAndShortFormButtons(
    BuildContext context, {
    required LongFormQualityControlScreenController controller,
    Function? onSpecAttribueClick,
    Function? onShortFormClick,
  }) {
    return Container(
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
              backgroundColor: AppColors.white,
              title: AppStrings.specAttributes,
              width: (MediaQuery.of(context).size.width / 2.3),
              height: 115,
              fontStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 35.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textFieldText_Color,
              ),
              onClickAction: onSpecAttribueClick,
            ),
            SizedBox(width: 38.w),
            customButton(
              backgroundColor: AppColors.white,
              title: AppStrings.shortForm,
              width: (MediaQuery.of(context).size.width / 2.3),
              height: 115,
              fontStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 35.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textFieldText_Color,
              ),
              onClickAction: onShortFormClick,
            )
          ],
        ),
      ),
    );
  }

  Expanded _commonQualityControllDropDown<T>(
      LongFormQualityControlScreenController controller,
      String labelText,
      List<T> itemList,
      T? selectedItem,
      ValueChanged<T?> onChanged,
      Widget Function(T) itemBuilder,
      String hintText) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        labelText,
                        style: Get.textTheme.titleLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.orange,
                height: 1,
              ),
            ],
          ),
          DropdownButtonFormField<T>(
            isExpanded: true,
            value: selectedItem,
            onChanged: onChanged,
            items: itemList.map((item) {
              return DropdownMenuItem<T>(
                value: item,
                child: itemBuilder(item),
              );
            }).toList(),
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 24.sp,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            dropdownColor: AppColors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  //Common Quality Control Text Field
  Expanded _commonQualityControllTextField(
      {required LongFormQualityControlScreenController controller,
      required String labelText,
      required TextEditingController textEditingController,
      TextInputType? keyboardType,
      bool? readOnly,
      Function(String)? onSubmitted}) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        labelText,
                        style: Get.textTheme.titleLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.orange,
                height: 1,
              ),
            ],
          ),
          TextField(
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 24.sp,
            ),
            onChanged: onSubmitted,
            readOnly: readOnly ?? false,
            controller: textEditingController,
            keyboardType: keyboardType ?? TextInputType.number,
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
              suffixIcon: hasValidOrderNo(textEditingController, controller)
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.info, color: Colors.red),
                      onPressed: () {
                        AppSnackBar.error(
                            message: "Please enter a valid value");
                      },
                    ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              disabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(10),
            ),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  bool hasValidOrderNo(TextEditingController textEditingController,
      LongFormQualityControlScreenController controller) {
    if (textEditingController != controller.lotNoController &&
        textEditingController != controller.qtyInspectedOkController &&
        textEditingController != controller.commentsController) {
      return textEditingController.text.trim().isNotEmpty;
    }
    return true;
  }

  // Sensitech Serial No Barcode scanner widget
  Expanded sensitechSerialNoWidget(
      LongFormQualityControlScreenController controller) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.QCDOPEN6,
                        style: Get.textTheme.titleLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                    sensitechSerialNoSuffix(controller)
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.orange,
                height: 1,
              ),
            ],
          ),
          TextField(
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 24.sp,
            ),
            controller: controller.sensitechSerialNoController,
            decoration: InputDecoration(
              hintText: AppStrings.QCDOPEN6,
              hintStyle: Get.textTheme.titleLarge!.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.normal,
                color: Colors.grey,
              ),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  // Sensitetech Serial No Suffix
  GestureDetector sensitechSerialNoSuffix(
      LongFormQualityControlScreenController controller) {
    return GestureDetector(
      onTap: () async {
        await controller.scanBarcode(onScanResult: (scanResult) {
          String? scannedCode =
              controller.scanSensitechSerialNoContents(scanResult);
          if (scannedCode != null) {
            controller.update();
          }
        });
      },
      child: Image.asset(
        AppImages.scanner,
        height: 30,
        width: 30,
      ),
    );
  }

  Expanded workDateWidget(
      LongFormQualityControlScreenController controller, BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.QCDOPEN7,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.orange,
                height: 1,
              ),
            ],
          ),
          TextField(
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 24.sp,
            ),
            controller: controller.workDateController,
            readOnly: false,
            autofocus: false,
            focusNode: controller.workDateFocusNode,
            decoration: InputDecoration(
              hintText: AppStrings.QCDOPEN7,
              hintStyle: Get.textTheme.bodyLarge!.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
              suffixIcon: GestureDetector(
                  onTap: () async {
                    await selectWorkDate(context, controller);
                  },
                  child: const Icon(Icons.calendar_month_outlined)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            onTap: () async {
              await selectWorkDate(context, controller);
            },
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Expanded packDateWidget(
      LongFormQualityControlScreenController controller, BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        AppStrings.packdate,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.orange,
                height: 1,
              ),
            ],
          ),
          TextField(
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 24.sp,
            ),
            controller: controller.packDateController,
            readOnly: true,
            autofocus: false,
            focusNode: controller.packDateFocusNode,
            decoration: InputDecoration(
              hintText: AppStrings.packdate,
              hintStyle: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.normal,
                  color: Colors.grey),
              suffixIcon: GestureDetector(
                  onTap: () async {
                    await selectPackDate(context, controller);
                  },
                  child: const Icon(Icons.calendar_month_outlined)),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            ),
            onTap: () async {
              await selectPackDate(context, controller);
            },
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Future<void> selectPackDate(
    BuildContext context,
    LongFormQualityControlScreenController controller,
  ) async {
    await controller.selectDate(
      context,
      initialDate: controller.packDate,
      onDateSelected: (DateTime selectedDate) {
        controller.packDateController.text = Utils().formatDate(selectedDate);
        controller.packDate = selectedDate;
        controller.update();
      },
      firstDate: DateTime(
        2000,
      ),
      lastDate: DateTime(
        2100,
      ),
    );
  }

  Future<void> selectWorkDate(
    BuildContext context,
    LongFormQualityControlScreenController controller,
  ) async {
    await controller.selectDate(
      context,
      initialDate: controller.workDate,
      onDateSelected: (DateTime selectedDate) {
        controller.workDateController.text = Utils().formatDate(selectedDate);
        controller.workDate = selectedDate;
        controller.update();
      },
      firstDate: DateTime(
        2000,
      ),
      lastDate: DateTime(
        2100,
      ),
    );
  }

  Widget _staticDropDownWidget(
    BuildContext context,
    String labelText,
    List<String> items,
    String? selectedValue,
    void Function(String?)? onChanged,
  ) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        labelText,
                        style: Get.textTheme.bodyLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.orange,
                height: 1,
              ),
            ],
          ),
          DropdownButtonFormField<String>(
            value: selectedValue,
            onChanged: onChanged,
            items: items.map((selectedType) {
              return DropdownMenuItem<String>(
                value: selectedType,
                child: Text(
                  selectedType,
                  style: Get.textTheme.titleLarge!.copyWith(
                    fontSize: 24.sp,
                    color: AppColors.hintColor,
                  ),
                ),
              );
            }).toList(),
            decoration: InputDecoration(
              hintText: labelText,
              hintStyle: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.normal,
                  color: AppColors.hintColor),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              border: const UnderlineInputBorder(
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
            dropdownColor: AppColors.grey,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
          ),
          Divider(
            color: AppColors.lightGrey,
            height: 1,
          ),
        ],
      ),
    );
  }

  Widget _minMaxTextfiledWidget({
    required LongFormQualityControlScreenController controller,
    required String labelText,
    required TextEditingController minTextEditingController,
    required TextEditingController maxTextEditingController,
    TextInputType? keyboardType,
    bool? readOnly,
    Function(String)? onSubmittedMin,
    Function(String)? onSubmittedMax,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: Text(
                        labelText,
                        style: Get.textTheme.titleLarge!.copyWith(
                          fontSize: 26.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
              Divider(
                color: AppColors.orange,
                height: 1,
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  AppStrings.min,
                  style: Get.textTheme.bodyLarge!.copyWith(
                    fontSize: 26.sp,
                    color: AppColors.lightGrey,
                  ),
                ),
                SizedBox(width: 50.w),
                Flexible(
                    child: TextField(
                  style: Get.textTheme.titleLarge!.copyWith(
                    fontSize: 24.sp,
                  ),
                  onSubmitted: onSubmittedMin,
                  readOnly: readOnly ?? false,
                  controller: minTextEditingController,
                  keyboardType: keyboardType ?? TextInputType.number,
                  decoration: InputDecoration(
                    labelStyle: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 24.sp,
                    ),
                    hintStyle: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 24.sp,
                    ),
                    contentPadding: EdgeInsets.only(top: 50.h),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                  ),
                )),
                SizedBox(width: 50.w),
                Text(
                  AppStrings.max,
                  style: Get.textTheme.bodyLarge!
                      .copyWith(fontSize: 26.sp, color: AppColors.lightGrey),
                ),
                SizedBox(width: 50.w),
                Flexible(
                    child: TextField(
                  style: Get.textTheme.titleLarge!.copyWith(
                    fontSize: 24.sp,
                  ),
                  onSubmitted: onSubmittedMax,
                  readOnly: readOnly ?? false,
                  controller: maxTextEditingController,
                  keyboardType: keyboardType ?? TextInputType.number,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.only(top: 50.h),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.lightGrey,
                        width: 1,
                      ),
                    ),
                  ),
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
