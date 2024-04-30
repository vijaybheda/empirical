import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/defects_screen_controller.dart';

class DefectsScreen extends GetWidget<DefectsScreenController> {
  const DefectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
        init: DefectsScreenController(),
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
