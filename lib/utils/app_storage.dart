import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pverify/models/agency_item.dart';
import 'package:pverify/models/brand_item.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_data.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/commodity_variety_data.dart';
import 'package:pverify/models/country_item.dart';
import 'package:pverify/models/defect_categories.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/delivery_to_item.dart';
import 'package:pverify/models/grade_commodity_detail_item.dart';
import 'package:pverify/models/grade_defect_detail_item.dart';
import 'package:pverify/models/inspection.dart';
import 'package:pverify/models/item_sku_data.dart';
import 'package:pverify/models/last_inspections_item.dart';
import 'package:pverify/models/my_inspection_48hour_item.dart';
import 'package:pverify/models/offline_commodity.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/reason_item.dart';
import 'package:pverify/models/severity.dart';
import 'package:pverify/models/severity_defect.dart';
import 'package:pverify/models/specification_analytical.dart';
import 'package:pverify/models/specification_by_item_sku.dart';
import 'package:pverify/models/specification_grade_tolerance.dart';
import 'package:pverify/models/specification_grade_tolerance_array.dart';
import 'package:pverify/models/specification_supplier_gtin.dart';
import 'package:pverify/models/to_location_item.dart';
import 'package:pverify/models/trending_data_item.dart';
import 'package:pverify/models/uom_item.dart';
import 'package:pverify/models/user_data.dart';
import 'package:pverify/models/variety_item.dart';

class AppStorage extends GetxController {
  // ignore: prefer_function_declarations_over_variables
  final storageBox = () => GetStorage(StorageKey.kAppStorageKey);

  List<FinishedGoodsItemSKU> selectedItemSKUList = [];

  List<SpecificationAnalytical>? specificationAnalyticalList;
  List<SpecificationGradeToleranceArray>? specificationGradeToleranceArrayList;
  List<SpecificationGradeTolerance>? specificationGradeToleranceList;

  List<PartnerItem>? partnersList;
  List<CarrierItem>? carrierList;
  List<Commodity>? mainCommodityList;
  List<CommodityItem>? commodityList;
  List<VarietyItem>? varietyList;
  List<DefectItem>? defectsList;
  List<SeverityDefect>? severityDefectsList;
  List<UOMItem> uomList = [];
  List<ReasonItem>? reasonList;
  List<AgencyItem>? agencyList;
  List<GradeCommodityDetailItem>? gradeCommodityList;
  List<GradeDefectDetailItem>? gradeDefectList;
  List<BrandItem>? brandList;
  List<CountryItem>? countryList;
  List<DeliveryToItem>? deliveryToList;
  List<TrendingDataItem>? trendingDataList;
  List<MyInspection48HourItem>? myInsp48HourList;
  List<LastInspectionsItem>? lastInspectionsList;
  List<FinishedGoodsItemSKU>? finishedGoodsItemSKUList;
  List<ToLocationItem>? toLocationItemList;
  List<Commodity>? cteCommodityList;

  List<int>? attachmentIds;

  List<Severity>? severityList;
  List<DefectCategories>? defectCategoriesList;
  List<SpecificationByItemSKU>? specificationByItemSKUList;
  List<FinishedGoodsItemSKU> tempSelectedItemSKUList = [];

  CommodityVarietyData? commodityVarietyData;
  List<CommodityVarietyData>? commodityVarietyDataList;

  Map<String, String> mapLogin = <String, String>{};

  Inspection? currentInspection;
  String? currentSealNumber;

  List<SpecificationGradeTolerance> specificationGradeToleranceTable = [];

  bool resumeFromSpecificationAttributes = false;
  // instance of this class
  static AppStorage get instance => _instance;
  static final AppStorage _instance = AppStorage._internal();

  AppStorage._internal();

  Future<void> appLogout() async {
    await storageBox().remove(StorageKey.kIsBoardWatched);
    await storageBox().remove(StorageKey.kLoginUserData);
    await storageBox().remove(StorageKey.kNotificationSettings);
    return;
  }

  dynamic read(String key) {
    return storageBox().read(key);
  }

  Future<void> write(String key, dynamic value) async {
    return await storageBox().write(key, value);
  }

  UserData? getUserData() {
    Map<String, dynamic>? loggedInUser = read(StorageKey.kLoginUserData);
    if (loggedInUser == null) {
      return null;
    }
    UserData userData = UserData.fromJson(loggedInUser);
    return userData;
  }

  Future<void> savePartnerList(List<PartnerItem> partnerList) {
    // list to String
    List<Map<String, dynamic>> partnerListString =
        partnerList.map((e) => e.toJson()).toList();
    return write(StorageKey.kPartnerList, partnerListString);
  }

  List<PartnerItem>? getPartnerList() {
    // read String data and convert to List<PartnerItem> list
    var partnerListString = read(StorageKey.kPartnerList);
    if (partnerListString == null) {
      return null;
    }

    List<dynamic> decodedData = partnerListString;
    List<PartnerItem> partnerList = decodedData
        .map((item) => PartnerItem.fromJson(item))
        .toList()
        .cast<PartnerItem>();

    return partnerList;
  }

  Future<void> saveCarrierList(List<CarrierItem> carrierList) {
    // list to String
    List<Map<String, dynamic>> carrierListString =
        carrierList.map((e) => e.toJson()).toList();
    return write(StorageKey.kCarrierList, carrierListString);
  }

  List<CarrierItem>? getCarrierList() {
    // read String data and convert to List<CarrierItem> list
    var carrierListString = read(StorageKey.kCarrierList);
    if (carrierListString == null) {
      return null;
    }

    List<dynamic> decodedData = carrierListString;
    List<CarrierItem> carrierList = decodedData
        .map((item) => CarrierItem.fromJson(item))
        .toList()
        .cast<CarrierItem>();

    return carrierList;
  }

  Future<void> saveCommodityList(List<CommodityItem> commodityList) {
    // list to String
    List<Map<String, dynamic>> commodityListString =
        commodityList.map((e) => e.toJson()).toList();
    return write(StorageKey.kCommodityList, commodityListString);
  }

  List<CommodityItem>? getCommodityList() {
    // read String data and convert to List<CommodityItem> list
    var commodityListString = read(StorageKey.kCommodityList);
    if (commodityListString == null) {
      return null;
    }

    List<dynamic> decodedData = commodityListString;
    List<CommodityItem> commodityList = decodedData
        .map((item) => CommodityItem.fromJson(item))
        .toList()
        .cast<CommodityItem>();

    return commodityList;
  }

  Future<void> saveMainCommodityList(List<Commodity> mainCommodityList) {
    // list to String
    List<Map<String, dynamic>> commodityListString =
        mainCommodityList.map((e) => e.toJson()).toList();
    if (this.mainCommodityList == null) {
      this.mainCommodityList = [];
    }
    this.mainCommodityList!.clear();
    this.mainCommodityList!.addAll(mainCommodityList);
    return write(StorageKey.kMainCommodityList, commodityListString);
  }

  List<Commodity>? getMainCommodityList() {
    // read String data and convert to List<CommodityItem> list
    var commodityListString = read(StorageKey.kMainCommodityList);
    if (commodityListString == null) {
      return null;
    }

    List<dynamic> decodedData = commodityListString;
    List<Commodity> commodityList = decodedData
        .map((item) => Commodity.fromJson(item))
        .toList()
        .cast<Commodity>();

    return commodityList;
  }

  Future<void> saveDefectList(List<DefectItem> defectList) {
    // list to String
    List<Map<String, dynamic>> defectListString =
        defectList.map((e) => e.toJson()).toList();
    return write(StorageKey.kDefectList, defectListString);
  }

  List<DefectItem>? getDefectList() {
    // read String data and convert to List<DefectItem> list
    var defectListString = read(StorageKey.kDefectList);
    if (defectListString == null) {
      return null;
    }

    List<dynamic> decodedData = defectListString;
    List<DefectItem> defectList = decodedData
        .map((item) => DefectItem.fromJson(item))
        .toList()
        .cast<DefectItem>();

    return defectList;
  }

  Future<void> saveSeverityDefectList(List<SeverityDefect> severityDefectList) {
    // list to String
    List<Map<String, dynamic>> severityDefectListString =
        severityDefectList.map((e) => e.toJson()).toList();
    return write(StorageKey.kSeverityDefectList, severityDefectListString);
  }

  List<SeverityDefect>? getSeverityDefectList() {
    // read String data and convert to List<SeverityDefectItem> list
    var severityDefectListString = read(StorageKey.kSeverityDefectList);
    if (severityDefectListString == null) {
      return null;
    }

    List<dynamic> decodedData = severityDefectListString;
    List<SeverityDefect> severityDefectList = decodedData
        .map((item) => SeverityDefect.fromJson(item))
        .toList()
        .cast<SeverityDefect>();

    return severityDefectList;
  }

  Future<void> saveItemSKUList(List<FinishedGoodsItemSKU> itemSKUList) {
    // list to String
    List<Map<String, dynamic>> itemSKUListString =
        itemSKUList.map((e) => e.toJson()).toList();
    return write(StorageKey.kFinishedGoodsItemSKUList, itemSKUListString);
  }

  List<FinishedGoodsItemSKU>? getItemSKUList() {
    var itemSKUListString = read(StorageKey.kFinishedGoodsItemSKUList);
    if (itemSKUListString == null) {
      return null;
    }

    List<dynamic> decodedData = itemSKUListString;
    List<FinishedGoodsItemSKU> itemSKUList = decodedData
        .map((item) => FinishedGoodsItemSKU.fromJson(item))
        .toList()
        .cast<FinishedGoodsItemSKU>();

    return itemSKUList;
  }

  Future<void> saveOfflineCommodityList(
      List<OfflineCommodity> offlineCommodityList) {
    // list to String
    List<Map<String, dynamic>> offlineCommodityListString =
        offlineCommodityList.map((e) => e.toJson()).toList();
    return write(StorageKey.kOfflineCommodityList, offlineCommodityListString);
  }

  List<OfflineCommodity>? getOfflineCommodityList() {
    // read String data and convert to List<OfflineCommodityItem> list
    var offlineCommodityListString = read(StorageKey.kOfflineCommodityList);
    if (offlineCommodityListString == null) {
      return null;
    }

    List<dynamic> decodedData = offlineCommodityListString;
    List<OfflineCommodity> offlineCommodityList = decodedData
        .map((item) => OfflineCommodity.fromJson(item))
        .toList()
        .cast<OfflineCommodity>();

    return offlineCommodityList;
  }

  Future<void> saveSpecificationSupplierGTINList(
      List<SpecificationSupplierGTIN> specificationSupplierGTINList) {
    // list to String
    List<Map<String, dynamic>> specificationSupplierGTINListString =
        specificationSupplierGTINList.map((e) => e.toJson()).toList();
    return write(StorageKey.kSpecificationSupplierGTINList,
        specificationSupplierGTINListString);
  }

  List<SpecificationSupplierGTIN>? getSpecificationSupplierGTINList() {
    // read String data and convert to List<SpecificationSupplierGTINItem> list
    var specificationSupplierGTINListString =
        read(StorageKey.kSpecificationSupplierGTINList);
    if (specificationSupplierGTINListString == null) {
      return null;
    }

    List<dynamic> decodedData = specificationSupplierGTINListString;
    List<SpecificationSupplierGTIN> specificationSupplierGTINList = decodedData
        .map((item) => SpecificationSupplierGTIN.fromJson(item))
        .toList()
        .cast<SpecificationSupplierGTIN>();

    return specificationSupplierGTINList;
  }

  Future<void> setUserData(UserData userData) async {
    await write(StorageKey.kLoginUserData, userData.toJson());
    return;
  }

  Future<void> setNotificationSettingData(
      Map<String, dynamic> notificationModel) async {
    await write(StorageKey.kNotificationSettings, notificationModel);
    return;
  }

  Map<String, dynamic>? getNotificationSettingData() {
    var data = read(StorageKey.kNotificationSettings);
    if (data == null) {
      return null;
    }
    return data;
  }

  bool getBool(String key) {
    return read(key) ?? false;
  }

  Future<void> setBool(String key, bool value) async {
    await write(key, value);
    return;
  }

  Future<void> setString(String key, String value) async {
    await write(key, value);
    return;
  }

  Future<String?> getString(String key) async {
    return read(key);
  }

  Future<void> setInt(String key, int value) async {
    await write(key, value);
    return;
  }

  int? getInt(String key) {
    return read(key);
  }

  Future<void> initStorage() async {
    await GetStorage.init(StorageKey.kAppStorageKey);
  }

  Future<bool> isBoardWatched() async {
    return getBool(StorageKey.kIsBoardWatched);
  }

  Future<void> setHeaderMap(Map<String, String> mapData) async {
    return write(StorageKey.kHeaderMap, mapData);
  }

  Map<String, dynamic> getHeaderMap() {
    return read(StorageKey.kHeaderMap) ?? {};
  }

  Future<void> removeDataByKey(String key) {
    return storageBox().remove(key);
  }
}

class StorageKey {
  static const String kAppStorageKey = 'AppStorageKey';

  static const String kLoginUserData = 'LoginUserData';
  static const String kNotificationSettings = 'notificationSetting';
  static const String kAppLanguage = 'appLanguage';
  static const String kIsBoardWatched = 'isBoardWatched';
  static const String kBaseUrlKey = 'baseUrlKey';
  static const String kCacheDate = 'cacheDate';
  static const String kIsCSVDownloaded1 = 'isCSVDownloaded1';
  static const String kHeaderMap = 'headerMap';
  static const String kPartnerList = 'partnerList';
  static const String kCarrierList = 'carrierList';
  static const String kCommodityList = 'commodityList';
  static const String kMainCommodityList = 'mainCommodityList';
  static const String kDefectList = 'defectList';
  static const String kSeverityDefectList = 'severityDefect';
  static const String kOfflineCommodityList = 'offlineCommodity';
  static const String kSpecificationSupplierGTINList =
      'specificationSupplierGTIN';
  static const String kFinishedGoodsItemSKUList = 'finishedGoodsItemSKUList';
}
