import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/select_supplier_screen_controller.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class SelectSupplierScreen extends GetWidget<SelectSupplierScreenController> {
  // final CarrierItem carrier;
  // final QCHeaderDetails? qcHeaderDetails;
  const SelectSupplierScreen({
    super.key,
    // required this.carrier,
    // this.qcHeaderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectSupplierScreenController>(
        init: SelectSupplierScreenController(
            /*carrier: carrier, qcHeaderDetails: qcHeaderDetails*/),
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
                title: AppStrings.selectPartner,
                isVersionShow: false,
              ),
            ),
            body: Column(
              children: [
                const SearchSupplierWidget(),
                Expanded(flex: 10, child: _partnerListSection(context)),
                BottomCustomButtonView(
                  title: AppStrings.scanBarcode,
                  onPressed: () async {
                    String? barcode = await controller.scanBarcode();
                    if (barcode != null) {
                      await controller.scanGTINResultContents(barcode);
                      // controller.navigateToScanBarcodeScreen();
                    }
                  },
                ),
                FooterContentView(),
              ],
            ),
          );
        });
  }

  GetBuilder<SelectSupplierScreenController> _partnerListSection(
      BuildContext context) {
    return GetBuilder<SelectSupplierScreenController>(
      id: 'partnerList',
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
                      child: controller.filteredPartnerList.isNotEmpty
                          ? partnerListView(context, controller)
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
    SelectSupplierScreenController controller,
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
                    style: Get.textTheme.titleLarge?.copyWith(
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
        style: Get.textTheme.titleLarge?.copyWith(),
      ),
    );
  }

  Widget partnerListView(
      BuildContext context, SelectSupplierScreenController controller) {
    return ListView.builder(
      controller: controller.scrollController,
      itemCount: controller.filteredPartnerList.length,
      itemBuilder: (context, index) {
        PartnerItem partner = controller.filteredPartnerList.elementAt(index);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Column(
            children: [
              getAlphabetContent(controller.filteredPartnerList, index),
              SizedBox(
                height: controller.listHeight,
                child: GestureDetector(
                  onTap: () {
                    controller.navigateToCommodityIdScreen(context, partner);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Expanded(
                        child: Text(
                          partner.name ?? '-',
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontSize: 50.h,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          controller.navigateToScorecardScreen(partner);
                        },
                        child: SizedBox(
                          width: 100,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if ((partner.greenPercentage ?? 0) != 0)
                                _buildBar(
                                    Colors.green, partner.greenPercentage ?? 0),
                              if ((partner.yellowPercentage ?? 0) != 0)
                                _buildBar(Colors.yellow,
                                    partner.yellowPercentage ?? 0),
                              if ((partner.orangePercentage ?? 0) != 0)
                                _buildBar(Colors.orange,
                                    partner.orangePercentage ?? 0),
                              if ((partner.redPercentage ?? 0) != 0)
                                _buildBar(
                                    Colors.red, partner.redPercentage ?? 0),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBar(Color color, double percentage) {
    return Container(
      width: 100,
      height: 12,
      alignment: Alignment.topRight,
      child: FractionallySizedBox(
        widthFactor: (percentage / 100),
        child: Container(
          color: color,
        ),
      ),
    );
  }

  Widget getAlphabetContent(List<PartnerItem> allSuppliers, int index) {
    String alphabet = '';
    PartnerItem itemData = allSuppliers[index];

    if (allSuppliers.isNotEmpty && index == 0) {
      alphabet = allSuppliers.first.name![0];
    } else if (itemData.name![0] !=
        allSuppliers.elementAt(index - 1).name![0]) {
      alphabet = itemData.name![0];
    }

    if (alphabet.isNotEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alphabet,
            style: Get.textTheme.titleLarge?.copyWith(
              fontSize: 60.h,
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

class SearchSupplierWidget extends StatelessWidget {
  const SearchSupplierWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SelectSupplierScreenController>(
        id: 'partnerList',
        builder: (controller) {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
            child: TextField(
              onChanged: (value) {
                Get.find<SelectSupplierScreenController>()
                    .searchAndAssignPartner(value);
              },
              controller: Get.find<SelectSupplierScreenController>()
                  .searchSuppController,
              decoration: InputDecoration(
                hintText: AppStrings.searchPartner,
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
                suffixIcon: Get.find<SelectSupplierScreenController>()
                        .searchSuppController
                        .text
                        .trim()
                        .isEmpty
                    ? const Offstage()
                    : IconButton(
                        onPressed: () {
                          Get.find<SelectSupplierScreenController>()
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
