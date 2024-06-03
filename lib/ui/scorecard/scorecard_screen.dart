import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/scorecard_screen_controller.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class ScorecardScreen extends GetWidget<ScorecardScreenController> {
  final PartnerItem partner;
  const ScorecardScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ScorecardScreenController>(
      init: ScorecardScreenController(partner),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          body: _widgetBody(controller: controller, context: context),
        );
      },
    );
  }
}

Widget _widgetBody({
  required ScorecardScreenController controller,
  required BuildContext context,
}) {
  return Column(
    children: <Widget>[
      HeaderContentView(
        title: controller.partner.name ?? '-',
      ),
      Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 50),
          child: SizedBox(
            width: ResponsiveHelper.getDeviceWidth(context),
            child: Column(
              children: [
                _widgetPercentageHeader(
                  context: context,
                  controller: controller,
                ),
                const SizedBox(height: 30),
                _widgetTableHeader(
                  context,
                  controller: controller,
                ),
                _widgetListViewData(context, controller: controller)
              ],
            ),
          ),
        ),
      ),
      FooterContentView()
    ],
  );
}

Widget _widgetPercentageHeader(
    {required BuildContext context,
    required ScorecardScreenController controller}) {
  return SizedBox(
    height: 115.h,
    child: IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          //Green Percentage
          _widgetPercentageContainer(
            context,
            percentageValue: "${controller.greenPercentage}%",
            containerColor: AppColors.greenButtonColor,
          ),
          //Yellow Percentage
          _widgetPercentageContainer(
            context,
            percentageValue: "${controller.yellowPercentage}%",
            containerColor: AppColors.yellow,
          ),
          //Orange Percentage
          _widgetPercentageContainer(
            context,
            percentageValue: "${controller.orangePercentage}%",
            containerColor: AppColors.orange,
          ),
          //Red Percentage
          _widgetPercentageContainer(
            context,
            percentageValue: "${controller.redPercentage}%",
            containerColor: AppColors.red,
          ),
        ],
      ),
    ),
  );
}

Widget _widgetPercentageContainer(
  BuildContext context, {
  required String percentageValue,
  required Color containerColor,
}) {
  return Container(
    alignment: Alignment.center,
    width: (MediaQuery.of(context).size.width / 4.6),
    padding: EdgeInsets.symmetric(vertical: 15.h),
    decoration: BoxDecoration(
      color: containerColor,
    ),
    child: Text(
      percentageValue,
      textAlign: TextAlign.center,
      style: Get.textTheme.titleLarge!.copyWith(
        color: AppColors.black,
        fontSize: 25,
        fontWeight: FontWeight.bold,
      ),
    ),
  );
}

Widget _widgetTableHeader(
  BuildContext context, {
  required ScorecardScreenController controller,
}) {
  return Container(
    decoration: const BoxDecoration(
      color: Colors.black45,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _divider(false),
        Expanded(
          flex: 2,
          child: HeaderCell(
            title: AppStrings.cssDate,
            onTapped: () {
              controller.sortByDate();
            },
            shortType: controller.dateSort,
            isShowIcon: controller.isShowDateIcon,
          ),
        ),
        _divider(true),
        Expanded(
          flex: 2,
          child: HeaderCell(
            title: AppStrings.cssCommodity,
            onTapped: () {
              controller.sortByCommodity();
            },
            shortType: controller.commoditySort,
            isShowIcon: controller.isShowCommodityIcon,
          ),
        ),
        _divider(true),
        Expanded(
          flex: 2,
          child: HeaderCell(
            title: AppStrings.cssResult,
            onTapped: () {
              controller.sortByResult();
            },
            shortType: controller.resultSort,
            isShowIcon: controller.isResultIcon,
          ),
        ),
        _divider(true),
        Expanded(
          flex: 2,
          child: HeaderCell(
            title: AppStrings.cssReason,
            onTapped: () {
              // controller.sortByReason();
            },
            shortType: controller.reasonSort,
            isShowIcon: controller.isReasonIcon,
          ),
        ),
        _divider(false),
      ],
    ),
  );
}

Widget _widgetListViewData(BuildContext context,
    {required ScorecardScreenController controller}) {
  return Expanded(
    child: Obx(
      () {
        if (controller.isLoading.value) {
          return const Padding(
            padding: EdgeInsets.only(top: 150),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
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
        } else {
          return GetBuilder<ScorecardScreenController>(
              id: "scoreboardItemList",
              builder: (controller) {
                return ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: controller.itemsList?.length ?? 0,
                    itemBuilder: (context, index) {
                      var lastInspectionItem = controller.itemsList?[index];
                      var dateTime = DateTime.fromMillisecondsSinceEpoch(
                          lastInspectionItem!.createdDate!);
                      var createdDate = Utils().dateFormat.format(dateTime);
                      Color backgroundColor = index.isOdd
                          ? AppColors.scoreCardRowColor
                          : const Color(0xFF424242);
                      Color textColor =
                          index.isEven ? AppColors.white : AppColors.black;
                      return Container(
                        decoration: BoxDecoration(
                          color: Color(backgroundColor.value),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _divider(false),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  createdDate,
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22.sp,
                                  ),
                                ),
                              ),
                            ),
                            _divider(true),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  lastInspectionItem.commodityName ?? '-',
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22.sp,
                                  ),
                                ),
                              ),
                            ),
                            _divider(true),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  lastInspectionItem.inspectionResult ?? '-',
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22.sp,
                                  ),
                                ),
                              ),
                            ),
                            _divider(true),
                            Expanded(
                              flex: 2,
                              child: Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  lastInspectionItem.inspectionReason ?? '',
                                  style: Get.textTheme.bodyMedium?.copyWith(
                                    color: textColor,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22.sp,
                                  ),
                                ),
                              ),
                            ),
                            _divider(false),
                          ],
                        ),
                      );
                    });
              });
        }
      },
    ),
  );
}

Container _divider(bool isHorizontalAlign) {
  return Container(
    color: AppColors.background,
    width: 2,
    height: 110.h,
    margin: EdgeInsets.symmetric(horizontal: isHorizontalAlign ? 5 : 0),
  );
}

class HeaderCell extends GetWidget<ScorecardScreenController> {
  final String title;
  final Function() onTapped;
  final dynamic shortType;
  final RxBool isShowIcon;
  const HeaderCell({
    super.key,
    required this.title,
    required this.onTapped,
    required this.shortType,
    required this.isShowIcon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Padding(
        padding: EdgeInsets.all(8.0.sp),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: Get.textTheme.titleLarge!.copyWith(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Obx(() {
              return Image.asset(
                isShowIcon.value ? AppImages.ic_sortUp : AppImages.ic_sortDown,
                width: 40.w,
                height: 40.h,
                color: AppColors.white,
              );
            }),
          ],
        ),
      ),
    );
  }
}
