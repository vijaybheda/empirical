// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names, prefer_const_literals_to_create_immutables, unrelated_type_equality_checks
import 'dart:async';
import 'dart:developer';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/trailer_temp/trailerTempClass.dart';
import 'package:pverify/ui/trailer_temp/trailertemp_controller.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/theme/theme.dart';

class TrailerTemp extends GetView<TrailerTempController> {
  final CarrierItem carrier;
  final String orderNumber;
  const TrailerTemp(
      {super.key, required this.carrier, required this.orderNumber});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrailerTempController>(
        init: TrailerTempController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: baseHeaderView(AppStrings.trailerTempRange, false),
            ),
            body: GestureDetector(
              onTap: () {},
              child: Container(
                color: Theme.of(context).colorScheme.background,
                child: contentView(context, controller),
              ),
            ),
          );
        });
  }

  Widget contentView(BuildContext context, TrailerTempController controller) {
    return Column(
      children: [
        Expanded(
          child: Container(
              padding: EdgeInsets.only(left: 50, right: 50, top: 25),
              child: truckContentView(context, controller)),
        ),
        Container(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          height: 150.h,
          color: AppColors.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customButton(
                  AppColors.white,
                  AppStrings.skip,
                  (MediaQuery.of(context).size.width / 2.3),
                  115,
                  GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {}),
              SizedBox(
                width: 38.w,
              ),
              customButton(
                  AppColors.white,
                  AppStrings.saveReadingsButton,
                  (MediaQuery.of(context).size.width / 2.3),
                  115,
                  GoogleFonts.poppins(
                      fontSize: 35.sp,
                      fontWeight: FontWeight.w600,
                      textStyle:
                          TextStyle(color: AppColors.textFieldText_Color)),
                  onClickAction: () => {}),
            ],
          ),
        ),
        FooterContentView(
          isVisibleCancel: true,
        )
      ],
    );
  }

  Widget truckContentView(
      BuildContext context, TrailerTempController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          alignment: Alignment.center,
          height: ((MediaQuery.of(context).size.width - 60) / 0.85).h,
          child: Stack(
            children: [
              Obx(
                () => Image.asset(controller.selectetdTruckArea.value ==
                        AppStrings.nose
                    ? AppImages.ic_trailerNose
                    : controller.selectetdTruckArea.value == AppStrings.middle
                        ? AppImages.ic_trailerMiddle
                        : AppImages.ic_trailerTail),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: (MediaQuery.of(context).size.width / 3.5),
                    bottom: 300.h),
                height: double.infinity - 100,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        controller.currentMode.value = TrailerEnum.Nose;
                        controller.setDataUI();
                        controller.selectetdTruckArea.value = AppStrings.nose;
                      },
                      child: Container(
                        width: ((MediaQuery.of(context).size.width / 3.5)).w,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controller.currentMode.value = TrailerEnum.Middle;
                        controller.setDataUI();
                        controller.selectetdTruckArea.value = AppStrings.middle;
                      },
                      child: Container(
                        width: ((MediaQuery.of(context).size.width / 3.5)).w,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controller.currentMode.value = TrailerEnum.Tail;
                        controller.setDataUI();
                        controller.selectetdTruckArea.value = AppStrings.tail;
                      },
                      child: Container(
                        width: (MediaQuery.of(context).size.width / 3.5).w,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Obx(
          () => Text(
            controller.selectetdTruckArea.value,
            style: GoogleFonts.poppins(
                fontSize: 32.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.white)),
          ),
        ),
        SizedBox(
          height: 40.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(
              () => palletview(
                  controller.pallet1_top_TextController.value,
                  controller.pallet1_middle_TextController.value,
                  controller.pallet1_bottom_TextController.value,
                  controller.pallet1_top_FocusNode,
                  controller.pallet1_middle_FocusNode,
                  controller.pallet1_bottom_FocusNode,
                  AppStrings.pallet1,
                  context,
                  controller),
            ),

            Obx(
              () => palletview(
                  controller.pallet2_top_TextController.value,
                  controller.pallet2_middle_TextController.value,
                  controller.pallet2_bottom_TextController.value,
                  controller.pallet2_top_FocusNode,
                  controller.pallet2_middle_FocusNode,
                  controller.pallet2_bottom_FocusNode,
                  AppStrings.pallet2,
                  context,
                  controller),
            ),

            Obx(
              () => palletview(
                  controller.pallet3_top_TextController.value,
                  controller.pallet3_middle_TextController.value,
                  controller.pallet3_bottom_TextController.value,
                  controller.pallet3_top_FocusNode,
                  controller.pallet3_middle_FocusNode,
                  controller.pallet3_bottom_FocusNode,
                  AppStrings.pallet3,
                  context,
                  controller),
            ),

            // () => palletview(
            //     controller.currentMode.value == TrailerEnum.Nose
            //         ? controller.pallet1_top_TextController.value
            //         : controller.selectetdTruckArea.value == AppStrings.middle
            //             ? controller.middle_pallet1_top_TextController.value
            //             : controller.tail_pallet1_top_TextController.value,
            //     controller.selectetdTruckArea.value == AppStrings.nose
            //         ? controller.nose_pallet1_middle_TextController.value
            //         : controller.selectetdTruckArea.value == AppStrings.middle
            //             ? controller
            //                 .middle_pallet1_middle_TextController.value
            //             : controller.tail_pallet1_middle_TextController.value,
            //     controller.selectetdTruckArea.value == AppStrings.nose
            //         ? controller.nose_pallet1_bottom_TextController.value
            //         : controller.selectetdTruckArea.value == AppStrings.middle
            //             ? controller
            //                 .middle_pallet1_bottom_TextController.value
            //             : controller.tail_pallet1_bottom_TextController.value,
            //     AppStrings.pallet1,
            //     context,
            //     controller),

            // Obx(
            //   () => palletview(
            //       controller.selectetdTruckArea.value == AppStrings.nose
            //           ? controller.nose_pallet2_top_TextController.value
            //           : controller.selectetdTruckArea.value == AppStrings.middle
            //               ? controller.middle_pallet2_top_TextController.value
            //               : controller.tail_pallet2_top_TextController.value,
            //       controller.selectetdTruckArea.value == AppStrings.nose
            //           ? controller.nose_pallet2_middle_TextController.value
            //           : controller.selectetdTruckArea.value == AppStrings.middle
            //               ? controller
            //                   .middle_pallet2_middle_TextController.value
            //               : controller.tail_pallet2_middle_TextController.value,
            //       controller.selectetdTruckArea.value == AppStrings.nose
            //           ? controller.nose_pallet2_bottom_TextController.value
            //           : controller.selectetdTruckArea.value == AppStrings.middle
            //               ? controller
            //                   .middle_pallet2_bottom_TextController.value
            //               : controller.tail_pallet2_bottom_TextController.value,
            //       AppStrings.pallet2,
            //       context,
            //       controller),
            // ),
            // Obx(
            //   () => palletview(
            //       controller.selectetdTruckArea.value == AppStrings.nose
            //           ? controller.nose_pallet3_top_TextController.value
            //           : controller.selectetdTruckArea.value == AppStrings.middle
            //               ? controller.middle_pallet3_top_TextController.value
            //               : controller.tail_pallet3_top_TextController.value,
            //       controller.selectetdTruckArea.value == AppStrings.nose
            //           ? controller.nose_pallet3_middle_TextController.value
            //           : controller.selectetdTruckArea.value == AppStrings.middle
            //               ? controller
            //                   .middle_pallet3_middle_TextController.value
            //               : controller.tail_pallet3_middle_TextController.value,
            //       controller.selectetdTruckArea.value == AppStrings.nose
            //           ? controller.nose_pallet3_bottom_TextController.value
            //           : controller.selectetdTruckArea.value == AppStrings.middle
            //               ? controller
            //                   .middle_pallet3_bottom_TextController.value
            //               : controller.tail_pallet3_bottom_TextController.value,
            //       AppStrings.pallet3,
            //       context,
            //       controller),
            // ),
          ],
        ),
        SizedBox(
          height: 20.h,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              AppStrings.comment,
              style: GoogleFonts.poppins(
                  fontSize: 25.sp,
                  fontWeight: FontWeight.normal,
                  textStyle: TextStyle(color: AppColors.white)),
            ),
            SizedBox(
              width: 50.w,
            ),
            Flexible(
              child: BoxTextField1(
                isMulti: false,
                controller: controller.commentTextController.value,
                onTap: () {},
                errorText: '',
                onEditingCompleted: () {},
                onChanged: (value) {},
                keyboardType: TextInputType.name,
                hintText: '',
                isPasswordField: true,
              ),
            ),
          ],
        )
      ],
    );
  }

  Widget palletview(
      TextEditingController topTextEditingController,
      TextEditingController middleTextEditingController,
      TextEditingController bottomTextEditingController,
      FocusNode topFocusNode,
      FocusNode middleFocusNode,
      FocusNode bottomFocusNode,
      String PalletTitle,
      BuildContext context,
      TrailerTempController controller) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          PalletTitle,
          style: GoogleFonts.poppins(
              fontSize: 32.sp,
              fontWeight: FontWeight.w600,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        SizedBox(
          width: 280.w,
          child: BoxTextField2(
            isMulti: false,
            controller: topTextEditingController,
            onTap: () {
              debugPrint('onTap');
            },
            errorText: '',
            onEditingCompleted: () {
              if (controller.currentMode == TrailerEnum.Nose) {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.nose?.pallet1?.top =
                      topTextEditingController.value.text;
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.nose?.pallet2?.top =
                      topTextEditingController.value.text;
                } else {
                  controller.tailerTempData.nose?.pallet3?.top =
                      topTextEditingController.value.text;
                }
              } else if (controller.currentMode == TrailerEnum.Middle) {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.middle?.pallet1?.top =
                      topTextEditingController.value.text;
                  debugPrint(controller.tailerTempData.middle?.pallet1?.top);
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.middle?.pallet2?.top =
                      topTextEditingController.value.text;
                } else {
                  controller.tailerTempData.middle?.pallet3?.top =
                      topTextEditingController.value.text;
                }
              } else {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.tail?.pallet1?.top =
                      topTextEditingController.value.text;
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.tail?.pallet2?.top =
                      topTextEditingController.value.text;
                } else {
                  controller.tailerTempData.tail?.pallet3?.top =
                      topTextEditingController.value.text;
                }
              }
              controller.setDataUI();
              topFocusNode.unfocus();
            },
            onChanged: (value) {
              debugPrint('onChanged');
            },
            keyboardType: TextInputType.number,
            hintText: AppStrings.topCap,
            isPasswordField: true,
            focusNode: topFocusNode,
          ),
        ),
        SizedBox(
          width: 280.w,
          child: BoxTextField2(
            isMulti: false,
            controller: middleTextEditingController,
            onTap: () {},
            errorText: '',
            onEditingCompleted: () {
              if (controller.currentMode == TrailerEnum.Nose) {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.nose?.pallet1?.middle =
                      middleTextEditingController.value.text.toString();
                  debugPrint(controller.tailerTempData.nose?.pallet1?.middle);
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.nose?.pallet2?.middle =
                      middleTextEditingController.value.text;
                } else {
                  controller.tailerTempData.nose?.pallet3?.middle =
                      middleTextEditingController.value.text;
                }
              } else if (controller.currentMode == TrailerEnum.Middle) {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.middle?.pallet1?.middle =
                      middleTextEditingController.value.text;
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.middle?.pallet2?.middle =
                      middleTextEditingController.value.text;
                } else {
                  controller.tailerTempData.middle?.pallet3?.middle =
                      middleTextEditingController.value.text;
                }
              } else {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.tail?.pallet1?.middle =
                      middleTextEditingController.value.text;
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.tail?.pallet2?.middle =
                      middleTextEditingController.value.text;
                } else {
                  controller.tailerTempData.tail?.pallet3?.middle =
                      middleTextEditingController.value.text;
                }
              }
              controller.setDataUI();
              middleFocusNode.unfocus();
            },
            onChanged: (value) {},
            keyboardType: TextInputType.number,
            hintText: AppStrings.middleCap,
            isPasswordField: true,
            focusNode: middleFocusNode,
          ),
        ),
        SizedBox(
          width: 280.w,
          child: BoxTextField2(
            isMulti: false,
            controller: bottomTextEditingController,
            onTap: () {},
            errorText: '',
            onEditingCompleted: () {
              if (controller.currentMode == TrailerEnum.Nose) {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.nose?.pallet1?.bottom =
                      bottomTextEditingController.value.text.toString();
                  debugPrint(controller.tailerTempData.nose?.pallet1?.bottom);
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.nose?.pallet2?.bottom =
                      bottomTextEditingController.value.text;
                } else {
                  controller.tailerTempData.nose?.pallet3?.bottom =
                      bottomTextEditingController.value.text;
                }
              } else if (controller.currentMode == TrailerEnum.Middle) {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.middle?.pallet1?.bottom =
                      bottomTextEditingController.value.text;
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.middle?.pallet2?.bottom =
                      bottomTextEditingController.value.text;
                } else {
                  controller.tailerTempData.middle?.pallet3?.bottom =
                      bottomTextEditingController.value.text;
                }
              } else {
                if (PalletTitle == AppStrings.pallet1) {
                  controller.tailerTempData.tail?.pallet1?.bottom =
                      bottomTextEditingController.value.text;
                } else if (PalletTitle == AppStrings.pallet2) {
                  controller.tailerTempData.tail?.pallet2?.bottom =
                      bottomTextEditingController.value.text;
                } else {
                  controller.tailerTempData.tail?.pallet3?.bottom =
                      bottomTextEditingController.value.text;
                }
              }
              controller.setDataUI();
              bottomFocusNode.unfocus();
            },
            onChanged: (value) {},
            keyboardType: TextInputType.number,
            hintText: AppStrings.bottomCap,
            isPasswordField: true,
            focusNode: bottomFocusNode,
          ),
        ),
      ],
    );
  }
}
