import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/home_controller.dart';
import 'package:pverify/ui/carrier/choose_carrier.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class Home extends GetView<HomeController> {
  final String tag;
  const Home({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: HomeController(),
        tag: tag,
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
              child: contentView(context, controller),
            ),
          );
        });
  }

  Widget contentView(BuildContext context, HomeController controller) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.all(35.h),
            child: SizedBox(
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
                              style: Get.textTheme.titleLarge!.copyWith(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              log("Upload Button tapped");
                              controller
                                  .onUploadAllInspectionButtonClick(context);
                            },
                            child: Container(
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
                                padding:
                                    const EdgeInsets.only(left: 25, right: 25),
                                child: Container(
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius:
                                          BorderRadius.circular(20.0)),
                                  child: Text(
                                    AppStrings.upload,
                                    textAlign: TextAlign.center,
                                    style: Get.textTheme.titleLarge!.copyWith(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  AppStrings.trsCompleteAll,
                                  textAlign: TextAlign.center,
                                  style: Get.textTheme.titleLarge!.copyWith(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    controller.selectInspectionForDownload(
                                        0, true);
                                  },
                                  child: Obx(() => Container(
                                        color: AppColors.primary,
                                        padding: const EdgeInsets.all(5),
                                        child: Image.asset(
                                          controller.completeAllCheckbox.value
                                              ? AppImages.ic_SelectedCheckbox
                                              : AppImages.ic_unSelectCheckbox,
                                          width: 60.w,
                                          height: 60.h,
                                          color: AppColors.white,
                                        ),
                                      )),
                                ),
                              ],
                            ),
                          )
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
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                          style: Get.textTheme.titleLarge!.copyWith(
                              fontSize: 30.sp,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          controller.sortArrayItem();
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width / 6.8,
                          padding: EdgeInsets.symmetric(vertical: 15.h),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            border:
                                Border.all(color: AppColors.black, width: 2.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                AppStrings.trsItemNo,
                                textAlign: TextAlign.center,
                                style: Get.textTheme.titleLarge!.copyWith(
                                  fontSize: 30.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 3),
                              Obx(() {
                                return Image.asset(
                                  controller.sortType.value == 'asc'
                                      ? AppImages.ic_sortUp
                                      : AppImages.ic_sortDown,
                                  width: 40.w,
                                  height: 40.h,
                                  color: AppColors.white,
                                );
                              }),
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
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () async {
                await Get.to(() => const SelectCarrierScreen());
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 15.h, horizontal: 25.w),
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(45.r)),
                child: Text(
                  textAlign: TextAlign.center,
                  AppStrings.inspectNewProduct.toUpperCase(),
                  style: Get.textTheme.titleLarge!.copyWith(
                    fontSize: 38.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
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
        tag: tag,
        builder: (controller) {
          return ListView.builder(
            itemCount: controller.myInsp48HourList.length,
            physics: const ClampingScrollPhysics(),
            itemBuilder: (context, position) {
              var myInspectionList = controller.myInsp48HourList[position];
              return GestureDetector(
                onTap: () {
                  controller.onItemTap(position);
                },
                child: IntrinsicHeight(
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
                          "${myInspectionList.id}",
                          textAlign: TextAlign.center,
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                          "${myInspectionList.poNumber}",
                          textAlign: TextAlign.center,
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                          "${myInspectionList.itemSKU}",
                          textAlign: TextAlign.center,
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
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
                          myInspectionList.result ?? "",
                          textAlign: TextAlign.center,
                          style: Get.textTheme.titleLarge!.copyWith(
                            color: controller
                                .getResultTextColor(myInspectionList.result),
                            fontSize: 30.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
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
                          "${myInspectionList.commodityName}",
                          textAlign: TextAlign.center,
                          style: Get.textTheme.titleLarge!.copyWith(
                            fontSize: 30.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (controller.expandContents
                              .contains(controller.itemsList[position].id)) {
                            controller.expandContents
                                .remove(controller.itemsList[position].id);
                          } else {
                            controller.expandContents
                                .add(controller.itemsList[position].id);
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
                              ),
                            ),
                          ),
                          child: Obx(
                            () => Text(
                              controller.itemsList[position].partnerName ?? '',
                              textAlign: TextAlign.center,
                              overflow: controller.expandContents.contains(
                                      controller.itemsList[position].id)
                                  ? TextOverflow.visible
                                  : TextOverflow.ellipsis,
                              style: Get.textTheme.titleLarge!.copyWith(
                                fontSize: 30.sp,
                                fontWeight: FontWeight.w600,
                              ),
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
                            ),
                          ),
                        ),
                        child: myInspectionList.uploadStatus == 1
                            ? Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    "Done",
                                    textAlign: TextAlign.center,
                                    style: Get.textTheme.titleLarge!.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  InkWell(
                                    onTap: () {
                                      controller.selectInspectionForDownload(
                                          myInspectionList.id!, false);
                                    },
                                    child: Obx(() => Image.asset(
                                          controller.selectedIDsInspection
                                                  .contains(myInspectionList)
                                              ? AppImages.ic_SelectedCheckbox
                                              : AppImages.ic_unSelectCheckbox,
                                          width: 60.w,
                                          height: 60.h,
                                          color: AppColors.white,
                                        )),
                                  ),
                                ],
                              )
                            : Row(
                                children: [
                                  Text(
                                    "WIP",
                                    style: Get.textTheme.titleLarge!.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 30.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                      )
                    ],
                  ),
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
        const SizedBox(
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
              margin: const EdgeInsets.symmetric(horizontal: 5),
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
