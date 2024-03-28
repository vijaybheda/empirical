import 'dart:developer';

import 'package:get/get.dart';
import 'package:pverify/models/login_data.dart';
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

  Future<LoginData?> checkLogin(String requestUrl, String mUsername,
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
      LoginData currentUser = LoginData.fromJson(data);
      await AppStorage.instance.setLoginData(currentUser);
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
        // Get.showSnackbar(GetSnackBar(
        //   title: 'Error',
        //   message: e.message,
        //   backgroundColor: AppColors.red,
        //   icon: const Icon(Icons.error_outline_rounded),
        //   duration: const Duration(seconds: 1, milliseconds: 500),
        //   key: const Key('error'),
        // ));
        throw Exception(e.message);
      } else {
        // internal exception
        throw Exception('Oops! Something went wrong.');
      }
      return null;
    }
  }
}
