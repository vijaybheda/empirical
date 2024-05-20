import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/defects_screen_controller.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/ui/defects/defects_info_dialog.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class DefectItemWidget extends StatefulWidget {
  final DefectsScreenController controller;
  final InspectionDefect inspectionDefect;
  final int defectItemIndex;
  final int sampleIndex;

  const DefectItemWidget({
    super.key,
    required this.controller,
    required this.inspectionDefect,
    required this.defectItemIndex,
    required this.sampleIndex,
  });

  @override
  State<DefectItemWidget> createState() => _DefectItemWidgetState();
}

class _DefectItemWidgetState extends State<DefectItemWidget> {
  DefectsScreenController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    String? comment =
        controller.sampleList[sampleIndex].defectItems[defectItemIndex].comment;
    bool hasComment = comment != null && comment.isNotEmpty;
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
                    onYesTap: () async {
                  String dataName = controller.sampleDataMap.values
                      .elementAt(sampleIndex)
                      .name;
                  await controller.removeDefectRow(
                    inspectionDefect: inspectionDefect,
                    dataName: dataName,
                    sampleIndex: sampleIndex,
                    defectIndex: defectItemIndex,
                  );
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
                    value: controller.sampleList[sampleIndex].defectItems
                            .elementAtOrNull(defectItemIndex)
                            ?.spinnerSelection ??
                        controller.defectSpinnerNames.first,
                    icon:
                        const Icon(Icons.arrow_drop_down, color: Colors.white),
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
                      controller.onDropDownChange(
                        id: controller.defectSpinnerIds[controller
                            .defectSpinnerNames
                            .indexWhere((obj) => obj == value)],
                        value: value ?? "",
                        sampleIndex: sampleIndex,
                        defectItemIndex: defectItemIndex,
                      );
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
                      intialValue: (inspectionDefect.injuryCnt ?? 0).toString(),
                      // TODO: Add controller
                      // controller: sampleData.injuryTextEditingController,
                      onTap: () {
                        // TODO: Add controller
                        // sampleData.injuryTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          value: v,
                          sampleIndex: sampleIndex,
                          defectIndex: defectItemIndex,
                          fieldName: AppStrings.injury,
                          context: context,
                        );
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
                      intialValue: (inspectionDefect.damageCnt ?? 0).toString(),
                      // TODO: Add controller
                      // controller: sampleData.damageTextEditingController,
                      onTap: () {
                        // TODO:
                        // sampleData.damageTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        // TODO: Save the damage value
                        /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.damage,
                        context: context,
                      );*/
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
                      intialValue:
                          (inspectionDefect.seriousDamageCnt ?? 0).toString(),
                      // TODO: Add controller
                      // controller: sampleData.sDamageTextEditingController,
                      onTap: () {
                        // sampleData.sDamageTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        // TODO: Save the serious damage value
                        /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.seriousDamage,
                        context: context,
                      );*/
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
                      intialValue: (inspectionDefect.verySeriousDamageCnt ?? 0)
                          .toString(),
                      // TODO: Add controller
                      // controller: sampleData.vsDamageTextEditingController,
                      keyboardType: TextInputType.number,
                      onTap: () {
                        // sampleData.vsDamageTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.verySeriousDamage,
                        context: context,
                      );*/
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
                      intialValue: (inspectionDefect.decayCnt ?? 0).toString(),
                      // TODO: Add controller
                      // controller: sampleData.decayTextEditingController,
                      keyboardType: TextInputType.number,
                      onTap: () {
                        // sampleData.decayTextEditingController?.text = '';
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        // TODO: Save the decay value
                        /*controller.onTextChange(
                        value: v,
                        setIndex: position,
                        rowIndex: defectItemIndex,
                        fieldName: AppStrings.decay,
                        context: context,
                      );*/
                      },
                    ),
                  )
                : const SizedBox(),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () {
                // TODO: Navigate to camera screen
                /*controller.navigateToCameraScreen(
                  position: position,
                  rowIndex: defectItemIndex,
                  dataName: inspectionDefect.id ?? '',
                );*/
              },
              child: Icon(
                Icons.photo_camera,
                color: AppColors.iconBlue,
                size: 90.w,
              ),
            ),
            SizedBox(width: 10.w),

            // TODO: implement
            GestureDetector(
              onTap: () {
                AppAlertDialog.textfiAlert(
                  context,
                  AppStrings.enterComment,
                  '',
                  value: hasComment ? comment : null,
                  onYesTap: (value) {
                    controller.onCommentAdd(
                      value: value ?? "",
                      sampleIndex: sampleIndex,
                      defectItemIndex: defectItemIndex,
                    );
                  },
                  windowWidth: MediaQuery.of(context).size.width * 0.9,
                  isMultiLine: true,
                );
              },
              child: Image.asset(
                hasComment
                    ? AppImages.ic_specCommentsAdded
                    : AppImages.ic_specComments,
                width: 80.w,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: 10.h),
            InkWell(
              onTap: () {
                DefectsInfoDialog defectsInfoDialog = DefectsInfoDialog(
                  position: sampleIndex,
                  commodityID: controller.commodityID!,
                  commodityList: controller.appStorage.commodityList ?? [],
                  defectList: controller.appStorage.defectsList ?? [],
                );

                defectsInfoDialog.showDefectDialog(Get.context!);
              },
              child: Image.asset(
                controller.isInformationIconEnabled(
                  sampleIndex: sampleIndex,
                  defectItemIndex: defectItemIndex,
                )
                    ? AppImages.ic_information
                    : AppImages.ic_informationDisabled,
                width: 80.w,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  int get defectItemIndex => widget.defectItemIndex;
  int get sampleIndex => widget.sampleIndex;
  InspectionDefect get inspectionDefect => widget.inspectionDefect;
}
