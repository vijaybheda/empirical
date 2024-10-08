import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/trailertemp_controller.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/trailer_temp/trailertemp_class.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/textfield/text_fields.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/theme/theme.dart';

class TrailerTemp extends GetView<TrailerTempController> {
  // final CarrierItem carrier;
  // final String orderNumber;
  const TrailerTemp({
    super.key,
    // required this.carrier,
    // required this.orderNumber,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TrailerTempController>(
        init: TrailerTempController(),
        builder: (controller) {
          // controller.carrier1 = carrier;
          // controller.orderNumber1 = orderNumber;
          if (controller.isOrderNumberAvailable == false) {
            controller.loadDataFromDB();
            controller.isOrderNumberAvailable = true;
          }
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: HeaderContentView(title: AppStrings.trailerTempRange),
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
          child: Container(child: truckContentView(context, controller)),
        ),
        Container(
          padding: EdgeInsets.only(left: 50.w, right: 50.w),
          height: 150.h,
          color: AppColors.primaryColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.skip,
                  width: (MediaQuery.of(context).size.width / 2.3),
                  height: 115,
                  fontStyle: Get.textTheme.titleLarge!.copyWith(
                    color: AppColors.textFieldText_Color,
                    fontSize: 35.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  onClickAction: () {
                    if (controller.allDataBlank()) {
                      controller.showPurchaseOrder();
                    } else {
                      AppAlertDialog.confirmationAlert(
                        context,
                        AppStrings.alert,
                        AppStrings.trailerTemperatureSkipAlert,
                        onYesTap: () {
                          Get.back();
                        },
                      );
                    }
                  }),
              SizedBox(
                width: 38.w,
              ),
              customButton(
                  backgroundColor: AppColors.white,
                  title: AppStrings.saveReadingsButton,
                  width: (MediaQuery.of(context).size.width / 2.3),
                  height: 115,
                  fontStyle: Get.textTheme.titleLarge!.copyWith(
                    color: AppColors.textFieldText_Color,
                    fontSize: 35.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  onClickAction: () async {
                    if (controller.allDataBlank()) {
                      AppAlertDialog.validateAlerts(context, AppStrings.error,
                          AppStrings.trailer_temperature_no_entries_alert);
                    } else {
                      await controller.saveTemperatureData(
                          'N',
                          controller.poNumber!,
                          controller.carrierId,
                          controller.tailerTempData);
                      await controller.saveTemperatureData(
                          'M',
                          controller.poNumber!,
                          controller.carrierId,
                          controller.tailerTempData);
                      await controller.saveTemperatureData(
                          'B',
                          controller.poNumber!,
                          controller.carrierId,
                          controller.tailerTempData);
                      Get.back();
                    }
                  }),
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
          padding: EdgeInsets.only(left: 50.w, right: 50, top: 25),
          color: AppColors.white,
          alignment: Alignment.center,
          height: ((MediaQuery.of(context).size.width - 60) / 0.80).h,
          child: Stack(
            children: [
              Obx(
                () => Image.asset(
                  controller.selectetdTruckArea.value == AppStrings.nose
                      ? AppImages.ic_trailerNose
                      : controller.selectetdTruckArea.value == AppStrings.middle
                          ? AppImages.ic_trailerMiddle
                          : AppImages.ic_trailerTail,
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                    left: (MediaQuery.of(context).size.width / 3.5),
                    bottom: 220.h),
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
        SizedBox(
          height: 32.h,
        ),
        Obx(
          () => Text(
            controller.selectetdTruckArea.value,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 35.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SizedBox(
          height: 40.h,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50, right: 50),
          child: Row(
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
            ],
          ),
        ),
        SizedBox(
          height: 40.h,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 50, right: 50),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                AppStrings.comments,
                style: Get.textTheme.titleLarge!.copyWith(
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w600,
                ),
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
                  onEditingCompleted: () {
                    FocusScope.of(context).unfocus();
                  },
                  onChanged: (value) {},
                  keyboardType: TextInputType.name,
                  hintText: '',
                  isPasswordField: true,
                ),
              ),
            ],
          ),
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
          style: Get.textTheme.titleLarge!.copyWith(
            fontSize: 32.sp,
            fontWeight: FontWeight.w600,
          ),
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
              controller.saveData(PalletTitle);
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
              controller.saveData(PalletTitle);
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
              controller.saveData(PalletTitle);
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
