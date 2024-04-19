import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/ui/photos_selection/photos_selection.dart';
import 'package:pverify/controller/worksheet_controller.dart';
import 'package:pverify/ui/worksheet/special_instructions.dart';
import 'package:pverify/ui/worksheet/tableDialog.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import '../../utils/dialogs/app_alerts.dart';

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
                AppStrings.specException,
                (MediaQuery.of(context).size.width / 4.5),
                320.h,
                GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    textStyle: TextStyle(color: AppColors.textFieldText_Color)),
                onClickAction: () {
                  Get.to(const SpecialInstructions(),
                      transition: Transition.downToUp);
                },
              ),
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
                    textStyle: TextStyle(color: AppColors.textFieldText_Color)),
                onClickAction: () {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return tableDialog(context);
                      });
                },
              ),
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
                    textStyle: TextStyle(
                      color: AppColors.textFieldText_Color,
                    ),
                  ), onClickAction: () {
                controller.openPDFFile(context, "Grade");
              }),
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
    WorksheetController controller) {
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
                defectCategoryTagRow(),
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
  required WorksheetController controller,
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
                child: DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: Theme.of(context).colorScheme.background,
                  iconEnabledColor: AppColors.hintColor,
                  value: controller.sampleSetObs[setIndex]
                          .defectItem?[defectItemIndex].name ??
                      "Select",
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: <String>['Select', 'Yes', 'No', 'N/A']
                      .map((String value) {
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
                      value: value ?? "",
                      setIndex: setIndex,
                      rowIndex: defectItemIndex,
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 20.w),
            Flexible(
              flex: 1,
              child: BoxTextField1(
                keyboardType: TextInputType.number,
                controller: defectItem?.injuryTextEditingController,
                onTap: () {
                  defectItem?.injuryTextEditingController?.text = '';
                },
                errorText: '',
                onEditingCompleted: () {},
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
            ),
            SizedBox(width: 20.w),
            Flexible(
              flex: 1,
              child: BoxTextField1(
                keyboardType: TextInputType.number,
                controller: defectItem?.damageTextEditingController,
                onTap: () {
                  defectItem?.damageTextEditingController?.text = '';
                },
                errorText: '',
                onEditingCompleted: () {},
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
            ),
            SizedBox(width: 20.w),
            Flexible(
              flex: 1,
              child: BoxTextField1(
                keyboardType: TextInputType.number,
                controller: defectItem?.sDamageTextEditingController,
                onTap: () {
                  defectItem?.sDamageTextEditingController?.text = '';
                },
                errorText: '',
                onEditingCompleted: () {},
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
            ),
            SizedBox(width: 20.w),
            Flexible(
              flex: 1,
              child: BoxTextField1(
                controller: defectItem?.vsDamageTextEditingController,
                keyboardType: TextInputType.number,
                onTap: () {
                  defectItem?.vsDamageTextEditingController?.text = '';
                },
                errorText: '',
                onEditingCompleted: () {},
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
            ),
            SizedBox(width: 20.w),
            Flexible(
              flex: 1,
              child: BoxTextField1(
                controller: defectItem?.decayTextEditingController,
                keyboardType: TextInputType.number,
                onTap: () {
                  defectItem?.decayTextEditingController?.text = '';
                },
                errorText: '',
                onEditingCompleted: () {},
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
            ),
            SizedBox(width: 10.w),
            Flexible(
              flex: 1,
              child: GestureDetector(
                onTap: () {
                  Get.to(const PhotosSelection());
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
              child: Image.asset(
                AppImages.ic_informationDisabled,
                width: 80.w,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
      ],
    ),
  );
}

Widget defectCategoryTagRow() {
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
        const SizedBox(width: 15),
        Flexible(
          flex: 1,
          child: defectCategoryTag(
            tag: AppStrings.injuryIcon,
            textStyle: textStyle,
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          flex: 1,
          child: defectCategoryTag(
            tag: AppStrings.damageIcon,
            textStyle: textStyle,
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          flex: 1,
          child: defectCategoryTag(
            tag: AppStrings.seriousDamageIcon,
            textStyle: textStyle,
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          flex: 1,
          child: defectCategoryTag(
            tag: AppStrings.verySeriousDamageIcon,
            textStyle: textStyle,
          ),
        ),
        const SizedBox(width: 15),
        Flexible(
          flex: 1,
          child: defectCategoryTag(
            tag: AppStrings.decayIcon,
            textStyle: textStyle,
          ),
        ),
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

  double typeColumnWidth = 160.w;
  double emptyColumnWidth = 80.w;
  double defectColumnWidth = 170.w;
  double cellHeight = 140.h;

  Color getDataColumnColor(String defectType) {
    switch (defectType) {
      case AppStrings.injury:
        return Colors.greenAccent;
      case AppStrings.damage:
        return Colors.orangeAccent;
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              tableTypeCell(
                text: AppStrings.dtType,
                isEnabledTopBorder: true,
              ),
              tableEmptyCell(isEnabledTopBorder: true),
              tableDefectsCell(
                defectType: AppStrings.injury,
                text: AppStrings.defects,
                isEnabledTopBorder: true,
              ),
              tableDefectsCell(
                defectType: AppStrings.damage,
                text: AppStrings.defects,
                isEnabledTopBorder: true,
                isEnabledRightBorder: true,
                isEnabledLeftBorder: true,
              ),
            ],
          ),

          // Quality Defect
          Row(
            children: [
              tableTypeCell(
                text: AppStrings.totalQualityDefects,
                isEnabledTopBorder: true,
              ),
              tableEmptyCell(),
              tableDefectsCell(defectType: AppStrings.injury, text: "2"),
              tableDefectsCell(defectType: AppStrings.damage, text: "2"),
            ],
          ),

          // Quality Defects percentage
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalQualityDefectsPercentage),
              tableEmptyCell(),
              tableDefectsCell(defectType: AppStrings.injury, text: "17 %"),
              tableDefectsCell(defectType: AppStrings.damage, text: "17 %"),
            ],
          ),

          // Condition Defect
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalConditionDefects),
              tableEmptyCell(),
              tableDefectsCell(defectType: AppStrings.injury, text: "0"),
              tableDefectsCell(defectType: AppStrings.damage, text: "0"),
            ],
          ),

          // Condition Defect Percentage
          Row(
            children: [
              tableTypeCell(text: AppStrings.totalConditionDefectsPercentage),
              tableEmptyCell(),
              tableDefectsCell(defectType: AppStrings.injury, text: "0%"),
              tableDefectsCell(defectType: AppStrings.damage, text: "0%"),
            ],
          ),

          // Total Severity
          Row(
            children: [
              tableTypeCell(text: AppStrings.total_severity),
              tableEmptyCell(),
              tableDefectsCell(defectType: AppStrings.injury, text: "2"),
              tableDefectsCell(defectType: AppStrings.damage, text: "0%"),
            ],
          )
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
    Widget? widget,
    bool? isEnabledTopBorder,
    bool? isEnabledBottomBorder,
    bool? isEnabledRightBorder,
    bool? isEnabledLeftBorder = false,
  }) {
    return Container(
      width: defectColumnWidth,
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
    int? flexCount,
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
    int? flexCount,
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
