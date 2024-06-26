import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/po_number_list_controller.dart';
import 'package:pverify/models/purchase_order_header.dart';
import 'package:pverify/ui/components/header_content_view.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/custom_radio_tile.dart';
import 'package:pverify/utils/theme/colors.dart';

class PoNumberListScreen extends GetWidget<PoNumberListController> {
  const PoNumberListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PoNumberListController>(
      init: PoNumberListController(),
      builder: (controller) {
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            toolbarHeight: 150.h,
            leading: const Offstage(),
            leadingWidth: 0,
            centerTitle: false,
            backgroundColor: Theme.of(context).primaryColor,
            title: HeaderContentView(
              title: AppStrings.selectPoNumber,
            ),
          ),
          body: Column(
            children: [
              _widgetPartnerNameWidget(controller),
              Container(
                color: Colors.black12,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: TextField(
                    onChanged: (value) {
                      controller.searchAndAssignPurchaseOrderHeader(value);
                    },
                    controller: controller.searchSuppController,
                    decoration: InputDecoration(
                      hintText: "",
                      hintStyle: Get.textTheme.bodyLarge?.copyWith(
                          fontSize: 25.sp,
                          color: AppColors.white.withOpacity(0.8)),
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
                      suffixIcon: IconButton(
                        onPressed: () {
                          if (controller.searchSuppController.text.isNotEmpty) {
                            controller.clearSearch();
                          }
                        },
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                child: GetBuilder<PoNumberListController>(
                  id: 'poList',
                  builder: (controller) {
                    if (controller.filteredPoList.isEmpty) {
                      return SizedBox(
                          height: Get.height * .3,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(child: noDataFoundWidget()),
                            ],
                          ));
                    }
                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: controller.filteredPoList.length,
                      padding: const EdgeInsets.all(0),
                      itemBuilder: (context, index) {
                        PurchaseOrderHeader purchaseOrderHeader =
                            controller.filteredPoList.elementAt(index);
                        return CustomRadioListTile(
                          title: Text(
                            "${purchaseOrderHeader.poNumber} ${purchaseOrderHeader.partnerName}",
                            style: Get.textTheme.bodyLarge,
                          ),
                          value: index,
                          groupValue: controller.selectedIndex.value,
                          onChanged: (value) async {
                            controller.selectedIndex.value = value;
                            controller.update(['poList']);
                          },
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const Divider(
                          height: 1,
                          color: Colors.grey,
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  static Center noDataFoundWidget() {
    return Center(
      child: Text(
        'No data found',
        style: Get.textTheme.displayMedium?.copyWith(
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _widgetPartnerNameWidget(PoNumberListController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      color: AppColors.textFieldText_Color,
      width: double.infinity,
      child: Text(
        controller.partnerName ?? "",
        textAlign: TextAlign.start,
        maxLines: 3,
        style: Get.textTheme.titleLarge!
            .copyWith(fontSize: 38.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
