// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_types_as_parameter_names, prefer_const_constructors, unrelated_type_equality_checks, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/quality_control_header/quality_control_controller.dart';
import 'package:pverify/ui/trailer_temp/trailertemp.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/theme/colors.dart';

class QualityControlHeader extends GetView<QualityControlController> {
  final CarrierItem carrier;

  const QualityControlHeader({
    super.key,
    required this.carrier,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: QualityControlController(),
        builder: (controller) {
          return Scaffold(
              backgroundColor: AppColors.white,
              resizeToAvoidBottomInset: false,
              appBar: AppBar(
                automaticallyImplyLeading: false,
                toolbarHeight: 150.h,
                backgroundColor: AppColors.primary,
                title: baseHeaderView(AppStrings.quality_control_header, false),
              ),
              body: Container(
                  color: Theme.of(context).colorScheme.background,
                  child: contentView(context, carrier, controller)));
        });
  }

  // CONTENT'S VIEW

  Widget contentView(BuildContext context, CarrierItem carrier,
      QualityControlController controller) {
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
                  AppColors.white,
                  AppStrings.trailerTemp,
                  (MediaQuery.of(context).size.width / 2.3),
                  115,
                  GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () {
                if (controller.isQualityControlFields_Validate(context)) {
                  Get.to(() => TrailerTemp(
                      carrier: carrier,
                      orderNumber:
                          controller.orderNoTextController.value.text.trim()));
                }
              }),
              SizedBox(
                width: 38.w,
              ),
              Obx(
                () => customButton(
                    AppColors.white,
                    controller.isShortForm == true
                        ? AppStrings.shortForm
                        : AppStrings.detailedForm,
                    (MediaQuery.of(context).size.width / 2.3),
                    115,
                    GoogleFonts.poppins(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w600,
                        textStyle:
                            TextStyle(color: AppColors.textFieldText_Color)),
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
              AppColors.white,
              AppStrings.save,
              (MediaQuery.of(context).size.width),
              115,
              GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
              onClickAction: () async {
            if (controller.isQualityControlFields_Validate(context)) {
              await controller.saveAction(carrier);
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
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            commonRowTextFieldView(context, AppStrings.purchaseOrderNumber,
                AppStrings.orderNo, controller.orderNoTextController.value),
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
                      // SizedBox(
                      //   height: Controller.spacingBetweenFields.h,
                      // ),
                      // commonRowTextFieldView(context, AppStrings.QCHOPEN9, '',
                      //     Controller.transportConditionTextController.value),
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
      String placeHolder, TextEditingController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            labelTitle,
            style: GoogleFonts.poppins(
                fontSize: 31.sp,
                fontWeight: FontWeight.w700,
                textStyle: TextStyle(color: AppColors.white)),
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
              onEditingCompleted: () {},
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
            style: GoogleFonts.poppins(
                fontSize: 31.sp,
                fontWeight: FontWeight.w700,
                textStyle: TextStyle(color: AppColors.white)),
          ),
        ),
        Expanded(
          flex: 2,
          child: Obx(
            () => DropdownButtonFormField<String>(
              decoration: InputDecoration(border: InputBorder.none),
              dropdownColor: Theme.of(context).colorScheme.background,
              iconEnabledColor: AppColors.hintColor,
              hint: Text(
                hintText,
                style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.hintColor)),
              ),
              items: items.map((selectedType) {
                return DropdownMenuItem<String>(
                  value: selectedType,
                  child: Text(
                    selectedType,
                    style: GoogleFonts.poppins(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.normal,
                        textStyle: TextStyle(color: AppColors.hintColor)),
                  ),
                );
              }).toList(),
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
}
