import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';

class InspectionController extends GetxController {
  int wifiLevel = 0;

  @override
  void onInit() {
    super.onInit();
    final GlobalConfigController globalConfigController =
        Get.find<GlobalConfigController>();

    globalConfigController.wifiLevelStream.listen((value) {
      wifiLevel = value;
    });
  }
}
