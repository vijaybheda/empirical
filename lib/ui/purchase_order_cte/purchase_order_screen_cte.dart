import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/purchase_order_screen_cte_controller.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/utils.dart';

class PurchaseOrderScreenCTE
    extends GetWidget<PurchaseOrderScreenCTEController> {
  final String tag;
  const PurchaseOrderScreenCTE({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderScreenCTEController>(
      init: PurchaseOrderScreenCTEController(),
      tag: tag,
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
                  controller.partnerName,
                  textAlign: TextAlign.start,
                  maxLines: 3,
                  style: Get.textTheme.titleLarge!.copyWith(
                    fontSize: 38.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _SearchItemSkuWidget(tag),
              Expanded(flex: 10, child: _itemSkuListSection(context)),
              BottomCustomButtonView(
                title: AppStrings.save,
                onPressed: () async {
                  await controller.navigateToPurchaseOrderDetails(context);
                },
              ),
              FooterContentView(),
            ],
          ),
        );
      },
    );
  }

  GetBuilder<PurchaseOrderScreenCTEController> _itemSkuListSection(
      BuildContext context) {
    return GetBuilder<PurchaseOrderScreenCTEController>(
      id: 'itemSkuList',
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
        style: Get.textTheme.titleLarge?.copyWith(),
      ),
    );
  }

  Widget _itemSkuListView(
    BuildContext context,
    PurchaseOrderScreenCTEController controller,
  ) {
    return ListView.separated(
      itemCount: controller.filteredItemSkuList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        FinishedGoodsItemSKU goodsItem =
            controller.filteredItemSkuList.elementAt(index);
        return InkWell(
          onTap: () async {
            goodsItem = await onCheckboxChange(
                goodsItem, !(goodsItem.isSelected ?? false), controller);
          },
          child: Container(
            margin: const EdgeInsets.only(left: 10, right: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: goodsItem.sku ?? '-',
                            style: Get.textTheme.titleLarge?.copyWith(
                              fontSize: 50.h,
                            ),
                          ),
                          const TextSpan(text: ' '),
                          TextSpan(
                            text: goodsItem.name ?? '-',
                            style: Get.textTheme.titleLarge?.copyWith(
                              color: AppColors.primary,
                              fontSize: 50.h,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Transform.scale(
                  scale: 1.5,
                  child: Checkbox(
                    value: goodsItem.isSelected ?? false,
                    onChanged: (bool? newValue) async {
                      goodsItem = await onCheckboxChange(
                          goodsItem, newValue, controller);
                    },
                    fillColor: MaterialStateProperty.all(
                      (goodsItem.isSelected ?? false)
                          ? AppColors.primary
                          : Colors.transparent,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    activeColor: Colors.transparent,
                    checkColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        );
        /*return CheckboxListTile(
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
            goodsItem = onCheckboxChange(goodsItem, value, controller);
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
        );*/
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

  Future<FinishedGoodsItemSKU> onCheckboxChange(FinishedGoodsItemSKU goodsItem,
      bool? value, PurchaseOrderScreenCTEController controller) async {
    goodsItem = goodsItem.copyWith(isSelected: (value!));
    goodsItem.uniqueItemId ??= generateUUID();
    if (value) {
      controller.localItemSKUList.add(goodsItem);
      controller.localItemSKUList.add(goodsItem);
      await controller.dao.createSelectedItemSKU(
        skuId: goodsItem.id,
        itemSKUCode: goodsItem.sku,
        poNo: controller.poNumber,
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
      controller.localItemSKUList.remove(goodsItem);
      controller.localItemSKUList.remove(goodsItem);
      await controller.dao.deleteSelectedItemSKUByUniqueId(
        uniqueId: goodsItem.uniqueItemId!,
        itemId: goodsItem.id,
        itemCode: goodsItem.sku,
      );
    }

    controller.updateSelectedItemSKUItem(goodsItem);
    return goodsItem;
  }
}

class _SearchItemSkuWidget extends StatelessWidget {
  final String tag;
  const _SearchItemSkuWidget(this.tag);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderScreenCTEController>(
        id: 'itemSkuList',
        tag: tag,
        builder: (context) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 25.w, vertical: 25.h),
              child: TextField(
                onChanged: (value) {
                  Get.find<PurchaseOrderScreenCTEController>(
                    tag: tag,
                  ).searchAndAssignOrder(value);
                },
                controller: Get.find<PurchaseOrderScreenCTEController>(
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
                  suffixIcon: Get.find<PurchaseOrderScreenCTEController>(
                    tag: tag,
                  ).searchController.text.trim().isEmpty
                      ? const Offstage()
                      : IconButton(
                          onPressed: () {
                            Get.find<PurchaseOrderScreenCTEController>(
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
        });
  }
}
