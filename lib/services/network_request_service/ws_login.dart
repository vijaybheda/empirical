import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:pverify/models/update_info.dart';

class WsLogin {
  Future<UpdateInfo?> fetchDownloadURL(
      {required String username, required String password}) async {
    var headers = {
      'username': username,
      'password': password,
      'Content-Type': 'application/json',
      'Cookie': 'JSESSIONID=00EFC46A980AC62163CADD6FDD1954F8'
    };

    var data = {"username": username, "password": password};

    try {
      var response = await Dio().request(
        'https://appqa.share-ify.com/PM/rest/ws/inspection/getAndroidUpdateInfo',
        options: Options(
          method: 'GET',
          headers: headers,
          sendTimeout: const Duration(milliseconds: 1000),
          receiveTimeout: const Duration(milliseconds: 1000),
        ),
        data: data,
      );

      if (response.statusCode == 200) {
        var responseData = response.data;
        return UpdateInfo.fromJson(responseData['updateInfo']);
      } else {
        debugPrint('🔴 Failed to load download URL');
        throw Exception('Failed to load download URL');
      }
    } catch (e) {
      debugPrint('🔴 Error fetching download URL: $e');
      return null;
    }
  }
}
