import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/defects_screen_controller.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/models/sample_data.dart';
import 'package:pverify/ui/defects/defect_item_widget.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class SampleSetWidget extends StatefulWidget {
  final int sampleIndex;
  final DefectsScreenController controller;
  final Function()? onRemoveAll;

  const SampleSetWidget({
    super.key,
    required this.sampleIndex,
    required this.controller,
    required this.onRemoveAll,
  });

  @override
  State<SampleSetWidget> createState() => _SampleSetWidgetState();
}

class _SampleSetWidgetState extends State<SampleSetWidget> {
  int get sampleIndex => widget.sampleIndex;

  DefectsScreenController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: 100.w, right: 100.w),
          height: 100.h,
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
                        controller.removeSampleSets(sampleIndex,
                            onRemoveAll: () {
                          if (widget.onRemoveAll != null) {
                            widget.onRemoveAll?.call();
                          }
                        });
                      },
                    );
                  },
                  child: Container(
                    color: AppColors.lightSky,
                    child: Image.asset(
                      AppImages.ic_minus,
                      width: 40.w,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  alignment: Alignment.center,
                  color: sampleIndex % 2 != 0
                      ? AppColors.orange
                      : AppColors.textFieldText_Color,
                  child: Text(
                    textAlign: TextAlign.center,
                    '${controller.sampleList[sampleIndex].sampleSize.toString()} samples Set #${controller.sampleList[sampleIndex].setNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w400,
                      textStyle: TextStyle(
                        color: sampleIndex % 2 != 0
                            ? AppColors.black
                            : AppColors.white,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        Obx(() => hasDefects()
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
            : const SizedBox()),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, defectIndex) {
            final InspectionDefect e =
                controller.sampleList[sampleIndex].defectItems[defectIndex];
            return DefectItemWidget(
              controller: controller,
              defectItemIndex: defectIndex,
              inspectionDefect: e,
              sampleIndex: sampleIndex,
            );
          },
          separatorBuilder: (context, index) => const Divider(),
          itemCount: controller.sampleList[sampleIndex].defectItems.length,
        ),
        SizedBox(height: 20.h),
        controller.sampleList.isNotEmpty &&
                controller.sampleList.length - 1 != sampleIndex
            ? Padding(
                padding: EdgeInsets.symmetric(horizontal: 50.w),
                child: const Divider(),
              )
            : const SizedBox(),
        SizedBox(height: 20.h),
        GestureDetector(
          onTap: () {
            controller.hideKeypad(context);
            SampleData sampleData = controller.sampleList[sampleIndex];
            controller.addDefectRow(context,
                sampleIndex: sampleIndex, sampleData: sampleData);
          },
          child: Text(
            AppStrings.addDefect,
            style: GoogleFonts.poppins(
                fontSize: 36.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.primary),
          ),
        ),
        SizedBox(height: 50.h),
      ],
    );
  }

  bool hasDefects() => (controller.defectDataMap[
              controller.sampleList.elementAt(sampleIndex).name] ??
          [])
      .isNotEmpty;

  Widget defectCategoryTagRow(DefectsScreenController defectsScreenController) {
    TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 32.sp,
    );
    return Row(
      children: [
        Flexible(flex: 6, child: Container()),
        Flexible(
            flex: defectsScreenController.hasSeverityInjury ? 1 : 0,
            child: Visibility(
              visible: defectsScreenController.hasSeverityInjury,
              child: defectCategoryTag(
                tag: AppStrings.injuryIcon,
                textStyle: textStyle,
              ),
            )),
        SizedBox(width: 10.w),
        Flexible(
            flex: defectsScreenController.hasSeverityDamage ? 1 : 0,
            child: Visibility(
              visible: defectsScreenController.hasSeverityDamage,
              child: defectCategoryTag(
                tag: AppStrings.damageIcon,
                textStyle: textStyle,
              ),
            )),
        SizedBox(width: 10.w),
        Flexible(
            flex: defectsScreenController.hasSeriousDamage ? 1 : 0,
            child: Visibility(
              visible: defectsScreenController.hasSeriousDamage,
              child: defectCategoryTag(
                tag: AppStrings.verySeriousDamageIcon,
                textStyle: textStyle,
              ),
            )),
        SizedBox(width: 10.w),
        Flexible(
            flex: defectsScreenController.hasSeveritySeriousDamage ? 1 : 0,
            child: Visibility(
              visible: defectsScreenController.hasSeveritySeriousDamage,
              child: defectCategoryTag(
                tag: AppStrings.seriousDamageIcon,
                textStyle: textStyle,
              ),
            )),
        SizedBox(width: 10.w),
        Flexible(
            flex: defectsScreenController.hasSeverityDecay ? 1 : 0,
            child: Visibility(
              visible: defectsScreenController.hasSeverityDecay,
              child: defectCategoryTag(
                tag: AppStrings.decayIcon,
                textStyle: textStyle,
              ),
            )),
        SizedBox(width: 10.w),
        Flexible(
            flex: defectsScreenController.hasSeverityVerySeriousDamage ? 1 : 0,
            child: Visibility(
              visible: defectsScreenController.hasSeverityVerySeriousDamage,
              child: defectCategoryTag(
                tag: AppStrings.defectVsd,
                textStyle: textStyle,
              ),
            )),
        Container(width: 280.w),
      ],
    );
  }

  Widget defectCategoryTag({required String tag, TextStyle? textStyle}) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(15)),
      width: getWidth(tag),
      child: Text(
          textAlign: TextAlign.center,
          tag,
          style: GoogleFonts.poppins(
            fontSize: 30.sp,
            fontWeight: FontWeight.w600,
            textStyle: TextStyle(
              color: AppColors.textFieldText_Color,
            ),
          ).merge(textStyle)),
    );
  }

  double getWidth(String tag) {
    if (tag.length > 2) {
      return 90.w;
    } else if (tag.length > 1) {
      return 80.w;
    } else {
      return 70.w;
    }
  }
}
