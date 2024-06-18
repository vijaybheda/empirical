import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/new_purchase_order_details_controller.dart';
import 'package:pverify/models/new_purchase_order_item.dart';
import 'package:pverify/ui/components/bottom_custom_button_view.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/ui/components/progress_adaptive.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/theme/colors.dart';

class NewPurchaseOrderDetailsScreen
    extends GetWidget<NewPurchaseOrderDetailsController> {
  final String tag;

  const NewPurchaseOrderDetailsScreen({super.key, required this.tag});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewPurchaseOrderDetailsController>(
        init: NewPurchaseOrderDetailsController(),
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
                      await controller.calculateButtonClick();
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

  GetBuilder<NewPurchaseOrderDetailsController> _purchaseOrderItemSection(
      BuildContext context, String tag) {
    return GetBuilder<NewPurchaseOrderDetailsController>(
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
    NewPurchaseOrderDetailsController controller,
  ) {
    return ListView.separated(
      itemCount: controller.filteredInspectionsList.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        NewPurchaseOrderItem goodsItem =
            controller.filteredInspectionsList.elementAt(index);
        return GetBuilder<NewPurchaseOrderDetailsController>(
            tag: tag,
            builder: (controller) {
              return Container();
              /*return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: NewPurchaseOrderListViewItem(
                  goodsItem: goodsItem,
                  partnerID: controller.partnerID,
                  position: index,
                  poNumber: controller.poNumber!,
                  sealNumber: controller.sealNumber,
                ),
              );*/
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

  Widget _footerMenuView(NewPurchaseOrderDetailsController controller) {
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
            Get.find<NewPurchaseOrderDetailsController>(tag: tag)
                .searchAndAssignItems(value);
          },
          controller: Get.find<NewPurchaseOrderDetailsController>(
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
            suffixIcon: Get.find<NewPurchaseOrderDetailsController>(
              tag: tag,
            ).searchController.text.trim().isEmpty
                ? const Offstage()
                : IconButton(
                    onPressed: () {
                      Get.find<NewPurchaseOrderDetailsController>(
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
