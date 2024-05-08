// ignore_for_file: unused_local_variable, prefer_const_constructors, unrelated_type_equality_checks

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/defects_screen_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/ui/components/drawer_header_content_view.dart';
import 'package:pverify/ui/inspection_photos/inspection_photos_screen.dart';
import 'package:pverify/ui/side_drawer.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

import '../../models/worksheet_data_table.dart';
import '../../utils/dialogs/app_alerts.dart';

class DefectsScreen extends GetView<DefectsScreenController> {
  const DefectsScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DefectsScreenController>(
        init: DefectsScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              toolbarHeight: 150.h,
              leadingWidth: 0,
              automaticallyImplyLeading: false,
              leading: const Offstage(),
              centerTitle: false,
              backgroundColor: Theme.of(context).primaryColor,
              titleSpacing: 0,
              title: DrawerHeaderContentView(
                title: AppStrings.itemDefects,
              ),
            ),
            drawer: SideDrawer(
              onDefectSaveAndCompleteTap: () async {
                await controller.saveAsDraftAndGotoMyInspectionScreen();
              },
              onDiscardTap: () async {
                await controller
                    .deleteInspectionAndGotoMyInspectionScreen(context);
              },
              onCameraTap: () async {
                await controller.onCameraMenuTap();
              },
              onSpecInstructionTap: () async {
                await controller.onSpecialInstrMenuTap();
              },
              onSpecificationTap: () async {
                await controller.onSpecificationTap(context);
              },
              onGradeTap: () async {
                await JsonFileOperations.instance.viewGradePdf();
              },
              onInspectionTap: () async {
                await JsonFileOperations.instance.viewSpecInsPdf();
              },
            ),
            body: Stack(
              children: [
                Container(
                  color: Theme.of(context).colorScheme.background,
                  child: contentView(context, controller),
                ),
                infoPopup(context)
              ],
            ),
          );
        });
  }

  Widget infoPopup(BuildContext context) {
    return Obx(
      () => controller.isVisibleInfoPopup.value
          ? Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      color: AppColors.black,
                      borderRadius: BorderRadius.circular(10)),
                  margin: EdgeInsets.all(20),
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          height: 0.5, // Adjust the height of the underline
                          color: AppColors
                              .background, // Set the color of the underline
                        ),
                        SizedBox(height: 30.h),
                        Text(
                          'Popup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup ContentPopup Content',
                          style: GoogleFonts.poppins(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.normal,
                              textStyle: TextStyle(
                                  color: AppColors.white, height: 1.8)),
                        ),
                        SizedBox(height: 30.h),
                        Container(
                          height: 0.5, // Adjust the height of the underline
                          color: AppColors
                              .background, // Set the color of the underline
                        ),
                        SizedBox(height: 40.h),
                        customButton(
                            backgroundColor: AppColors.white,
                            title: AppStrings.ok,
                            width: 300.w,
                            height: 100,
                            fontStyle: GoogleFonts.poppins(
                                fontSize: 35.sp,
                                fontWeight: FontWeight.w600,
                                textStyle: TextStyle(
                                    color: AppColors.textFieldText_Color)),
                            onClickAction: () async {
                              controller.hidePopup();
                            }),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : SizedBox(),
    );
  }

// MAIN CONTENTS VIEW

  Widget contentView(BuildContext context, DefectsScreenController controller) {
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
            const Spacer(),
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
      Obx(
        () => Container(
          padding: EdgeInsets.only(left: 40.w, right: 40.w),
          color: AppColors.black,
          height: 150.h,
          width: ResponsiveHelper.getDeviceWidth(context),
          child: Row(
            children: [
              controller.sampleSetObs.isNotEmpty
                  ? GestureDetector(
                      onTap: () {
                        controller.activeTabIndex.value = 0;
                      },
                      child: customViewDefectsView(
                        100.h,
                        320.w,
                        AppStrings.defectsTable,
                        context,
                        controller.activeTabIndex.value == 0,
                      ),
                    )
                  : const SizedBox(),
              controller.sampleSetObs.isNotEmpty
                  ? Container(
                      width: 3.w,
                      height: 100.h,
                      decoration:
                          BoxDecoration(color: Theme.of(context).primaryColor),
                      child: Container(
                        decoration:
                            BoxDecoration(color: Theme.of(context).canvasColor),
                      ),
                    )
                  : const SizedBox(),
              GestureDetector(
                onTap: () {
                  controller.activeTabIndex.value = 1;
                },
                child: customViewDefectsView(
                  100.h,
                  320.w,
                  AppStrings.defectsEntry,
                  context,
                  controller.activeTabIndex.value == 1,
                ),
              )
            ],
          ),
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
      Obx(
        () => controller.activeTabIndex.value == 0
            ? Expanded(
                child: SingleChildScrollView(
                  child: DefectsTable(),
                ),
              )
            : Expanded(
                child: Column(
                  children: [
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
                                      topLeft: Radius.circular(20.r),
                                      bottomLeft: Radius.circular(20.r))),
                              child: SizedBox(
                                width: 360.w,
                                child: BoxTextField1(
                                  textColor: AppColors.textFieldText_Color,
                                  hintColor: AppColors.textFieldText_Color,
                                  isMulti: false,
                                  controller: controller
                                      .sizeOfNewSetTextController.value,
                                  onTap: () {},
                                  errorText: '',
                                  onEditingCompleted: () {
                                    FocusScope.of(context).unfocus();
                                  },
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
                            child: GestureDetector(
                              onTap: () {
                                if (controller.isValid(context)) {
                                  controller.addSampleSets(controller
                                      .sizeOfNewSetTextController.value.text);
                                }
                              },
                              child: Container(
                                padding: EdgeInsets.only(left: 40.w),
                                alignment: Alignment.centerLeft,
                                height: 200.h,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(20.r),
                                        topRight: Radius.circular(20.r))),
                                child: Text(
                                  AppStrings.addSample,
                                  style: GoogleFonts.poppins(
                                      fontSize: 35.sp,
                                      fontWeight: FontWeight.w400,
                                      textStyle:
                                          TextStyle(color: AppColors.white)),
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
                    Expanded(
                      child: ListView.builder(
                          itemCount: controller.sampleSetObs.length,
                          itemBuilder: (BuildContext context, int setIndex) {
                            return Column(
                              children: [
                                sampleSetsUI(
                                  context,
                                  setIndex,
                                  controller.sampleSetObs[setIndex].sampleValue
                                      .toString(),
                                  controller,
                                ),
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
                    )
                  ],
                ),
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
    double height,
    double width,
    String title,
    BuildContext context,
    bool isActive,
  ) {
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            border: isActive
                ? Border(
                    bottom: BorderSide(
                      color: AppColors.blue,
                      width: 3,
                    ),
                  )
                : null,
          ),
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
                  backgroundColor: AppColors.white,
                  title: AppStrings.defectDiscard,
                  width: (MediaQuery.of(context).size.width / 2.3),
                  height: 115,
                  fontStyle: GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () {
                    controller
                        .deleteInspectionAndGotoMyInspectionScreen(context);
                  }),
              SizedBox(
                width: 38.w,
              ),
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.saveInspectionButton,
                  width: (MediaQuery.of(context).size.width / 2.3),
                  height: 115,
                  fontStyle: GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {
                        if (controller.isValidDefects())
                          {
                            if (controller.validateSameDefects())
                              {}
                            else
                              {
                                AppAlertDialog.validateAlerts(
                                    context,
                                    AppStrings.error,
                                    AppStrings.sameDefectEntryAlert)
                              }
                          }
                        else
                          {
                            AppAlertDialog.validateAlerts(context,
                                AppStrings.error, AppStrings.defectEntryAlert)
                          }
                      }),
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
                backgroundColor: AppColors.white,
                title: AppStrings.specException,
                width: (MediaQuery.of(context).size.width / 4.5),
                height: 320.h,
                fontStyle: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    textStyle: TextStyle(color: AppColors.textFieldText_Color)),
                onClickAction: () {
                  controller.onSpecialInstrMenuTap();
                },
              ),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                backgroundColor: AppColors.white,
                title: AppStrings.specification,
                width: (MediaQuery.of(context).size.width / 4.5),
                height: 320.h,
                fontStyle: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    textStyle: TextStyle(color: AppColors.textFieldText_Color)),
                onClickAction: () {
                  controller.onSpecificationTap(context);
                },
              ),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.grade,
                  width: (MediaQuery.of(context).size.width / 4.5),
                  height: 320.h,
                  fontStyle: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    textStyle: TextStyle(
                      color: AppColors.textFieldText_Color,
                    ),
                  ),
                  onClickAction: () {
                    controller.openPDFFile(context, "Grade");
                  }),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.specInstrunction,
                  width: (MediaQuery.of(context).size.width / 4.5),
                  height: 320.h,
                  fontStyle: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () {
                    controller.openPDFFile(context, "Inspection Instructions");
                  })
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

Widget sampleSetsUI(BuildContext context, int index, String sampleValue,
    DefectsScreenController controller) {
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
                  AppAlertDialog.confirmationAlert(
                    context,
                    AppStrings.alert,
                    AppStrings.removeSample,
                    onYesTap: () {
                      controller.removeSampleSets(index);
                    },
                  );
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
                    ? AppColors.orange
                    : AppColors.textFieldText_Color,
                child: Text(
                  textAlign: TextAlign.center,
                  '${sampleValue.toString()} samples   Set #${controller.sampleSetObs[index].sampleId}',
                  style: GoogleFonts.poppins(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w400,
                    textStyle: TextStyle(
                      color: index % 2 == 0 ? AppColors.black : AppColors.white,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      controller.sampleSetObs[index].defectItem?.isNotEmpty ?? false
          ? Column(
              children: [
                SizedBox(height: 50.h),
                defectCategoryTagRow(controller),
                SizedBox(height: 50.h),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 50.w),
                  child: const Divider(),
                )
              ],
            )
          : const SizedBox(),
      Column(
        children: (controller.sampleSetObs[index].defectItem ?? [])
            .map(
              (e) => defectRow(
                context: context,
                controller: controller,
                defectItemIndex: controller.getDefectItemIndex(
                    setIndex: index, defectItem: e),
                defectItem: e,
                setIndex: index,
              ),
            )
            .toList(),
      ),
      SizedBox(height: 20.h),
      controller.sampleSetObs[index].defectItem?.isNotEmpty ?? false
          ? Padding(
              padding: EdgeInsets.symmetric(horizontal: 50.w),
              child: const Divider(),
            )
          : const SizedBox(),
      SizedBox(height: 20.h),
      GestureDetector(
        onTap: () {
          controller.addDefectRow(setIndex: index);
        },
        child: Text(
          AppStrings.addDefect,
          style: GoogleFonts.poppins(
              fontSize: 36.sp,
              fontWeight: FontWeight.w600,
              textStyle: TextStyle(color: AppColors.primary)),
        ),
      ),
      SizedBox(height: 50.h),
    ],
  );
}

Widget defectRow({
  required BuildContext context,
  required DefectsScreenController controller,
  required DefectItem? defectItem,
  required int defectItemIndex,
  required int setIndex,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 50.w),
    child: Column(
      children: [
        const SizedBox(height: 10),
        Row(
          children: [
            Flexible(
              flex: 1,
              child: InkWell(
                onTap: () {
                  AppAlertDialog.confirmationAlert(
                      context, AppStrings.alert, AppStrings.removeDefect,
                      onYesTap: () {
                    controller.removeDefectRow(
                      setIndex: setIndex,
                      rowIndex: defectItemIndex,
                    );
                  });
                },
                child: Image.asset(
                  AppImages.ic_minus,
                  width: 50.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Flexible(
              flex: 3,
              child: Container(
                width: 120,
                padding: const EdgeInsets.only(top: 5),
                child: Obx(
                  () => DropdownButton<String>(
                    isExpanded: true,
                    dropdownColor: Theme.of(context).colorScheme.background,
                    iconEnabledColor: AppColors.hintColor,
                    value: controller.sampleSetObs[setIndex]
                            .defectItem?[defectItemIndex].name ??
                        controller.defectSpinnerNames[0],
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
                    items: controller.defectSpinnerNames.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      controller.onDropDownChange(
                        id: controller.defectSpinnerIds[controller
                            .defectSpinnerNames
                            .indexWhere((obj) => obj == value)],
                        value: value ?? "",
                        setIndex: setIndex,
                        rowIndex: defectItemIndex,
                      );
                      controller.defectsSelect_Action(defectItem);
                    },
                  ),
                ),
              ),
            ),
            SizedBox(width: 20.w),
            controller.hasSeverityInjury
                ? Flexible(
                    flex: 1,
                    child: BoxTextField1(
                      textalign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      controller: defectItem?.injuryTextEditingController,
                      onTap: () {
                        defectItem?.injuryTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          value: v,
                          setIndex: setIndex,
                          rowIndex: defectItemIndex,
                          fieldName: AppStrings.injury,
                          context: context,
                        );
                      },
                    ),
                  )
                : Flexible(flex: 1, child: SizedBox()),
            SizedBox(width: 20.w),
            controller.hasSeverityDamage
                ? Flexible(
                    flex: 1,
                    child: BoxTextField1(
                      textalign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      controller: defectItem?.damageTextEditingController,
                      onTap: () {
                        defectItem?.damageTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          value: v,
                          setIndex: setIndex,
                          rowIndex: defectItemIndex,
                          fieldName: AppStrings.damage,
                          context: context,
                        );
                      },
                    ),
                  )
                : Flexible(flex: 1, child: SizedBox()),
            SizedBox(width: 20.w),
            controller.hasSeveritySeriousDamage
                ? Flexible(
                    flex: 1,
                    child: BoxTextField1(
                      textalign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      controller: defectItem?.sDamageTextEditingController,
                      onTap: () {
                        defectItem?.sDamageTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          value: v,
                          setIndex: setIndex,
                          rowIndex: defectItemIndex,
                          fieldName: AppStrings.seriousDamage,
                          context: context,
                        );
                      },
                    ),
                  )
                : Flexible(flex: 1, child: SizedBox()),
            SizedBox(width: 20.w),
            controller.hasSeverityVerySeriousDamage
                ? Flexible(
                    flex: 1,
                    child: BoxTextField1(
                      textalign: TextAlign.center,
                      controller: defectItem?.vsDamageTextEditingController,
                      keyboardType: TextInputType.number,
                      onTap: () {
                        defectItem?.vsDamageTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          value: v,
                          setIndex: setIndex,
                          rowIndex: defectItemIndex,
                          fieldName: AppStrings.verySeriousDamage,
                          context: context,
                        );
                      },
                    ),
                  )
                : Flexible(flex: 1, child: SizedBox()),
            SizedBox(width: controller.hasSeveritySeriousDamage ? 0 : 20.w),
            controller.hasSeverityDecay
                ? Flexible(
                    flex: 1,
                    child: BoxTextField1(
                      textalign: TextAlign.center,
                      controller: defectItem?.decayTextEditingController,
                      keyboardType: TextInputType.number,
                      onTap: () {
                        defectItem?.decayTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          value: v,
                          setIndex: setIndex,
                          rowIndex: defectItemIndex,
                          fieldName: AppStrings.decay,
                          context: context,
                        );
                      },
                    ),
                  )
                : Flexible(flex: 1, child: SizedBox()),
            SizedBox(width: 10.w),
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Get.to(const InspectionPhotos());
                },
                child: Icon(
                  Icons.photo_camera,
                  color: AppColors.iconBlue,
                  size: 90.w,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  AppAlertDialog.textfiAlert(
                    context,
                    AppStrings.enterComment,
                    '',
                    onYesTap: (value) {
                      defectItem?.instruction = value;
                      controller.onCommentAdd(
                        value: value ?? "",
                        setIndex: setIndex,
                        rowIndex: defectItemIndex,
                      );
                    },
                    windowWidth: MediaQuery.of(context).size.width * 0.9,
                    isMultiLine: true,
                    value: defectItem?.instruction,
                  );
                },
                child: Image.asset(
                  (defectItem?.instruction?.isNotEmpty ?? false)
                      ? AppImages.ic_specCommentsAdded
                      : AppImages.ic_specComments,
                  width: 80.w,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(width: 10.h),
            Flexible(
              flex: 1,
              child: Obx(
                () => InkWell(
                  onTap: () {
                    controller.visisblePopupIndex.value = setIndex;
                    controller.isVisibleInfoPopup.value = true;
                  },
                  child: Image.asset(
                    controller.informationIconEnabled.value
                        ? AppImages.ic_information
                        : AppImages.ic_informationDisabled,
                    width: 80.w,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
      ],
    ),
  );
}

Widget defectCategoryTagRow(DefectsScreenController defectsScreenController) {
  TextStyle textStyle = TextStyle(
    color: Colors.white,
    fontSize: 32.sp,
  );
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 50.w),
    child: Row(
      children: [
        Flexible(flex: 1, child: Container()),
        const SizedBox(width: 15),
        Flexible(flex: 2, child: Container()),
        SizedBox(
            width: defectsScreenController.hasSeveritySeriousDamage ? 0 : 15),
        defectsScreenController.hasSeverityInjury
            ? Flexible(
                flex: 1,
                child: defectCategoryTag(
                  tag: AppStrings.injuryIcon,
                  textStyle: textStyle,
                ),
              )
            : Flexible(flex: 1, child: SizedBox()),
        const SizedBox(width: 15),
        defectsScreenController.hasSeverityDamage
            ? Flexible(
                flex: 1,
                child: defectCategoryTag(
                  tag: AppStrings.damageIcon,
                  textStyle: textStyle,
                ),
              )
            : Flexible(flex: 1, child: SizedBox()),
        const SizedBox(width: 15),
        defectsScreenController.hasSeriousDamage
            ? Flexible(
                flex: 1,
                child: defectCategoryTag(
                  tag: AppStrings.seriousDamageIcon,
                  textStyle: textStyle,
                ),
              )
            : Flexible(flex: 1, child: SizedBox()),
        SizedBox(
            width: defectsScreenController.hasSeveritySeriousDamage ? 0 : 15),
        defectsScreenController.hasSeveritySeriousDamage
            ? Flexible(
                flex: 1,
                child: defectCategoryTag(
                  tag: AppStrings.verySeriousDamageIcon,
                  textStyle: textStyle,
                ),
              )
            : Flexible(flex: 1, child: SizedBox()),
        const SizedBox(width: 15),
        defectsScreenController.hasSeverityDecay
            ? Flexible(
                flex: 1,
                child: defectCategoryTag(
                  tag: AppStrings.decayIcon,
                  textStyle: textStyle,
                ),
              )
            : Flexible(flex: 1, child: SizedBox()),
        const SizedBox(width: 20),
        Flexible(child: Container()),
        const SizedBox(width: 10),
        Flexible(child: Container()),
        const SizedBox(width: 10),
        Flexible(child: Container()),
      ],
    ),
  );
}

Widget defectCategoryTag({required String tag, TextStyle? textStyle}) {
  return Container(
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
          textStyle: TextStyle(
            color: AppColors.textFieldText_Color,
          ),
        ).merge(textStyle)),
  );
}

class DefectsTable extends StatelessWidget {
  DefectsTable({super.key});

  final double typeColumnWidth = 160.w;
  final double emptyColumnWidth = 80.w;
  final double defectColumnWidth = 170.w;
  final double cellHeight = 140.h;

  Color getDataColumnColor(String defectType) {
    switch (defectType) {
      case AppStrings.injury:
        return Colors.greenAccent;
      case AppStrings.damage:
        return AppColors.orange;
      case AppStrings.seriousDamage:
        return Colors.cyanAccent;
      case AppStrings.verySeriousDamage:
        return Colors.redAccent;
      case AppStrings.decay:
        return Colors.purpleAccent;
      default:
        return Colors.white;
    }
  }

  final WorksheetDataTable worksheetDataTable = WorksheetDataTable(
    defectType: AppStrings.types,
    severity: [
      [AppStrings.injury],
      [
        AppStrings.damage,
        AppStrings.damage,
        AppStrings.damage,
      ],
      [
        AppStrings.verySeriousDamage,
      ],
      [
        AppStrings.decay,
      ],
      [
        AppStrings.injury,
      ],
    ],
    qualityDefects: [2, 5, 15, 20, 25],
    qualityDefectsPercentage: [10, 15, 4, 7, 17],
    conditionDefects: [0, 0, 1, 23, 26],
    conditionDefectsPercentage: [0, 0, 4, 8, 25],
    totalSeverity: [
      [0],
      [5, 15, 12],
      [5],
      [6],
      [18]
    ],
    totalSeverityPercentage: [
      [1],
      [11, 12, 14],
      [11],
      [12],
      [18]
    ],
    sizeDefects: [12, 13, 17, 16, 18],
    sizeDefectsPercentage: [11, 14, 18, 20, 12],
    colorDefects: [11, 14, 17, 22, 17],
    colorDefectsPercentage: [15, 16, 11, 12, 18],
  );

  Widget getDefectTypeTag({required String defectType}) {
    String text = '';
    switch (defectType) {
      case AppStrings.injury:
        text = AppStrings.injuryIcon;
      case AppStrings.damage:
        text = AppStrings.damageIcon;
      case AppStrings.seriousDamage:
        text = AppStrings.seriousDamageIcon;
      case AppStrings.verySeriousDamage:
        text = AppStrings.verySeriousDamageIcon;
      case AppStrings.decay:
        text = AppStrings.decayIcon;
      default:
        text = '';
    }

    return Container(
      width: 60.w,
      height: 60.w,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.red,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget getSeverityRowWidget() {
    List<Widget> widgets = [];

    for (List<String> i in worksheetDataTable.severity) {
      List<Widget> innnerWidget = [];

      for (String serverity in i) {
        innnerWidget.add(
          tableDefectsCell(
            text: serverity,
            defectType: serverity,
            widget: getDefectTypeTag(defectType: serverity),
          ),
        );
      }
      widgets.addAll(innnerWidget);
    }
    return Row(
      children: widgets,
    );
  }

  Widget getSingleDataRowWidgets({
    required List<num> field,
    bool? isPercentage = false,
  }) {
    List<Widget> widgets = [];

    for (var i = 0; i < field.length; i++) {
      widgets.add(
        tableDefectsCell(
          defectType: worksheetDataTable.severity[i][0],
          text: "${field[i]}${(isPercentage == true ? "%" : "")}",
          colSpanItem: worksheetDataTable.severity[i].length,
        ),
      );
    }
    return Row(
      children: widgets,
    );
  }

  Widget getMultipleDataRowWidgets({
    required List<List<num>> field,
    bool? isPercentage = false,
    bool? isColumnHeader,
  }) {
    List<Widget> widgets = [];

    for (var i = 0; i < field.length; i++) {
      List<Widget> innerWidget = [];
      for (var j = 0; j < field[i].length; j++) {
        innerWidget.add(tableDefectsCell(
          defectType: worksheetDataTable.severity[i][0],
          text: isColumnHeader == true
              ? AppStrings.defects
              : "${field[i][j]}${(isPercentage == true ? "%" : "")}",
        ));
      }
      widgets.addAll(innerWidget);
    }
    return Row(
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Severity
          Row(
            children: [
              tableTypeCell(
                text: AppStrings.dtType,
                isEnabledTopBorder: true,
              ),
              getMultipleDataRowWidgets(
                  field: worksheetDataTable.totalSeverity, isColumnHeader: true)
            ],
          ),

          // Severity
          Row(
            children: [
              tableTypeCell(
                text: AppStrings.dtSeverity,
              ),
              getSeverityRowWidget()
            ],
          ),

          // Quality Defect
          Row(
            children: [
              tableTypeCell(
                text: AppStrings.totalQualityDefects,
                isEnabledTopBorder: true,
              ),
              getSingleDataRowWidgets(field: worksheetDataTable.qualityDefects),
            ],
          ),

          // Quality Defects percentage
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalQualityDefectsPercentage),
              getSingleDataRowWidgets(
                field: worksheetDataTable.qualityDefectsPercentage,
                isPercentage: true,
              ),
            ],
          ),

          // Condition Defect
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalConditionDefects),
              getSingleDataRowWidgets(
                field: worksheetDataTable.conditionDefects,
              )
            ],
          ),

          // Condition Defect Percentage
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalConditionDefectsPercentage),
              getSingleDataRowWidgets(
                field: worksheetDataTable.conditionDefectsPercentage,
                isPercentage: true,
              )
            ],
          ),

          // Total Severity
          Row(
            children: [
              tableTypeCell(text: AppStrings.dtTotalByDefectType),
              getMultipleDataRowWidgets(
                field: worksheetDataTable.totalSeverity,
              ),
            ],
          ),

          // Total Severity Percentage
          Row(
            children: [
              tableTypeCell(text: AppStrings.dtPercentByDefectType),
              getMultipleDataRowWidgets(
                field: worksheetDataTable.totalSeverityPercentage,
                isPercentage: true,
              ),
            ],
          ),

          // Size Defect
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalSizeDefects),
              getSingleDataRowWidgets(
                field: worksheetDataTable.sizeDefects,
              )
            ],
          ),

          // Size Defect Percentage
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalSizeDefectsPercentage),
              getSingleDataRowWidgets(
                field: worksheetDataTable.sizeDefectsPercentage,
                isPercentage: true,
              )
            ],
          ),

          // Color defects
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalColorDefects),
              getSingleDataRowWidgets(
                field: worksheetDataTable.colorDefects,
              )
            ],
          ),

          // Color Defects percentage
          Row(
            children: [
              tableTypeCell(
                  text: AppStrings.totalColorDefectsPercentage,
                  isEnabledBottomBorder: true),
              getSingleDataRowWidgets(
                field: worksheetDataTable.colorDefectsPercentage,
                isPercentage: true,
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget tableSideContainer({
    Color? bgColor,
    Widget? widget,
    int? flexCount,
    bool? isEmpty,
    required BuildContext context,
    bool? isEnabledTopBorder,
    bool? isEnabledBottomBorder,
    bool? isEnabledRightBorder,
    bool? isEnabledLeftBorder = false,
  }) {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
          color: bgColor ?? Theme.of(context).colorScheme.background,
          border: Border(
            top: isEnabledTopBorder == true
                ? const BorderSide(color: Colors.black, width: 2)
                : const BorderSide(color: Colors.transparent, width: 0),
            bottom: isEnabledBottomBorder == true
                ? const BorderSide(color: Colors.black, width: 2)
                : const BorderSide(color: Colors.transparent, width: 0),
            right: isEnabledRightBorder == true
                ? const BorderSide(color: Colors.black, width: 2)
                : const BorderSide(color: Colors.transparent, width: 0),
            left: isEnabledLeftBorder == true
                ? const BorderSide(color: Colors.grey, width: 4)
                : const BorderSide(color: Colors.transparent, width: 0),
          )),
      padding: EdgeInsets.symmetric(vertical: 35.h),
      child: isEmpty == true
          ? const SizedBox()
          : widget ??
              Icon(
                Icons.camera,
                color: Theme.of(context).colorScheme.background,
              ),
    );
  }

  Widget tableDefectsCell({
    required String text,
    required String defectType,
    int colSpanItem = 1,
    Widget? widget,
    bool? isEnabledTopBorder,
    bool? isEnabledBottomBorder,
    bool? isEnabledRightBorder,
    bool? isEnabledLeftBorder = false,
  }) {
    return Container(
      width: (defectColumnWidth * colSpanItem),
      height: cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: getDataColumnColor(defectType),
        border: Border(
          top: isEnabledTopBorder == true
              ? const BorderSide(color: Colors.black, width: 2)
              : const BorderSide(color: Colors.transparent, width: 0),
          bottom: isEnabledBottomBorder == true
              ? const BorderSide(color: Colors.black, width: 2)
              : const BorderSide(color: Colors.transparent, width: 0),
          right: isEnabledRightBorder == true
              ? const BorderSide(color: Colors.black, width: 2)
              : const BorderSide(color: Colors.transparent, width: 0),
          left: isEnabledLeftBorder == true
              ? const BorderSide(color: Colors.grey, width: 4)
              : const BorderSide(color: Colors.transparent, width: 0),
        ),
      ),
      child: widget ??
          Text(
            text,
            style: const TextStyle(color: Colors.black),
          ),
    );
  }

  Widget tableEmptyCell({
    bool? isEnabledTopBorder,
    bool? isEnabledBottomBorder,
  }) {
    return Container(
      width: emptyColumnWidth,
      height: cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey,
        border: Border(
          top: isEnabledTopBorder == true
              ? const BorderSide(color: Colors.black, width: 2)
              : const BorderSide(color: Colors.transparent, width: 0),
          bottom: isEnabledBottomBorder == true
              ? const BorderSide(color: Colors.black, width: 2)
              : const BorderSide(color: Colors.transparent, width: 0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 16),
      child: const Text(
        "s",
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  Widget tableTypeCell({
    required String text,
    bool? isEnabledTopBorder,
    bool? isEnabledBottomBorder,
  }) {
    return Container(
      width: typeColumnWidth,
      height: cellHeight,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: isEnabledTopBorder == true
              ? const BorderSide(color: Colors.black, width: 2)
              : const BorderSide(color: Colors.transparent, width: 0),
          left: const BorderSide(color: Colors.black, width: 2),
          bottom: isEnabledBottomBorder == true
              ? const BorderSide(color: Colors.black, width: 2)
              : const BorderSide(color: Colors.transparent, width: 0),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Text(
        text,
        style: const TextStyle(color: Colors.black),
        textAlign: TextAlign.center,
      ),
    );
  }
}
