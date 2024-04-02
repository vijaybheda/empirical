import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/purchase_order_screen_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/finished_goods_item_sku.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';

class PurchaseOrderScreen extends GetWidget<PurchaseOrderScreenController> {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  const PurchaseOrderScreen({
    super.key,
    required this.partner,
    required this.carrier,
    required this.commodity,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderScreenController>(
        init: PurchaseOrderScreenController(
            carrier: carrier, partner: partner, commodity: commodity),
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
                    partner.name ?? '-',
                    textAlign: TextAlign.start,
                    maxLines: 3,
                    style: GoogleFonts.poppins(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w600,
                        textStyle: TextStyle(color: AppColors.white)),
                  ),
                ),
                const SearchGradingStandardWidget(),
                Expanded(flex: 10, child: _commodityListSection(context)),
                FooterContentView(
                  onDownloadTap: () {
                    // TODO: Implement download functionality
                  },
                )
              ],
            ),
          );
        });
  }

  GetBuilder<PurchaseOrderScreenController> _commodityListSection(
      BuildContext context) {
    return GetBuilder<PurchaseOrderScreenController>(
      id: 'commodityList',
      builder: (controller) {
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
            ],
          ),
        );
      },
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
      BuildContext context, PurchaseOrderScreenController controller) {
    return ListView.separated(
      itemCount: controller.filteredCommodityList.length,
      itemBuilder: (context, index) {
        FinishedGoodsItemSKU partner =
            controller.filteredCommodityList.elementAt(index);
        return GestureDetector(
          onTap: () {
            // TODO:
            // controller.navigateToPurchaseOrderScreen(partner);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20.h),
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
                        // TODO: Implement name as per the existing app
                        partner.itemSkuName ?? '-',
                        style: Get.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.white, fontSize: 50.h),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 10,
          indent: 0,
          endIndent: 0,
          color: AppColors.white,
          thickness: 1,
        );
      },
    );
  }
}

class SearchGradingStandardWidget extends StatelessWidget {
  const SearchGradingStandardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
        child: TextField(
          onChanged: (value) {
            // TODO: Implement search functionality
            // Get.find<PurchaseOrderScreenController>()
            //     .searchAndAssignCommodity(value);
          },
          decoration: InputDecoration(
            hintText: AppStrings.searchItem,
            hintStyle: Get.textTheme.bodyLarge,
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
          ),
        ),
      ),
    );
  }
}
