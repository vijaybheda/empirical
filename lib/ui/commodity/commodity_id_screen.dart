import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/commodity_id_screen_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class CommodityIDScreen extends GetWidget<CommodityIDScreenController> {
  final PartnerItem partner;
  final CarrierItem carrier;
  final QCHeaderDetails? qcHeaderDetails;
  const CommodityIDScreen({
    super.key,
    required this.partner,
    required this.carrier,
    required this.qcHeaderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommodityIDScreenController>(
        init: CommodityIDScreenController(
            partner: partner,
            carrier: carrier,
            qcHeaderDetails: qcHeaderDetails),
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
                    "${partner.name ?? '-'} > ${carrier.name ?? '-'}",
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    style: GoogleFonts.poppins(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w600,
                        textStyle: TextStyle(color: AppColors.white)),
                  ),
                ),
                const _SearchGradingStandardWidget(),
                Expanded(flex: 10, child: _commodityListSection(context)),
                FooterContentView(
                  onDownloadTap: () {
                    controller.onDownloadTap();
                  },
                )
              ],
            ),
          );
        });
  }

  GetBuilder<CommodityIDScreenController> _commodityListSection(
      BuildContext context) {
    return GetBuilder<CommodityIDScreenController>(
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
    CommodityIDScreenController controller,
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
              height:
                  MediaQuery.of(context).size.height * .70 / alphabets.length,
              child: GestureDetector(
                onTap: () {
                  controller.scrollToSection(letter, index);
                },
                child: SizedBox(
                  height: 20,
                  child: Text(
                    letter,
                    style: Get.textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                        fontSize: 60.h,
                        fontWeight: FontWeight.bold),
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
        style: Get.textTheme.displayMedium?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget commodityListView(
      BuildContext context, CommodityIDScreenController controller) {
    return ListView.separated(
      controller: controller.scrollController,
      itemCount: controller.filteredCommodityList.length,
      itemBuilder: (context, index) {
        CommodityItem partner =
            controller.filteredCommodityList.elementAt(index);
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
                              partner.name ?? '-',
                              style: Get.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.white, fontSize: 50.h),
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

  Widget getAlphabetContent(List<CommodityItem> allCommodities, int index) {
    String alphabet = '';
    CommodityItem itemData = allCommodities[index];

    if (allCommodities.isNotEmpty && index == 0) {
      alphabet = allCommodities.first.name![0];
    } else if (itemData.name![0] !=
        allCommodities.elementAt(index - 1).name![0]) {
      alphabet = itemData.name![0];
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
                style: Get.textTheme.headlineMedium?.copyWith(
                  color: AppColors.white,
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
}

class _SearchGradingStandardWidget extends StatelessWidget {
  const _SearchGradingStandardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommodityIDScreenController>(
        id: 'commodityList',
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
              child: TextField(
                onChanged: (value) {
                  Get.find<CommodityIDScreenController>()
                      .searchAndAssignCommodity(value);
                },
                controller:
                    Get.find<CommodityIDScreenController>().searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchCommodity,
                  hintStyle: Get.textTheme.bodyLarge?.copyWith(
                      fontSize: 25.sp, color: AppColors.white.withOpacity(0.5)),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
                  prefixIcon: Icon(Icons.search, color: AppColors.white),
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
                  suffixIcon: Get.find<CommodityIDScreenController>()
                          .searchController
                          .text
                          .trim()
                          .isEmpty
                      ? const Offstage()
                      : IconButton(
                          onPressed: () {
                            Get.find<CommodityIDScreenController>()
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
