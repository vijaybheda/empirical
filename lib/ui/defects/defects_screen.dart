import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/defects_screen_controller.dart';

class DefectsScreen extends GetWidget<DefectsScreenController> {
  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: controller,
        builder: (_) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Defects'),
            ),
            body: Center(
              child: Text('Defects Screen'),
            ),
          );
        });
  }
}
