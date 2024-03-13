import 'package:get/get.dart';
import 'package:pverify/ui/login_screen.dart';

class SplashScreenController extends GetxController {
  // final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void onInit() {
    super.onInit();
    Future.delayed(const Duration(seconds: 3)).then((value) async {
      // if (_auth.currentUser != null) {
      //   UserController userController = Get.find();
      //   await userController.fetchUser();
      //   Get.offAll(() => HomeScreen());
      // } else {
      Get.offAll(() => LoginScreen());
      // }
    });
  }
}
