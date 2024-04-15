import 'package:get/get.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/partner_item.dart';

class NewPurchaseOrderDetailsController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;

  late final int serverInspectionID;
  late final String partnerName;
  late final int partnerID;
  late final String carrierName;
  late final int carrierID;
  late final int commodityID;
  late final String commodityName;
  late final String poNumber;
  late final String sealNumber;

  NewPurchaseOrderDetailsController({
    required this.partner,
    required this.carrier,
    required this.commodity,
  });

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments not allowed');
    }
    serverInspectionID = args?['serverInspectionID'] ?? -1;
    partnerName = args?['partnerName'] ?? '';
    partnerID = args?['partnerID'] ?? 0;
    carrierName = args?['carrierName'] ?? '';
    carrierID = args?['carrierID'] ?? 0;
    commodityID = args?['commodityID'] ?? 0;
    commodityName = args?['commodityName'] ?? '';
    poNumber = args?['poNumber'] ?? '';
    sealNumber = args?['sealNumber'] ?? '';
    super.onInit();
  }
}
