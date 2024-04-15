import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/overridden_result_screen_controller.dart';

class OverriddenResultScreen
    extends GetWidget<OverriddenResultScreenController> {
  const OverriddenResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OverriddenResultScreenController>(
        init: OverriddenResultScreenController(),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              title: const Text('Overridden Result'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text(
                    'Overridden Result',
                    style: TextStyle(fontSize: 20),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
