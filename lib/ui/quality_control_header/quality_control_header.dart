import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/quality_control_controller.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/trailer_temp/trailertemp.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class QualityControlHeader extends StatefulWidget {
  const QualityControlHeader({super.key});

  @override
  State<QualityControlHeader> createState() => _QualityControlHeaderState();
}

class _QualityControlHeaderState extends State<QualityControlHeader> {
  late QualityControlController controller;

  @override
  void initState() {
    String tag = Random().nextInt(1000).toString();
    controller = Get.put(QualityControlController(), tag: tag);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.white,
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 150.h,
          backgroundColor: AppColors.primary,
          title: HeaderContentView(title: AppStrings.quality_control_header),
        ),
        body: Container(
            color: Theme.of(context).colorScheme.background,
            child: contentView(context, controller)));
  }

  // CONTENT'S VIEW
  Widget contentView(
      BuildContext context, QualityControlController controller) {
    return Column(
      children: [
        Expanded(child: mainContentUI(context, controller)),
        Container(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          height: 150.h,
          color: AppColors.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.trailerTemp,
                  width: (MediaQuery.of(context).size.width / 2.3),
                  height: 115,
                  fontStyle: Get.textTheme.titleLarge!.copyWith(
                    fontSize: 35.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textFieldText_Color,
                  ),
                  onClickAction: () {
                    if (controller.isQualityControlFields_Validate(context)) {
                      Get.to(
                          () => const TrailerTemp(
                              // carrier: carrier,
                              // orderNumber: controller
                              //     .orderNoTextController.value.text
                              //     .trim(),
                              ),
                          arguments: {
                            Consts.ORDERNUMBER: controller
                                .orderNoTextController.value.text
                                .trim(),
                            Consts.CARRIER_ID: controller.carrierID,
                            Consts.CARRIER_NAME: controller.carrierName,
                            // Consts.CARRIER: carrier,
                          });
                    }
                  }),
              SizedBox(
                width: 38.w,
              ),
              Obx(
                () => customButton(
                    backgroundColor: AppColors.white,
                    title: controller.isShortForm == true
                        ? AppStrings.shortForm
                        : AppStrings.detailedForm,
                    width: (MediaQuery.of(context).size.width / 2.3),
                    height: 115,
                    fontStyle: Get.textTheme.titleLarge!.copyWith(
                        color: AppColors.textFieldText_Color,
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w600),
                    onClickAction: () => {
                          if (controller.isShortForm == true)
                            {controller.isShortForm.value = false}
                          else
                            {controller.isShortForm.value = true}
                        }),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 25.h,
        ),
        Padding(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          child: customButton(
              backgroundColor: AppColors.white,
              title: AppStrings.save,
              width: (MediaQuery.of(context).size.width),
              height: 115,
              fontStyle: Get.textTheme.titleLarge!.copyWith(
                  color: AppColors.textFieldText_Color,
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600),
              onClickAction: () async {
                if (controller.isQualityControlFields_Validate(context)) {
                  await controller.saveAction();
                }
              }),
        ),
        SizedBox(
          height: 25.h,
        ),
        FooterContentView(leftText: AppStrings.cancel)
      ],
    );
  }

  // MAIN CONTENT VIEW
  Widget mainContentUI(
      BuildContext context, QualityControlController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    AppStrings.purchaseOrderNumber,
                    style: Get.textTheme.titleLarge!.copyWith(
                      fontSize: 31.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    width: 350.w,
                    child: TextFormField(
                      textAlign: TextAlign.left,
                      textAlignVertical: TextAlignVertical.center,
                      onChanged: onChanged,
                      onEditingComplete: () {
                        FocusScope.of(context).unfocus();
                      },
                      minLines: 1,
                      maxLines: 1,
                      enabled: controller.orderNoEnabled,
                      readOnly: !controller.orderNoEnabled,
                      keyboardType: TextInputType.name,
                      controller: controller.orderNoTextController.value,
                      style: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                      cursorColor:
                          Theme.of(context).textSelectionTheme.cursorColor,
                      decoration: InputDecoration(
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        errorMaxLines: 1,
                        // errorText: hasValidOrderNo(
                        //         controller.orderNoTextController.value)
                        //     ? null
                        //     : 'Please enter a valid value',
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        disabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          // borderRadius: BorderRadius.all(Radius.circular(5)),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        hintText: AppStrings.orderNo,
                        hintStyle: Get.textTheme.titleLarge!.copyWith(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                        suffixIcon: hasValidOrderNo(
                                controller.orderNoTextController.value)
                            ? null
                            : IconButton(
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
                              ),
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 0, vertical: 5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: controller.spacingBetweenFields.h,
            ),
            commonRowDropDownView(context, controller, AppStrings.truckTempOK,
                controller.truckTempOk, AppStrings.truckTempOK),
            SizedBox(
              height: controller.spacingBetweenFields.h,
            ),
            commonRowDropDownView(context, controller, AppStrings.dtType,
                controller.type, AppStrings.dtType),
            SizedBox(
              height: controller.spacingBetweenFields.h,
            ),
            commonRowTextFieldView(context, AppStrings.qcComments,
                AppStrings.qcComments, controller.commentTextController.value),
            SizedBox(
              height: controller.spacingBetweenFields.h,
            ),
            Obx(() => controller.isShortForm == true
                ? Column(
                    children: [
                      commonRowTextFieldView(
                          context,
                          AppStrings.qcSeal,
                          AppStrings.qcSeal,
                          controller.sealTextController.value),
                      SizedBox(
                        height: controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN1, '',
                          controller.certificateDepartureTextController.value),
                      SizedBox(
                        height: controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN2, '',
                          controller.factoryReferenceTextController.value),
                      SizedBox(
                        height: controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN3, '',
                          controller.usdaReferenceTextController.value),
                      SizedBox(
                        height: controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN4, '',
                          controller.containerTextController.value),
                      SizedBox(
                        height: controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN5, '',
                          controller.totalQuantityTextController.value),
                      SizedBox(
                        height: controller.spacingBetweenFields.h,
                      ),
                      commonRowDropDownView(
                          context,
                          controller,
                          AppStrings.QCHOPEN6,
                          controller.loadType,
                          AppStrings.QCHOPEN6),
                      SizedBox(
                        height: controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN9, '',
                          controller.transportConditionTextController.value),
                    ],
                  )
                : Container())
          ],
        ),
      ),
    );
  }

  // COMMONG WIDGET FOR TEXTFIELD VIEW AND DROPDOWN VIEW
  Widget commonRowTextFieldView(BuildContext context, String labelTitle,
      String placeHolder, TextEditingController controller,
      {bool readOnly = false, bool enabled = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            labelTitle,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 31.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SizedBox(
            width: 350.w,
            child: BoxTextField1(
              isMulti: false,
              controller: controller,
              onTap: () {},
              errorText: '',
              readOnly: readOnly,
              enabled: enabled,
              onEditingCompleted: () {
                FocusScope.of(context).unfocus();
              },
              onChanged: (value) {},
              keyboardType: TextInputType.name,
              hintText: placeHolder,
              isPasswordField: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget commonRowDropDownView(
      BuildContext context,
      QualityControlController controller,
      String labelTitle,
      List items,
      String hintText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            labelTitle,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 31.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Obx(
            () => DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: InputBorder.none),
              dropdownColor: Theme.of(context).colorScheme.background,
              iconEnabledColor: AppColors.hintColor,
              hint: Text(
                hintText,
                style: Get.textTheme.titleLarge!.copyWith(
                  color: AppColors.hintColor,
                  fontSize: 28.sp,
                  fontWeight: FontWeight.normal,
                ),
              ),
              items: items.map((selectedType) {
                return DropdownMenuItem<String>(
                  value: selectedType,
                  child: Text(
                    selectedType,
                    style: Get.textTheme.titleLarge!.copyWith(
                      color: AppColors.hintColor,
                      fontSize: 28.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                );
              }).toList(),
              icon: const Icon(
                Icons.arrow_drop_down,
                color: Colors.white,
              ),
              value: labelTitle == AppStrings.truckTempOK
                  ? controller.selectetdTruckTempOK.value
                  : labelTitle == AppStrings.dtType
                      ? controller.selectetdTypes.value
                      : controller.selectetdloadType.value,
              onChanged: (newValue) {
                controller.setSelected(
                    newValue ?? '',
                    labelTitle == AppStrings.truckTempOK
                        ? 'TruckTempOK'
                        : labelTitle == AppStrings.dtType
                            ? 'Type'
                            : 'LoadTypes');
              },
            ),
          ),
        ),
      ],
    );
  }

  void onChanged(String value) {
    print(value);
    setState(() {});
  }

  bool hasValidOrderNo(TextEditingController controller) {
    return controller.text.trim().isNotEmpty;
  }
}
