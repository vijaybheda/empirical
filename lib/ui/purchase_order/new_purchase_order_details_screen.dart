import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/new_purchase_order_details_controller.dart';

class NewPurchaseOrderDetailsScreen
    extends GetWidget<NewPurchaseOrderDetailsController> {
  const NewPurchaseOrderDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<NewPurchaseOrderDetailsController>(
        init: NewPurchaseOrderDetailsController(),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('New Purchase Order Details'),
            ),
            body: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  // Text('Partner: ${controller.partner.name}'),
                  // Text('Carrier: ${controller.carrier.name}'),
                  // Text('Commodity: ${controller.commodity.name}'),
                ],
              ),
            ),
          );
        });
  }
}
