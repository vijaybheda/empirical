import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/auth_controller.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/ui/splash_screen.dart';
import 'package:pverify/utils/theme/colors_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: GetMaterialApp(
          debugShowCheckedModeBanner: false,
          enableLog: true,
          initialRoute: '/',
          useInheritedMediaQuery: true,
          title: 'p-ver-ify',
          theme: ThemeColor.mThemeData(context),
          darkTheme: ThemeColor.mThemeData(context, isDark: true),
          initialBinding: GlobalBindings(),
          defaultTransition: Transition.cupertino,
          opaqueRoute: Get.isOpaqueRouteDefault,
          popGesture: Get.isPopGestureEnable,
          transitionDuration: const Duration(milliseconds: 500),
          defaultGlobalState: true,
          themeMode: ThemeMode.light,
          home: const SplashScreen()),
    );
  }
}

class GlobalBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AuthController(), fenix: true);
    Get.lazyPut(() => GlobalConfigController(), fenix: true);
  }
}
