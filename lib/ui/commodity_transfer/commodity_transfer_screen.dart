import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/commodity_transfer_screen_controller.dart';

class CommodityTransferScreen
    extends GetWidget<CommodityTransferScreenController> {
  const CommodityTransferScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: CommodityTransferScreenController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: Text('Commodity Transfer'),
          ),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Commodity Transfer',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
