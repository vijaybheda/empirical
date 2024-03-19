import 'package:get/get.dart';
import 'package:pverify/ui/login_screen.dart';

class DashboardScreenController extends GetxController {
  @override
  void onInit() {
    super.onInit();
  }

  void onLogout() {
    Get.offAll(() => const LoginScreen());
  }
}
