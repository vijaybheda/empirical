import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/models/user.dart';
import 'package:pverify/utils/app_storage.dart';

class AuthController extends GetxController {
  bool isLoading = false;

  User? userModel;
  final TextEditingController emailTextController = TextEditingController();
  final TextEditingController passwordTextController = TextEditingController();
  final FocusNode fNodeEmail = FocusNode();
  final FocusNode fNodePass = FocusNode();

  bool socialButtonVisible = true;
  AppStorage appStorage = AppStorage.instance;

  bool isLoggedIn() {
    User? userData = AppStorage.instance.getUserData();

    return userData != null;
  }

  Future<void> userLogout() async {
    //get user data
    AppStorage appStorage = AppStorage.instance;
    // User? userData = appStorage.getUserData();
    //user data remove
    await appStorage.appLogout();
  }
}
