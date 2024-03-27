// ignore_for_file: must_be_immutable, non_constant_identifier_names, avoid_types_as_parameter_names, prefer_const_constructors, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/ui/Home/home_controller.dart';
import 'package:pverify/ui/quality_control_header/quality_control_controller.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/alert.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

import '../../utils/app_const.dart';

class QualityControlHeader extends GetView<HomeController> {
  QualityControlHeader({super.key});
  QualityControl_Controller Controller = QualityControl_Controller();

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
                child: contentView(context)),
          );
        });
  }

  // CONTENT'S VIEW

  Widget contentView(BuildContext context) {
    return Column(
      children: [
        mainContentUI(context),
        Container(
          height: 150.h,
          color: AppColors.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customButton(
                  AppColors.white,
                  AppStrings.trailerTemp,
                  ((ResponsiveHelper.getDeviceWidth(context) - 180) / 2) - 50.w,
                  115,
                  GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {}),
              SizedBox(
                width: 50.w,
              ),
              Obx(
                () => customButton(
                    AppColors.white,
                    Controller.isShortForm == true
                        ? AppStrings.shortForm
                        : AppStrings.detailedForm,
                    ((ResponsiveHelper.getDeviceWidth(context) - 180) / 2) -
                        50.w,
                    115,
                    GoogleFonts.poppins(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w600,
                        textStyle:
                            TextStyle(color: AppColors.textFieldText_Color)),
                    onClickAction: () => {
                          if (Controller.isShortForm == true)
                            {Controller.isShortForm.value = false}
                          else
                            {Controller.isShortForm.value = true}
                        }),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 25.h,
        ),
        customButton(
            AppColors.white,
            AppStrings.save,
            MediaQuery.of(context).size.width,
            115,
            GoogleFonts.poppins(
                fontSize: 35.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.textFieldText_Color)),
            onClickAction: () => {}),
        SizedBox(
          height: 25.h,
        ),
        bottomContent(context)
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
            commonRowTextFieldView(context, AppStrings.purchaseOrderNumber,
                AppStrings.orderNo, Controller.orderNoTextController.value),
            SizedBox(
              height: Controller.spacingBetweenFields.h,
            ),
            commonRowDropDownView(context, AppStrings.truckTempOK,
                Controller.truckTempOk, AppStrings.truckTempOK),
            SizedBox(
              height: Controller.spacingBetweenFields.h,
            ),
            commonRowDropDownView(
                context, AppStrings.dtType, Controller.type, AppStrings.dtType),
            SizedBox(
              height: Controller.spacingBetweenFields.h,
            ),
            commonRowTextFieldView(context, AppStrings.qcComments,
                AppStrings.qcComments, Controller.commentTextController.value),
            SizedBox(
              height: Controller.spacingBetweenFields.h,
            ),
            Obx(() => Controller.isShortForm == true
                ? Column(
                    children: [
                      commonRowTextFieldView(
                          context,
                          AppStrings.qcSeal,
                          AppStrings.qcSeal,
                          Controller.sealTextController.value),
                      SizedBox(
                        height: Controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN1, '',
                          Controller.certificateDepartureTextController.value),
                      SizedBox(
                        height: Controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN2, '',
                          Controller.factoryReferenceTextController.value),
                      SizedBox(
                        height: Controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN3, '',
                          Controller.usdaReferenceTextController.value),
                      SizedBox(
                        height: Controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN4, '',
                          Controller.containerTextController.value),
                      SizedBox(
                        height: Controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN5, '',
                          Controller.totalQuantityTextController.value),
                      SizedBox(
                        height: Controller.spacingBetweenFields.h,
                      ),
                      commonRowDropDownView(context, AppStrings.QCHOPEN6,
                          Controller.loadType, AppStrings.QCHOPEN6),
                      SizedBox(
                        height: Controller.spacingBetweenFields.h,
                      ),
                      commonRowTextFieldView(context, AppStrings.QCHOPEN9, '',
                          Controller.transportConditionTextController.value),
                    ],
                  )
                : Container())
          ],
        ),
      ),
    );
  }

  // BOTTOM VIEW

  Widget bottomContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      height: 120.h,
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          InkWell(
            onTap: () {
              Get.back();
            },
            child: Text(
              AppStrings.cancel,
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
            ),
          ),
          const Spacer(),
          Text(
            AppStrings.data0DaysOld,
            style: GoogleFonts.poppins(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                textStyle: TextStyle(color: AppColors.white)),
          ),
          SizedBox(
            width: 40.w,
          ),
          InkWell(
            onTap: () {
              debugPrint('Download button tap.');
            },
            child: Image.asset(
              AppImages.ic_download,
              width: 80.w,
              height: 80.h,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              showLogoutConfirmation(context);
            },
            child: Text(
              AppStrings.logOut,
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
            ),
          )
        ],
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
        Text(
          labelTitle,
          style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        SizedBox(
          width: 30.w,
        ),
        SizedBox(
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
      ],
    );
  }

  Widget commonRowDropDownView(
      BuildContext context, String labelTitle, List items, String hintText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          labelTitle,
          style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        SizedBox(
          width: 30.w,
        ),
        SizedBox(
          width: 350.w,
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
                  ? Controller.selectetdTruckTempOK.value
                  : labelTitle == AppStrings.dtType
                      ? Controller.selectetdTypes.value
                      : Controller.selectetdloadType.value,
              onChanged: (newValue) {
                Controller.setSelected(
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

  void showLogoutConfirmation(BuildContext context) {
    return customAlert(context,
        title: Text(
          AppStrings.alert,
          style: GoogleFonts.poppins(
              fontSize: 28.sp,
              fontWeight: FontWeight.w500,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        content: Text(
          AppStrings.logoutConfirmation,
          style: GoogleFonts.poppins(
              fontSize: 25.sp,
              fontWeight: FontWeight.normal,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        actions: [
          InkWell(
              onTap: () {
                Get.back();
              },
              child: Text(
                AppStrings.cancel,
                style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.primary)),
              )),
          SizedBox(
            width: 10.w,
          ),
          InkWell(
              onTap: () {
                Get.back();
              },
              child: Text(
                AppStrings.yes,
                style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.primary)),
              )),
        ]);
  }
}
