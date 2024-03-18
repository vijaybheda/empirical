import 'dart:developer';

import 'package:get/get.dart';
import 'package:pverify/models/user.dart';
import 'package:pverify/services/custom_exception/custom_exception.dart';
import 'package:pverify/services/network_request_service/network_request_base_class.dart';
import 'package:pverify/utils/app_storage.dart';

class UserService extends BaseRequestService {
  late int phoneNumber;
  String hashData = "";

  Future<User> getUser() async {
    try {
      final Response<Map<String, dynamic>> result = await get("/me");
      log('result is ${result.body}');
      final Map<String, dynamic> data = await errorHandler(result);
      User currentUser = User.fromJson(data['data']);
      AppStorage.instance.setUserData(currentUser);
      return currentUser;
    } catch (e, stackTrace) {
      log(e.toString(), error: e, name: "[getUser]");

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
