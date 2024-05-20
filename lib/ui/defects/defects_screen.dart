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
import 'package:pverify/utils/dialogs/app_alerts.dart';
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
              child: controller.drawDefectsTable(),
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
                            // sampleValue: controller
                            //     .sampleList[sampleIndex].sampleNameUser,
                            controller: controller,
                          );
                        }),
                  )
                ],
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
                      color: AppColors.textFieldText_Color),
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
                      color: AppColors.textFieldText_Color),
                  onClickAction: () async {
                    if (controller.validateDefects()) {
                      if (controller.validateSameDefects()) {
                        // TODO: Save the defects
                        await controller.saveSamplesToDB();
                        controller.getToQCDetailShortForm();
                      } else {
                        AppAlertDialog.validateAlerts(context, AppStrings.error,
                            AppStrings.sameDefectEntryAlert);
                      }
                    } else {
                      AppAlertDialog.validateAlerts(context, AppStrings.error,
                          AppStrings.defectEntryAlert);
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
                    color: AppColors.textFieldText_Color),
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
                  controller.onSpecificationTap();
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

// SAMPLE SET'S LIST UI

/*Widget defectRow({
  required BuildContext context,
  required DefectsScreenController controller,
  required SampleData? sampleData,
  required int defectItemIndex,
  required int position,
}) {
  return Padding(
    padding: EdgeInsets.symmetric(horizontal: 50.w),
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 10.h),
      child: Row(
        children: [
          InkWell(
            onTap: () {
              AppAlertDialog.confirmationAlert(
                  context, AppStrings.alert, AppStrings.removeDefect,
                  onYesTap: () {
                */ /*controller.removeDefectRow(
                  setIndex: position,
                  rowIndex: defectItemIndex,
                );*/ /*
              });
            },
            child: Image.asset(
              AppImages.ic_minus,
              width: 50.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            flex: 6,
            child: Container(
              width: 120,
              padding: const EdgeInsets.only(top: 5),
              child: Obx(
                () => DropdownButton<String>(
                  isExpanded: true,
                  dropdownColor: Theme.of(context).colorScheme.background,
                  iconEnabledColor: AppColors.hintColor,
                  value: controller.sampleList[position].name,
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                  items: controller.defectSpinnerNames.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Container(
                        width: double.infinity,
                        child: Text(
                          value,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    // TODO: Save the defect type
                    */ /*controller.onDropDownChange(
                      id: controller.defectSpinnerIds[controller
                          .defectSpinnerNames
                          .indexWhere((obj) => obj == value)],
                      value: value ?? "",
                      setIndex: position,
                      rowIndex: defectItemIndex,
                    );
                    controller.defectsSelect_Action(defectItem);*/ /*
                  },
                ),
              ),
            ),
          ),
          SizedBox(width: 20.w),
          controller.hasSeverityInjury
              ? Expanded(
                  flex: 1,
                  child: BoxTextField1(
                    textalign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: sampleData?.injuryTextEditingController,
                    onTap: () {
                      sampleData?.injuryTextEditingController?.text = '';
                    },
                    errorText: '',
                    onEditingCompleted: () {
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (v) {
                      // TODO: Save the injury value
                      */ /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.injury,
                        context: context,
                      );*/ /*
                    },
                  ),
                )
              : const SizedBox(),
          SizedBox(width: 20.w),
          controller.hasSeverityDamage
              ? Expanded(
                  flex: 1,
                  child: BoxTextField1(
                    textalign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: sampleData?.damageTextEditingController,
                    onTap: () {
                      sampleData?.damageTextEditingController?.text = '';
                    },
                    errorText: '',
                    onEditingCompleted: () {
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (v) {
                      // TODO: Save the damage value
                      */ /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.damage,
                        context: context,
                      );*/ /*
                    },
                  ),
                )
              : const SizedBox(),
          SizedBox(width: 20.w),
          controller.hasSeveritySeriousDamage
              ? Expanded(
                  flex: 1,
                  child: BoxTextField1(
                    textalign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    controller: sampleData?.sDamageTextEditingController,
                    onTap: () {
                      sampleData?.sDamageTextEditingController?.text = '';
                    },
                    errorText: '',
                    onEditingCompleted: () {
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (v) {
                      // TODO: Save the serious damage value
                      */ /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.seriousDamage,
                        context: context,
                      );*/ /*
                    },
                  ),
                )
              : const SizedBox(),
          SizedBox(width: 20.w),
          controller.hasSeverityVerySeriousDamage
              ? Expanded(
                  flex: 1,
                  child: BoxTextField1(
                    textalign: TextAlign.center,
                    controller: sampleData?.vsDamageTextEditingController,
                    keyboardType: TextInputType.number,
                    onTap: () {
                      sampleData?.vsDamageTextEditingController?.text = '';
                    },
                    errorText: '',
                    onEditingCompleted: () {
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (v) {
                      */ /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.verySeriousDamage,
                        context: context,
                      );*/ /*
                    },
                  ),
                )
              : const SizedBox(),
          SizedBox(width: controller.hasSeveritySeriousDamage ? 0 : 20.w),
          controller.hasSeverityDecay
              ? Expanded(
                  flex: 1,
                  child: BoxTextField1(
                    textalign: TextAlign.center,
                    controller: sampleData?.decayTextEditingController,
                    keyboardType: TextInputType.number,
                    onTap: () {
                      sampleData?.decayTextEditingController?.text = '';
                    },
                    errorText: '',
                    onEditingCompleted: () {
                      FocusScope.of(context).unfocus();
                    },
                    onChanged: (v) {
                      // TODO: Save the decay value
                      */ /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.decay,
                        context: context,
                      );*/ /*
                    },
                  ),
                )
              : const SizedBox(),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {
              controller.navigateToCameraScreen(
                position: position,
                rowIndex: defectItemIndex,
                dataName: sampleData?.name ?? '',
              );
            },
            child: Icon(
              Icons.photo_camera,
              color: AppColors.iconBlue,
              size: 90.w,
            ),
          ),
          SizedBox(width: 10.w),
          GestureDetector(
            onTap: () {
              AppAlertDialog.textfiAlert(
                context,
                AppStrings.enterComment,
                '',
                onYesTap: (value) {
                  // TODO: Save the comment
                  // sampleData?.inspectionInstruction = value;
                  */ /*controller.onCommentAdd(
                    value: value ?? "",
                    setIndex: position,
                    rowIndex: defectItemIndex,
                  );*/ /*
                },
                windowWidth: MediaQuery.of(context).size.width * 0.9,
                isMultiLine: true,
                // TODO: Set the initial value
                // value: sampleData?.inspectionInstruction,
              );
            },
            child: Image.asset(
              (sampleData?.inspectionInstruction?.isNotEmpty ?? false)
                  ? AppImages.ic_specCommentsAdded
                  : AppImages.ic_specComments,
              width: 80.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(width: 10.h),
          Obx(
            () => InkWell(
              onTap: () {
                // controller.visisblePopupIndex.value = setIndex;
                // controller.isVisibleInfoPopup.value = true;

                DefectsInfoDialog defectsInfoDialog = DefectsInfoDialog(
                  position: position,
                  commodityID: controller.commodityID!,
                  commodityList: controller.appStorage.commodityList!,
                );

                defectsInfoDialog.showDefectDialog(Get.context!);
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
        ],
      ),
    ),
  );
}*/

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
