import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/defects_screen_controller.dart';
import 'package:pverify/models/inspection_defect.dart';
import 'package:pverify/ui/defects/defect_item_widget.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class SampleSetWidget extends StatefulWidget {
  final int sampleIndex;
  final DefectsScreenController controller;
  const SampleSetWidget({
    super.key,
    required this.sampleIndex,
    required this.controller,
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
                        controller.removeSampleSets(sampleIndex);
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
                  color: sampleIndex % 2 == 0
                      ? AppColors.orange
                      : AppColors.textFieldText_Color,
                  child: Text(
                    textAlign: TextAlign.center,
                    '${controller.sampleList[sampleIndex].sampleSize.toString()} samples Set #${controller.sampleList[sampleIndex].setNumber}',
                    style: GoogleFonts.poppins(
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w400,
                      textStyle: TextStyle(
                        color: sampleIndex % 2 == 0
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
        controller.sampleList[sampleIndex].defectItems.isNotEmpty
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
            controller.addDefectRow(sampleIndex: sampleIndex);
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

  Widget defectCategoryTagRow(DefectsScreenController defectsScreenController) {
    TextStyle textStyle = TextStyle(
      color: Colors.white,
      fontSize: 32.sp,
    );
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 50.w),
      child: Row(
        children: [
          Flexible(flex: 5, child: Container()),
          const SizedBox(width: 15),
          Flexible(flex: 4, child: Container()),
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
              : const Flexible(flex: 1, child: SizedBox()),
          const SizedBox(width: 15),
          defectsScreenController.hasSeverityDamage
              ? Flexible(
                  flex: 1,
                  child: defectCategoryTag(
                    tag: AppStrings.damageIcon,
                    textStyle: textStyle,
                  ),
                )
              : const Flexible(flex: 1, child: SizedBox()),
          const SizedBox(width: 15),
          defectsScreenController.hasSeriousDamage
              ? Flexible(
                  flex: 1,
                  child: defectCategoryTag(
                    tag: AppStrings.seriousDamageIcon,
                    textStyle: textStyle,
                  ),
                )
              : const Flexible(flex: 1, child: SizedBox()),
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
              : const Flexible(flex: 1, child: SizedBox()),
          const SizedBox(width: 15),
          defectsScreenController.hasSeverityDecay
              ? Flexible(
                  flex: 1,
                  child: defectCategoryTag(
                    tag: AppStrings.decayIcon,
                    textStyle: textStyle,
                  ),
                )
              : const Flexible(flex: 1, child: SizedBox()),
          const SizedBox(width: 20),
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
          border: Border.all(color: AppColors.lightGrey),
          borderRadius: BorderRadius.circular(15)),
      width: 80.w,
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
}
