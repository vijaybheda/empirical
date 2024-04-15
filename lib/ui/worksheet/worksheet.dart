// ignore_for_file: prefer_const_constructors, unnecessary_string_interpolations, prefer_is_empty, unnecessary_brace_in_string_interps, unused_local_variable, avoid_init_to_null

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/get_state_manager/src/simple/get_state.dart';
import 'package:get/get_state_manager/src/simple/get_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/ui/worksheet/defects_data.dart';
import 'package:pverify/controller/worksheet_controller.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class Worksheet extends GetView<WorksheetController> {
  const Worksheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<WorksheetController>(
        init: WorksheetController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: baseHeaderView(AppStrings.trailerTempRange, false),
            ),
            body: Container(
              color: Theme.of(context).colorScheme.background,
              child: contentView(context, controller),
            ),
          );
        });
  }

// MAIN CONTENTS VIEW

  Widget contentView(BuildContext context, WorksheetController controller) {
    return Column(mainAxisAlignment: MainAxisAlignment.start, children: [
      Container(
        padding: EdgeInsets.only(left: 40.w, right: 40.w),
        color: AppColors.orange,
        height: 90.h,
        width: ResponsiveHelper.getDeviceWidth(context),
        child: Row(
          children: [
            Text(
              'Strawberries',
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  textStyle: TextStyle(color: AppColors.white)),
            ),
            Spacer(),
            Text(
              'SB2021',
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  textStyle: TextStyle(color: AppColors.white)),
            )
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.only(left: 40.w, right: 40.w),
        color: AppColors.black,
        height: 150.h,
        width: ResponsiveHelper.getDeviceWidth(context),
        child: Row(
          children: [
            customViewDefectsView(
                100.h, 320.w, AppStrings.defectsTable, context),
            Container(
              width: 3.w,
              height: 100.h,
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).canvasColor),
              ),
            ),
            customViewDefectsView(
                100.h, 320.w, AppStrings.defectsEntry, context)
          ],
        ),
      ),
      Container(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        color: AppColors.lightSky,
        height: 165.h,
        width: ResponsiveHelper.getDeviceWidth(context),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            customviewCategories(AppStrings.injuryIcon, AppStrings.injury),
            customviewCategories(AppStrings.damageIcon, AppStrings.damage),
            customviewCategories(
                AppStrings.seriousDamageIcon, AppStrings.seriousDamage),
            customviewCategories(
                AppStrings.verySeriousDamageIcon, AppStrings.verySeriousDamage),
            customviewCategories(AppStrings.decayIcon, AppStrings.decay),
          ],
        ),
      ),
      SizedBox(
        height: 60.h,
      ),
      Padding(
        padding: EdgeInsets.only(left: 50.w, right: 50.w),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                alignment: Alignment.center,
                height: 200.h,
                decoration: BoxDecoration(
                    color: AppColors.lightSky,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0),
                        bottomLeft: Radius.circular(20))),
                child: SizedBox(
                  width: 360.w,
                  child: BoxTextField1(
                    textColor: AppColors.textFieldText_Color,
                    hintColor: AppColors.textFieldText_Color,
                    isMulti: false,
                    controller: controller.sizeOfNewSetTextController.value,
                    onTap: () {},
                    errorText: '',
                    onEditingCompleted: () {},
                    onChanged: (value) {},
                    keyboardType: TextInputType.number,
                    hintText: AppStrings.sizeOfNewSample,
                    isPasswordField: true,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: InkWell(
                onTap: () {
                  if (controller.isValid(context)) {
                    controller.addSampleSets(
                        controller.sizeOfNewSetTextController.value.text);
                  }
                },
                child: Container(
                  padding: EdgeInsets.only(left: 40.w),
                  alignment: Alignment.centerLeft,
                  height: 200.h,
                  decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(20.0),
                          topRight: Radius.circular(20))),
                  child: Text(
                    AppStrings.addSample,
                    style: GoogleFonts.poppins(
                        fontSize: 35.sp,
                        fontWeight: FontWeight.w400,
                        textStyle: TextStyle(color: AppColors.white)),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      SizedBox(
        height: 60.h,
      ),
      Obx(
        () => Expanded(
          child: ListView.builder(
              itemCount: controller.sampleSetObs.length,
              itemBuilder: (BuildContext context, int index) {
                return Column(
                  children: [
                    sampleSetsUI(
                        index,
                        controller.sampleSetObs[index].sampleValue.toString(),
                        controller),
                    /* Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        defectTags(AppStrings.damageIcon),
                        SizedBox(
                          width: 40.w,
                        ),
                        defectTags(AppStrings.seriousDamageIcon),
                        SizedBox(
                          width: 40.w,
                        ),
                        defectTags(AppStrings.decayIcon),
                        SizedBox(
                          width: 40.w,
                        ),
                      ],
                    ), */
                  ],
                );
              }),
        ),
      ),
      bottomContent(context)
    ]);
  }

  Widget defectTags(String title) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.lightGrey), // Border color
        borderRadius: BorderRadius.circular(15.0), // Border radius
      ),
      width: 72.w,
      child: Text(
        textAlign: TextAlign.center,
        title,
        style: GoogleFonts.poppins(
            fontSize: 35.sp,
            fontWeight: FontWeight.w600,
            textStyle: TextStyle(color: AppColors.white)),
      ),
    );
  }

// DEFECTS VIEW

  Widget customViewDefectsView(
      double height, double width, String title, BuildContext context) {
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          height: height,
          width: width,
          decoration: BoxDecoration(color: Theme.of(context).primaryColor),
          child: Text(
            textAlign: TextAlign.center,
            title,
            style: GoogleFonts.poppins(
                fontSize: 34.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.white)),
          ),
        ),
      ],
    );
  }

// CATEGORIES VIEW LIKE:: INJURY, DAMAGE

  Widget customviewCategories(String tag, String title) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.lightGrey), // Border color
            borderRadius: BorderRadius.circular(15.0), // Border radius
          ),
          width: 72.w,
          child: Text(
            textAlign: TextAlign.center,
            tag,
            style: GoogleFonts.poppins(
                fontSize: 32.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.textFieldText_Color)),
          ),
        ),
        SizedBox(
          width: 15.w,
        ),
        Text(
          textAlign: TextAlign.center,
          title,
          style: GoogleFonts.poppins(
              fontSize: 30.sp,
              fontWeight: FontWeight.w600,
              textStyle: TextStyle(color: AppColors.textFieldText_Color)),
        )
      ],
    );
  }

// BOTTOM CONTENTS

  Widget bottomContent(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          height: 150.h,
          color: AppColors.primaryColor,
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
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () {}),
              SizedBox(
                width: 38.w,
              ),
              customButton(
                  AppColors.white,
                  AppStrings.saveInspectionButton,
                  (MediaQuery.of(context).size.width / 2.3),
                  115,
                  GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {}),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.only(left: 20.w, right: 20.w),
          height: 180.h,
          color: AppColors.hintColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customButton(
                  AppColors.white,
                  AppStrings.specInstrunction,
                  (MediaQuery.of(context).size.width / 4.5),
                  320.h,
                  GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () {

                  }),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                  AppColors.white,
                  AppStrings.specification,
                  (MediaQuery.of(context).size.width / 4.5),
                  320.h,
                  GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {}),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                  AppColors.white,
                  AppStrings.grade,
                  (MediaQuery.of(context).size.width / 4.5),
                  320.h,
                  GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {}),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                  AppColors.white,
                  AppStrings.specInstrunction,
                  (MediaQuery.of(context).size.width / 4.5),
                  320.h,
                  GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {}),
            ],
          ),
        ),
        // FooterContentView(
        //   hasLeftButton: false,
        // )
      ],
    );
  }
}

// SAMPLE SET'S LIST UI

Widget sampleSetsUI(
    int index, String sampleValue, WorksheetController controller) {
  return Column(
    children: [
      Container(
        padding: EdgeInsets.only(left: 110.w, right: 110.w),
        height: 120.h,
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: InkWell(
                onTap: () {
                  controller.removeSampleSets(index);
                },
                child: Container(
                  color: AppColors.lightSky,
                  child: Image.asset(
                    AppImages.ic_minus,
                    width: 50.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: Container(
                alignment: Alignment.center,
                color: index % 2 == 0
                    ? AppColors.yellow
                    : AppColors.textFieldText_Color,
                child: Text(
                  textAlign: TextAlign.center,
                  '${sampleValue.toString()} samples   Set #${index + 1}',
                  style: GoogleFonts.poppins(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w400,
                      textStyle: TextStyle(
                          color: index % 2 == 0
                              ? AppColors.black
                              : AppColors.white)),
                ),
              ),
            )
          ],
        ),
      ),
      SizedBox(
        height: 50.h,
      ),
      Text(
        AppStrings.addDefect,
        style: GoogleFonts.poppins(
            fontSize: 36.sp,
            fontWeight: FontWeight.w600,
            textStyle: TextStyle(color: AppColors.primary)),
      ),
      SizedBox(
        height: 50.h,
      ),
    ],
  );
}
