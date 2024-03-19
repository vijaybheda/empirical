import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:wifi_info_plugin_plus/wifi_info_plugin_plus.dart';

class WifiController extends GetxController {
  var wifiLevel = 0.obs;

  @override
  void onInit() {
    super.onInit();
    checkWifiLevel();
    update();
  }

  void checkWifiLevel() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.wifi) {
      WifiInfoWrapper? wifiObject;

      wifiObject = await WifiInfoPlugin.wifiDetails;
       if(wifiObject!=null) {
         int level = wifiObject.signalStrength;
         wifiLevel.value = level;
       }
       else{
         wifiLevel.value = 0;
       }
       update(["wifiLevel"]);
    } else {
      wifiLevel.value = 0;
      update(["wifiLevel"]);
    }
  }
}