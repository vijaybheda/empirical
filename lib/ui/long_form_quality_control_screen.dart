import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/long_form_quality_control_screen_controller.dart';

class LongFormQualityControlScreen
    extends GetWidget<LongFormQualityControlScreenController> {
  const LongFormQualityControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: LongFormQualityControlScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Long Form Quality Control Screen'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Long Form Quality Control Screen',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
