import 'package:get/state_manager.dart';

class TextFieldController extends GetxController {
  var showPassword = false.obs;

  void changePwdVisibility() {
    showPassword.value = !showPassword.value;
    update();
  }
}
