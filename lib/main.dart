import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pverify/controller/global_config_controller.dart';
import 'package:pverify/services/database/database_helper.dart';
import 'package:pverify/ui/login_screen.dart';
import 'package:pverify/utils/app_storage.dart';
import 'package:pverify/utils/app_strings.dart';
import 'package:pverify/utils/theme/colors_theme.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.database;
  await AppStorage.instance.initStorage();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://acc77a1e828b627090bc26c0c2f16b50@o4507260711403520.ingest.us.sentry.io/4507260712648704';
      // Set tracesSampleRate to 1.0 to capture 100% of transactions for performance monitoring.
      // We recommend adjusting this value in production.
      options.tracesSampleRate = 1.0;
      // The sampling rate for profiling is relative to tracesSampleRate
      // Setting to 1.0 will profile 100% of sampled transactions:
      options.profilesSampleRate = 1.0;
    },
    appRunner: () => runApp(const MyApp()),
  );
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
        designSize: const Size(1200, 2670),
        builder: (context, child) => GetMaterialApp(
          theme: AppThemeData.mThemeData(context, isDark: false),
          darkTheme: AppThemeData.mThemeData(context, isDark: true),
          themeMode: ThemeMode.dark,
          debugShowCheckedModeBanner: false,
          enableLog: true,
          locale: Get.deviceLocale ?? const Locale('en', 'US'),
          initialRoute: '/',
          useInheritedMediaQuery: true,
          title: AppStrings.appName,
          initialBinding: GlobalBindings(),
          defaultTransition: Transition.cupertino,
          opaqueRoute: Get.isOpaqueRouteDefault,
          popGesture: Get.isPopGestureEnable,
          transitionDuration: const Duration(milliseconds: 500),
          defaultGlobalState: true,
          home: const LoginScreen(),
        ),
        child: const LoginScreen(),
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
