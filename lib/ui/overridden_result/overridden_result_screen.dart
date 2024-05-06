import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/overridden_result_screen_controller.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/theme/colors.dart';

class OverriddenResultScreen
    extends GetWidget<OverriddenResultScreenController> {
  const OverriddenResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OverriddenResultScreenController>(
      init: OverriddenResultScreenController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
            toolbarHeight: 150.h,
            leading: const Offstage(),
            leadingWidth: 0,
            centerTitle: false,
            backgroundColor: Theme.of(context).primaryColor,
            title: HeaderContentView(
              title: controller.partnerName ?? '',
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _commodityInfoWidget(controller),
              _bodyForm(context, controller),
              Expanded(flex: 10, child: Container()),
              BottomCustomButtonView(
                title: AppStrings.saveAndContinue,
                backgroundColor: AppColors.grey2,
                onPressed: () {
                  if (controller.isOverrideControllerValidate(context)) {
                    controller.saveAndContinue(context);
                  }
                },
              ),
              FooterContentView()
            ],
          ),
        );
      },
    );
  }

  // BODY
  Widget _bodyForm(
    BuildContext context,
    OverriddenResultScreenController controller,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 28,
        vertical: 50,
      ),
      child: Form(
        child: Obx(() => Column(
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.originalResult,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontSize: 65.h,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 240.w),
                    Text(
                      controller.finalInspectionResult?.value ?? '',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: controller.finalInspectionResultColor,
                        fontSize: 65.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                Row(
                  children: [
                    Text(
                      "(Original Qtys:  Accepted ${controller.qtyShipped.value} / Rejected ${controller.qtyRejected.value})"
                          .tr,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontSize: 55.h,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                _commonRowDropDownView(
                  context: context,
                  controller: controller,
                  labelTitle: AppStrings.newResult,
                  items: AppStrings.newResultList,
                  hintText: AppStrings.accept,
                ),
                SizedBox(height: 50.h),
                Visibility(
                  visible: controller.layoutQtyRejectedVisibility.isTrue
                      ? true
                      : false,
                  child: _commonRowTextFieldView(
                    context,
                    AppStrings.qtyRejected,
                    controller.qtyRejected.value.toString(),
                    controller.gtyRejectController.value,
                  ),
                ),
                SizedBox(
                  height: (controller.finalInspectionResult?.value == "RJ" ||
                          controller.finalInspectionResult?.value ==
                              AppStrings.reject ||
                          controller.layoutQtyRejectedVisibility.isTrue)
                      ? 50.h
                      : 0,
                ),
                Row(
                  children: [
                    Text(
                      AppStrings.rejectionDetails,
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontSize: 65.h,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 195.w),
                    Text(
                      controller.finalInspectionResult?.value ?? '',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: controller.finalInspectionResultColor,
                        fontSize: 65.h,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 50.h),
                _commonRowTextFieldView(
                  context,
                  AppStrings.overrideComments,
                  '',
                  controller.ovverRiddenCommentTextController.value,
                ),
                SizedBox(height: 20.h),
              ],
            )),
      ),
    );
  }

  //Commodity Info
  Widget _commodityInfoWidget(OverriddenResultScreenController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.orange,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.commodityName ?? '',
            textAlign: TextAlign.start,
            maxLines: 3,
            style: GoogleFonts.poppins(
                fontSize: 38.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.white)),
          ),
          Text(
            controller.itemSku ?? '',
            textAlign: TextAlign.start,
            maxLines: 3,
            style: GoogleFonts.poppins(
                fontSize: 38.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.white)),
          ),
        ],
      ),
    );
  }

  // TextField
  Widget _commonRowTextFieldView(BuildContext context, String labelTitle,
      String placeHolder, TextEditingController controller,
      {bool readOnly = false, bool enabled = true}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            labelTitle,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.white,
              fontSize: 65.h,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SizedBox(
            width: 350.w,
            child: BoxTextField1(
              isMulti: false,
              controller: controller,
              onTap: () {},
              errorText: '',
              readOnly: readOnly,
              enabled: enabled,
              onEditingCompleted: () {
                FocusScope.of(context).unfocus();
              },
              onChanged: (value) {},
              keyboardType: TextInputType.name,
              hintText: placeHolder,
              isPasswordField: true,
            ),
          ),
        ),
      ],
    );
  }

  //DropDown
  Widget _commonRowDropDownView(
      {required BuildContext context,
      required OverriddenResultScreenController controller,
      required String labelTitle,
      required List items,
      required String hintText}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            labelTitle,
            style: Get.textTheme.bodyMedium?.copyWith(
              color: AppColors.white,
              fontSize: 65.h,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Obx(
            () => DropdownButtonFormField<String>(
              decoration: const InputDecoration(border: InputBorder.none),
              dropdownColor: Theme.of(context).colorScheme.background,
              iconEnabledColor: AppColors.hintColor,
              hint: Text(
                hintText,
                style: GoogleFonts.poppins(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.normal,
                    textStyle: TextStyle(color: AppColors.hintColor)),
              ),
              items: items.map((selectedType) {
                return DropdownMenuItem<String>(
                  value: selectedType,
                  child: Text(
                    selectedType,
                    style: GoogleFonts.poppins(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.normal,
                        textStyle: TextStyle(color: AppColors.hintColor)),
                  ),
                );
              }).toList(),
              value: controller.newResultAccept.value,
              onChanged: (newValue) {
                controller.setSelected(
                  newValue ?? '',
                  labelTitle == AppStrings.accept
                      ? AppStrings.accept
                      : labelTitle == AppStrings.reject
                          ? AppStrings.reject
                          : labelTitle == "A-"
                              ? "A-"
                              : AppStrings.acceptCondition,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
