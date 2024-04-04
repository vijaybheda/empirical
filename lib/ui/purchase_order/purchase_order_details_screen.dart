import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/purchase_order_details_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';

class PurchaseOrderDetailsScreen
    extends GetWidget<PurchaseOrderDetailsController> {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  const PurchaseOrderDetailsScreen({
    super.key,
    required this.partner,
    required this.carrier,
    required this.commodity,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PurchaseOrderDetailsController>(
        init: PurchaseOrderDetailsController(
            partner: partner, carrier: carrier, commodity: commodity),
        builder: (controller) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Purchase Order Details'),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text('Partner: ${controller.partner.name}'),
                  Text('Carrier: ${controller.carrier.name}'),
                  Text('Commodity: ${controller.commodity.name}'),
                ],
              ),
            ),
          );
        });
  }
}
