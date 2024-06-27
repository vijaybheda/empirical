import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/overridden_result_screen_controller.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_snackbar.dart';
import 'package:pverify/utils/app_strings.dart';
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
                    controller.saveAndContinueClick(context,
                        controller.finalInspectionResult.value.toString());
                  }
                },
              ),
              FooterContentView(
                onBackTap: () {
                  Get.back();
                },
              )
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
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(width: 240.w),
                    Text(
                      controller.myInspectionResult,
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: controller.finalInspectionResultColor,
                        fontSize: 32.sp,
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
                      style: Get.textTheme.titleLarge?.copyWith(
                        color: AppColors.white,
                        fontSize: 32.sp,
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
                  height: (controller.finalInspectionResult.value == "RJ" ||
                          controller.finalInspectionResult.value ==
                              AppStrings.reject ||
                          controller.layoutQtyRejectedVisibility.isTrue)
                      ? 50.h
                      : 0,
                ),
                controller.rejectionDetailsVisibility.isTrue
                    ? Row(
                        children: [
                          Text(
                            AppStrings.rejectionDetails,
                            style: Get.textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 195.w),
                          Flexible(
                            child: Text(
                              controller.txtRejectionDetails.value,
                              style: Get.textTheme.titleLarge?.copyWith(
                                color: AppColors.white,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(
                    height: controller.rejectionDetailsVisibility.isTrue
                        ? 50.h
                        : 0),
                controller.defectCommentsVisibility.isTrue
                    ? Row(
                        children: [
                          Text(
                            AppStrings.defectComments,
                            style: Get.textTheme.titleLarge?.copyWith(
                              color: AppColors.white,
                              fontSize: 32.sp,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          SizedBox(width: 195.w),
                          Flexible(
                            child: Text(
                              controller.txtDefectComment.value,
                              style: Get.textTheme.titleLarge?.copyWith(
                                color: AppColors.white,
                                fontSize: 32.sp,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      )
                    : Container(),
                SizedBox(
                    height:
                        controller.defectCommentsVisibility.isTrue ? 50.h : 0),
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
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            controller.itemSku ?? '',
            textAlign: TextAlign.start,
            maxLines: 3,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
            ),
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
            style: Get.textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontSize: 32.sp,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: SizedBox(
            width: 350.w,
            child: Container(
              alignment: Alignment.center,
              height: 105.h,
              child: TextFormField(
                textAlign: TextAlign.left,
                textAlignVertical: TextAlignVertical.center,
                onChanged: (value) {},
                onEditingComplete: () {
                  FocusScope.of(context).unfocus();
                },
                autofocus: false,
                minLines: 1,
                maxLines: 1,
                onTap: () {},
                enabled: enabled,
                readOnly: readOnly,
                keyboardType: TextInputType.name,
                controller: controller,
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                ),
                cursorColor: Theme.of(context).textSelectionTheme.cursorColor,
                decoration: InputDecoration(
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: AppColors.hintColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide:
                        BorderSide(color: Theme.of(context).primaryColor),
                  ),
                  hintText: placeHolder,
                  hintStyle: Get.textTheme.titleLarge!.copyWith(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey,
                  ),
                  suffixIcon: hasValidOrderNo(controller)
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.info,
                              color: Colors.red, size: 24),
                          onPressed: () {
                            AppSnackBar.error(
                                message: "Please enter a valid value");
                          },
                        ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 0, vertical: 5),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  bool hasValidOrderNo(TextEditingController controller) {
    return controller.text.trim().isNotEmpty;
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
            style: Get.textTheme.titleLarge?.copyWith(
              color: AppColors.white,
              fontSize: 32.sp,
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
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.normal,
                  color: AppColors.hintColor,
                ),
              ),
              items: items.map((selectedType) {
                return DropdownMenuItem<String>(
                  value: selectedType,
                  child: Text(
                    selectedType,
                    style: Get.textTheme.bodyMedium!.copyWith(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.normal,
                      color: AppColors.hintColor,
                    ),
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
