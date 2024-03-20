import 'package:get_storage/get_storage.dart';
import 'package:pverify/models/login_data.dart';
import 'package:pverify/models/user.dart';

class AppStorage {
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
    return await getBool(StorageKey.kIsBoardWatched);
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
}
