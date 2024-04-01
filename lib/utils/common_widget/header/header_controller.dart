// ignore_for_file: unused_field, prefer_final_fields, unused_local_variable, non_constant_identifier_names, prefer_const_constructors

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HeaderController extends GetxController {
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  Map _source = {ConnectivityResult.none: false};
  var wifiImage1 = AppImages.ic_Wifi_off.obs;
  final isConnectedToNetwork_iOS = false.obs;
  var appVersion = ''.obs;
  final Connectivity _networkConnectivityIOS = Connectivity();
  final FlutterInternetSignal internetSignal = FlutterInternetSignal();
  RxBool hasStableInternet = false.obs;
  final StreamController<bool> _hasStableInternetController =
      StreamController<bool>.broadcast();
  final StreamController<int> _wifiLevelController =
      StreamController<int>.broadcast();

  ValueNotifier<int> rssiValueNotifier = ValueNotifier(-120);
  static const stream = EventChannel(AppStrings.platformEventIOS);

  late StreamSubscription _streamSubscription;

  @override
  void onInit() {
    super.onInit();
    appversion();
    if (Platform.isAndroid) {
      snetwork();
    } else if (Platform.isIOS) {
      checkInternet();
    }
  }

  Future<void> checkInternet() async {
    _networkConnectivityIOS.onConnectivityChanged.listen(
      (result) async {
        try {
          ConnectivityResult connectivityResult =
              await Connectivity().checkConnectivity();
          hasStableInternet.value =
              (connectivityResult == ConnectivityResult.wifi);

          wifiImage1.value = hasStableInternet.value
              ? AppImages.ic_Wifi_bar_3
              : AppImages.ic_Wifi_off;
          _hasStableInternetController.add(hasStableInternet.value);
        } catch (e) {
          debugPrint('Error occurred during connectivity check: $e');
          // Handle error here if needed
        }
      },
      onError: (error) {
        debugPrint('Error occurred in stream subscription: $error');
        // Handle error here if needed
      },
    );
  }

  // Future<void> checkInternet() async {
  //   _networkConnectivityIOS.onConnectivityChanged
  //       .listen((result, {error}) async {
  //     debugPrint(error);
  //     ConnectivityResult connectivityResult =
  //         await Connectivity().checkConnectivity();
  //     hasStableInternet.value = (connectivityResult == ConnectivityResult.wifi);
  //
  //     wifiImage1.value = hasStableInternet.value
  //         ? AppImages.ic_Wifi_bar_3
  //         : AppImages.ic_Wifi_off;
  //     _hasStableInternetController.add(hasStableInternet.value);
  //   });
  // }

  // FETCHED APPVERSION

  void appversion() {
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      String appName = packageInfo.appName;
      String packageName = packageInfo.packageName;
      String version = packageInfo.version;
      String buildNumber = packageInfo.buildNumber;
      appVersion.value = version;
    });
  }

  void networkChecker() async {
    final FlutterInternetSignal internetSignal = FlutterInternetSignal();
    final int? mobileSignal = await internetSignal.getMobileSignalStrength();
    final int wifiSignal = await internetSignal.getWifiSignalStrength() ?? 0;

    if (wifiSignal <= -50 && wifiSignal >= -60) {
      wifiImage1.value = AppImages.ic_Wifi_bar_3;
    } else if (wifiSignal <= -61 && wifiSignal >= -70) {
      wifiImage1.value = AppImages.ic_Wifi_bar_3;
    } else if (wifiSignal <= -71 && wifiSignal >= -80) {
      wifiImage1.value = AppImages.ic_Wifi_bar_2;
    } else if (wifiSignal <= -81 && wifiSignal >= -90) {
      wifiImage1.value = AppImages.ic_Wifi_bar_1;
    } else if (wifiSignal <= -91) {
      wifiImage1.value = AppImages.ic_Wifi_off;
    } else {
      wifiImage1.value = AppImages.ic_Wifi_off;
    }
  }

  void snetwork() {
    _networkConnectivity.initialise();
    _networkConnectivity.myStream.listen((source) {
      _source = source;
      networkChecker();
    });
  }
}

// CONTINUOUS NETWORK MONITOR CONTROLLER

class NetworkConnectivity {
  NetworkConnectivity._();
  static final _instance = NetworkConnectivity._();
  static NetworkConnectivity get instance => _instance;
  final _networkConnectivity = Connectivity();
  final _controller = StreamController.broadcast();
  Stream get myStream => _controller.stream;
  // 1.
  void initialise() async {
    ConnectivityResult result = await _networkConnectivity.checkConnectivity();
    _checkStatus(result);
    _networkConnectivity.onConnectivityChanged.listen((result) {
      _checkStatus(result);
    });
  }

// 2.
  void _checkStatus(ConnectivityResult result) async {
    bool isOnline = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      isOnline = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      isOnline = false;
    }
    _controller.sink.add({result: isOnline});
  }

  void disposeStream() => _controller.close();
}
