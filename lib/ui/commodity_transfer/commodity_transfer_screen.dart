import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/commodity_transfer_screen_controller.dart';
import 'package:pverify/models/commodity_data.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class CommodityTransferScreen
    extends GetWidget<CommodityTransferScreenController> {
  const CommodityTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommodityTransferScreenController>(
      init: CommodityTransferScreenController(),
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
              title: AppStrings.selectCommodity,
            ),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                color: AppColors.textFieldText_Color,
                width: double.infinity,
                child: Text(
                  "${controller.partnerName} > ${controller.carrierName}",
                  textAlign: TextAlign.start,
                  maxLines: 3,
                  style: Get.textTheme.titleLarge!.copyWith(
                    fontSize: 38.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const _SearchGradingStandardWidget(),
              Expanded(flex: 10, child: _commodityListSection(context)),
              FooterContentView(
                  // onDownloadTap: () {
                  //   controller.onDownloadTap();
                  // },
                  )
            ],
          ),
        );
      },
    );
  }
}

GetBuilder<CommodityTransferScreenController> _commodityListSection(
    BuildContext context) {
  return GetBuilder<CommodityTransferScreenController>(
    id: 'commodityList',
    builder: (controller) {
      List<String> alphabets = controller.getListOfAlphabets();
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 20.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            controller.listAssigned.value
                ? Expanded(
                    flex: 10,
                    child: controller.filteredCommodityList.isNotEmpty
                        ? commodityListView(context, controller)
                        : noDataFoundWidget(),
                  )
                : const Center(
                    child: SizedBox(
                        height: 25, width: 25, child: ProgressAdaptive())),
            if (controller.listAssigned.value && alphabets.isNotEmpty)
              Flexible(
                flex: 0,
                child: listAlphabetsWidget(controller, alphabets, context),
              )
            else
              const Offstage(),
          ],
        ),
      );
    },
  );
}

Widget listAlphabetsWidget(
  CommodityTransferScreenController controller,
  List<String> alphabets,
  BuildContext context,
) {
  return Container(
    alignment: Alignment.center,
    width: 60.sp,
    // padding: const EdgeInsets.symmetric(vertical: 10),
    child: GestureDetector(
      onVerticalDragUpdate: (details) {
        int index = _calculateIndexFromDragPosition(
            details.localPosition.dy, alphabets.length, context);
        if (index >= 0 && index < alphabets.length) {
          String letter = alphabets[index];
          controller.scrollToSection(letter, index);
        }
      },
      child: ListView.builder(
        itemCount: alphabets.length,
        shrinkWrap: false,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          String letter = alphabets.elementAt(index);
          return SizedBox(
            height: MediaQuery.of(context).size.height * .70 / alphabets.length,
            child: GestureDetector(
              onTap: () {
                controller.scrollToSection(letter, index);
              },
              child: SizedBox(
                height: 20,
                child: Text(
                  letter,
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontSize: 60.h,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      ),
    ),
  );
}

Center noDataFoundWidget() {
  return Center(
    child: Text(
      'No data found',
      style: Get.textTheme.titleLarge?.copyWith(),
    ),
  );
}

Widget commodityListView(
    BuildContext context, CommodityTransferScreenController controller) {
  return ListView.separated(
    controller: controller.scrollController,
    itemCount: controller.filteredCommodityList.length,
    itemBuilder: (context, index) {
      Commodity partner = controller.filteredCommodityList.elementAt(index);
      return GestureDetector(
        onTap: () {
          controller.navigateToPurchaseOrderScreen(partner);
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 25.h),
          child: Column(
            children: [
              getAlphabetContent(controller.filteredCommodityList, index),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 20.h),
                height: controller.listHeight,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            partner.keywordName ?? '-',
                            style: Get.textTheme.titleLarge?.copyWith(
                              fontSize: 50.h,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
    separatorBuilder: (BuildContext context, int index) {
      return Divider(
        height: 5,
        indent: 10,
        endIndent: 10,
        color: AppColors.white,
        thickness: 0.15,
      );
    },
  );
}

int _calculateIndexFromDragPosition(
    double dragPosition, int itemCount, BuildContext context) {
  double totalHeight = MediaQuery.of(context).size.height * .70;
  double itemHeight = totalHeight / itemCount;
  int index = (dragPosition / itemHeight).floor();
  return index;
}

Widget getAlphabetContent(List<Commodity> allCommodities, int index) {
  String alphabet = '';
  Commodity itemData = allCommodities[index];

  if (allCommodities.isNotEmpty && index == 0) {
    alphabet = allCommodities.first.keywordName![0];
  } else if (itemData.keywordName![0] !=
      allCommodities.elementAt(index - 1).keywordName![0]) {
    alphabet = itemData.keywordName![0];
  }

  if (alphabet.isNotEmpty) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10.h),
          Align(
            alignment: Alignment.topLeft,
            child: Text(
              alphabet,
              style: Get.textTheme.titleLarge?.copyWith(
                fontSize: 60.h,
              ),
              textAlign: TextAlign.start,
            ),
          ),
          Divider(
            height: 10,
            indent: 0,
            endIndent: 0,
            color: AppColors.white,
            thickness: 0.9,
          )
        ],
      ),
    );
  } else {
    return Container();
  }
}

class _SearchGradingStandardWidget extends StatelessWidget {
  const _SearchGradingStandardWidget();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommodityTransferScreenController>(
        id: 'commodityList',
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
              child: TextField(
                onChanged: (value) {
                  Get.find<CommodityTransferScreenController>()
                      .searchAndAssignCommodity(value);
                },
                controller: Get.find<CommodityTransferScreenController>()
                    .searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchCommodity,
                  hintStyle: Get.textTheme.titleLarge?.copyWith(
                    fontSize: 25.sp,
                    color: AppColors.white.withOpacity(0.8),
                  ),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.white,
                    size: 24,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: AppColors.white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: AppColors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide(color: AppColors.white),
                  ),
                  suffixIcon: Get.find<CommodityTransferScreenController>()
                          .searchController
                          .text
                          .trim()
                          .isEmpty
                      ? const Offstage()
                      : IconButton(
                          onPressed: () {
                            Get.find<CommodityTransferScreenController>()
                                .clearSearch();
                          },
                          icon: Icon(
                            Icons.clear,
                            color: AppColors.white,
                          ),
                        ),
                ),
              ),
            ),
          );
        });
  }
}
