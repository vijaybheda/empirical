import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/purchase_order_details_controller.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/partner_item_sku_inspections.dart';
import 'package:pverify/models/purchase_order_item.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/ui/purchase_order/purchase_order_item.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

// Main class
class PurchaseOrderDetailsScreen
    extends GetView<PurchaseOrderDetailsController> {
  final String tag;
  const PurchaseOrderDetailsScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderDetailsController>(
        init: PurchaseOrderDetailsController(),
        tag: tag,
        builder: (controller) {
          return WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Scaffold(
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
                  message: 'PO# ${controller.poNumber ?? '-'}',
                ),
              ),
              body: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 10),
                    color: AppColors.textFieldText_Color,
                    width: double.infinity,
                    child: Text(
                      controller.partnerName ?? '-',
                      textAlign: TextAlign.start,
                      maxLines: 3,
                      style: Get.textTheme.titleLarge!.copyWith(
                        fontSize: 38.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  _SearchOrderItemsWidget(tag),
                  Expanded(
                      flex: 10, child: _purchaseOrderItemSection(context, tag)),
                  BottomCustomButtonView(
                    title: AppStrings.inspectionCalculateResultButton,
                    backgroundColor: AppColors.orange,
                    onPressed: () async {
                      await controller.calculateButtonClick(context);
                      controller.update();
                    },
                  ),
                  _footerMenuView(controller),
                  FooterContentView(
                    hasLeftButton: false,
                  )
                ],
              ),
            ),
          );
        });
  }

  GetBuilder<PurchaseOrderDetailsController> _purchaseOrderItemSection(
      BuildContext context, String tag) {
    return GetBuilder<PurchaseOrderDetailsController>(
      // id: 'inspectionItems',
      tag: tag,
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
        style: Get.textTheme.titleLarge?.copyWith(),
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
        return GetBuilder<PurchaseOrderDetailsController>(
            tag: tag,
            builder: (controller) {
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: PurchaseOrderListViewItem(
                  goodsItem: goodsItem,
                  inspectTap: (
                    Inspection? inspection,
                    PartnerItemSKUInspections? partnerItemSKU,
                    String lotNo,
                    String packDate,
                    bool isComplete,
                    bool isPartialComplete,
                    int? inspectionId,
                    String poNumber,
                    String sealNumber,
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
                      isPartialComplete,
                      inspectionId,
                      poNumber,
                      sealNumber,
                      index,
                      (data) {
                        // controller.appStorage.selectedItemSKUList[index] = data;
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
                    await controller.onEditIconTap(goodsItem,
                        finishedGoodsItemSKU, inspection, partnerItemSKU);
                  },
                  infoTap: (Inspection? inspection,
                      PartnerItemSKUInspections? partnerItemSKU) async {
                    await controller.onInformationIconTap(goodsItem);
                  },
                  partnerID: controller.partnerID!,
                  position: index,
                  productTransfer: controller.productTransfer ?? '',
                  poNumber: controller.poNumber!,
                  sealNumber: controller.sealNumber!,
                ),
              );
            });
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
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () async {
              await controller.onHomeMenuTap();
            },
            icon: Image.asset(
              AppImages.homeImage,
              height: 65.w,
              width: 65.w,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              controller.onTailerTempMenuTap();
            },
            icon: Image.asset(
              AppImages.tailerTempImage,
              height: 80.w,
              width: 80.w,
              color: Colors.white,
            ),
            iconSize: 80.w,
          ),
          IconButton(
            onPressed: () async {
              await controller.onQCHeaderMenuTap();
            },
            icon: Image.asset(
              AppImages.qcHeaderImage,
              height: 80.w,
              width: 80.w,
              color: Colors.white,
            ),
            iconSize: 80.w,
          ),
          IconButton(
            onPressed: () async {
              await controller.onAddGradingStandardMenuTap();
            },
            icon: Image.asset(
              AppImages.gradingAddImage,
              height: 80.w,
              width: 80.w,
              color: Colors.white,
            ),
            iconSize: 80.w,
          ),
          IconButton(
            onPressed: () async {
              await controller.onSelectItemMenuTap();
            },
            icon: Image.asset(
              AppImages.itemsAddImage,
              height: 80.w,
              width: 80.w,
              color: Colors.white,
            ),
            iconSize: 80.w,
          ),
        ],
      ),
    );
  }
}

class _SearchOrderItemsWidget extends StatelessWidget {
  final String tag;
  const _SearchOrderItemsWidget(this.tag);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
        child: TextField(
          onChanged: (value) {
            Get.find<PurchaseOrderDetailsController>(tag: tag)
                .searchAndAssignItems(value);
          },
          controller: Get.find<PurchaseOrderDetailsController>(
            tag: tag,
          ).searchController,
          decoration: InputDecoration(
            hintText: AppStrings.searchItem,
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
            suffixIcon: Get.find<PurchaseOrderDetailsController>(
              tag: tag,
            ).searchController.text.trim().isEmpty
                ? const Offstage()
                : IconButton(
                    onPressed: () {
                      Get.find<PurchaseOrderDetailsController>(
                        tag: tag,
                      ).clearSearch();
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
