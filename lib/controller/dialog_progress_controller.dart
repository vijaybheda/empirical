import 'package:get/get.dart';

class ProgressController extends GetxController {
  RxInt progress = 0.obs;

  void updateProgress(int value) {
    progress.value = value;
  }
}
