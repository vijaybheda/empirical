import 'dart:developer';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pverify/services/custom_exception/custom_exception.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/utils/app_storage.dart';

class BaseRequestService extends GetConnect {
  static const String timeOut = "timed out";
  static const String timeOut2 = "TimeoutException";
  static const String platformException = "SocketException: Failed host lookup";
  static const String unAuthorizedMessage =
      'To view the contents, kindly contact the admin.';

  final AppStorage appStorage = AppStorage.instance;

  @override
  void onInit() {
    httpClient.baseUrl = ApiUrls.serverUrl;
    final String authToken = appStorage.read(StorageKey.jwtToken) ?? "";
    httpClient.defaultContentType = "application/json";
    httpClient.timeout = const Duration(seconds: 10);
    final Map<String, String> headers = {'Authorization': "Bearer $authToken"};
    log('Bearer$authToken');
    httpClient.addRequestModifier<Object?>((request) {
      request.headers.addAll(headers);
      return request;
    });

    super.onInit();
  }

  Future<Map<String, dynamic>> errorHandler(
      Response<Map<String, dynamic>> response) async {
    switch (response.statusCode) {
      case 200:
        Map<String, dynamic>? responseJson = response.body;
        return responseJson!;
      case 400:
        throw CustomException(response
            .body?["message"]); //user phone/otp number not registered/wrong
      case 401:
        String message = response.body?["message"];
        // await LoginServices.unAuthorizedRedirection(message);
        throw CustomException(unAuthorizedMessage);
      case 404:
        throw throw CustomException(response.body?["message"]);
      case 500:
        throw CustomException(response.body?["message"]);
      case 403:
        String message = response.body?["message"];
        // await LoginServices.unAuthorizedRedirection(message);
        throw CustomException(unAuthorizedMessage);
      case null:
        if ((response.statusText ?? "").contains(timeOut) ||
            (response.statusText ?? "").contains(timeOut2)) {
          throw CustomException("Timeout, Please try again after some time.");
        } else if ((response.statusText ?? "").startsWith(platformException)) {
          throw CustomException("Please check your internet connection.");
        }
        throw Exception(response.statusText);
      default:
        throw Exception(response.statusText);
    }
  }

  String? getString(String key) => GetStorage().read(key);
}
