import 'dart:developer';

import 'package:get/get.dart';
import 'package:pverify/models/user_data.dart';
import 'package:pverify/services/custom_exception/custom_exception.dart';
import 'package:pverify/services/network_request_service/network_request_base_class.dart';
import 'package:pverify/utils/app_storage.dart';

class UserService extends BaseRequestService {
  late int phoneNumber;
  String hashData = "";

  Future<UserData> getUser() async {
    try {
      final Response<Map<String, dynamic>> result = await get("/me");
      log('result is ${result.body}');
      final Map<String, dynamic> data = await errorHandler(result);
      UserData currentUser = UserData.fromJson(data['data']);
      AppStorage.instance.setUserData(currentUser);
      return currentUser;
    } catch (e) {
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

  Future<UserData?> checkLogin(String requestUrl, String mUsername,
      String mPassword, bool isLoginButton) async {
    try {
      final Response result = await getCallResponse(
        requestUrl,
        headers: {
          'username': mUsername,
          'password': mPassword,
        },
      );
      log('result is ${result.body}');
      final Map<String, dynamic> data =
          await errorHandlerDynamicResponse(result);
      UserData currentUser = UserData.fromJson(data);
      currentUser = currentUser.copyWith(
        userName: data['userName'],
        language: data['language'],
      );
      await AppStorage.instance.setUserData(currentUser);
      await AppStorage.instance.setHeaderMap({
        'username': mUsername,
        'password': mPassword,
      });
      return currentUser;
    } catch (e) {
      log(e.toString(), error: e, name: "[checkLogin]");
      if (e is CustomException) {
        //handled exception
        rethrow;
        // Utils.hideLoadingDialog();
        // throw Exception(e.message);
      } else {
        // internal exception
        throw Exception('Oops! Something went wrong.');
      }
      // return null;
    }
  }
}
