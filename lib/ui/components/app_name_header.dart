import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/utils/app_strings.dart';

class AppNameHeader extends StatefulWidget {
  const AppNameHeader({super.key});

  @override
  State<AppNameHeader> createState() => _AppNameHeaderState();
}

class _AppNameHeaderState extends State<AppNameHeader> {
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      direction: Axis.horizontal,
      children: [
        Text(AppStrings.appName,
            style: Get.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w300,
            )),
        const SizedBox(width: 8),
        Obx(() => Text(globalConfigController.appVersion.value,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w100,
                ))),
      ],
    );
  }
}
