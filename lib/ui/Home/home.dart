// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, non_constant_identifier_names, avoid_types_as_parameter_names, must_be_immutable, avoid_unnecessary_containers, unrelated_type_equality_checks, unused_element, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/ui/Home/home_controller.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/alert.dart';
import 'package:pverify/utils/common_widget/buttons.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class Home extends GetView<HomeController> {
  Home({super.key});
  HomeController Controller = HomeController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        builder: (HomeController) {
          return Scaffold(
            backgroundColor: AppColors.white,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              toolbarHeight: 150.h,
              backgroundColor: AppColors.primary,
              title: baseHeaderView(AppStrings.home, false),
            ),
            body: Container(
                color: Theme.of(context).colorScheme.background,
                child: contentView(context)),
          );
        });
  }

  Widget contentView(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(35.h),
            child: Container(
              width: ResponsiveHelper.getDeviceWidth(context),
              child: Column(
                children: [
                  bannersView(),
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
                                    Controller.selectInspectionForDownload(
                                        'id', true);
                                  },
                                  child: Container(
                                    color: AppColors.primary,
                                    padding: EdgeInsets.all(5),
                                    child: Obx(() => Image.asset(
                                          Controller.selectedIDsInspection
                                                      .length ==
                                                  Controller
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
                          Controller.sortArray_Item();
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
                                    Controller.sortType == ''
                                        ? AppImages.ic_sortNone
                                        : Controller.sortType == 'asc'
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
                  listViewData() // Table's All Columnns Row Data
                ],
              ),
            ),
          ),
        ),
        customButton(
            AppColors.primary,
            AppStrings.inspectNewProduct.toUpperCase(),
            320,
            125,
            GoogleFonts.poppins(
                fontSize: 38.sp,
                fontWeight: FontWeight.w600,
                textStyle: TextStyle(color: AppColors.white)),
            onClickAction: () => {Get.to(QualityControlHeader())}),
        SizedBox(
          height: 35.h,
        ),
        bottomContent(context)
      ],
    );
  }

  Widget listViewData() {
    return Expanded(
      child: Obx(() => ListView.builder(
            itemCount: Controller.listOfInspection.length,
            itemBuilder: (context, position) {
              return Container(
                color: position % 2 == 0
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.secondary,
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 10.2,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
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
                          Controller.listOfInspection[position]['ID'] ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 7.25,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
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
                          Controller.listOfInspection[position]['PO'] ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 6.9,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
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
                          Controller.listOfInspection[position]['Item'] ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width / 14.5,
                        padding: EdgeInsets.symmetric(vertical: 15.h),
                        decoration: BoxDecoration(
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
                            Controller.listOfInspection[position]['Res'] ?? '',
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
                          Controller.listOfInspection[position]['GR'] ?? '',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displayMedium,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (Controller.expandContents.contains(
                              Controller.listOfInspection[position]['ID'] ??
                                  '')) {
                            Controller.expandContents.remove(
                                Controller.listOfInspection[position]['ID'] ??
                                    '');
                          } else {
                            Controller.expandContents.add(
                                Controller.listOfInspection[position]['ID'] ??
                                    '');
                          }
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width: MediaQuery.of(context).size.width / 5.61,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(
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
                              Controller.listOfInspection[position]
                                      ['Supplier'] ??
                                  '',
                              textAlign: TextAlign.center,
                              overflow: Controller.expandContents.contains(
                                      Controller.listOfInspection[position]
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
                              Controller.listOfInspection[position]['Status'] ??
                                  '',
                              textAlign: TextAlign.center,
                              style: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(color: AppColors.primary,
                                  fontWeight: FontWeight.w800),
                            ),
                            InkWell(
                              onTap: () {
                                Controller.selectInspectionForDownload(
                                    Controller.listOfInspection[position]
                                            ['ID'] ??
                                        '',
                                    false);
                              },
                              child: Obx(() => Image.asset(
                                    Controller.selectedIDsInspection.contains(
                                            Controller.listOfInspection[
                                                    position]['ID'] ??
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
                ),
              );
            },
          )),
    );
  }

  // TOP BANNER'S VIEW UI

  Widget bannersView() {
    return Column(
      children: [
        Container(
          height: 800.h,
          decoration: BoxDecoration(
              border: Border.all(width: 3, color: AppColors.black)),
          child: PageView.builder(
            controller: Controller.pageController,
            itemCount: Controller.bannerImages.length,
            onPageChanged: (value) {
              Controller.bannersCurrentPage.value = value;
            },
            itemBuilder: (context, index) {
              return Image.asset(
                Controller.bannerImages[index],
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
          children: _buildPageIndicator(),
        ),
      ],
    );
  }

  List<Widget> _buildPageIndicator() {
    List<Widget> indicators = [];
    for (int i = 0; i < controller.bannerImages.length; i++) {
      indicators.add(
        Obx(() => Container(
              width: 25.w,
              height: 25.h,
              margin: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Controller.bannersCurrentPage == i
                    ? AppColors.primary
                    : AppColors.brightGrey,
              ),
            )),
      );
    }
    return indicators;
  }

  // BOTTOM VIEW

  Widget bottomContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 15, right: 15),
      height: 120.h,
      color: AppColors.primary,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),
          Text(
            AppStrings.data0DaysOld,
            style: GoogleFonts.poppins(
                fontSize: 40.sp,
                fontWeight: FontWeight.bold,
                textStyle: TextStyle(color: AppColors.white)),
          ),
          SizedBox(
            width: 40.w,
          ),
          InkWell(
            onTap: () {
              debugPrint('Download button tap.');
            },
            child: Image.asset(
              AppImages.ic_download,
              width: 80.w,
              height: 80.h,
            ),
          ),
          const Spacer(),
          InkWell(
            onTap: () {
              showLogoutConfirmation(context);
            },
            child: Text(
              AppStrings.logOut,
              style: GoogleFonts.poppins(
                  fontSize: 35.sp,
                  fontWeight: FontWeight.bold,
                  textStyle: TextStyle(color: AppColors.textFieldText_Color)),
            ),
          )
        ],
      ),
    );
  }
}
