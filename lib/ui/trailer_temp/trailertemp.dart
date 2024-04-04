// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:get/state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/trailer_temp/trailertemp_controller.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/theme/theme.dart';

class TrailerTemp extends GetView<TrailerTempController> {
  const TrailerTemp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
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
            body: Container(
              color: Theme.of(context).colorScheme.background,
              child: contentView(context, controller),
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
          hasLeftButton: false,
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
                        controller.selectetdTruckArea.value = AppStrings.nose;
                      },
                      child: Container(
                        width: ((MediaQuery.of(context).size.width / 3.5)).w,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controller.selectetdTruckArea.value = AppStrings.middle;
                      },
                      child: Container(
                        width: ((MediaQuery.of(context).size.width / 3.5)).w,
                      ),
                    ),
                    InkWell(
                      onTap: () {
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
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet1_top_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller.middle_pallet1_top_TextController.value
                          : controller.tail_pallet1_top_TextController.value,
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet1_middle_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller
                              .middle_pallet1_middle_TextController.value
                          : controller.tail_pallet1_middle_TextController.value,
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet1_bottom_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller
                              .middle_pallet1_bottom_TextController.value
                          : controller.tail_pallet1_bottom_TextController.value,
                  AppStrings.pallet1,
                  context),
            ),
            Obx(
              () => palletview(
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet2_top_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller.middle_pallet2_top_TextController.value
                          : controller.tail_pallet2_top_TextController.value,
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet2_middle_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller
                              .middle_pallet2_middle_TextController.value
                          : controller.tail_pallet2_middle_TextController.value,
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet2_bottom_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller
                              .middle_pallet2_bottom_TextController.value
                          : controller.tail_pallet2_bottom_TextController.value,
                  AppStrings.pallet2,
                  context),
            ),
            Obx(
              () => palletview(
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet3_top_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller.middle_pallet3_top_TextController.value
                          : controller.tail_pallet3_top_TextController.value,
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet3_middle_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller
                              .middle_pallet3_middle_TextController.value
                          : controller.tail_pallet3_middle_TextController.value,
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? controller.nose_pallet3_bottom_TextController.value
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? controller
                              .middle_pallet3_bottom_TextController.value
                          : controller.tail_pallet3_bottom_TextController.value,
                  AppStrings.pallet3,
                  context),
            ),
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
      String PalletTitle,
      BuildContext context) {
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
          child: BoxTextField1(
            isMulti: false,
            controller: topTextEditingController,
            onTap: () {
              debugPrint('onTap');
            },
            errorText: '',
            onEditingCompleted: () {},
            onChanged: (value) {
              debugPrint('onChanged');
            },
            keyboardType: TextInputType.number,
            hintText: AppStrings.topCap,
            isPasswordField: true,
          ),
        ),
        SizedBox(
          width: 280.w,
          child: BoxTextField1(
            isMulti: false,
            controller: middleTextEditingController,
            onTap: () {},
            errorText: '',
            onEditingCompleted: () {},
            onChanged: (value) {},
            keyboardType: TextInputType.number,
            hintText: AppStrings.middleCap,
            isPasswordField: true,
          ),
        ),
        SizedBox(
          width: 280.w,
          child: BoxTextField1(
            isMulti: false,
            controller: bottomTextEditingController,
            onTap: () {},
            errorText: '',
            onEditingCompleted: () {},
            onChanged: (value) {},
            keyboardType: TextInputType.number,
            hintText: AppStrings.bottomCap,
            isPasswordField: true,
          ),
        ),
      ],
    );
  }
}
