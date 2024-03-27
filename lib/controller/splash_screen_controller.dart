import 'package:get/get.dart';
import 'package:pverify/ui/login_screen.dart';
import 'package:pverify/ui/quality_control_header/quality_control_header.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 0)).then((value) async {
      Get.offAll(() => const LoginScreen());
      //Get.offAll(() => QualityControlHeader());
    });
  }
}
