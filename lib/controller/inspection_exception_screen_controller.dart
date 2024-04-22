import 'package:get/get.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/const.dart';

class InspectionExceptionScreenController extends GetxController {
  final AppStorage appStorage = AppStorage.instance;
  List<Map<String, String>> exceptionCollection = <Map<String, String>>[];

  @override
  void onInit() {
    for (var item in (appStorage.commodityVarietyData?.exceptions) ?? []) {
      var map = <String, String>{
        Consts.TITLE: item.shortDescription,
        Consts.DETAIL: item.longDescription,
      };
      exceptionCollection.add(map);
    }
    super.onInit();
    Future.delayed(Duration.zero, () {
      if (exceptionCollection.isEmpty) {
        update();
      }
    });
  }
}
