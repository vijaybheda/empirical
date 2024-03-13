import 'dart:developer';

import 'package:get/get.dart';
import 'package:pverify/services/custom_exception/custom_exception.dart';
import 'package:pverify/services/network_request_service/network_request_base_class.dart';

class NotificationApiService extends BaseRequestService {
  Future<String> clearAllNotification() async {
    try {
      final Response<Map<String, dynamic>> response =
          await delete('/notifications');

      final Map<String, dynamic> data = await errorHandler(response);

      return data['message'];
    } catch (e, stackTrace) {
      log(e.toString(), error: e, name: "[clearAllNotification]");

      if (e is CustomException) {
        //handled exception
        throw Exception(e.message);
      } else {
        // internal exception
        throw Exception('Oops! Something went wrong.');
      }
    }
  }

  Future<String?> markNotificationReadOrDelete(String notificationId,
      [bool isDeleteCall = false]) async {
    try {
      final String endPoint = '/notifications?ids=$notificationId';
      final Response<Map<String, dynamic>> response;
      if (isDeleteCall) {
        response = await delete(endPoint);
      } else {
        response = await put(endPoint, {});
      }
      final Map<String, dynamic> data = await errorHandler(response);
      log('Response Mark Notification : $data');

      return data['message'];
    } catch (e, stackTrace) {
      log(e.toString(), error: e, name: "[markNotificationRead]");

      if (e is CustomException) {
        //handled exception
        throw Exception(e.message);
      } else {
        // internal exception
        throw Exception('Oops! Something went wrong.');
      }
    }
  }
}
