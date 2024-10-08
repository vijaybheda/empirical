import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/select_carrier_screen_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class SelectCarrierScreen extends GetWidget<SelectCarrierScreenController> {
  const SelectCarrierScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectCarrierScreenController>(
        init: SelectCarrierScreenController(),
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
                title: AppStrings.selectCarrier,
                isVersionShow: false,
              ),
            ),
            body: Column(
              children: [
                const SearchCarrierWidget(),
                Expanded(flex: 10, child: _carrierListSection(context)),
                FooterContentView(),
              ],
            ),
          );
        });
  }

  GetBuilder<SelectCarrierScreenController> _carrierListSection(
      BuildContext context) {
    return GetBuilder<SelectCarrierScreenController>(
      id: 'carrierList',
      builder: (controller) {
        List<String> alphabets = controller.getListOfAlphabets();
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              controller.listAssigned.value
                  ? Expanded(
                      flex: 10,
                      child: controller.filteredCarrierList.isNotEmpty
                          ? carrierListView(controller, alphabets, context)
                          : noDataFoundWidget(),
                    )
                  : const Center(
                      child: SizedBox(
                          height: 25, width: 25, child: ProgressAdaptive())),
              if (controller.listAssigned.value && alphabets.isNotEmpty)
                Flexible(
                  flex: 0,
                  child: listAlphabetsWidget(controller, alphabets),
                )
              else
                const Offstage(),
            ],
          ),
        );
      },
    );
  }

  Container listAlphabetsWidget(
    SelectCarrierScreenController controller,
    List<String> alphabets,
  ) {
    return Container(
      alignment: Alignment.center,
      width: 60.sp,
      // padding: const EdgeInsets.symmetric(vertical: 10),
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
                  style: Get.textTheme.titleLarge!.copyWith(
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
    );
  }

  Center noDataFoundWidget() {
    return Center(
      child: Text(
        'No data found',
        style: Get.textTheme.titleLarge!.copyWith(),
      ),
    );
  }

  Widget carrierListView(SelectCarrierScreenController controller,
      List<String> alphabets, BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        int index = _calculateIndexFromDragPosition(
            details.localPosition.dy, alphabets.length, context);
        if (index >= 0 && index < alphabets.length) {
          String letter = alphabets[index];
          controller.scrollToSection(letter, index);
        }
      },
      child: ListView.builder(
        controller: controller.scrollController,
        itemCount: controller.filteredCarrierList.length,
        itemBuilder: (context, index) {
          CarrierItem carrier = controller.filteredCarrierList.elementAt(index);
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                getAlphabetContent(controller.filteredCarrierList, index),
                InkWell(
                  onTap: () {
                    controller.navigateToQcHeader(carrier);
                  },
                  highlightColor: Colors.transparent,
                  child: SizedBox(
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
                                carrier.name ?? '-',
                                style: Get.textTheme.titleLarge!.copyWith(
                                  fontSize: 45.h,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                // controller.navigateToCarrierDetails(carrier);
                              },
                              child: SizedBox(
                                width: 100,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  mainAxisSize: MainAxisSize.max,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if ((carrier.greenPercentage ?? 0) != 0)
                                      _buildBar(Colors.green,
                                          carrier.greenPercentage ?? 0),
                                    if ((carrier.yellowPercentage ?? 0) != 0)
                                      _buildBar(Colors.yellow,
                                          carrier.yellowPercentage ?? 0),
                                    if ((carrier.orangePercentage ?? 0) != 0)
                                      _buildBar(Colors.orange,
                                          carrier.orangePercentage ?? 0),
                                    if ((carrier.redPercentage ?? 0) != 0)
                                      _buildBar(Colors.red,
                                          carrier.redPercentage ?? 0),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBar(Color color, double percentage) {
    return Container(
      width: 100,
      height: 20,
      alignment: Alignment.topRight,
      child: FractionallySizedBox(
        widthFactor: (percentage / 100),
        child: Container(
          color: color,
        ),
      ),
    );
  }

  Widget getAlphabetContent(List<CarrierItem> allCarriers, int index) {
    String alphabet = '';
    CarrierItem itemData = allCarriers[index];

    if (allCarriers.isNotEmpty && index == 0) {
      alphabet = allCarriers.first.name![0];
    } else if (itemData.name![0] != allCarriers.elementAt(index - 1).name![0]) {
      alphabet = itemData.name![0];
    }

    if (alphabet.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alphabet,
            style: Get.textTheme.titleLarge!.copyWith(
              fontSize: 60.h,
              fontWeight: FontWeight.bold,
            ),
          ),
          Divider(
            height: 10,
            indent: 0,
            endIndent: 0,
            color: AppColors.white,
            thickness: 1,
          )
        ],
      );
    } else {
      return Container();
    }
  }

  int _calculateIndexFromDragPosition(
      double dragPosition, int itemCount, BuildContext context) {
    double totalHeight = MediaQuery.of(context).size.height * .70;
    double itemHeight = totalHeight / itemCount;
    int index = (dragPosition / itemHeight).floor();
    return index;
  }
}

class SearchCarrierWidget extends StatelessWidget {
  const SearchCarrierWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectCarrierScreenController>(
        id: 'carrierList',
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
            child: TextField(
              onChanged: (value) {
                Get.find<SelectCarrierScreenController>()
                    .searchAndAssignCarrier(value);
              },
              controller:
                  Get.find<SelectCarrierScreenController>().searchController,
              decoration: InputDecoration(
                hintText: AppStrings.searchCarrier,
                hintStyle: Get.textTheme.titleLarge?.copyWith(
                    fontSize: 25.sp, color: AppColors.white.withOpacity(0.8)),
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
                suffixIcon: Get.find<SelectCarrierScreenController>()
                        .searchController
                        .text
                        .trim()
                        .isEmpty
                    ? const Offstage()
                    : IconButton(
                        onPressed: () {
                          Get.find<SelectCarrierScreenController>()
                              .clearSearch();
                        },
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.white,
                        ),
                      ),
              ),
            ),
          );
        });
  }
}
