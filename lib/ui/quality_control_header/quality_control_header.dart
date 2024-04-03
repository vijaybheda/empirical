// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_types_as_parameter_names, prefer_const_constructors, unrelated_type_equality_checks, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/ui/Home/home_controller.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/quality_control_header/quality_control_controller.dart';
import 'package:pverify/ui/trailer_temp/trailertemp.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/theme/colors.dart';

class QualityControlHeader extends GetView<HomeController> {
  final CarrierItem carrier;

  QualityControlHeader({
    super.key,
    required this.carrier,
  });
  QualityControl_Controller qcHeaderController = QualityControl_Controller();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: QualityControl_Controller(),
        builder: (QualityControl_Controller) {
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
                  child: contentView(context, carrier)));
        });
  }

  // CONTENT'S VIEW

  Widget contentView(BuildContext context, CarrierItem carrier) {
    return Column(
      children: [
        Expanded(child: mainContentUI(context)),
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
                  onClickAction: ()  {
                    if (qcHeaderController.isQualityControlFields_Validate(context)) {
                      Get.to(() => TrailerTemp(carrier: carrier,orderNumber: qcHeaderController.orderNoTextController.value.text.trim()));
                    }
                  }
              ),
              SizedBox(
                width: 38.w,
              ),
              Obx(
                () => customButton(
                    AppColors.white,
                    qcHeaderController.isShortForm == true
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
                          if (qcHeaderController.isShortForm == true)
                            {qcHeaderController.isShortForm.value = false}
                          else
                            {qcHeaderController.isShortForm.value = true}
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
            if (qcHeaderController.isQualityControlFields_Validate(context)) {
              await qcHeaderController.saveAction(carrier);
            }
          }),
        ),
        SizedBox(
          height: 25.h,
        ),
        FooterContentView()
      ],
    );
  }

  // MAIN CONTENT VIEW

  Widget mainContentUI(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          children: [
            commonRowTextFieldView(
                context,
                AppStrings.purchaseOrderNumber,
                AppStrings.orderNo,
                qcHeaderController.orderNoTextController.value),
            SizedBox(
              height: qcHeaderController.spacingBetweenFields.h,
            ),
            commonRowDropDownView(context, AppStrings.truckTempOK,
                qcHeaderController.truckTempOk, AppStrings.truckTempOK),
            SizedBox(
              height: qcHeaderController.spacingBetweenFields.h,
            ),
            commonRowDropDownView(context, AppStrings.dtType,
                qcHeaderController.type, AppStrings.dtType),
            SizedBox(
              height: qcHeaderController.spacingBetweenFields.h,
            ),
            commonRowTextFieldView(
                context,
                AppStrings.qcComments,
                AppStrings.qcComments,
                qcHeaderController.commentTextController.value),
            SizedBox(
              height: qcHeaderController.spacingBetweenFields.h,
            ),
            Obx(() => qcHeaderController.isShortForm == true
                ? Column(
                    children: [
                      commonRowTextFieldView(
                          context,
                          AppStrings.qcSeal,
                          AppStrings.qcSeal,
                          qcHeaderController.sealTextController.value),
                      SizedBox(
                        height: qcHeaderController.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(
                          context,
                          AppStrings.QCHOPEN1,
                          '',
                          qcHeaderController
                              .certificateDepartureTextController.value),
                      SizedBox(
                        height: qcHeaderController.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(
                          context,
                          AppStrings.QCHOPEN2,
                          '',
                          qcHeaderController
                              .factoryReferenceTextController.value),
                      SizedBox(
                        height: qcHeaderController.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN3, '',
                          qcHeaderController.usdaReferenceTextController.value),
                      SizedBox(
                        height: qcHeaderController.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN4, '',
                          qcHeaderController.containerTextController.value),
                      SizedBox(
                        height: qcHeaderController.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN5, '',
                          qcHeaderController.totalQuantityTextController.value),
                      SizedBox(
                        height: qcHeaderController.spacingBetweenFields.h,
                      ),
                      commonRowDropDownView(context, AppStrings.QCHOPEN6,
                          qcHeaderController.loadType, AppStrings.QCHOPEN6),
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
      BuildContext context, String labelTitle, List items, String hintText) {
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
                  ? qcHeaderController.selectetdTruckTempOK.value
                  : labelTitle == AppStrings.dtType
                      ? qcHeaderController.selectetdTypes.value
                      : qcHeaderController.selectetdloadType.value,
              onChanged: (newValue) {
                qcHeaderController.setSelected(
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
