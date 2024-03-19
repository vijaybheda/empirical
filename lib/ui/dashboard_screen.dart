import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/dashboard_screen_controller.dart';

class DashboardScreen extends GetWidget<DashboardScreenController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardScreenController>(
        init: DashboardScreenController(),
        builder: (controller) {
          return const Placeholder();
        });
  }
}
