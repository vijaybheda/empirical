import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/specification_attributes_controller.dart';

class SpecificationAttributesScreen
    extends GetWidget<SpecificationAttributesController> {
  const SpecificationAttributesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: SpecificationAttributesController(),
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
