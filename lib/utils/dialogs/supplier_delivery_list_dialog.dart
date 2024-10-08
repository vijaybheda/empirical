import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/delivered_from_controller.dart';
import 'package:pverify/controller/select_supplier_screen_controller.dart';
import 'package:pverify/models/delivery_to_item.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/common_widget/custom_radio_tile.dart';
import 'package:pverify/utils/dialogs/app_alerts.dart';
import 'package:pverify/utils/theme/colors.dart';

class DeliveryToListDialog {
  static Future<DeliveryToItem?> showListDialog(BuildContext context) {
    DeliveredFromController controller = Get.find<DeliveredFromController>();
    return showDialog<DeliveryToItem?>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: Text(
            AppStrings.selectOpenPartner,
            style: Get.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    onChanged: (value) {
                      controller.searchAndAssignNonOpenPartner(value);
                    },
                    controller: controller.searchNonOpenSuppController,
                    decoration: InputDecoration(
                      hintText: AppStrings.searchPartner,
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
                          if (controller
                              .searchNonOpenSuppController.text.isNotEmpty) {
                            controller.clearOpenSearch();
                          }
                        },
                        icon: Icon(
                          Icons.clear,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    child: GetBuilder<SelectSupplierScreenController>(
                      id: 'nonOpenPartnerList',
                      builder: (controller) {
                        if (controller.filteredNonOpenPartnersList.isEmpty) {
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
                          itemCount:
                              controller.filteredNonOpenPartnersList.length,
                          padding: const EdgeInsets.all(0),
                          itemBuilder: (context, index) {
                            PartnerItem partnerItem = controller
                                .filteredNonOpenPartnersList
                                .elementAt(index);
                            return CustomRadioListTile(
                              title: Text(
                                partnerItem.name ?? '-',
                                style: Get.textTheme.bodyLarge,
                              ),
                              value: index,
                              groupValue: controller.selectedIndex.value,
                              onChanged: (value) {
                                controller.selectedIndex.value = value;
                                controller.update(['nonOpenDeliveryList']);
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
            ),
          ),
          actions: <Widget>[
            Center(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (controller.selectedIndex.value != -1) {
                        int index = controller.selectedIndex.value;
                        Get.back(
                            result: controller.filteredDeliveryToItemList
                                .elementAt(index));
                      } else {
                        AppAlertDialog.validateAlerts(context, AppStrings.alert,
                            AppStrings.selectPartnerInfo);
                      }
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.primary),
                      foregroundColor:
                          MaterialStateProperty.all(AppColors.primary),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      minimumSize:
                          MaterialStateProperty.all(const Size(100, 40)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Text(
                        AppStrings.ok,
                        style: Get.textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(AppColors.primary),
                      foregroundColor:
                          MaterialStateProperty.all(AppColors.primary),
                      shape: MaterialStateProperty.all(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      minimumSize:
                          MaterialStateProperty.all(const Size(100, 40)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      child: Text(
                        AppStrings.cancel,
                        style: Get.textTheme.labelLarge?.copyWith(
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
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
}
