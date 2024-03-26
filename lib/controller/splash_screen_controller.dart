import 'package:get/get.dart';
import 'package:pverify/ui/login_screen.dart';

class SplashScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3)).then((value) async {
      Get.offAll(() => const LoginScreen());
    });
  }
}
