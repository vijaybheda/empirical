import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/controller/purchase_order_details_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/models/qc_header_details.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/ui/purchase_order/purchase_order_item.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class PurchaseOrderDetailsScreen
    extends GetWidget<PurchaseOrderDetailsController> {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  final QCHeaderDetails? qcHeaderDetails;
  const PurchaseOrderDetailsScreen({
    super.key,
    required this.partner,
    required this.carrier,
    required this.commodity,
    required this.qcHeaderDetails,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderDetailsController>(
        init: PurchaseOrderDetailsController(
            partner: partner,
            carrier: carrier,
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
                title: AppStrings.beginInspection,
                message: 'PO# ${qcHeaderDetails?.poNo ?? '-'}',
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
                const _SearchOrderItemsWidget(),
                Expanded(flex: 10, child: _purchaseOrderItemSection(context)),
                BottomCustomButtonView(
                  title: AppStrings.inspectionCalculateResultButton,
                  backgroundColor: AppColors.orange,
                  onPressed: () async {
                    await controller.calculateButtonClick(context);
                  },
                ),
                _footerMenuView(controller),
                FooterContentView()
              ],
            ),
          );
        });
  }

  GetBuilder<PurchaseOrderDetailsController> _purchaseOrderItemSection(
      BuildContext context) {
    return GetBuilder<PurchaseOrderDetailsController>(
      id: 'inspectionItems',
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
                      child: controller.filteredInspectionsList.isNotEmpty
                          ? _inspectionsListView(context, controller)
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

  Widget _inspectionsListView(
    BuildContext context,
    PurchaseOrderDetailsController controller,
  ) {
    return ListView.separated(
      itemCount: controller.filteredInspectionsList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        PurchaseOrderItem goodsItem =
            controller.filteredInspectionsList.elementAt(index);
        return GestureDetector(
          onTap: () {
            controller.onItemTap(goodsItem, index);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: PurchaseOrderListViewItem(
              goodsItem: goodsItem,
              inspectTap: (
                Inspection? inspection,
                PartnerItemSKUInspections? partnerItemSKU,
                String lotNo,
                String packDate,
                bool isComplete,
                bool ispartialComplete,
                int? inspectionId,
                String po_number,
                String seal_number,
              ) async {
                FinishedGoodsItemSKU? finishedGoodsItemSKU = controller
                    .appStorage.selectedItemSKUList
                    .elementAtOrNull(index);
                if (finishedGoodsItemSKU == null) {
                  return;
                }

                await controller.onInspectTap(
                  goodsItem,
                  finishedGoodsItemSKU,
                  inspection,
                  partnerItemSKU,
                  lotNo,
                  packDate,
                  isComplete,
                  ispartialComplete,
                  inspectionId,
                  po_number,
                  seal_number,
                  (data) {
                    // TODO: implement below
                    // current_lot_number = data[Consts.Lot_No];
                    // current_Item_SKU = data[Consts.ITEM_SKU];
                    // current_pack_Date = data[Consts.PACK_DATE];
                    // current_Item_SKU_ID = data[Consts.ITEM_SKU_ID];
                    // current_lot_size = data[Consts.LOT_SIZE];
                    // current_unique_id = data[Consts.ITEM_UNIQUE_ID];
                    // item_SKU_Name = data[Consts.ITEM_SKU_NAME];
                    // commodityID = data[Consts.COMMODITY_ID];
                    // commodityName = data[Consts.COMMODITY_NAME];
                    // gtin = data[Consts.GTIN];
                  },
                );
              },
              onTapEdit: (Inspection? inspection,
                  PartnerItemSKUInspections? partnerItemSKU) async {
                FinishedGoodsItemSKU? finishedGoodsItemSKU = controller
                    .appStorage.selectedItemSKUList
                    .elementAtOrNull(index);
                if (finishedGoodsItemSKU == null || inspection == null) {
                  return;
                }
                await controller.onEditIconTap(goodsItem, finishedGoodsItemSKU,
                    inspection, partnerItemSKU);
              },
              infoTap: (Inspection? inspection,
                  PartnerItemSKUInspections? partnerItemSKU) async {
                await controller.onInformationIconTap(goodsItem);
              },
              partnerID: partner.id!,
              position: index,
              productTransfer: controller.productTransfer ?? '',
              poNumber: qcHeaderDetails!.poNo!,
              sealNumber: qcHeaderDetails!.sealNo!,
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

  Widget _footerMenuView(PurchaseOrderDetailsController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: () async {
            controller.onHomeMenuTap();
          },
          icon: Image.asset(AppImages.homeImage, height: 80.h, width: 50.w),
        ),
        IconButton(
            onPressed: () async {
              controller.onTailerTempMenuTap();
            },
            icon: Image.asset(AppImages.tailerTempImage,
                height: 50.h, width: 50.w)),
        IconButton(
            onPressed: () async {
              controller.onQCHeaderMenuTap();
            },
            icon: Image.asset(AppImages.qcHeaderImage,
                height: 50.h, width: 50.w)),
        IconButton(
            onPressed: () async {
              controller.onAddGradingStandardMenuTap();
            },
            icon: Image.asset(AppImages.gradingAddImage,
                height: 50.h, width: 50.w)),
        IconButton(
          onPressed: () async {
            controller.onSelectItemMenuTap();
          },
          icon: Image.asset(AppImages.itemsAddImage, height: 50.h, width: 50.w),
        ),
      ],
    );
  }
}

class _SearchOrderItemsWidget extends StatelessWidget {
  const _SearchOrderItemsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
        child: TextField(
          onChanged: (value) {
            Get.find<PurchaseOrderDetailsController>()
                .searchAndAssignItems(value);
          },
          controller:
              Get.find<PurchaseOrderDetailsController>().searchController,
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
            suffixIcon: Get.find<PurchaseOrderDetailsController>()
                    .searchController
                    .text
                    .trim()
                    .isEmpty
                ? const Offstage()
                : IconButton(
                    onPressed: () {
                      Get.find<PurchaseOrderDetailsController>().clearSearch();
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
  }
}
