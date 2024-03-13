import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/user_model.dart';
import 'package:pverify/utils/app_storage.dart';

class AuthController extends GetxController {
  bool isLoading = false;

  UserModel? userModel;
  TextEditingController emailTextController = TextEditingController();
  TextEditingController passwordTextController = TextEditingController();

  bool socialButtonVisible = true;
  AppStorage appStorage = AppStorage.instance;

  bool isLoggedIn() {
    UserModel? userData = AppStorage.instance.getUserData();

    return userData != null;
  }

  Future<void> userLogout() async {
    //get user data
    AppStorage appStorage = AppStorage.instance;
    // UserModel? userData = appStorage.getUserData();
    //user data remove
    await appStorage.appLogout();
  }
}
