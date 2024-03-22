import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pverify/models/carrier_item.dart';
import 'package:pverify/models/commodity_item.dart';
import 'package:pverify/models/defect_item.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/models/offline_commodity.dart';
import 'package:pverify/models/partner_item.dart';
import 'package:pverify/models/severity_defect.dart';
import 'package:pverify/models/user.dart';

class AppStorage extends GetxController {
  // ignore: prefer_function_declarations_over_variables
  final storageBox = () => GetStorage(StorageKey.kAppStorageKey);

  // instance of this class
  static AppStorage get instance => _instance;
  static final AppStorage _instance = AppStorage._internal();

  AppStorage._internal();

  Future<void> appLogout() async {
    await storageBox().remove(StorageKey.kIsBoardWatched);
    await storageBox().remove(StorageKey.kUser);
    await storageBox().remove(StorageKey.kNotificationSettings);
    return;
  }

  dynamic read(String key) {
    return storageBox().read(key);
  }

  Future<void> write(String key, dynamic value) async {
    return await storageBox().write(key, value);
  }

  User? getUserData() {
    String? loggedInUser = read(StorageKey.kUser);
    if (loggedInUser == null) {
      return null;
    }
    User user = User.fromJson(loggedInUser);
    return user;
  }

  Future<void> setUserData(User user) async {
    await write(StorageKey.kUser, user.toJson());
    return;
  }

  LoginData? getLoginData() {
    Map<String, dynamic>? loggedInUser = read(StorageKey.kLoginUserData);
    if (loggedInUser == null) {
      return null;
    }
    LoginData loginData = LoginData.fromJson(loggedInUser);
    return loginData;
  }

  Future<void> savePartnerList(List<PartnerItem> partnerList) {
    // list to String
    List<Map<String, dynamic>> partnerListString =
        partnerList.map((e) => e.toJson()).toList();
    return write(StorageKey.kPartnerList, partnerListString);
  }

  List<PartnerItem>? getPartnerList() {
    // read String data and convert to List<PartnerItem> list
    String? partnerListString = read(StorageKey.kPartnerList);
    if (partnerListString == null) {
      return null;
    }

    List<dynamic> decodedData = json.decode(partnerListString);
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
    String? carrierListString = read(StorageKey.kCarrierList);
    if (carrierListString == null) {
      return null;
    }

    List<dynamic> decodedData = json.decode(carrierListString);
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
    String? commodityListString = read(StorageKey.kCommodityList);
    if (commodityListString == null) {
      return null;
    }

    List<dynamic> decodedData = json.decode(commodityListString);
    List<CommodityItem> commodityList = decodedData
        .map((item) => CommodityItem.fromJson(item))
        .toList()
        .cast<CommodityItem>();

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
    String? defectListString = read(StorageKey.kDefectList);
    if (defectListString == null) {
      return null;
    }

    List<dynamic> decodedData = json.decode(defectListString);
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
    String? severityDefectListString = read(StorageKey.kSeverityDefectList);
    if (severityDefectListString == null) {
      return null;
    }

    List<dynamic> decodedData = json.decode(severityDefectListString);
    List<SeverityDefect> severityDefectList = decodedData
        .map((item) => SeverityDefect.fromJson(item))
        .toList()
        .cast<SeverityDefect>();

    return severityDefectList;
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
    String? offlineCommodityListString = read(StorageKey.kOfflineCommodityList);
    if (offlineCommodityListString == null) {
      return null;
    }

    List<dynamic> decodedData = json.decode(offlineCommodityListString);
    List<OfflineCommodity> offlineCommodityList = decodedData
        .map((item) => OfflineCommodity.fromJson(item))
        .toList()
        .cast<OfflineCommodity>();

    return offlineCommodityList;
  }

  Future<void> setLoginData(LoginData loginData) async {
    await write(StorageKey.kLoginUserData, loginData.toJson());
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

  Future<int?> getInt(String key) async {
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
}

class StorageKey {
  static const String kAppStorageKey = 'AppStorageKey';

  static const String kUser = 'LoggedInUser';
  static const String kLoginUserData = 'LoginUserData';
  static const String kNotificationSettings = 'notificationSetting';
  static const String kAppLanguage = 'appLanguage';
  static const String kIsBoardWatched = 'isBoardWatched';
  static const String jwtToken = 'jwtToken';
  static const String kBaseUrlKey = 'baseUrlKey';
  static const String kCacheDate = 'cacheDate';
  static const String kIsCSVDownloaded1 = 'isCSVDownloaded1';
  static const String kHeaderMap = 'headerMap';
  static const String kPartnerList = 'partnerList';
  static const String kCarrierList = 'carrierList';
  static const String kCommodityList = 'commodityList';
  static const String kDefectList = 'defectList';
  static const String kSeverityDefectList = 'severityDefect';
  static const String kOfflineCommodityList = 'offlineCommodity';
}
