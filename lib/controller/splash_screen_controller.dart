import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/ui/login_screen.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Get.lazyPut(() => GlobalConfigController(), fenix: true);
    Future.delayed(const Duration(seconds: 0)).then((value) async {
      Get.offAll(() => const LoginScreen());
    });
  }
}
