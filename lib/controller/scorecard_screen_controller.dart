import 'package:get/get.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/utils/const.dart';
import 'package:pverify/utils/enumeration.dart';
import 'package:pverify/utils/images.dart';

class ScorecardScreenController extends GetxController {
  late final String scorecardName;
  late final int scorecardID;
  late final double redPercentage;
  late final double greenPercentage;
  late final double yellowPercentage;
  late final double orangePercentage;

  final PartnerItem partner;
  ScorecardScreenController(this.partner);

  @override
  void onInit() {
    Map<String, dynamic>? args = Get.arguments;
    if (args == null) {
      Get.back();
      throw Exception('Arguments not allowed');
    }

    scorecardName = args[Consts.SCORECARD_NAME] ?? '';
    scorecardID = args[Consts.SCORECARD_ID] ?? 0;
    redPercentage = args[Consts.REDPERCENTAGE] ?? 0.0;
    greenPercentage = args[Consts.GREENPERCENTAGE] ?? 0.0;
    yellowPercentage = args[Consts.YELLOWPERCENTAGE] ?? 0.0;
    orangePercentage = args[Consts.ORANGEPERCENTAGE] ?? 0.0;

    super.onInit();
  }

  List<String> bannerImages = [AppImages.img_banner, AppImages.img_banner];
  List<Map<String, String>> listOfInspection = [
    {
      "ID": "1",
      "PO": "ee",
      "Item": "6443101",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organicfsdfsfdsfsd",
      "Status": "Done"
    },
    {
      "ID": "2",
      "PO": "ee",
      "Item": "6443102",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organicfsdfsfdsfsd",
      "Status": "Done"
    },
    {
      "ID": "3",
      "PO": "ee",
      "Item": "6443108",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
    {
      "ID": "4",
      "PO": "ee",
      "Item": "6443104",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
    {
      "ID": "5",
      "PO": "ee",
      "Item": "6443103",
      "Res": "AC",
      "GR": "Asparagus",
      "Supplier": "A A Organic",
      "Status": "Done"
    },
  ].obs;
  var bannersCurrentPage = 0.obs;
  List selectedIDsInspection = [].obs;
  List expandContents = [].obs;
  var sortType = ''.obs;

  DateSort dateSort = DateSort.asc;
  CommoditySort commoditySort = CommoditySort.none;
  ResultSort resultSort = ResultSort.none;
  ReasonSort reasonSort = ReasonSort.none;

  selectInspectionForDownload(String id, bool isSelectAll) {
    if (isSelectAll) {
      if (selectedIDsInspection.length != listOfInspection.length) {
        selectedIDsInspection.clear();
        List list1 = listOfInspection.map((array) => array['ID']).toList();
        selectedIDsInspection.addAll(list1);
      } else {
        selectedIDsInspection.clear();
      }
    } else {
      if (selectedIDsInspection.contains(id)) {
        selectedIDsInspection.remove(id);
      } else {
        selectedIDsInspection.add(id);
      }
    }
  }

  void sortArrayItem() {
    if (sortType.value == 'asc') {
      sortType.value = 'dsc';
      listOfInspection
          .sort((b, a) => a['Item'].toString().compareTo(b['Item'].toString()));
    } else {
      sortType.value = 'asc';
      listOfInspection
          .sort((a, b) => a['Item'].toString().compareTo(b['Item'].toString()));
    }
    update();
  }
}
