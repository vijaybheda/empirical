import 'package:get/get.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';

class NewPurchaseOrderDetailsController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  NewPurchaseOrderDetailsController({
    required this.partner,
    required this.carrier,
    required this.commodity,
  });
}
