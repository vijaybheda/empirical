// ignore_for_file: unused_element, prefer_const_constructors, unused_import

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/services/database/database_helper.dart';
import 'package:pverify/ui/login_screen.dart';
import 'package:pverify/ui/photos_selection/photos_selection.dart';
import 'package:pverify/ui/worksheet/worksheet.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/enumeration.dart';
import 'package:pverify/utils/theme/app_theme.dart';
import 'package:pverify/utils/theme/colors_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await AppStorage.instance.initStorage();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);

    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: ScreenUtilInit(
        designSize: Size(1200, 2670),
        builder: (context, child) => GetMaterialApp(
          theme: AppThemeData.mThemeData(context, isDark: false),
          darkTheme: AppThemeData.mThemeData(context, isDark: true),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          enableLog: true,
          locale: Get.deviceLocale ?? Locale('en', 'US'),
          initialRoute: '/',
          useInheritedMediaQuery: true,
          title: AppStrings.appName,
          initialBinding: GlobalBindings(),
          defaultTransition: Transition.cupertino,
          opaqueRoute: Get.isOpaqueRouteDefault,
          popGesture: Get.isPopGestureEnable,
          transitionDuration: const Duration(milliseconds: 500),
          defaultGlobalState: true,
          home: const PhotosSelection(),
        ),
        child: PhotosSelection(),
      ),
    );
  }
}

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(() => GlobalConfigController(), permanent: true);
  }
}
