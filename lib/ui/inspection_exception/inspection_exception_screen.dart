import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/inspection_exception_screen_controller.dart';
import 'package:pverify/utils/const.dart';

class InspectionExceptionScreen
    extends GetWidget<InspectionExceptionScreenController> {
  const InspectionExceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionExceptionScreenController>(
      init: InspectionExceptionScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: null,
          body: ListView.builder(
            itemCount: controller.exceptionCollection.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(
                    controller.exceptionCollection[index][Consts.TITLE] ?? '-',
                    style: Get.textTheme.bodyLarge),
                subtitle: Text(
                    controller.exceptionCollection[index][Consts.DETAIL] ?? '-',
                    style: Get.textTheme.bodyMedium),
                onTap: () {
                  Get.back();
                },
              );
            },
          ),
        );
      },
    );
  }
}
