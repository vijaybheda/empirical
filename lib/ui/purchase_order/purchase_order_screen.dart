import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/purchase_order_screen_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class PurchaseOrderScreen extends GetWidget<PurchaseOrderScreenController> {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;
  const PurchaseOrderScreen({
    super.key,
    required this.partner,
    required this.carrier,
    required this.commodity,
    required this.qcHeaderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderScreenController>(
        init: PurchaseOrderScreenController(
            carrier: carrier,
            partner: partner,
            commodity: commodity,
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
                title: AppStrings.selectItems,
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
                const _SearchItemSkuWidget(),
                Expanded(flex: 10, child: _itemSkuListSection(context)),
                BottomCustomButtonView(
                  title: AppStrings.save,
                  onPressed: () async {
                    await controller.navigateToPurchaseOrderDetails(
                        partner, carrier, commodity);
                  },
                ),
                FooterContentView(),
              ],
            ),
          );
        });
  }

  GetBuilder<PurchaseOrderScreenController> _itemSkuListSection(
      BuildContext context) {
    return GetBuilder<PurchaseOrderScreenController>(
      id: 'itemSkuList',
      builder: (controller) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: 20.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              controller.listAssigned.value
                  ? Expanded(
                      flex: 10,
                      child: controller.filteredItemSkuList.isNotEmpty
                          ? _itemSkuListView(context, controller)
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

  Widget _itemSkuListView(
    BuildContext context,
    PurchaseOrderScreenController controller,
  ) {
    return ListView.separated(
      itemCount: controller.filteredItemSkuList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        FinishedGoodsItemSKU goodsItem =
            controller.filteredItemSkuList.elementAt(index);
        return CheckboxListTile(
          value: goodsItem.isSelected ?? false,
          visualDensity: VisualDensity.compact,
          contentPadding: EdgeInsets.zero,
          activeColor: Colors.transparent,
          checkColor: Colors.white,
          fillColor: MaterialStateProperty.all((goodsItem.isSelected ?? false)
              ? AppColors.primary
              : Colors.transparent),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          onChanged: (value) {
            goodsItem = goodsItem.copyWith(isSelected: (value!));
            goodsItem.uniqueItemId = generateUUID();
            if (value) {
              controller.appStorage.selectedItemSKUList.add(goodsItem);
              controller.appStorage.tempSelectedItemSKUList.add(goodsItem);
              controller.dao.createSelectedItemSKU(
                skuId: goodsItem.id,
                itemSKUCode: goodsItem.sku,
                poNo: "",
                lotNo: "",
                itemSKUName: goodsItem.name,
                commodityName: goodsItem.commodityName,
                uniqueId: goodsItem.uniqueItemId!,
                commodityId: goodsItem.commodityID,
                description: "",
                partnerID: goodsItem.partnerId,
                packDate: "",
                GTIN: "",
                partnerName: goodsItem.partnerName,
                ftl: goodsItem.FTLflag,
                branded: goodsItem.Branded,
                dateType: goodsItem.dateType,
              );
            } else {
              controller.appStorage.selectedItemSKUList.remove(goodsItem);
              controller.appStorage.tempSelectedItemSKUList.remove(goodsItem);
              controller.dao.deleteSelectedItemSKUByUniqueId(
                uniqueId: goodsItem.uniqueItemId!,
                itemId: goodsItem.id,
                itemCode: goodsItem.sku,
              );
            }

            controller.updateCommodityItem(goodsItem);
          },
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: goodsItem.sku ?? '-',
                    style: Get.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.white, fontSize: 50.h),
                  ),
                  const TextSpan(text: ' '),
                  TextSpan(
                    text: goodsItem.name ?? '-',
                    style: Get.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.primary, fontSize: 50.h),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return Divider(
          height: 5,
          indent: 0,
          endIndent: 0,
          color: AppColors.white,
          thickness: 1,
        );
      },
    );
  }
}

class _SearchItemSkuWidget extends StatelessWidget {
  const _SearchItemSkuWidget();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderScreenController>(
        id: 'itemSkuList',
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
              child: TextField(
                onChanged: (value) {
                  Get.find<PurchaseOrderScreenController>()
                      .searchAndAssignOrder(value);
                },
                controller:
                    Get.find<PurchaseOrderScreenController>().searchController,
                decoration: InputDecoration(
                  hintText: AppStrings.searchItem,
                  hintStyle: Get.textTheme.bodyLarge?.copyWith(
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
                  suffixIcon: Get.find<PurchaseOrderScreenController>()
                          .searchController
                          .text
                          .trim()
                          .isEmpty
                      ? const Offstage()
                      : IconButton(
                          onPressed: () {
                            Get.find<PurchaseOrderScreenController>()
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
