import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/defects_screen_controller.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/models/worksheet_data_table.dart';
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

  /*Widget infoPopup(BuildContext context) {
    return Obx(() => controller.isVisibleInfoPopup.value
        ? Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width,
                decoration: BoxDecoration(
                    color: AppColors.black,
                    borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.all(20),
                child: Padding(
                  padding: const EdgeInsets.all(16),
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
                          color: AppColors.white,
                          height: 1.8,
                        ),
                      ),
                      SizedBox(height: 30.h),
                      Container(
                        height: 0.5,
                        color: AppColors.background,
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
                              color: AppColors.textFieldText_Color),
                          onClickAction: () async {
                            controller.hidePopup();
                          }),
                    ],
                  ),
                ),
              ),
            ),
          )
        : const SizedBox());
  }*/

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
                          controller.activeTabIndex.value = 0;
                          controller.update();
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
              child: //controller.drawDefectsTable()
                  SingleChildScrollView(
                child: DefectsTable(
                  worksheetDataTable: WorksheetDataTable(
                    defectType: AppStrings.types,
                    severity: [
                      [AppStrings.injury],
                      [AppStrings.damage, AppStrings.damage, AppStrings.damage],
                      [AppStrings.verySeriousDamage],
                      [AppStrings.decay],
                      [AppStrings.injury],
                    ],
                    qualityDefects: [2, 5, 15, 20, 25],
                    qualityDefectsPercentage: [10, 15, 4, 7, 17],
                    conditionDefects: [0, 0, 1, 23, 26],
                    conditionDefectsPercentage: [0, 0, 4, 8, 25],
                    totalSeverity: getTotalSeverity(controller),
                    totalSeverityPercentage: [],
                    // TODO:
                    // totalSeverityPercentage:
                    //     getTotalSeverityPercentage(controller),
                    sizeDefects: [
                      controller.totalSizeInjury,
                      controller.totalSizeDamage,
                      controller.totalSizeSeriousDamage,
                      controller.totalSizeVerySeriousDamage,
                      controller.totalSizeDecay
                    ],
                    // TODO:
                    sizeDefectsPercentage: [],
                    // sizeDefectsPercentage: getSizeDefectsPercentage(controller),
                    colorDefects: [
                      controller.totalColorInjury,
                      controller.totalColorDamage,
                      controller.totalColorSeriousDamage,
                      controller.totalColorVerySeriousDamage,
                      controller.totalColorDecay
                    ],
                    colorDefectsPercentage: [],
                    // colorDefectsPercentage: getColorDefectsPercentage(controller),
                  ),
                ),
              ),
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
                    await controller.saveDefectEntriesAndContinue();
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

class DefectsTable extends StatelessWidget {
  final WorksheetDataTable worksheetDataTable;

  const DefectsTable({
    super.key,
    required this.worksheetDataTable,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
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
            '${value}${isPercentage ? '%' : ''}',
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
                    '${value}${isPercentage ? '%' : ''}',
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
}
