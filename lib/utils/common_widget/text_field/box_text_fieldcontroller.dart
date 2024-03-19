import 'package:get/state_manager.dart';

class BoxTextFieldController extends GetxController {
  var showPassword = false.obs;

  void changePwdVisibility() {
    showPassword.value = !showPassword.value;
    update();
  }
}
