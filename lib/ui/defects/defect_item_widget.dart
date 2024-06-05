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
    // String? comment = controller.getComment(sampleIndex);
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
                  String dataName =
                      controller.sampleList.elementAt(sampleIndex).name;
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
                        selected: value ?? "",
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
                      // intialValue: (inspectionDefect.injuryCnt ?? 0).toString(),
                      controller: inspectionDefect.injuryTextEditingController,
                      onTap: () {
                        inspectionDefect.injuryTextEditingController.clear();
                      },
                      errorText: '',
                      onFocusChange: (bool hasFocus) {
                        String text = inspectionDefect
                            .injuryTextEditingController.text
                            .trim();
                        if (hasFocus) {
                          if (text == "0") {
                            inspectionDefect.injuryTextEditingController.text =
                                '';
                          }
                        } else {
                          if (text.isEmpty) {
                            inspectionDefect.injuryTextEditingController.text =
                                '0';
                          }
                        }
                      },
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          textData: v,
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
                      // intialValue: (inspectionDefect.damageCnt ?? 0).toString(),
                      controller: inspectionDefect.damageTextEditingController,
                      onTap: () {
                        inspectionDefect.damageTextEditingController.clear();
                      },
                      onFocusChange: (bool hasFocus) {
                        String text = inspectionDefect
                            .damageTextEditingController.text
                            .trim();
                        if (hasFocus) {
                          if (text == "0") {
                            inspectionDefect.damageTextEditingController.text =
                                '';
                          }
                        } else {
                          if (text.isEmpty) {
                            inspectionDefect.damageTextEditingController.text =
                                '0';
                          }
                        }
                      },
                      errorText: '',
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          textData: v,
                          sampleIndex: sampleIndex,
                          defectIndex: defectItemIndex,
                          fieldName: AppStrings.damage,
                          context: context,
                        );
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
                      // intialValue:
                      //     (inspectionDefect.seriousDamageCnt ?? 0).toString(),
                      controller: inspectionDefect.sDamageTextEditingController,
                      onTap: () {
                        inspectionDefect.sDamageTextEditingController.clear();
                      },
                      errorText: '',
                      onFocusChange: (bool hasFocus) {
                        String text = inspectionDefect
                            .sDamageTextEditingController.text
                            .trim();
                        if (hasFocus) {
                          if (text == "0") {
                            inspectionDefect.sDamageTextEditingController.text =
                                '';
                          }
                        } else {
                          if (text.isEmpty) {
                            inspectionDefect.sDamageTextEditingController.text =
                                '0';
                          }
                        }
                      },
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          textData: v,
                          sampleIndex: sampleIndex,
                          defectIndex: defectItemIndex,
                          fieldName: AppStrings.seriousDamageStr,
                          context: context,
                        );
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
                      // intialValue: (inspectionDefect.verySeriousDamageCnt ?? 0)
                      //     .toString(),
                      controller:
                          inspectionDefect.vsDamageTextEditingController,
                      keyboardType: TextInputType.number,
                      onTap: () {
                        inspectionDefect.vsDamageTextEditingController.clear();
                      },
                      errorText: '',
                      onFocusChange: (bool hasFocus) {
                        String text = inspectionDefect
                            .vsDamageTextEditingController.text
                            .trim();
                        if (hasFocus) {
                          if (text == "0") {
                            inspectionDefect
                                .vsDamageTextEditingController.text = '';
                          }
                        } else {
                          if (text.isEmpty) {
                            inspectionDefect
                                .vsDamageTextEditingController.text = '0';
                          }
                        }
                      },
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          textData: v,
                          sampleIndex: sampleIndex,
                          defectIndex: defectItemIndex,
                          fieldName: AppStrings.verySeriousDamageStr,
                          context: context,
                        );
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
                      // intialValue: (inspectionDefect.decayCnt ?? 0).toString(),
                      controller: inspectionDefect.decayTextEditingController,
                      keyboardType: TextInputType.number,
                      onTap: () {
                        inspectionDefect.decayTextEditingController.clear();
                      },
                      errorText: '',
                      onFocusChange: (bool hasFocus) {
                        String text = inspectionDefect
                            .decayTextEditingController.text
                            .trim();
                        if (hasFocus) {
                          if (text == "0") {
                            inspectionDefect.decayTextEditingController.text =
                                '';
                          }
                        } else {
                          if (text.isEmpty) {
                            inspectionDefect.decayTextEditingController.text =
                                '0';
                          }
                        }
                      },
                      onEditingCompleted: () {
                        FocusScope.of(context).unfocus();
                      },
                      onChanged: (v) {
                        controller.onTextChange(
                          textData: v,
                          sampleIndex: sampleIndex,
                          defectIndex: defectItemIndex,
                          fieldName: AppStrings.decay,
                          context: context,
                        );
                      },
                    ),
                  )
                : const SizedBox(),
            SizedBox(width: 10.w),
            GestureDetector(
              onTap: () async {
                await controller.navigateToCameraScreen(
                  sampleIndex: sampleIndex,
                  defectItemIndex: defectItemIndex,
                  inspectionDefect: inspectionDefect,
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
            SizedBox(width: 10.w),
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
