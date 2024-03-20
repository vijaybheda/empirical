// ignore_for_file: unused_element, prefer_const_constructors, unused_import, unused_local_variable

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/services/database/database_helper.dart';
import 'package:pverify/ui/splash_screen.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/enumeration.dart';
import 'package:pverify/utils/theme/app_theme.dart';
import 'package:pverify/utils/theme/colors_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHelper.instance.database;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  void initState() {
    Size size = WidgetsBinding.instance.window.physicalSize;
    double width = size.width;
    double height = size.height;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
          theme: AppThemeData.mThemeData(context, isDark: false),
          darkTheme: AppThemeData.mThemeData(context, isDark: false),
          themeMode: ThemeMode.light,
          debugShowCheckedModeBanner: false,
          enableLog: true,
          initialRoute: '/',
          useInheritedMediaQuery: true,
          title: AppStrings.appName,
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
