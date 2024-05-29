import 'package:get/get.dart';

class ProgressController extends GetxController {
  RxDouble progress = 0.0.obs;

  void updateProgress(double value) {
    progress.value = value;
  }
}
