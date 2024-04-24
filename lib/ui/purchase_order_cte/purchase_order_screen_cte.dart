import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/purchase_order_screen_cte_controller.dart';

class PurchaseOrderScreenCTE
    extends GetWidget<PurchaseOrderScreenCTEController> {
  const PurchaseOrderScreenCTE({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: PurchaseOrderScreenCTEController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Purchase Order Screen CTE'),
          ),
          body: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Purchase Order Screen CTE',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
