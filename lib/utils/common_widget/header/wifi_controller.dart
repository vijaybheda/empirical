// ignore_for_file: unused_field, prefer_final_fields, unused_local_variable

import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_internet_signal/flutter_internet_signal.dart';
import 'package:get/get.dart';
import 'package:pverify/utils/common_widget/header/header.dart';
import 'package:pverify/utils/images.dart';

class WifiController extends GetxController {
  final NetworkConnectivity _networkConnectivity = NetworkConnectivity.instance;
  Map _source = {ConnectivityResult.none: false};
  final wifiImage1 = AppImages.ic_Wifi_off.obs;
  WifiController();

  @override
  void onInit() {
    super.onInit();
    snetwork();
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
