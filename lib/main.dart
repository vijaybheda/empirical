// ignore_for_file: unused_element, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/services/database/database_helper.dart';
import 'package:pverify/ui/splash_screen.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/enumeration.dart';
import 'package:pverify/utils/theme/app_theme.dart';
import 'package:pverify/utils/theme/colors_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await AppStorage.instance.initStorage();
  runApp(const MyApp());
}

// Dark Theme Colors

ThemeData currentTheme =
    AppConst.AppTheme == ThemeType.dark ? _darkTheme : _lightTheme;
ThemeData _darkTheme = ThemeData(
    hintColor: Colors.red,
    brightness: Brightness.dark,
    primaryColor: Colors.amber,
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.amber,
      disabledColor: Colors.grey,
    ));

// Light Theme Colors

ThemeData _lightTheme = ThemeData(
    hintColor: Colors.pink,
    brightness: Brightness.light,
    primaryColor: Colors.blue,
    buttonTheme: ButtonThemeData(
      buttonColor: Colors.blue,
      disabledColor: Colors.grey,
    ));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  void initState() {
    Size size = WidgetsBinding.instance.window.physicalSize;
    double width = size.width;
    double height = size.height;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
          theme: currentTheme,
          darkTheme: _darkTheme,
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          enableLog: true,
          locale: Get.deviceLocale ?? Locale('en', 'US'),
          initialRoute: '/',
          useInheritedMediaQuery: true,
          title: 'p-ver-ify',
          initialBinding: GlobalBindings(),
          defaultTransition: Transition.cupertino,
          opaqueRoute: Get.isOpaqueRouteDefault,
          popGesture: Get.isPopGestureEnable,
          transitionDuration: const Duration(milliseconds: 500),
          defaultGlobalState: true,
          home: ScreenUtilInit(
            designSize: Size(1200, 2670),
            child: const SplashScreen(),
          )),
    );
  }
}

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => GlobalConfigController(), fenix: true);
  }
}
