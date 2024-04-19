import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/inspection_exception_screen_controller.dart';

class InspectionExceptionScreen
    extends GetWidget<InspectionExceptionScreenController> {
  const InspectionExceptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<InspectionExceptionScreenController>(
      init: InspectionExceptionScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Inspection Exception'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Show SnackBar'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
