import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/defects_screen_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/sample_data.dart';
import 'package:pverify/table/merge_table.dart';
import 'package:pverify/table/table_widget.dart';
import 'package:pverify/ui/components/drawer_header_content_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/defects/sample_set_widget.dart';
import 'package:pverify/ui/side_drawer.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class DefectsScreen extends GetView<DefectsScreenController> {
  final String tag;

  const DefectsScreen({
    super.key,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DefectsScreenController>(
        init: DefectsScreenController(),
        tag: tag,
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .background,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              toolbarHeight: 150.h,
              leadingWidth: 0,
              automaticallyImplyLeading: false,
              leading: const Offstage(),
              centerTitle: false,
              backgroundColor: Theme
                  .of(context)
                  .primaryColor,
              titleSpacing: 0,
              title: DrawerHeaderContentView(
                title: controller.partnerName,
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
              children: [
                Expanded(
                  flex: 1,
                  child: contentView(context, controller),
                ),
                FooterContentView(),
              ],
            ),
          );
        });
  }

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
              controller.commodityName,
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white),
            ),
            const Spacer(),
            Text(
              controller.itemSku ?? '',
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.white),
            )
          ],
        ),
      ),
      Obx(() =>
          Container(
            padding: EdgeInsets.only(left: 40.w, right: 40.w),
            color: AppColors.black,
            height: 150.h,
            width: double.infinity,
            child: Row(
              children: [
                controller.sampleList.isNotEmpty
                    ? GestureDetector(
                  onTap: () {
                    controller.setSampleAndDefectCounts();
                    controller.activeTabIndex.value = 0;
                    controller.populateSeverityList();
                    Future.delayed(const Duration(milliseconds: 500))
                        .then((_) {
                      controller.update();
                    });
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
                controller.sampleList.isNotEmpty
                    ? Container(
                  width: 3.w,
                  height: 100.h,
                  decoration: BoxDecoration(
                      color: Theme
                          .of(context)
                          .primaryColor),
                  child: Container(
                    decoration: BoxDecoration(
                        color: Theme
                            .of(context)
                            .canvasColor),
                  ),
                )
                    : const SizedBox(),
                GestureDetector(
                  onTap: () {
                    controller.activeTabIndex.value = 1;
                    controller.update();
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
          )),
      Container(
        padding: EdgeInsets.only(left: 20.w, right: 20.w),
        color: AppColors.lightSky,
        height: 165.h,
        width: ResponsiveHelper.getDeviceWidth(context),
        child: Row(
          children: [
            customViewCategories(AppStrings.injuryIcon, AppStrings.injury),
            customViewCategories(AppStrings.damageIcon, AppStrings.damage),
            customViewCategories(
                AppStrings.seriousDamageIcon, AppStrings.seriousDamage),
            customViewCategories(
                AppStrings.verySeriousDamageIcon, AppStrings.verySeriousDamage),
            customViewCategories(AppStrings.decayIcon, AppStrings.decay),
          ],
        ),
      ),
      SizedBox(
        height: 60.h,
      ),
      controller.activeTabIndex.value == 0
          ? Expanded(
          flex: 1,
          child: SingleChildScrollView(
            child: DefectsMergerTable(
              controller: controller,
            ),
          ))
          : Expanded(
        flex: 1,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 50.w, right: 50.w),
              child: SizedBox(
                height: 150.h,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: AppColors.lightSky,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20.r),
                                bottomLeft: Radius.circular(20.r))),
                        child: Container(
                          margin:
                          const EdgeInsets.symmetric(horizontal: 20),
                          child: BoxTextField1(
                            textColor: AppColors.textFieldText_Color,
                            hintColor: AppColors.textFieldText_Color,
                            isMulti: false,
                            controller:
                            controller.sizeOfNewSetTextController,
                            onTap: () {},
                            textalign: TextAlign.center,
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
                            controller.addSample();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(20.r),
                                  topRight: Radius.circular(20.r))),
                          child: Text(
                            AppStrings.addSample,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w400,
                                color: AppColors.white),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 60.h,
            ),
            Expanded(
              flex: 1,
              child: ListView.builder(
                  itemCount: controller.sampleList.length,
                  itemBuilder: (BuildContext context, int sampleIndex) {
                    return SampleSetWidget(
                      sampleIndex: sampleIndex,
                      controller: controller,
                      onRemoveAll: () {
                        controller.update();
                      },
                    );
                  }),
            )
          ],
        ),
      ),
      bottomContent(context, controller)
    ]);
  }

// DEFECTS VIEW

  Widget customViewDefectsView(double height,
      double width,
      String title,
      BuildContext context,
      bool isActive,) {
    return Row(
      children: [
        Container(
          alignment: Alignment.center,
          height: height,
          width: width,
          decoration: BoxDecoration(
            color: Theme
                .of(context)
                .primaryColor,
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
                color: AppColors.white),
          ),
        ),
      ],
    );
  }

// CATEGORIES VIEW LIKE:: INJURY, DAMAGE

  Widget customViewCategories(String tag, String title) {
    return Container(
      padding: const EdgeInsets.only(left: 10),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.lightGrey), // Border color
              borderRadius: BorderRadius.circular(30), // Border radius
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Expanded(
              flex: 1,
              child: Text(
                textAlign: TextAlign.center,
                tag,
                style: GoogleFonts.poppins(
                    fontSize: 26.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textFieldText_Color),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Text(
            textAlign: TextAlign.start,
            title,
            style: GoogleFonts.poppins(
                fontSize: 26.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textFieldText_Color),
          )
        ],
      ),
    );
  }

// BOTTOM CONTENTS

  Widget bottomContent(BuildContext context,
      DefectsScreenController controller) {
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
                  width: (MediaQuery
                      .of(context)
                      .size
                      .width / 2.3),
                  height: 115,
                  fontStyle: GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFieldText_Color),
                  onClickAction: () async {
                    await controller
                        .deleteInspectionAndGotoMyInspectionScreen(context);
                  }),
              SizedBox(
                width: 38.w,
              ),
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.saveInspectionButton,
                  width: (MediaQuery
                      .of(context)
                      .size
                      .width / 2.3),
                  height: 115,
                  fontStyle: GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textFieldText_Color),
                  onClickAction: () async {
                    await controller.saveDefectEntriesAndContinue(context);
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
                width: (MediaQuery
                    .of(context)
                    .size
                    .width / 4.5),
                height: 320.h,
                fontStyle: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textFieldText_Color),
                onClickAction: () async {
                  if (controller.appStorage.commodityVarietyData != null &&
                      controller.appStorage.commodityVarietyData?.exceptions !=
                          null &&
                      controller.appStorage.commodityVarietyData!.exceptions
                          .isNotEmpty) {
                    await controller.onSpecialInstrMenuTap();
                  } else {
                    AppSnackBar.info(
                        message: AppStrings.noSpecificationInstructions);
                  }
                },
              ),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                backgroundColor: AppColors.white,
                title: AppStrings.specification,
                width: (MediaQuery
                    .of(context)
                    .size
                    .width / 4.5),
                height: 320.h,
                fontStyle: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textFieldText_Color),
                onClickAction: () async {
                  controller.appStorage.specificationGradeToleranceTable =
                  await controller.dao.getSpecificationGradeToleranceTable(
                      controller.specificationNumber!,
                      controller.specificationVersion!);
                  if (controller
                      .appStorage.specificationGradeToleranceTable.isNotEmpty) {
                    await controller.onSpecificationTap();
                  }
                  // await controller.onSpecificationTap();
                },
              ),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.grade,
                  width: (MediaQuery
                      .of(context)
                      .size
                      .width / 4.5),
                  height: 320.h,
                  fontStyle: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    textStyle: TextStyle(
                      color: AppColors.textFieldText_Color,
                    ),
                  ),
                  onClickAction: () async {
                    await controller.jsonFileOperations.viewGradePdf();
                  }),
              SizedBox(
                width: 20.w,
              ),
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.specInstrunction,
                  width: (MediaQuery
                      .of(context)
                      .size
                      .width / 4.5),
                  height: 320.h,
                  fontStyle: GoogleFonts.poppins(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textFieldText_Color),
                  onClickAction: () async {
                    await controller.jsonFileOperations.viewSpecInsPdf();
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

/// defect from merger

class DefectsMergerTable extends StatelessWidget {
  final DefectsScreenController controller;

  const DefectsMergerTable({super.key, required this.controller});

  // bool get hasSeverityInjury => controller.hasSeverityInjury;
  //
  // bool get hasSeverityDamage => controller.hasSeverityDamage;
  //
  // bool get hasSeveritySeriousDamage => controller.hasSeveritySeriousDamage;
  //
  // bool get hasSeverityVerySeriousDamage =>
  //     controller.hasSeverityVerySeriousDamage;
  //
  // bool get hasSeverityDecay => controller.hasSeverityDecay;

  int get numberSamples => controller.numberSamples;

  int get numberSeriousDefects => controller.numberSeriousDefects;

  int get totalQualityInjury => controller.totalQualityInjury;

  int get totalQualityDamage => controller.totalQualityDamage;

  int get totalQualitySeriousDamage => controller.totalQualitySeriousDamage;

  int get totalQualityVerySeriousDamage =>
      controller.totalQualityVerySeriousDamage;

  int get totalQualityDecay => controller.totalQualityDecay;

  int get totalSamples => controller.totalSamples;

  int get totalConditionInjury => controller.totalConditionInjury;

  int get totalConditionDamage => controller.totalConditionDamage;

  int get totalConditionSeriousDamage => controller.totalConditionSeriousDamage;

  int get totalConditionVerySeriousDamage =>
      controller.totalConditionVerySeriousDamage;

  int get totalConditionDecay => controller.totalConditionDecay;

  int get totalSizeInjury => controller.totalSizeInjury;

  int get totalSizeDamage => controller.totalSizeDamage;

  int get totalSizeSeriousDamage => controller.totalSizeSeriousDamage;

  int get totalSizeVerySeriousDamage => controller.totalSizeVerySeriousDamage;

  int get totalSizeDecay => controller.totalSizeDecay;

  int get totalColorInjury => controller.totalColorInjury;

  int get totalColorDamage => controller.totalColorDamage;

  int get totalColorSeriousDamage => controller.totalColorSeriousDamage;

  int get totalColorVerySeriousDamage => controller.totalColorVerySeriousDamage;

  int get totalColorDecay => controller.totalColorDecay;

  @override
  Widget build(BuildContext context) {
    controller.populateSeverityList();
    if (controller.appStorage.severityList != null) {
      for (var severity in controller.appStorage.severityList!) {
        if (severity.name == "Injury" || severity.name == "Lesión") {
          controller.hasSeverityInjury = true;
        } else if (severity.name == "Damage" || severity.name == "Daño") {
          controller.hasSeverityDamage = true;
        } else if (severity.name == "Serious Damage" ||
            severity.name == "Daño Serio") {
          controller.hasSeveritySeriousDamage = true;
        } else if (severity.name == "Very Serious Damage" ||
            severity.name == "Daño Muy Serio") {
          controller.hasSeverityVerySeriousDamage = true;
        } else if (severity.name == "Decay" || severity.name == "Pudrición") {
          controller.hasSeverityDecay = true;
        }
      }
    }

    List<List<BaseMRow>> rows = _getRows();

    return Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: TableWidget(datas: rows));

    /*return MergeTable(
      borderColor: Colors.grey,
      alignment: MergeTableAlignment.center,
      // columns: _getColumns(),
      columns: _createDefectTableHeaderRow(maxLength),
      rows: rows,
    );*/
  }

  List<List<BaseMRow>> _getRows() {
    List<List<BaseMRow>> rows = [];
    rows.add(_createDefectTableHeaderRow());
    rows.add(_getRowSeverity());

    for (int i = 0; i < numberSamples; i++) {
      rows.add(_getSampleRow(i));
    }

    rows.add(_getTotalQualityDefectsRow());
    rows.add(_getTotalQualityDefectsPercentRow());
    rows.add(_getTotalConditionDefectsRow());
    rows.add(_getTotalConditionDefectsPercentRow());
    rows.add(_getTotalSeverityByDefectTypeRow());
    rows.add(_getTotalSeverityByDefectPercentRow());
    rows.add(_getTotalSizeDefectsRow());
    rows.add(_getTotalSizeDefectsPercentRow());
    rows.add(_getTotalColorDefectsRow());
    rows.add(_getTotalColorDefectsPercentRow());

    return rows;
  }

  List<BaseMRow> _getRowSeverity() {
    return [
      MRow(Container(
        color: AppColors.white,
        child: Center(
          child: Text(
            "Severity",
            style: textStyle(),
          ),
        ),
      )),
      if (controller.hasSeverityInjury)
        MRow(Container(
          color: AppColors.defectBlue,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 35, height: 35, child: circularDefectItem("I")),
              ],
            ),
          ),
        )),
      if (controller.hasSeverityDamage)
        MRow(Container(
          color: AppColors.defectGreen,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 35, height: 35, child: circularDefectItem("D")),
              ],
            ),
          ),
        )),
      // if (controller.hasSeveritySeriousDamage)
      //   MMergedRows(List.generate(
      //       numberSeriousDefects, (index) => circularDefectItem("SD"))),
      if (controller.hasSeveritySeriousDamage)
        for (int i = 0; i < numberSeriousDefects; i++)
          if (controller.hasSeveritySeriousDamage)
            MRow(GestureDetector(
              onTap: () {
                // alert dialog with ok action button
                AppAlertDialog.showSeverityItemDialog(
                  context: Get.context!,
                  title: controller.seriousDefectList[(i)],
                  titleWidget: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 35,
                          height: 35,
                          child: circularDefectItem("SD",
                              color: const Color(0xff680000))),
                      Text(
                        (i + 1).toString(),
                        style: textStyle(),
                      )
                    ],
                  ),
                );
              },
              child: Container(
                color: AppColors.defectOrange,
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                          width: 35,
                          height: 35,
                          child: circularDefectItem("SD",
                              color: const Color(0xff680000))),
                      const SizedBox(width: 3),
                      Text(
                        (i + 1).toString(),
                        style: textStyle(),
                      )
                    ],
                  ),
                ),
              ),
            )),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(circularDefectItem("VS")),
      if (controller.hasSeverityDecay) MRow(circularDefectItem("DK")),
    ];
  }

  TextStyle textStyle() {
    return Get.textTheme.labelMedium!.copyWith(
      fontWeight: FontWeight.w600,
      color: AppColors.black,
    );
  }

  List<MRow> _createDefectTableHeaderRow() {
    List<MRow> rows = [
      MRow(Container(color: AppColors.white, child: defaultTextItem("Type"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue, child: defaultTextItem('Defects'))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen, child: defaultTextItem('Defects'))),
      if (controller.hasSeveritySeriousDamage)
        for (int i = 0; i < numberSeriousDefects; i++)
          if (controller.hasSeveritySeriousDamage)
            MRow(Container(
                color: AppColors.defectOrange,
                child: defaultTextItem('Defects'))),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem('Defects')),
      if (controller.hasSeverityDecay) MRow(defaultTextItem('Defects')),
    ];
    return rows;
  }

  Widget circularDefectItem(String title, {Color? color}) {
    return SizedBox(
      height: 25,
      width: 25,
      child: Container(
        padding: const EdgeInsets.all(2),
        // margin: EdgeInsets.symmetric(vertical: 5),
        height: 25,
        width: 25,
        decoration: BoxDecoration(
          border: Border.all(color: color ?? const Color(0xffFA0000)),
          shape: BoxShape.circle,
          color: color ?? AppColors.red,
        ),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: textStyle().copyWith(
              color: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget defaultTextItem(String title, {Color? color}) {
    return Center(
      child: SizedBox(
        width: 100,
        child: Container(
          padding: const EdgeInsets.all(2),
          // margin: EdgeInsets.symmetric(vertical: 5),
          width: 100,
          height: 50,
          child: Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: textStyle(),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildSeriousDefect({
    required BuildContext context,
    required int index,
    required int numberSeriousDefects,
    required String defectName,
    required bool hasSeveritySeriousDamage,
    required Function(int) onClick,
  }) {
    return GestureDetector(
      onTap: () => onClick(index),
      child: Container(
        margin: EdgeInsets.only(
          right: index == numberSeriousDefects - 1 ? 4.0 : 0,
          bottom: 4.0,
        ),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.orange,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'SD',
                style: textStyle(),
              ),
            ),
            if (numberSeriousDefects > 1)
              Text(
                '${index + 1}',
                style: TextStyle(fontSize: 12.0, color: AppColors.black),
              ),
          ],
        ),
      ),
    );
  }

  List<BaseMRow> _getSampleRow(int index) {
    SampleData? a = controller.sampleList.elementAtOrNull(index);
    SampleData? sampleData = controller.sampleDataMap[a?.sampleSize ?? 0];
    return [
      MRow(Container(
          color: AppColors.white,
          child: defaultTextItem((sampleData?.sampleSize ?? 0).toString()))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem((sampleData?.iCnt ?? 0).toString()))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem((sampleData?.dCnt ?? 0).toString()))),
      if (controller.hasSeveritySeriousDamage)
        for (int i = 0; i < numberSeriousDefects; i++)
          if (controller.hasSeveritySeriousDamage)
            MRow(Container(
              color: AppColors.defectOrange,
              child: defaultTextItem(
                  getCount(sampleData?.name ?? '', i).toString()),
            )),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem((sampleData?.vsdCnt ?? 0).toString())),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem((sampleData?.dcCnt ?? 0).toString())),
      MRow(_createPicturesCell(sampleData)),
      MRow(_createCommentsCell(sampleData)),
    ];
  }

  // Done
  List<BaseMRow> _getTotalQualityDefectsRow() {
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Quality Defects"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem("${controller.totalQualityInjury}"))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem("${controller.totalQualityDamage}"))),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$totalQualitySeriousDamage";
          }
          if (value.isEmpty) {
            return Offstage(
                child: Container(
                    width: 100, height: 65, color: AppColors.defectOrange));
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    value,
                    style: textStyle(),
                  )),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("${controller.totalQualityVerySeriousDamage}")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("${controller.totalQualityDecay}")),
    ];
  }

  // Done
  List<BaseMRow> _getTotalQualityDefectsPercentRow() {
    int percentDecay = (totalQualityDecay / totalSamples * 100).round();
    int percentVSDamage =
    (totalQualityVerySeriousDamage / totalSamples * 100).round();
    int percentSDamage =
    (totalQualitySeriousDamage / totalSamples * 100).round();
    int percentDamage = (totalQualityDamage / totalSamples * 100).round();
    int percentInjury = (totalQualityInjury / totalSamples * 100).round();
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Quality Defects %"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem("$percentInjury%"))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem("$percentDamage%"))),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$percentSDamage%";
          }
          if (value.isEmpty) {
            return Offstage(
                child: Container(
                    width: 100, height: 65, color: AppColors.defectOrange));
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: textStyle().copyWith(
                    color: (controller.seriousDamageQualitySpec != null &&
                        percentSDamage >
                            (controller.seriousDamageQualitySpec ?? 0.0))
                        ? AppColors.red
                        : AppColors.black,
                  ),
                ),
              ),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(Center(
          child: Text(
            "$percentVSDamage%",
            textAlign: TextAlign.center,
            style: textStyle().copyWith(
              color: (controller.verySeriousDamageQualitySpec != null &&
                  percentVSDamage >
                      (controller.verySeriousDamageQualitySpec ?? 0.0))
                  ? AppColors.red
                  : AppColors.black,
            ),
          ),
        )),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem(
          "$percentDecay%",
          color: (controller.decayQualitySpec != null &&
              percentDecay > (controller.decayQualitySpec ?? 0.0))
              ? AppColors.red
              : null,
        )),
    ];
  }

  // Done
  List<BaseMRow> _getTotalConditionDefectsRow() {
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Condition Defects"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem("${controller.totalConditionInjury}"))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem("${controller.totalConditionDamage}"))),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            int a = controller.totalConditionSeriousDamage;
            value = "$a";
          }
          if (value.isEmpty) {
            return Offstage(
                child: Container(
                    width: 100, height: 65, color: AppColors.defectOrange));
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(value, style: textStyle())),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("${controller.totalConditionVerySeriousDamage}")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("${controller.totalConditionDecay}")),
    ];
  }

  // Done
  List<BaseMRow> _getTotalConditionDefectsPercentRow() {
    int percentCDecay = (totalConditionDecay / totalSamples * 100).round();
    int percentCVSDamage =
    (totalConditionVerySeriousDamage / totalSamples * 100).round();
    int percentSCDamage =
    (totalConditionSeriousDamage / totalSamples * 100).round();
    int percentCDamage = (totalConditionDamage / totalSamples * 100).round();
    int percentCInjury = (totalConditionInjury / totalSamples * 100).round();

    return [
      MRow(Container(
          color: AppColors.white,
          child: defaultTextItem("Condition Defects %"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
          color: AppColors.defectBlue,
          child: defaultTextItem(
            "$percentCInjury%",
            color: (controller.injuryConditionSpec != null &&
                percentCInjury > (controller.injuryConditionSpec ?? 0.0))
                ? AppColors.red
                : null,
          ),
        )),
      if (controller.hasSeverityDamage)
        MRow(Container(
          color: AppColors.defectGreen,
          child: defaultTextItem(
            "$percentCDamage%",
            color: (controller.damageConditionSpec != null &&
                percentCDamage > (controller.damageConditionSpec ?? 0.0))
                ? AppColors.red
                : null,
          ),
        )),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$percentSCDamage%";
          }
          if (value.isEmpty) {
            return Offstage(
                child: Container(
                    width: 100, height: 65, color: AppColors.defectOrange));
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  value,
                  textAlign: TextAlign.center,
                  style: textStyle().copyWith(
                    color: (controller.seriousDamageConditionSpec != null &&
                        percentSCDamage >
                            (controller.seriousDamageConditionSpec ?? 0.0))
                        ? AppColors.red
                        : AppColors.black,
                  ),
                ),
              ),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(Center(
          child: Text(
            "$percentCVSDamage%",
            textAlign: TextAlign.center,
            style: textStyle().copyWith(
              color: (controller.verySeriousDamageConditionSpec != null &&
                  percentCVSDamage >
                      (controller.verySeriousDamageConditionSpec ?? 0.0))
                  ? AppColors.red
                  : AppColors.black,
            ),
          ),
        )),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem(
          "$percentCDecay%",
          color: (controller.decayConditionSpec != null &&
              percentCDecay > (controller.decayConditionSpec ?? 0.0))
              ? AppColors.red
              : null,
        )),
    ];
  }

  // Done
  List<BaseMRow> _getTotalSeverityByDefectTypeRow() {
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Total Severity"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem("${controller.totalInjury}"))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem("${controller.totalDamage}"))),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          int percent = 0;
          if (controller.seriousDefectList.isNotEmpty) {
            int? sdcount = controller
                .seriousDefectCountMap[controller.seriousDefectList[index]];
            if (sdcount != null) {
              percent = sdcount;
            }
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    percent.toString(),
                    textAlign: TextAlign.center,
                    style: textStyle().copyWith(
                      color: (controller.seriousDamageSpec != null &&
                          percent > (controller.seriousDamageSpec ?? 0.0))
                          ? AppColors.red
                          : AppColors.black,
                    ),
                  )),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("${controller.totalVerySeriousDamage}")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("${controller.totalDecay}")),
    ];
  }

  // Done
  List<BaseMRow> _getTotalSeverityByDefectPercentRow() {
    int totalDecay = (controller.totalDecay / totalSamples * 100).round();
    int totalDamage = (controller.totalDamage / totalSamples * 100).round();
    int totalInjury = (controller.totalInjury / totalSamples * 100).round();
    int totalVerySeriousDamage =
    (controller.totalVerySeriousDamage / totalSamples * 100).round();
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Total Severity %"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
          color: AppColors.defectBlue,
          child: defaultTextItem(
            "$totalInjury%",
            color: (controller.injurySpec != null &&
                totalInjury > (controller.injurySpec ?? 0.0))
                ? AppColors.red
                : null,
          ),
        )),
      if (controller.hasSeverityDamage)
        MRow(Container(
          color: AppColors.defectGreen,
          child: defaultTextItem(
            "$totalDamage%",
            color: (controller.damageSpec != null &&
                totalDamage > (controller.damageSpec ?? 0.0))
                ? AppColors.red
                : null,
          ),
        )),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "0";
          int percent = 0;
          if (!controller.seriousDefectList.isEmpty) {
            int? sdcount = controller
                .seriousDefectCountMap[controller.seriousDefectList[index]];
            if (sdcount != null) {
              percent = (sdcount / totalSamples * 10).round();
              value = percent.toString();
            }
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    "$value%",
                    textAlign: TextAlign.center,
                    style: textStyle().copyWith(
                      color: (controller.seriousDamageSpec != null &&
                          percent > (controller.seriousDamageSpec ?? 0.0))
                          ? AppColors.red
                          : AppColors.black,
                    ),
                  )),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem(
          "$totalVerySeriousDamage%",
          color: controller.verySeriousDamageSpec != null &&
              totalVerySeriousDamage >
                  (controller.verySeriousDamageSpec ?? 0.0)
              ? AppColors.red
              : null,
        )),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("$totalDecay%",
            color: (controller.decaySpec != null &&
                totalDecay > (controller.decaySpec ?? 0.0))
                ? AppColors.red
                : null)),
    ];
  }

  // Done
  List<BaseMRow> _getTotalSizeDefectsRow() {
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Size Defects"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem("$totalSizeInjury"))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem("$totalSizeDamage"))),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$totalSizeSeriousDamage";
          }
          if (value.isEmpty) {
            return Offstage(
                child: Container(
                    width: 100, height: 65, color: AppColors.defectOrange));
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(value, style: textStyle())),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("$totalSizeVerySeriousDamage")),
      if (controller.hasSeverityDecay) MRow(defaultTextItem("$totalSizeDecay")),
    ];
  }

  // Done
  List<BaseMRow> _getTotalSizeDefectsPercentRow() {
    int percentSizeDecay = (totalSizeDecay / totalSamples * 100).round();
    int percentSizeVSDamage =
    (totalSizeVerySeriousDamage / totalSamples * 100).round();
    int percentSizeDamage = (totalSizeDamage / totalSamples * 100).round();
    int percentSizeInjury = (totalSizeInjury / totalSamples * 100).round();
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Size Defects %"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem("$percentSizeInjury%"))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem("$percentSizeDamage%"))),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            int percentSCDamage =
            (totalSizeSeriousDamage / totalSamples * 100).round();
            value = "$percentSCDamage%";
          }
          if (value.isEmpty) {
            return Offstage(
                child: Container(
                    width: 100, height: 65, color: AppColors.defectOrange));
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(value, style: textStyle()),
              ),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(Center(child: Text("$percentSizeVSDamage%", style: textStyle()))),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("$percentSizeDecay%")),
    ];
  }

  // Done
  List<BaseMRow> _getTotalColorDefectsRow() {
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Color Defects"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem("$totalColorInjury"))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem("$totalColorDamage"))),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$totalColorSeriousDamage";
          }
          if (value.isEmpty) {
            return Offstage(
                child: Container(
                    width: 100, height: 65, color: AppColors.defectOrange));
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Text(value, style: textStyle())),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("$totalColorVerySeriousDamage")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("$totalColorDecay")),
    ];
  }

  // Done
  List<BaseMRow> _getTotalColorDefectsPercentRow() {
    double percentColorDecay = (totalColorDecay / totalSamples * 100);
    double percentColorVSDamage =
    (totalColorVerySeriousDamage / totalSamples * 100);
    int percentColorDamage = (totalColorDamage / totalSamples * 100).round();
    int percentColorInjury = (totalColorInjury / totalSamples * 100).round();
    return [
      MRow(Container(
          color: AppColors.white, child: defaultTextItem("Color Defects %"))),
      if (controller.hasSeverityInjury)
        MRow(Container(
            color: AppColors.defectBlue,
            child: defaultTextItem("$percentColorInjury%"))),
      if (controller.hasSeverityDamage)
        MRow(Container(
            color: AppColors.defectGreen,
            child: defaultTextItem("$percentColorDamage%"))),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            int percentSColorDamage =
            (totalColorSeriousDamage / totalSamples * 100).round();
            value = "$percentSColorDamage%";
          }
          if (value.isEmpty) {
            return Offstage(
                child: Container(
                    width: 100, height: 65, color: AppColors.defectOrange));
          }
          return Container(
            color: AppColors.defectOrange,
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 5),
                child: Text(value, style: textStyle()),
              ),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(Center(
            child:
            Text("${percentColorVSDamage.round()}%", style: textStyle()))),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("${percentColorDecay.round()}%")),
    ];
  }

  Widget _createPicturesCell(SampleData? sampleData) {
    return GestureDetector(
      onTap: () async {
        if (sampleData != null) {
          controller.navigateToViewCameraScreen(sampleData: sampleData);
        }
      },
      child: Icon(
        Icons.photo_camera,
        color: AppColors.iconBlue,
        size: 90.w,
      ),
    );
  }

  Widget _createCommentsCell(SampleData? sampleData) {
    String comment = controller.getCommentsForSample(sampleData!.name);
    return GestureDetector(
      onTap: () {
        AppAlertDialog.validateAlerts(
          Get.context!,
          AppStrings.viewComment,
          comment,
        );
      },
      child: Image.asset(
        comment
            .trim()
            .isNotEmpty
            ? AppImages.ic_specCommentsAdded
            : AppImages.ic_specComments,
        width: 80.w,
        fit: BoxFit.contain,
      ),
    );
  }

  int getCount(String name, int i) {
    List<InspectionDefect>? data = controller.defectDataMap[name];
    int count = 0;
    if (data != null) {
      for (int k = 0; k < data.length; k++) {
        if ((controller.seriousDefectList.isNotEmpty) &&
            (data[k].spinnerSelection == controller.seriousDefectList[i])) {
          if (data[k].seriousDamageCnt != null) {
            count += data[k].seriousDamageCnt!;
          }
        }
      }
    }
    return count;
  }
}

class VerticalMergedCells extends StatelessWidget {
  final int rowSpan;
  final Widget child;

  VerticalMergedCells({required this.rowSpan, required this.child});

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.fill,
      child: Column(
        children: List.generate(rowSpan, (index) => child),
      ),
    );
  }
}
