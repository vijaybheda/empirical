import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/commodity_id_screen_controller.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/ui/components/footer_content_view.dart';
import 'package:pverify/ui/components/header_content_view.dart';

class CommodityIDScreen extends GetWidget<CommodityIDScreenController> {
  final PartnerItem partner;
  const CommodityIDScreen({super.key, required this.partner});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommodityIDScreenController>(
        init: CommodityIDScreenController(partner: partner),
        builder: (controller) {
          return Scaffold(
            backgroundColor: Theme.of(context).colorScheme.background,
            body: Column(
              children: <Widget>[
                HeaderContentView(
                  title: partner.name ?? '-',
                ),
                Expanded(
                  child: Column(
                    children: [],
                  ),
                ),
                FooterContentView()
              ],
            ),
          );
        });
  }
}
