// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_types_as_parameter_names, must_be_immutable, avoid_unnecessary_containers, unrelated_type_equality_checks, unused_element, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/home_controller.dart';
import 'package:pverify/ui/carrier/choose_carrier.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class Home extends GetView<HomeController> {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: HeaderContentView(title: AppStrings.home),
            ),
            body: Container(
                color: Theme.of(context).colorScheme.background,
                child: contentView(context, controller)),
          );
        });
  }

  Widget contentView(BuildContext context, HomeController controller) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(35.h),
            child: Container(
              width: ResponsiveHelper.getDeviceWidth(context),
              child: Column(
                children: [
                  bannersView(controller),
                  SizedBox(
                    height: 40.h,
                  ),
                  SizedBox(
                    // Top Headers
                    height: 115.h,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            alignment: Alignment.center,
                            width: (MediaQuery.of(context).size.width / 2.5),
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                border: Border(
                                    right: BorderSide(
                                      color: AppColors.black,
                                      width: 2.0,
                                    ),
                                    left: BorderSide(
                                      color: AppColors.black,
                                      width: 2.0,
                                    ),
                                    top: BorderSide(
                                      color: AppColors.black,
                                      width: 2.0,
                                    ))),
                            child: Text(
                              AppStrings.myInspectionScreen,
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.displayLarge,
                            ),
                          ),
                          Container(
                            width: (MediaQuery.of(context).size.width / 4.3),
                            padding: EdgeInsets.symmetric(vertical: 15.h),
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border(
                                    right: BorderSide(
                                      color: AppColors.black,
                                      width: 2.0,
                                    ),
                                    top: BorderSide(
                                      color: AppColors.black,
                                      width: 2.0,
                                    ))),
                            child: Padding(
                              padding: EdgeInsets.only(left: 25, right: 25),
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius: BorderRadius.circular(20.0)),
                                child: Text(
                                  AppStrings.upload,
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                ),
                              ),
                            ),
                          ),
                          Container(
                            alignment: Alignment.centerLeft,
                            width: (MediaQuery.of(context).size.width / 3.09),
                            padding: EdgeInsets.symmetric(
                                vertical: 15.h, horizontal: 10),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                border: Border(
                                    right: BorderSide(
                                      color: AppColors.black,
                                      width: 2.0,
                                    ),
                                    top: BorderSide(
                                      color: AppColors.black,
                                      width: 2.0,
                                    ))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.trsCompleteAll,
                                  textAlign: TextAlign.center,
                                  style:
                                      Theme.of(context).textTheme.displayLarge,
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.selectInspectionForDownload(
                                        'id', true);
                                  },
                                  child: Container(
                                    color: AppColors.primary,
                                    padding: EdgeInsets.all(5),
                                    child: Obx(() => Image.asset(
                                          controller.selectedIDsInspection
                                                      .length ==
                                                  controller
                                                      .listOfInspection.length
                                              ? AppImages.ic_SelectedCheckbox
                                              : AppImages.ic_unSelectCheckbox,
                                          width: 60.w,
                                          height: 60.h,
                                          color: AppColors.white,
                                        )),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    // Table's Columng
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width / 10.2,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border:
                                Border.all(color: AppColors.black, width: 2.0)),
                        child: Text(
                          AppStrings.ID,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                              textStyle: TextStyle(color: AppColors.white)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 7.4,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border: Border(
                                bottom: BorderSide(
                                    color: AppColors.black, width: 2.0),
                                top: BorderSide(
                                    color: AppColors.black, width: 2.0))),
                        child: Text(
                          AppStrings.qcPoNumber,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                              textStyle: TextStyle(
                                  color: AppColors.white,
                                  overflow: TextOverflow.ellipsis)),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          controller.sortArray_Item();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 6.8,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              border: Border.all(
                                  color: AppColors.black, width: 2.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.trsItemNo,
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 30.sp,
                                    fontWeight: FontWeight.w600,
                                    textStyle:
                                        TextStyle(color: AppColors.white)),
                              ),
                              SizedBox(
                                width: 3,
                              ),
                              Obx(() => Image.asset(
                                    controller.sortType == ''
                                        ? AppImages.ic_sortNone
                                        : controller.sortType == 'asc'
                                            ? AppImages.ic_sortUp
                                            : AppImages.ic_sortDown,
                                    width: 40.w,
                                    height: 40.h,
                                    color: AppColors.white,
                                  ))
                            ],
                          ),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 15,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border: Border(
                                bottom: BorderSide(
                                    color: AppColors.black, width: 2.0),
                                top: BorderSide(
                                    color: AppColors.black, width: 2.0))),
                        child: Text(
                          AppStrings.Res,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                              textStyle: TextStyle(color: AppColors.white)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 6,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border:
                                Border.all(color: AppColors.black, width: 2.0)),
                        child: Text(
                          AppStrings.trsItem,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                              textStyle: TextStyle(color: AppColors.white)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 5.69,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border: Border(
                                bottom: BorderSide(
                                    color: AppColors.black, width: 2.0),
                                top: BorderSide(
                                    color: AppColors.black, width: 2.0))),
                        child: Text(
                          AppStrings.trsSupplier,
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          style: GoogleFonts.poppins(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                              textStyle: TextStyle(color: AppColors.white)),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width / 6,
                        padding: EdgeInsets.symmetric(
                            vertical: 15.h, horizontal: 15.w),
                        decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border:
                                Border.all(color: AppColors.black, width: 2.0)),
                        child: Text(
                          AppStrings.trsDefectType,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                              textStyle: TextStyle(color: AppColors.white)),
                        ),
                      )
                    ],
                  ),
                  listViewData(controller) // Table's All Columnns Row Data
                ],
              ),
            ),
          ),
        ),
        customButton(
            AppColors.primary,
            AppStrings.inspectNewProduct.toUpperCase(),
            520.w,
            125,
            GoogleFonts.poppins(
                fontSize: 38.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.white)),
            onClickAction: () {
          return Get.to(() => SelectCarrierScreen());
        }),
        SizedBox(
          height: 35.h,
        ),
        FooterContentView(
          hasLeftButton: false,
        )
      ],
    );
  }

  Widget listViewData(HomeController controller) {
    return Expanded(
      child: GetBuilder<HomeController>(
        id: 'inspectionsList',
        builder: (controller) {
          return ListView.builder(
            itemCount: controller.listOfInspection.length,
            physics: ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              return IntrinsicHeight(
                child: Row(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 10.2,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                          color: position % 2 == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          border: Border(
                              right: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ),
                              left: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ),
                              bottom: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ))),
                      child: Text(
                        controller.listOfInspection[position]['ID'] ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 7.25,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                          color: position % 2 == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          border: Border(
                              right: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ),
                              bottom: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ))),
                      child: Text(
                        controller.listOfInspection[position]['PO'] ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 6.9,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                          color: position % 2 == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          border: Border(
                              right: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ),
                              bottom: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ))),
                      child: Text(
                        controller.listOfInspection[position]['Item'] ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 14.5,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                          color: position % 2 == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          border: Border(
                              right: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ),
                              bottom: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ))),
                      child: Text(
                          controller.listOfInspection[position]['Res'] ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800)),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 6.1,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      decoration: BoxDecoration(
                          color: position % 2 == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          border: Border(
                              right: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ),
                              bottom: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ))),
                      child: Text(
                        controller.listOfInspection[position]['GR'] ?? '',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.displayMedium,
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        if (controller.expandContents.contains(
                            controller.listOfInspection[position]['ID'] ??
                                '')) {
                          controller.expandContents.remove(
                              controller.listOfInspection[position]['ID'] ??
                                  '');
                        } else {
                          controller.expandContents.add(
                              controller.listOfInspection[position]['ID'] ??
                                  '');
                        }
                      },
                      child: Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 5.61,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
                            color: position % 2 == 0
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.secondary,
                            border: Border(
                                right: BorderSide(
                                  color: AppColors.black,
                                  width: 2.0,
                                ),
                                bottom: BorderSide(
                                  color: AppColors.black,
                                  width: 2.0,
                                ))),
                        child: Obx(
                          () => Text(
                            controller.listOfInspection[position]['Supplier'] ??
                                '',
                            textAlign: TextAlign.center,
                            overflow: controller.expandContents.contains(
                                    controller.listOfInspection[position]
                                            ['ID'] ??
                                        '')
                                ? TextOverflow.visible
                                : TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width / 6.1,
                      padding: EdgeInsets.symmetric(
                          vertical: 15.h, horizontal: 15.w),
                      decoration: BoxDecoration(
                          color: position % 2 == 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.secondary,
                          border: Border(
                              right: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ),
                              bottom: BorderSide(
                                color: AppColors.black,
                                width: 2.0,
                              ))),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            controller.listOfInspection[position]['Status'] ??
                                '',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w800),
                          ),
                          InkWell(
                            onTap: () {
                              controller.selectInspectionForDownload(
                                  controller.listOfInspection[position]['ID'] ??
                                      '',
                                  false);
                            },
                            child: Obx(() => Image.asset(
                                  controller.selectedIDsInspection.contains(
                                          controller.listOfInspection[position]
                                                  ['ID'] ??
                                              '')
                                      ? AppImages.ic_SelectedCheckbox
                                      : AppImages.ic_unSelectCheckbox,
                                  width: 60.w,
                                  height: 60.h,
                                  color: AppColors.white,
                                )),
                          )
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  // TOP BANNER'S VIEW UI

  Widget bannersView(HomeController controller) {
    return Column(
      children: [
        Container(
          height: 800.h,
          decoration: BoxDecoration(
              border: Border.all(width: 3, color: AppColors.black)),
          child: PageView.builder(
            controller: controller.pageController,
            itemCount: controller.bannerImages.length,
            onPageChanged: (value) {
              controller.bannersCurrentPage.value = value;
            },
            itemBuilder: (context, index) {
              return Image.asset(
                controller.bannerImages[index],
                fit: BoxFit.cover,
              );
            },
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: _buildPageIndicator(controller),
        ),
      ],
    );
  }

  List<Widget> _buildPageIndicator(HomeController controller) {
    List<Widget> indicators = [];
    for (int i = 0; i < controller.bannerImages.length; i++) {
      indicators.add(
        Obx(() => Container(
              width: 25.w,
              height: 25.h,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: controller.bannersCurrentPage == i
                    ? AppColors.primary
                    : AppColors.brightGrey,
              ),
            )),
      );
    }
    return indicators;
  }
}
