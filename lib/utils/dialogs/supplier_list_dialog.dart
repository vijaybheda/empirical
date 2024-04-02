import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/select_supplier_screen_controller.dart';
import 'package:pverify/utils/app_strings.dart';

class SupplierListDialog extends GetWidget<SelectSupplierScreenController> {
  const SupplierListDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        AppStrings.selectOpenPartner,
        style: Get.textTheme.titleLarge,
      ),
      content: Wrap(
        // mainAxisSize: MainAxisSize.min,
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.start,
        runAlignment: WrapAlignment.start,
        children: [
          TextField(
            controller: controller.searchOpenSuppController,
            onChanged: (value) {
              controller.searchAndAssignNonOpenPartner(value);
            },
            decoration: const InputDecoration(
              hintText: AppStrings.searchPartner,
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GetBuilder<SelectSupplierScreenController>(
                id: 'nonOpenPartnerList',
                builder: (controller) {
                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: controller.filteredNonOpenPartnersList.length,
                    itemBuilder: (context, index) {
                      return RadioListTile(
                        title: Text(controller
                                .filteredNonOpenPartnersList[index].name ??
                            '-'),
                        value: index,
                        groupValue: controller.selectedIndex.value,
                        onChanged: (value) {
                          controller.selectedIndex.value = value as int;
                        },
                      );
                    },
                  );
                }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back(); // Close the dialog
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.selectedIndex.value != -1) {
              // Handle selection here
              debugPrint(
                  'Selected Supplier: ${controller.filteredNonOpenPartnersList[controller.selectedIndex.value].name}');
              Get.back(); // Close the dialog
            } else {
              // Show error message or handle invalid selection
              debugPrint('No supplier selected');
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  static void show(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => const SupplierListDialog(),
    );
  }
}
