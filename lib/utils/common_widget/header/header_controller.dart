// ignore_for_file: unused_field, prefer_final_fields, unused_local_variable, non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/images.dart';
import 'package:package_info_plus/package_info_plus.dart';

class HeaderController extends GetxController {
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  Map _source = {ConnectivityResult.none: false};
  final wifiImage1 = AppImages.ic_Wifi_off.obs;
  final isConnectedToNetwork_iOS = false.obs;
  var appVersion = ''.obs;
  HeaderController();

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
      _eventChannelStartListener();
    }
  }

  void _eventChannelStartListener() {
    _streamSubscription = stream.receiveBroadcastStream().listen(_listenStream);
  }

  void _listenStream(value) async {
    isConnectedToNetwork_iOS.value = value;
  }
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
