// ignore_for_file: sized_box_for_whitespace, prefer_const_constructors, avoid_unnecessary_containers, non_constant_identifier_names, prefer_const_literals_to_create_immutables
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/get_state_manager.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/trailer_temp/trailertemp_controller.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

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
                () => Image.asset(controller.selectetdTruckArea.value == "Nose"
                    ? AppImages.ic_trailerNose
                    : controller.selectetdTruckArea.value == "Middle"
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
                        controller.selectetdTruckArea.value = "Nose";
                      },
                      child: Container(
                        width: ((MediaQuery.of(context).size.width / 3.5)).w,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controller.selectetdTruckArea.value = "Middle";
                      },
                      child: Container(
                        width: ((MediaQuery.of(context).size.width / 3.5)).w,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        controller.selectetdTruckArea.value = "Tail";
                      },
                      child: Container(
                        width: ((MediaQuery.of(context).size.width / 3.5)).w,
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
            palletview(
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet1_top_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet1_top_TextController.value
                        : controller.tail_pallet1_top_TextController.value,
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet1_middle_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet1_middle_TextController.value
                        : controller.tail_pallet1_middle_TextController.value,
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet1_bottom_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet1_bottom_TextController.value
                        : controller.tail_pallet1_bottom_TextController.value,
                'Pallet 1'),

            palletview(
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet2_top_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet2_top_TextController.value
                        : controller.tail_pallet2_top_TextController.value,
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet2_middle_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet2_middle_TextController.value
                        : controller.tail_pallet2_middle_TextController.value,
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet2_bottom_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet2_bottom_TextController.value
                        : controller.tail_pallet2_bottom_TextController.value,
                'Pallet 2'),

            palletview(
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet3_top_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet3_top_TextController.value
                        : controller.tail_pallet3_top_TextController.value,
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet3_middle_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet3_middle_TextController.value
                        : controller.tail_pallet3_middle_TextController.value,
                controller.selectetdTruckArea.value == "Nose"
                    ? controller.nose_pallet3_bottom_TextController.value
                    : controller.selectetdTruckArea.value == "Middle"
                        ? controller.middle_pallet3_bottom_TextController.value
                        : controller.tail_pallet3_bottom_TextController.value,
                'Pallet 3'),

            // palletview(
            //     controller.selectetdTruckArea.value == "Nose"
            //         ? controller.nose_pallet1_top_TextController.value
            //         : controller.selectetdTruckArea.value == "Middle"
            //             ? controller.nose_pallet1_middle_TextController.value
            //             : controller.nose_pallet1_bottom_TextController.value,
            //     controller.selectetdTruckArea.value == "Nose"
            //         ? controller.nose_pallet2_top_TextController.value
            //         : controller.selectetdTruckArea.value == "Middle"
            //             ? controller.nose_pallet2_middle_TextController.value
            //             : controller.nose_pallet2_bottom_TextController.value,
            //     controller.selectetdTruckArea.value == "Nose"
            //         ? controller.nose_pallet3_top_TextController.value
            //         : controller.selectetdTruckArea.value == "Middle"
            //             ? controller.nose_pallet3_middle_TextController.value
            //             : controller.nose_pallet3_TailTextController.value,
            //     PalletTitle)

            // palletview(
            //     controller.pallet1NoseTextController.value,
            //     controller.pallet1MiddleTextController.value,
            //     controller.pallet1TailTextController.value,
            //     'Pallet 1'),
            // palletview(
            //     controller.pallet2NoseTextController.value,
            //     controller.pallet2MiddleTextController.value,
            //     controller.pallet2TailTextController.value,
            //     'Pallet 2'),
            // palletview(
            //     controller.pallet3NoseTextController.value,
            //     controller.pallet3MiddleTextController.value,
            //     controller.pallet3TailTextController.value,
            //     'Pallet 3'),
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
              'Comment',
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
      String PalletTitle) {
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
            onEditingCompleted: () {
              debugPrint('onEditingCompleted');
            },
            onChanged: (value) {
              debugPrint('onChanged');
            },
            keyboardType: TextInputType.name,
            hintText: 'Top',
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
            keyboardType: TextInputType.name,
            hintText: 'Middle',
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
            keyboardType: TextInputType.name,
            hintText: 'Bottom',
            isPasswordField: true,
          ),
        ),
      ],
    );
  }
}
