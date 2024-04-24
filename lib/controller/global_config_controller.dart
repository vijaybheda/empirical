import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';
import 'package:get/get.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pverify/services/database/application_dao.dart';
import 'package:pverify/ui/login_screen.dart';
import 'package:pverify/utils/app_storage.dart';

class GlobalConfigController extends GetxController {
  final AppStorage appStorage = AppStorage.instance;
  // late StreamSubscription _streamSubscription;
  // static const stream = EventChannel(AppStrings.platformEventIOS);
  RxBool hasStableInternet = false.obs;
  RxInt wifiLevel = 0.obs;
  final Connectivity _networkConnectivity = Connectivity();
  final FlutterInternetSignal internetSignal = FlutterInternetSignal();

  final StreamController<bool> _hasStableInternetController =
      StreamController<bool>.broadcast();
  final StreamController<int> _wifiLevelController =
      StreamController<int>.broadcast();

  Stream<bool> get hasStableInternetStream =>
      _hasStableInternetController.stream;
  Stream<int> get wifiLevelStream => _wifiLevelController.stream;

  RxString appVersion = ''.obs;
  final ApplicationDao dao = ApplicationDao();

  @override
  void onInit() {
    log('GlobalConfigController onInit');
    fetchAppVersion();
    checkInternet();
    // if (Platform.isIOS) {
    //   _eventChannelStartListener();
    // }
    super.onInit();
    Future.delayed(const Duration(milliseconds: 200)).then((value) {
      wifiLevelStream.listen((wifiLevel) {
        debugPrint('_wifiLevel $wifiLevel');
      });
    });
  }

  // void _eventChannelStartListener() {
  //   _streamSubscription = stream.receiveBroadcastStream().listen(_listenStream);
  // }

  // void _listenStream(value) {
  //   hasStableInternet.value = value;
  //   _hasStableInternetController.add(hasStableInternet.value);
  //   _wifiLevelController.add(hasStableInternet.value ? 3 : 0);
  // }

  Future<int?> networkChecker() async {
    final int wifiSignal = await internetSignal.getWifiSignalStrength() ?? 0;

    if (wifiSignal <= -50 && wifiSignal >= -60) {
      return 4;
    } else if (wifiSignal <= -61 && wifiSignal >= -70) {
      return 3;
    } else if (wifiSignal <= -71 && wifiSignal >= -80) {
      return 2;
    } else if (wifiSignal <= -81 && wifiSignal >= -90) {
      return 1;
    } else if (wifiSignal <= -91) {
      return null;
    } else {
      return 4;
    }
  }

  Future<void> checkInternet() async {
    if (Platform.isAndroid) {
      int? networkStrength = await networkChecker();
      hasStableInternet.value =
          (networkStrength != null && networkStrength > 2);
      _hasStableInternetController.add(hasStableInternet.value);
      wifiLevel.value = networkStrength ?? 0;
      _wifiLevelController.add(networkStrength ?? 0);
      update();
    }

    _networkConnectivity.onConnectivityChanged.listen((result) async {
      if (Platform.isAndroid) {
        if (result.contains(ConnectivityResult.none)) {
          hasStableInternet.value = false;
          _hasStableInternetController.add(hasStableInternet.value);
          wifiLevel.value = 0;
          _wifiLevelController.add(0);
          update();
          return;
        }
        int? networkStrength = await networkChecker();
        hasStableInternet.value =
            (networkStrength != null && networkStrength > 2);
        _hasStableInternetController.add(hasStableInternet.value);
        wifiLevel.value = networkStrength ?? 0;
        _wifiLevelController.add(networkStrength ?? 0);
        update();
      } else if (Platform.isIOS) {
        List<ConnectivityResult> connectivityResult =
            await Connectivity().checkConnectivity();
        hasStableInternet.value =
            (connectivityResult.contains(ConnectivityResult.wifi));

        wifiLevel.value = hasStableInternet.value ? 3 : 0;
        _hasStableInternetController.add(hasStableInternet.value);
        _wifiLevelController.add(wifiLevel.value);
        update();
      } else {
        hasStableInternet.value = false;
        _hasStableInternetController.add(hasStableInternet.value);
        wifiLevel.value = 0;
        _wifiLevelController.add(wifiLevel.value);
        update();
      }
    });
  }

  @override
  void onReady() {
    log('GlobalConfigController onReady');
    super.onReady();
  }

  /* @override
  void dispose() {
    log('GlobalConfigController dispose');
    // _streamSubscription.cancel();
    _hasStableInternetController.close();
    _wifiLevelController.close();
    super.dispose();
  }*/

  @override
  void onClose() {
    log('GlobalConfigController onClose');
    super.onClose();
  }

  void fetchAppVersion() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String version = packageInfo.version;
      appVersion.value = version;
    });
  }

  Future<void> appLogoutAction({Function()? onSuccess}) async {
    int tempTrailer = await dao.deleteRowsTempTrailerTable();
    log('Deleted $tempTrailer rows from temp_trailer table.');
    int tempTrailerDetail = await dao.deleteTempTrailerTemperatureDetails();
    log('Deleted $tempTrailerDetail rows from temp_trailer_temperature_details table.');
    await appStorage.removeDataByKey(StorageKey.kFinishedGoodsItemSKUList);
    int selectedItemSku = await dao.deleteSelectedItemSKUList();
    log('Deleted $selectedItemSku rows from selected_item_sku_list table.');

    if (onSuccess != null) {
      onSuccess.call();
    }
    Get.offAll(() => const LoginScreen());
  }
}
