import 'dart:developer';

import 'package:get/get.dart';

abstract class GetConnectImpl extends GetConnect {
  GetConnectImpl() : super(timeout: const Duration(seconds: 25));

  void printApiLog(String url, Response<dynamic> response) {
    log('API Call ${toString()} ${runtimeType.hashCode} $url');
    log('API Call ${runtimeType.hashCode} ${response.bodyString}');
  }
}
