import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/finished_goods_item_sku.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/utils/app_storage.dart';

class PurchaseOrderScreenController extends GetxController {
  final PartnerItem partner;
  final CarrierItem carrier;
  final CommodityItem commodity;
  PurchaseOrderScreenController({
    required this.partner,
    required this.carrier,
    required this.commodity,
  });

  final AppStorage appStorage = AppStorage.instance;
  final GlobalConfigController globalConfigController =
      Get.find<GlobalConfigController>();
  final ApplicationDao dao = ApplicationDao();

  RxList<FinishedGoodsItemSKU> filteredCommodityList =
      <FinishedGoodsItemSKU>[].obs;
  RxList<FinishedGoodsItemSKU> commodityList = <FinishedGoodsItemSKU>[].obs;
  RxBool listAssigned = false.obs;

  @override
  void onInit() {
    super.onInit();
    assignInitialData();
  }

  Future<void> assignInitialData() async {
    LoginData? loginData = appStorage.getLoginData();

    if (loginData != null) {
      if (filteredCommodityList.isEmpty) {
        int enterpriseId = await dao
            .getEnterpriseIdByUserId(loginData.userName!.toLowerCase());
        // TODO:
        /*List<FinishedGoodsItemSKU>? filteredCommodityList =
            await dao.getFinishedGoodItemSkuFromTable(
                partnerID,
                enterpriseId,
                commodityID,
                commodityName,
                AppInfo.user.getSupplierId(),
                AppInfo.user.getHeadqauterId(),
                partnerName);

        appStorage.commodityList = sfd;
        filteredCommodityList = AppInfo.filteredCommodityList;*/
      } else {
        // TODO:
        // filteredCommodityList = asd;
      }
    }
  }
}
