import 'dart:convert';

import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pverify/services/custom_exception/custom_exception.dart';
import 'package:pverify/services/network_request_service/api_urls.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';

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
    httpClient.defaultContentType = "application/json";
    httpClient.timeout = const Duration(seconds: 60);
    // final Map<String, String> headers = {'Authorization': "Bearer $authToken"};
    final Map<String, String> headers = appStorage.read(StorageKey.kHeaderMap);
    // log('Bearer$authToken');
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
        // String message = response.body?["message"];
        // await LoginServices.unAuthorizedRedirection(message);
        throw CustomException(unAuthorizedMessage);
      case 404:
        throw throw CustomException(response.body?["message"]);
      case 500:
        throw CustomException(response.body?["message"]);
      case 403:
        // String message = response.body?["message"];
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

  Future<Map<String, dynamic>> errorHandlerDynamicResponse(
      Response response) async {
    switch (response.statusCode) {
      case 200:
        Map<String, dynamic>? responseJson = response.body;
        return responseJson!;
      case 400:
        throw CustomException(extractMessage(response.body));
      case 401:
        String message = AppStrings.invalidUsernamePassword;
        // await LoginServices.unAuthorizedRedirection(message);
        throw CustomException(message, code: 401);
      case 404:
        throw throw CustomException(extractMessage(response.body), code: 404);
      case 500:
        throw CustomException(extractMessage(response.body));
      case 403:
        String message = extractMessage(response.body);
        // await LoginServices.unAuthorizedRedirection(message);
        throw CustomException(message);
      case null:
        if ((response.statusText ?? "").contains('SocketException')) {
          throw CustomException(
              "Looks like there's a problem connecting to the network. Please check your internet connection and try again.");
        } else if ((response.statusText ?? "").contains('FormatException')) {
          throw CustomException(
              "Oops! Something went wrong while processing the data from the server. Please try again later.");
        } else if ((response.statusText ?? "").contains('TimeoutException')) {
          throw CustomException(
              "Oh no! It seems like the request took too long to complete. Please check your internet connection and try again.");
        } else if ((response.statusText ?? "").contains('ClientException')) {
          throw CustomException(
              "Looks like there's an issue with your request. Please double-check your information and try again.");
        }
        throw CustomException(response.statusText!);
      default:
        throw CustomException(response.statusText!);
    }
  }

  String? getString(String key) => GetStorage().read(key);

  // global get request
  Future<Response<Map<String, dynamic>>> getCall(
    String url, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    Map<String, String>? headersMap;

    if (headers != null && headers.isNotEmpty) {
      headersMap = headers.map((key, value) {
        return MapEntry(key, value.toString());
      });
    }
    Response<Map<String, dynamic>> response =
        await super.get<Map<String, dynamic>>(
      url,
      query: query,
      headers: headersMap,
    );
    if (response.isOk) {
      return response;
    } else {
      throw await errorHandler(response);
    }
  }

  // get dynamic Response
  Future<Response> getCallResponse(
    String url, {
    Map<String, dynamic>? query,
    Map<String, dynamic>? headers,
  }) async {
    Map<String, String>? headersMap;

    if (headers != null && headers.isNotEmpty) {
      headersMap = headers.map((key, value) {
        return MapEntry(key, value.toString());
      });
    }
    Response response = await super.get(
      url,
      query: query,
      headers: headersMap,
    );
    if (response.isOk) {
      return response;
    } else {
      throw await errorHandlerDynamicResponse(response);
    }
  }

  String extractMessage(var content) {
    String htmlContent;
    if (content is String) {
      htmlContent = content.toString();
      // Find the start and end index of the message
      int startIndex = htmlContent.indexOf('<title>');
      int endIndex = htmlContent.indexOf('</title>', startIndex);

      // Extract the title
      String title = htmlContent.substring(startIndex + 7, endIndex);

      return title;
    } else {
      Map data = jsonDecode(content);
      return data['message'];
    }
  }
}
