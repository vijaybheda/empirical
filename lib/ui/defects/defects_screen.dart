import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/defects_screen_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/sample_data.dart';
import 'package:pverify/table/merge_table.dart';
import 'package:pverify/ui/components/drawer_header_content_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/defects/sample_set_widget.dart';
import 'package:pverify/ui/side_drawer.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
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
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              toolbarHeight: 150.h,
              leadingWidth: 0,
              automaticallyImplyLeading: false,
              leading: const Offstage(),
              centerTitle: false,
              backgroundColor: Theme.of(context).primaryColor,
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
      Obx(() => Container(
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
                            color: Theme.of(context).primaryColor),
                        child: Container(
                          decoration: BoxDecoration(
                              color: Theme.of(context).canvasColor),
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
              ),
              //controller.drawDefectsTable()
              //     SingleChildScrollView(
              //   child: DefectsTable(
              //     defectDataMap: controller.defectDataMap,
              //     numberSamples: controller.numberSamples,
              //     numberSeriousDefects: controller.numberSeriousDefects,
              //     sampleDataMap: controller.sampleDataMap,
              //     sampleDataMapIndexList: controller.sampleDataMapIndexList,
              //     seriousDefectList: controller.seriousDefectList,
              //     severityList: controller.appStorage.severityList ?? [],
              //     controller: controller,
              //   ),
              // ),
            )
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
                          );
                        }),
                  )
                ],
              ),
            ),
      bottomContent(context, controller)
    ]);
  }

  List<int> getColorDefectsPercentage(DefectsScreenController controller) {
    return [
      (((controller.totalColorInjury / controller.totalSamples) * 100)).round(),
      (((controller.totalColorDamage / controller.totalSamples) * 100)).round(),
      (((controller.totalColorSeriousDamage / controller.totalSamples) * 100))
          .round(),
      (((controller.totalColorVerySeriousDamage / controller.totalSamples) *
              100))
          .round(),
      (((controller.totalColorDecay / controller.totalSamples) * 100)).round(),
    ];
  }

  List<int> getSizeDefectsPercentage(DefectsScreenController controller) {
    return [
      (((controller.totalSizeInjury / controller.totalSamples) * 100)).round(),
      (((controller.totalSizeDamage / controller.totalSamples) * 100)).round(),
      (((controller.totalSizeSeriousDamage / controller.totalSamples) * 100))
          .round(),
      (((controller.totalSizeVerySeriousDamage / controller.totalSamples) *
              100))
          .round(),
      (((controller.totalSizeDecay / controller.totalSamples) * 100)).round(),
    ];
  }

  List<List<int>> getTotalSeverityPercentage(
      DefectsScreenController controller) {
    return [
      [(((controller.totalInjury / controller.totalSamples) * 100)).round()],
      [
        (((controller.totalDamage / controller.totalSamples) * 100)).round(),
        (((controller.seriousDefectCountMap[controller.seriousDefectList[0]]! /
                    controller.totalSamples) *
                100))
            .round(),
        (((controller.seriousDefectCountMap[controller.seriousDefectList[1]]! /
                    controller.totalSamples) *
                100))
            .round()
      ],
      [
        (((controller.totalVerySeriousDamage / controller.totalSamples) * 100))
            .round()
      ],
      [(((controller.totalDecay / controller.totalSamples) * 100)).round()],
      [(((controller.totalInjury / controller.totalSamples) * 100)).round()]
    ];
  }

  List<List<int>> getTotalSeverity(DefectsScreenController controller) {
    int x1 = 0;
    int x2 = 0;
    if (controller.seriousDefectCountMap.isNotEmpty &&
        controller.seriousDefectList.isNotEmpty) {
      x1 = controller.seriousDefectCountMap[controller.seriousDefectList[0]] ??
          0;
      if (controller.seriousDefectList.length > 1) {
        x2 =
            controller.seriousDefectCountMap[controller.seriousDefectList[1]] ??
                0;
      }
    }
    return [
      [controller.totalInjury],
      [controller.totalDamage, x1, x2],
      [controller.totalVerySeriousDamage],
      [controller.totalDecay],
      [controller.totalInjury]
    ];
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
            color: AppColors.white),
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

  Widget bottomContent(
      BuildContext context, DefectsScreenController controller) {
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
                  width: (MediaQuery.of(context).size.width / 2.3),
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
                width: (MediaQuery.of(context).size.width / 4.5),
                height: 320.h,
                fontStyle: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textFieldText_Color),
                onClickAction: () async {
                  await controller.onSpecialInstrMenuTap();
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
                    color: AppColors.textFieldText_Color),
                onClickAction: () async {
                  /*controller.appStorage.specificationGradeToleranceTable =
                      await controller.dao.getSpecificationGradeToleranceTable(
                          controller.specificationNumber!,
                          controller.specificationVersion!);
                  if (controller
                      .appStorage.specificationGradeToleranceTable.isNotEmpty) {
                    controller.onSpecificationTap();
                  }*/
                  await controller.onSpecificationTap();
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
                  onClickAction: () async {
                    await controller.jsonFileOperations.viewGradePdf();
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

    return MergeTable(
      borderColor: Colors.grey,
      alignment: MergeTableAlignment.center,
      columns: _getColumns(),
      rows: _getRows(),
    );
  }

  List<BaseMColumn> _getColumns() {
    return [
      MColumn(header: "Type"),
      if (controller.hasSeverityInjury) MColumn(header: "Defects"),
      if (controller.hasSeverityDamage) MColumn(header: "Defects"),
      if (controller.hasSeveritySeriousDamage)
        MMergedColumns(
          header: "Defects",
          columns:
              List.generate(numberSeriousDefects, (index) => "SD ${index + 1}"),
        ),
      if (controller.hasSeverityVerySeriousDamage) MColumn(header: "Defects"),
      if (controller.hasSeverityDecay) MColumn(header: "Defects"),
      MColumn(header: ""),
    ];
  }

  List<List<BaseMRow>> _getRows() {
    List<List<BaseMRow>> rows = [];

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
    rows.add(_getPercentByDefectTypeRow());
    rows.add(_getTotalSizeDefectsRow());
    rows.add(_getTotalSizeDefectsPercentRow());
    rows.add(_getTotalColorDefectsRow());
    rows.add(_getTotalColorDefectsPercentRow());

    return rows;
  }

  List<BaseMRow> _getRowSeverity() {
    return [
      MRow(Text("Severity")),
      if (controller.hasSeverityInjury) MRow(circularDefectItem("I")),
      if (controller.hasSeverityDamage) MRow(circularDefectItem("D")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(
            numberSeriousDefects, (index) => circularDefectItem("SD"))),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(circularDefectItem("VS")),
      if (controller.hasSeverityDecay) MRow(circularDefectItem("DK")),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  Widget circularDefectItem(String title) {
    return SizedBox(
      child: Container(
        padding: EdgeInsets.all(2),
        // margin: EdgeInsets.symmetric(vertical: 5),
        height: 35,
        width: 35,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red),
          shape: BoxShape.circle,
          color: Colors.red,
        ),
        child: Center(
          child: Text(
            title,
            style: Get.textTheme.labelMedium!
                .copyWith(fontWeight: FontWeight.w600, color: AppColors.white),
          ),
        ),
      ),
    );
  }

  Widget defaultTextItem(String title, {Color? color}) {
    return SizedBox(
      width: 100,
      child: Container(
        padding: EdgeInsets.all(2),
        // margin: EdgeInsets.symmetric(vertical: 5),
        width: 100,
        height: 50,
        child: Center(
          child: Text(
            title,
            style: Get.textTheme.labelMedium!.copyWith(
                fontWeight: FontWeight.w600, color: color ?? AppColors.white),
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
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.orange,
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(4.0),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'SD',
                style: TextStyle(color: Colors.white),
              ),
            ),
            if (numberSeriousDefects > 1)
              Text(
                '${index + 1}',
                style: TextStyle(fontSize: 12.0),
              ),
          ],
        ),
      ),
    );
  }

  List<Widget> buildSeriousDefectRow({
    required BuildContext context,
    required int numberSeriousDefects,
    required List<String> seriousDefectList,
    required bool hasSeveritySeriousDamage,
  }) {
    List<Widget> rowChildren = [];

    for (int i = 0; i < numberSeriousDefects; i++) {
      rowChildren.add(buildSeriousDefect(
        context: context,
        index: i,
        numberSeriousDefects: numberSeriousDefects,
        defectName: seriousDefectList[i],
        hasSeveritySeriousDamage: hasSeveritySeriousDamage,
        onClick: (int index) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Serious Defect'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Subscript: ${index + 1}'),
                    Text('Name: ${seriousDefectList[index]}'),
                  ],
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
      ));
    }

    return rowChildren;
  }

  List<BaseMRow> _getSampleRow(int index) {
    SampleData? sampleData = controller.sampleList.elementAtOrNull(index);
    return [
      MRow(defaultTextItem((sampleData?.setNumber ?? 0).toString())),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem((sampleData?.iCnt ?? 0).toString())),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem((sampleData?.sdCnt ?? 0).toString())),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(
            numberSeriousDefects,
            (index) => Container(
                margin: EdgeInsets.symmetric(vertical: 5),
                child: defaultTextItem((sampleData?.sdCnt ?? 0).toString())))),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem((sampleData?.vsdCnt ?? 0).toString())),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem((sampleData?.dCnt ?? 0).toString())),
      MMergedRows(List.generate(
          numberSeriousDefects, (index) => circularDefectItem("1"))),
    ];
  }

  // Done
  List<BaseMRow> _getTotalQualityDefectsRow() {
    return [
      MRow(defaultTextItem("Quality Defects")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("${controller.totalQualityInjury}")),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem("${controller.totalQualityDamage}")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$totalQualitySeriousDamage";
          }
          return Container(
              margin: EdgeInsets.symmetric(vertical: 5), child: Text(value));
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("${controller.totalQualityVerySeriousDamage}")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("${controller.totalQualityDecay}")),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalQualityDefectsPercentRow() {
    int percentDecay = (totalQualityDecay / totalSamples * 100).ceil();
    int percentVSDamage =
        (totalQualityVerySeriousDamage / totalSamples * 100).ceil();
    int percentSDamage =
        (totalQualitySeriousDamage / totalSamples * 100).ceil();
    int percentDamage = (totalQualityDamage / totalSamples * 100).ceil();
    int percentInjury = (totalQualityInjury / totalSamples * 100).ceil();
    return [
      MRow(defaultTextItem("Quality Defects %")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("$percentInjury%")),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem("$percentDamage%")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$percentSDamage%";
          }
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              value,
              style: TextStyle(
                color: (controller.seriousDamageQualitySpec != null &&
                        percentSDamage >
                            (controller.seriousDamageQualitySpec ?? 0.0))
                    ? Colors.red
                    : Colors.white,
              ),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(Text(
          "$percentVSDamage%",
          style: TextStyle(
            color: (controller.verySeriousDamageQualitySpec != null &&
                    percentVSDamage >
                        (controller.verySeriousDamageQualitySpec ?? 0.0))
                ? Colors.red
                : Colors.white,
          ),
        )),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem(
          "$percentDecay%",
          color: (controller.decayQualitySpec != null &&
                  percentDecay > (controller.decayQualitySpec ?? 0.0))
              ? Colors.red
              : null,
        )),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalConditionDefectsRow() {
    return [
      MRow(defaultTextItem("Condition Defects")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("${controller.totalConditionInjury}")),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem("${controller.totalConditionDamage}")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            int a = controller.totalConditionSeriousDamage;
            value = "$a";
          }
          return Container(
              margin: EdgeInsets.symmetric(vertical: 5), child: Text(value));
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("${controller.totalConditionVerySeriousDamage}")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("${controller.totalConditionDecay}")),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalConditionDefectsPercentRow() {
    int percentCDecay = (totalConditionDecay / totalSamples * 100).ceil();
    int percentCVSDamage =
        (totalConditionVerySeriousDamage / totalSamples * 100).ceil();
    int percentSCDamage =
        (totalConditionSeriousDamage / totalSamples * 100).ceil();
    int percentCDamage = (totalConditionDamage / totalSamples * 100).ceil();
    int percentCInjury = (totalConditionInjury / totalSamples * 100).ceil();

    return [
      MRow(defaultTextItem("Condition Defects %")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem(
          "$percentCInjury%",
          color: (controller.injuryConditionSpec != null &&
                  percentCInjury > (controller.injuryConditionSpec ?? 0.0))
              ? Colors.red
              : null,
        )),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem(
          "$percentCDamage%",
          color: (controller.damageConditionSpec != null &&
                  percentCDamage > (controller.damageConditionSpec ?? 0.0))
              ? Colors.red
              : null,
        )),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$percentSCDamage%";
          }
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              value,
              style: TextStyle(
                color: (controller.seriousDamageConditionSpec != null &&
                        percentSCDamage >
                            (controller.seriousDamageConditionSpec ?? 0.0))
                    ? Colors.red
                    : Colors.white,
              ),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(Text(
          "$percentCVSDamage%",
          style: TextStyle(
            color: (controller.verySeriousDamageConditionSpec != null &&
                    percentCVSDamage >
                        (controller.verySeriousDamageConditionSpec ?? 0.0))
                ? Colors.red
                : Colors.white,
          ),
        )),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem(
          "$percentCDecay%",
          color: (controller.decayConditionSpec != null &&
                  percentCDecay > (controller.decayConditionSpec ?? 0.0))
              ? Colors.red
              : null,
        )),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalSeverityByDefectTypeRow() {
    return [
      MRow(defaultTextItem("Total Severity")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("${controller.totalInjury}%")),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem("${controller.totalDamage}%")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "0";
          int percent = 0;
          if (!controller.seriousDefectList.isEmpty) {
            int? sdcount = controller
                .seriousDefectCountMap[controller.seriousDefectList[index]];
            if (sdcount != null) {
              percent = (sdcount / totalSamples * 100).ceil();
              value = percent.toString();
            }
          }
          return Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                "$value%",
                style: TextStyle(
                  color: (controller.seriousDamageSpec != null &&
                          percent > (controller.seriousDamageSpec ?? 0.0))
                      ? Colors.red
                      : Colors.white,
                ),
              ));
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("${controller.totalVerySeriousDamage}%")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("${controller.totalDecay}%")),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalSeverityByDefectPercentRow() {
    int totalDecay = (controller.totalDecay / totalSamples * 100).ceil();
    int totalDamage = (controller.totalDamage / totalSamples * 100).ceil();
    int totalInjury = (controller.totalInjury / totalSamples * 100).ceil();
    int totalVerySeriousDamage =
        (controller.totalVerySeriousDamage / totalSamples * 100).ceil();
    return [
      MRow(defaultTextItem("Total Severity %")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem(
          "$totalInjury%",
          color: (controller.injurySpec != null &&
                  totalInjury > (controller.injurySpec ?? 0.0))
              ? Colors.red
              : null,
        )),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem(
          "$totalDamage%",
          color: (controller.damageSpec != null &&
                  totalDamage > (controller.damageSpec ?? 0.0))
              ? Colors.red
              : null,
        )),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "0";
          int percent = 0;
          if (!controller.seriousDefectList.isEmpty) {
            int? sdcount = controller
                .seriousDefectCountMap[controller.seriousDefectList[index]];
            if (sdcount != null) {
              percent = (sdcount / totalSamples * 100).ceil();
              value = percent.toString();
            }
          }
          return Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: Text(
                "$value%",
                style: TextStyle(
                  color: (controller.seriousDamageSpec != null &&
                          percent > (controller.seriousDamageSpec ?? 0.0))
                      ? Colors.red
                      : Colors.white,
                ),
              ));
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem(
          "$totalVerySeriousDamage%",
          color: controller.verySeriousDamageSpec != null &&
                  totalVerySeriousDamage >
                      (controller.verySeriousDamageSpec ?? 0.0)
              ? Colors.red
              : null,
        )),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("$totalDecay%",
            color: (controller.decaySpec != null &&
                    totalDecay > (controller.decaySpec ?? 0.0))
                ? Colors.red
                : null)),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getPercentByDefectTypeRow() {
    int totalDecay = (controller.totalDecay / totalSamples * 100).ceil();
    int totalVerySeriousDamage =
        (controller.totalSeriousDamage / totalSamples * 100).ceil();
    int totalInjury = (controller.totalInjury / totalSamples * 100).ceil();
    int totalDamage = (controller.totalDamage / totalSamples * 100).ceil();

    return [
      MRow(defaultTextItem("Total %")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("$totalInjury%",
            color: (controller.injurySpec != null &&
                    totalInjury > (controller.injurySpec ?? 0.0))
                ? Colors.red
                : null)),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem(
          "$totalDamage%",
          color: (controller.damageSpec != null &&
                  totalDamage > (controller.damageSpec ?? 0.0))
              ? Colors.red
              : null,
        )),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          int percent =
              (controller.totalSeriousDamage / totalSamples * 100).ceil();
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(
              "$percent%",
              style: TextStyle(
                  color: (controller.seriousDamageSpec != null &&
                          percent > (controller.seriousDamageSpec ?? 0.0))
                      ? Colors.red
                      : null),
            ),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(
          Text("$totalVerySeriousDamage%",
              style: TextStyle(
                color: (controller.verySeriousDamageSpec != null &&
                        totalVerySeriousDamage >
                            (controller.verySeriousDamageSpec ?? 0.0))
                    ? Colors.red
                    : null,
              )),
        ),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("$totalDecay%",
            color: (controller.decaySpec != null &&
                    totalDecay > (controller.decaySpec ?? 0.0))
                ? Colors.red
                : null)),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalSizeDefectsRow() {
    return [
      MRow(defaultTextItem("Size Defects")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("$totalSizeInjury")),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem("$totalSizeDamage")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$totalSizeSeriousDamage";
          }
          return Container(
              margin: EdgeInsets.symmetric(vertical: 5), child: Text(value));
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("$totalSizeVerySeriousDamage")),
      if (controller.hasSeverityDecay) MRow(defaultTextItem("$totalSizeDecay")),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalSizeDefectsPercentRow() {
    int percentSizeDecay = (totalSizeDecay / totalSamples * 100).ceil();
    int percentSizeVSDamage =
        (totalSizeVerySeriousDamage / totalSamples * 100).ceil();
    int percentSizeDamage = (totalSizeDamage / totalSamples * 100).ceil();
    int percentSizeInjury = (totalSizeInjury / totalSamples * 100).ceil();
    return [
      MRow(defaultTextItem("Size Defects %")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("$percentSizeInjury%")),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem("$percentSizeDamage%")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            int percentSCDamage =
                (totalSizeSeriousDamage / totalSamples * 100).ceil();
            value = "$percentSCDamage%";
          }
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(value),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(Text("$percentSizeVSDamage%")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("$percentSizeDecay%")),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalColorDefectsRow() {
    return [
      MRow(defaultTextItem("Color Defects")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("$totalColorInjury")),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem("$totalColorDamage")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            value = "$totalColorSeriousDamage";
          }
          return Container(
              margin: EdgeInsets.symmetric(vertical: 5), child: Text(value));
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(defaultTextItem("$totalColorVerySeriousDamage")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("$totalColorDecay")),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
  }

  // Done
  List<BaseMRow> _getTotalColorDefectsPercentRow() {
    double percentColorDecay = (totalColorDecay / totalSamples * 100);
    double percentColorVSDamage =
        (totalColorVerySeriousDamage / totalSamples * 100);
    int percentColorDamage = (totalColorDamage / totalSamples * 100).ceil();
    int percentColorInjury = (totalColorInjury / totalSamples * 100).ceil();
    return [
      MRow(defaultTextItem("Color Defects %")),
      if (controller.hasSeverityInjury)
        MRow(defaultTextItem("$percentColorInjury%")),
      if (controller.hasSeverityDamage)
        MRow(defaultTextItem("$percentColorDamage%")),
      if (controller.hasSeveritySeriousDamage)
        MMergedRows(List.generate(numberSeriousDefects, (index) {
          String value = "";
          if (index == 0) {
            int percentSColorDamage =
                (totalColorSeriousDamage / totalSamples * 100).ceil();
            "$percentSColorDamage%";
          }
          return Container(
            margin: EdgeInsets.symmetric(vertical: 5),
            child: Text(value),
          );
        })),
      if (controller.hasSeverityVerySeriousDamage)
        MRow(Text("${percentColorVSDamage.ceil()}%")),
      if (controller.hasSeverityDecay)
        MRow(defaultTextItem("${percentColorDecay.ceil()}%")),
      VerticalMergedRow(rowSpan: 5, child: Container())
    ];
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

/// Defects Cloud AI

/*class DefectsTable extends StatelessWidget {
  final int numberSamples;
  final List<Severity> severityList;
  final int numberSeriousDefects;
  final Map<String, List<InspectionDefect>> defectDataMap;
  final Map<int, SampleData> sampleDataMap;
  final List<int> sampleDataMapIndexList;
  final List<String> seriousDefectList;
  final DefectsScreenController controller;

  const DefectsTable({
    super.key,
    required this.numberSamples,
    required this.severityList,
    required this.numberSeriousDefects,
    required this.defectDataMap,
    required this.sampleDataMap,
    required this.sampleDataMapIndexList,
    required this.seriousDefectList,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    bool hasSeverityInjury = controller.hasSeverityInjury;
    bool hasSeverityDamage = controller.hasSeverityDamage;
    bool hasSeveritySeriousDamage = controller.hasSeveritySeriousDamage;
    bool hasSeverityVerySeriousDamage = controller.hasSeverityVerySeriousDamage;
    bool hasSeverityDecay = controller.hasSeverityDecay;

    int totalQualityInjury = controller.totalQualityInjury;
    int totalQualityDamage = controller.totalQualityDamage;
    int totalQualitySeriousDamage = controller.totalQualitySeriousDamage;
    int totalQualityVerySeriousDamage =
        controller.totalQualityVerySeriousDamage;
    int totalQualityDecay = controller.totalQualityDecay;

    int totalConditionInjury = controller.totalConditionInjury;
    int totalConditionDamage = controller.totalConditionDamage;
    int totalConditionSeriousDamage = controller.totalConditionSeriousDamage;
    int totalConditionVerySeriousDamage =
        controller.totalConditionVerySeriousDamage;
    int totalConditionDecay = controller.totalConditionDecay;

    int totalSizeInjury = controller.totalSizeInjury;
    int totalSizeDamage = controller.totalSizeDamage;
    int totalSizeSeriousDamage = controller.totalSizeSeriousDamage;
    int totalSizeVerySeriousDamage = controller.totalSizeVerySeriousDamage;
    int totalSizeDecay = controller.totalSizeDecay;

    int totalColorInjury = controller.totalColorInjury;
    int totalColorDamage = controller.totalColorDamage;
    int totalColorSeriousDamage = controller.totalColorSeriousDamage;
    int totalColorVerySeriousDamage = controller.totalColorVerySeriousDamage;
    int totalColorDecay = controller.totalColorDecay;

    int totalInjury = controller.totalInjury;
    int totalDamage = controller.totalDamage;
    int totalSeriousDamage = controller.totalSeriousDamage;
    int totalVerySeriousDamage = controller.totalVerySeriousDamage;
    int totalDecay = controller.totalDecay;

    int totalSamples = controller.totalSamples;

    controller.populateSeverityList();
    // Calculate the totals and update the flags based on the severity list
    for (Severity severity in severityList) {
      if (severity.name == 'Injury' || severity.name == 'Lesión') {
        hasSeverityInjury = true;
      } else if (severity.name == 'Damage' || severity.name == 'Daño') {
        hasSeverityDamage = true;
      } else if (severity.name == 'Serious Damage' ||
          severity.name == 'Daño Serio') {
        hasSeveritySeriousDamage = true;
      } else if (severity.name == 'Very Serious Damage' ||
          severity.name == 'Daño Muy Serio') {
        hasSeverityVerySeriousDamage = true;
      } else if (severity.name == 'Decay' || severity.name == 'Pudrición') {
        hasSeverityDecay = true;
      }
    }

    // Build the table
    Table table = Table(
      border: TableBorder.all(),
      defaultColumnWidth: IntrinsicColumnWidth(),
      children: [
        // Type row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Type'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Defects'),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Defects'),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Defects'),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Defects'),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Defects'),
                ),
              ),
          ],
        ),
        // Severity row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Severity'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Icon(Icons.error, color: Colors.red),
                ),
              ),
          ],
        ),
        // Sample rows
        for (var i = 0; i < numberSamples; i++)
          TableRow(
            children: [
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      sampleDataMap[sampleDataMapIndexList.elementAtOrNull(i)]
                              ?.name ??
                          ''),
                ),
              ),
              if (controller.hasSeverityInjury)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text((sampleDataMap[
                                    sampleDataMapIndexList.elementAtOrNull(i)]
                                ?.iCnt ??
                            '')
                        .toString()),
                  ),
                ),
              if (controller.hasSeverityDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text((sampleDataMap[
                                    sampleDataMapIndexList.elementAtOrNull(i)]
                                ?.dCnt ??
                            '')
                        .toString()),
                  ),
                ),
              for (var j = 0; j < numberSeriousDefects; j++)
                if (controller.hasSeveritySeriousDamage)
                  TableCell(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text((sampleDataMap[
                                      sampleDataMapIndexList.elementAtOrNull(i)]
                                  ?.sdCnt ??
                              '')
                          .toString()),
                    ),
                  ),
              if (controller.hasSeverityVerySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text((sampleDataMap[
                                    sampleDataMapIndexList.elementAtOrNull(i)]
                                ?.vsdCnt ??
                            '')
                        .toString()),
                  ),
                ),
              if (controller.hasSeverityDecay)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text((sampleDataMap[
                                    sampleDataMapIndexList.elementAtOrNull(i)]
                                ?.dCnt ??
                            '')
                        .toString()),
                  ),
                ),
            ],
          ),
        // Total Quality Defects row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Quality Defects'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalQualityInjury.toString()),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalQualityDamage.toString()),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(totalQualitySeriousDamage.toString()),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalQualityVerySeriousDamage.toString()),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalQualityDecay.toString()),
                ),
              ),
          ],
        ),
        // Total Quality Defects % row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Quality Defects %'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalQualityInjury, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalQualityDamage, totalSamples)),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(getTotalQualityInjury(
                        totalQualitySeriousDamage, totalSamples)),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(
                      totalQualityVerySeriousDamage, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalQualityDecay, totalSamples)),
                ),
              ),
          ],
        ),
        // Total Condition Defects row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Condition Defects'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalConditionInjury.toString()),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalConditionDamage.toString()),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(totalConditionSeriousDamage.toString()),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalConditionVerySeriousDamage.toString()),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalConditionDecay.toString()),
                ),
              ),
          ],
        ),
        // Total Condition Defects % row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Condition Defects %'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(
                      totalConditionInjury, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(
                      totalConditionDamage, totalSamples)),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(getTotalQualityInjury(
                        totalConditionSeriousDamage, totalSamples)),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(
                      totalConditionVerySeriousDamage, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalConditionDecay, totalSamples)),
                ),
              ),
          ],
        ),
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Severity by Defect Type'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalInjury.toString()),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalDamage.toString()),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child:
                        Text(seriousDefectList.elementAtOrNull(i).toString()),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalVerySeriousDamage.toString()),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalDecay.toString()),
                ),
              ),
          ],
        ),
// Total Severity by Defect Type % row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Severity by Defect Type %'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(totalInjury, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(totalDamage, totalSamples)),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(getSeriousDefectList(i, totalSamples)),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(
                      totalVerySeriousDamage, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(totalDecay, totalSamples)),
                ),
              ),
          ],
        ),
// % by Severity Level row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('% by Severity Level'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(totalInjury, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(totalDamage, totalSamples)),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(getTotalQualityInjury(
                        totalSeriousDamage, totalSamples)),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(
                      totalVerySeriousDamage, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(totalDecay, totalSamples)),
                ),
              ),
          ],
        ),
// Total Size Defects row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Size Defects'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalSizeInjury.toString()),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalSizeDamage.toString()),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(totalSizeSeriousDamage.toString()),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalSizeVerySeriousDamage.toString()),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalSizeDecay.toString()),
                ),
              ),
          ],
        ),
// Total Size Defects % row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Size Defects %'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalSizeInjury, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalSizeDamage, totalSamples)),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(getTotalQualityInjury(
                        totalSizeSeriousDamage, totalSamples)),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(
                      totalSizeVerySeriousDamage, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child:
                      Text(getTotalQualityInjury(totalSizeDecay, totalSamples)),
                ),
              ),
          ],
        ),
// Total Color Defects row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Color Defects'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalColorInjury.toString()),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalColorDamage.toString()),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(totalColorSeriousDamage.toString()),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalColorVerySeriousDamage.toString()),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(totalColorDecay.toString()),
                ),
              ),
          ],
        ),
// Total Color Defects % row
        TableRow(
          children: [
            TableCell(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Total Color Defects %'),
              ),
            ),
            if (controller.hasSeverityInjury)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalColorInjury, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalColorDamage, totalSamples)),
                ),
              ),
            for (var i = 0; i < numberSeriousDefects; i++)
              if (controller.hasSeveritySeriousDamage)
                TableCell(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(getTotalQualityInjury(
                        totalColorSeriousDamage, totalSamples)),
                  ),
                ),
            if (controller.hasSeverityVerySeriousDamage)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(getTotalQualityInjury(
                      totalColorVerySeriousDamage, totalSamples)),
                ),
              ),
            if (controller.hasSeverityDecay)
              TableCell(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                      getTotalQualityInjury(totalColorDecay, totalSamples)),
                ),
              ),
          ],
        ),
      ],
    );
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final double newKeyboardHeight = bottomInset > 0 ? bottomInset : 0;

    return Container(
        padding: EdgeInsets.only(bottom: newKeyboardHeight), child: table);
  }

  String getSeriousDefectList(int i, int totalSamples) {
    int getSeriousDefect =
        int.tryParse(seriousDefectList.elementAtOrNull(i).toString()) ?? 0;
    if (getSeriousDefect == 0 || totalSamples == 0) {
      return '0%';
    }
    return '${((int.parse(seriousDefectList.elementAtOrNull(i) ?? 0.toString()) / totalSamples) * 100).round()}%';
  }

  String getTotalQualityInjury(int totalQualityInjury, int totalSamples) {
    if (totalSamples == 0 || totalQualityInjury == 0) {
      return '0%';
    }
    return '${((totalQualityInjury / totalSamples) * 100).round()}%';
  }
}*/

/// DefectsTable UI
/*class DefectsTable1 extends StatelessWidget {
  final WorksheetDataTable worksheetDataTable;

  const DefectsTable1({
    super.key,
    required this.worksheetDataTable,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[300],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildTableHeader(),
            _buildSeverityRow(),
            _buildTableRow(
              title: 'Total Quality Defects',
              data: worksheetDataTable.qualityDefects,
            ),
            _buildTableRow(
              title: 'Total Quality Defects %',
              data: worksheetDataTable.qualityDefectsPercentage,
              isPercentage: true,
            ),
            _buildTableRow(
              title: 'Total Condition Defects',
              data: worksheetDataTable.conditionDefects,
            ),
            _buildTableRow(
              title: 'Total Condition Defects %',
              data: worksheetDataTable.conditionDefectsPercentage,
              isPercentage: true,
            ),
            _buildTotalSeverityRow(
              title: 'Total Severity by Defect Type',
              data: worksheetDataTable.totalSeverity,
            ),
            _buildTotalSeverityRow(
              title: '% by Defect Type',
              data: worksheetDataTable.totalSeverityPercentage,
              isPercentage: true,
            ),
            _buildTableRow(
              title: 'Total Size Defects',
              data: worksheetDataTable.sizeDefects,
            ),
            _buildTableRow(
              title: 'Total Size Defects %',
              data: worksheetDataTable.sizeDefectsPercentage,
              isPercentage: true,
            ),
            _buildTableRow(
              title: 'Total Color Defects',
              data: worksheetDataTable.colorDefects,
            ),
            _buildTableRow(
              title: 'Total Color Defects %',
              data: worksheetDataTable.colorDefectsPercentage,
              isPercentage: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeaderCell('Type'),
        ...worksheetDataTable.severity.map(
          (severityList) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: severityList
                .map(
                  (severity) => _buildHeaderCell(severity),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSeverityRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeaderCell('Severity'),
        ...worksheetDataTable.severity.map(
          (severityList) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: severityList
                .map(
                  (severity) => _buildSeverityCell(severity),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildTableRow({
    required String title,
    required List<num> data,
    bool isPercentage = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeaderCell(title),
        ...data.map(
          (value) => _buildDataCell(
            '$value${isPercentage ? '%' : ''}',
          ),
        ),
      ],
    );
  }

  Widget _buildTotalSeverityRow({
    required String title,
    required List<List<num>> data,
    bool isPercentage = false,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeaderCell(title),
        ...data.map(
          (severityList) => Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: severityList
                .map(
                  (value) => _buildDataCell(
                    '$value${isPercentage ? '%' : ''}',
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.grey[300],
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red,
        ),
      ),
    );
  }

  Widget _buildSeverityCell(String severity) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: getDataColumnColor(severity),
      ),
      child: Center(
        child: Text(
          getDefectTypeIcon(severity),
          style: const TextStyle(
            fontSize: 24,
            color: Colors.red,
          ),
        ),
      ),
    );
  }

  Widget _buildDataCell(String text) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        color: Colors.white,
      ),
      child: Text(text,
          style: const TextStyle(
            color: Colors.red,
          )),
    );
  }

  Color getDataColumnColor(String defectType) {
    switch (defectType) {
      case 'Injury':
        return Colors.greenAccent;
      case 'Damage':
        return Colors.orange;
      case 'Serious Damage':
        return Colors.cyanAccent;
      case 'Very Serious Damage':
        return Colors.redAccent;
      case 'Decay':
        return Colors.purpleAccent;
      default:
        return Colors.white;
    }
  }

  String getDefectTypeIcon(String defectType) {
    switch (defectType) {
      case 'Injury':
        return 'I';
      case 'Damage':
        return 'D';
      case 'Serious Damage':
        return 'SD';
      case 'Very Serious Damage':
        return 'VSD';
      case 'Decay':
        return 'DC';
      default:
        return '';
    }
  }
}*/
