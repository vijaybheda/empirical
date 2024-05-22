import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/json_file_operations.dart';
import 'package:pverify/controller/specification_attributes_controller.dart';
import 'package:pverify/ui/components/drawer_header_content_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/ui/side_drawer.dart';
import 'package:pverify/ui/spec_attributes/spec_attribute_table.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/theme/colors.dart';

class SpecificationAttributesScreen
    extends GetWidget<SpecificationAttributesController> {
  final String uniqueTag;
  const SpecificationAttributesScreen({super.key, required this.uniqueTag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      tag: uniqueTag,
      init: SpecificationAttributesController(),
      builder: (controller) {
        if (!controller.hasInitialised.value) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: SizedBox(
                    height: 25,
                    width: 25,
                    child: ProgressAdaptive(),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            toolbarHeight: 150.h,
            leadingWidth: 0,
            automaticallyImplyLeading: false,
            leading: const Offstage(),
            centerTitle: false,
            backgroundColor: Theme.of(context).primaryColor,
            titleSpacing: 0,
            title: DrawerHeaderContentView(title: AppStrings.itemAttributes),
          ),
          drawer: SideDrawer(
            isSpecialInstructionTextVisible: true,
            onDefectSaveAndCompleteTap: () async {
              controller.saveDefectEntriesAndContinue();
            },
            onDiscardTap: () async {
              controller.deleteInspectionAndGotoMyInspectionScreen();
            },
            onCameraTap: () async {
              await controller.onCameraMenuTap();
            },
            onSpecInstructionTap: () async {
              await controller.specialInstructions();
            },
            onSpecificationTap: () async {
              await controller.onSpecificationTap();
            },
            onGradeTap: () async {
              await JsonFileOperations.instance.viewGradePdf();
            },
            onInspectionTap: () async {
              await JsonFileOperations.instance.viewSpecInsPdf();
            },
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              _commodityInfoWidget(controller),
              Expanded(
                  child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 24,
                        horizontal: 12,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Text(
                              AppStrings.specAttributes,
                              style: Get.textTheme.titleLarge!.copyWith(),
                            ),
                            SizedBox(height: 20.h),
                            Column(
                              children: [
                                _specTableHeading(),
                                SpecAttributeTable(
                                  uniqueTag: uniqueTag,
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 20.h,
                      top: 20.h,
                    ),
                    color: AppColors.primaryColor,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _commonFooterButtons(
                            context: context,
                            controller: controller,
                            onClick: () {
                              controller
                                  .deleteInspectionAndGotoMyInspectionScreen();
                            },
                            buttonTitle: AppStrings.defectDiscard,
                          ),
                          SizedBox(
                            width: 38.w,
                          ),
                          _commonFooterButtons(
                            context: context,
                            controller: controller,
                            onClick: () {
                              controller.saveDefectEntriesAndContinue();
                            },
                            buttonTitle: AppStrings.saveInspectionButton,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(
                      bottom: 20.h,
                      top: 20.h,
                    ),
                    color: AppColors.grey2,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _commonFooterButtons(
                            fontSize: 25.sp,
                            width: (MediaQuery.of(context).size.width / 3.5),
                            context: context,
                            controller: controller,
                            onClick: () {
                              controller.specialInstructions();
                            },
                            buttonTitle: AppStrings.specException,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          _commonFooterButtons(
                            fontSize: 25.sp,
                            width: (MediaQuery.of(context).size.width / 4.5),
                            context: context,
                            controller: controller,
                            onClick: () {
                              controller.onSpecificationTap();
                            },
                            buttonTitle: AppStrings.specification,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          _commonFooterButtons(
                            fontSize: 25.sp,
                            width: (MediaQuery.of(context).size.width / 5),
                            context: context,
                            controller: controller,
                            onClick: () async {
                              await JsonFileOperations.instance.viewGradePdf();
                            },
                            buttonTitle: AppStrings.grade,
                          ),
                          SizedBox(
                            width: 20.w,
                          ),
                          _commonFooterButtons(
                            fontSize: 25.sp,
                            width: (MediaQuery.of(context).size.width / 4.5),
                            context: context,
                            controller: controller,
                            onClick: () async {
                              await JsonFileOperations.instance
                                  .viewSpecInsPdf();
                            },
                            buttonTitle: AppStrings.specInstrunction,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FooterContentView(
                    onBackTap: () {
                      controller.onBackButtonClick();
                    },
                  ),
                ],
              ))
            ],
          ),
        );
      },
    );
  }

  Widget _specTableHeading() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 5,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Name",
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "On Spec",
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "UOM",
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Value",
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Comply",
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
          ),
          _divider(),
          Expanded(
            flex: 2,
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Comment",
                style: Get.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Container _divider() {
    return Container(
      color: Colors.grey,
      width: 1,
      height: 90.h,
      margin: const EdgeInsets.symmetric(horizontal: 5),
    );
  }

  //Commodity Info
  Widget _commodityInfoWidget(SpecificationAttributesController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      color: AppColors.primaryColor,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            controller.commodityName ?? '',
            textAlign: TextAlign.start,
            maxLines: 3,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            controller.itemSKU ?? '',
            textAlign: TextAlign.start,
            maxLines: 3,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 38.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _commonFooterButtons({
    required BuildContext context,
    required SpecificationAttributesController controller,
    required Function onClick,
    required String buttonTitle,
    double? width,
    double? fontSize,
  }) {
    return customButton(
      backgroundColor: AppColors.white,
      title: buttonTitle,
      width: width ?? (MediaQuery.of(context).size.width / 2.3),
      height: 115,
      fontStyle: Get.textTheme.titleLarge!.copyWith(
        color: AppColors.textFieldText_Color,
        fontSize: fontSize ?? 35.sp,
        fontWeight: FontWeight.w600,
      ),
      onClickAction: onClick,
    );
  }
}
