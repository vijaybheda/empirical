// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/app_font.dart';
import 'package:pverify/utils/theme/colors.dart';

class AppThemeData {
  static ThemeData mThemeData(BuildContext context, {bool isDark = false}) {
    return ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        primaryColor: isDark ? AppColors.primary : AppColors.primary,
        scaffoldBackgroundColor: isDark ? AppColors.white : AppColors.grey,
        applyElevationOverlayColor: true,
        bannerTheme: MaterialBannerTheme.of(context),
        bottomAppBarTheme: BottomAppBarTheme.of(context),
        canvasColor: isDark ? Colors.white : Colors.grey[50]!,
        cardColor: isDark ? Colors.black : Colors.white,
        cardTheme: CardTheme(
          color: isDark ? Colors.black : Colors.white,
          clipBehavior: Clip.antiAliasWithSaveLayer,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: isDark ? AppColors.primaryColor : AppColors.blue,
        ),
        checkboxTheme: CheckboxThemeData(
            checkColor: MaterialStateProperty.all(Colors.white),
            fillColor: MaterialStateProperty.all(AppColors.primaryColor),
            visualDensity: VisualDensity.adaptivePlatformDensity),
        dialogBackgroundColor: Colors.white,
        dialogTheme: DialogTheme(
          backgroundColor: Colors.white,
          contentTextStyle: Theme.of(context).textTheme.bodyLarge,
        ),
        dividerColor: Colors.grey[500],
        dividerTheme: DividerThemeData(
            color: Colors.grey[500], indent: 8.0, endIndent: 8.0, space: 8.0),
        focusColor: Colors.pink[50],
        fontFamily: AppFont.fontFamily,
        hintColor: Colors.grey,
        indicatorColor: AppColors.primaryColor,
        outlinedButtonTheme: OutlinedButtonThemeData(style: textButtonStyle),
        primaryTextTheme: textTheme(isDark, context),
        textButtonTheme: TextButtonThemeData(style: textButtonStyle),
        timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.white,
            hourMinuteColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected)
                    ? AppColors.lightGrey
                    : AppColors.lightGrey),
            hourMinuteTextColor: MaterialStateColor.resolveWith(
                (states) => AppColors.primaryColor),
            dialHandColor: Colors.pink.shade200,
            dialBackgroundColor: AppColors.lightGrey,
            dayPeriodColor: AppColors.primaryColor,
            dialTextColor: MaterialStateColor.resolveWith((states) =>
                states.contains(MaterialState.selected)
                    ? Colors.black
                    : Colors.black),
            entryModeIconColor: AppColors.primaryColor),
        buttonTheme: ButtonThemeData(
          height: 50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          // buttonColor: pink,
          textTheme: ButtonTextTheme.normal,
        ),
        inputDecorationTheme: InputDecorationTheme(
          focusColor: AppColors.primaryColor,
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            ),
          ),
          errorBorder: OutlineInputBorder(
            gapPadding: 0,
            borderRadius: BorderRadius.circular(20),
            borderSide: const BorderSide(
              color: Colors.grey,
            ),
          ),
          errorStyle: const TextStyle(color: Colors.red),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(
              color: AppColors.primaryColor,
            ),
          ),
          hintStyle: TextStyle(
            fontSize: 14, // 35
            fontFamily: AppFont.fontFamily,
            color: AppColors.primaryColor,
          ),
        ),
        appBarTheme: AppBarTheme(
          iconTheme: const IconThemeData(color: Colors.white),
          backgroundColor: const Color(0xffF3F4F9),
          elevation: 0,
          actionsIconTheme: IconThemeData(color: AppColors.primaryColor),
          toolbarTextStyle: TextTheme(
                  bodyLarge: TextStyle(
                    fontSize: 29.h, // 35
                    fontFamily: AppFont.fontFamily,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  bodyMedium: TextStyle(
                      fontSize: 29, // 35
                      fontFamily: AppFont.fontFamily,
                      color: Colors.grey))
              .bodyMedium,
          titleTextStyle: TextTheme(
                  bodyLarge: TextStyle(
                    fontSize: 29, // 35
                    fontFamily: AppFont.fontFamily,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                  bodyMedium: TextStyle(
                      fontSize: 29, // 35
                      fontFamily: AppFont.fontFamily,
                      color: Colors.grey))
              .titleLarge,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          elevation: 0,
          backgroundColor: Colors.white,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: AppColors.primaryColor,
          unselectedItemColor: Colors.grey,
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey[400],
          labelStyle: TextStyle(
            fontSize: 22,
            fontFamily: AppFont.fontFamily,
          ),
          unselectedLabelStyle: TextStyle(
            fontSize: 22,
            fontFamily: AppFont.fontFamily,
          ),
        ),
        textTheme: textTheme(isDark, context),
        snackBarTheme: SnackBarThemeData(
          actionTextColor: Colors.white,
          backgroundColor: isDark ? Colors.white : Colors.black,
          behavior: SnackBarBehavior.floating,
          elevation: 3,
        ),
        colorScheme: ColorScheme(
          primary: isDark ? AppColors.darkBackgroundGrey : AppColors.lightGrey,
          secondary:
              isDark ? AppColors.lightBackgroundGrey : AppColors.lightGrey,
          brightness: Brightness.light,
          background: isDark ? AppColors.dark : Colors.white,
          error: Colors.red,
          onBackground: isDark ? AppColors.dark : AppColors.white,
          onError: Colors.red,
          onPrimary:
              isDark ? AppColors.darkBackgroundGrey : AppColors.lightGrey,
          onSecondary:
              isDark ? AppColors.lightBackgroundGrey : AppColors.lightGrey,
          onSurface: AppColors.lightGrey,
          surface: AppColors.lightGrey,
        ) //.copyWith(background: AppColors.lightGrey).copyWith(error: Colors.red),
        );
  }

  static ButtonStyle get textButtonStyle {
    return TextButton.styleFrom(
      // backgroundColor: primaryColor,
      textStyle: TextStyle(
        color: Colors.white,
        fontFamily: AppFont.fontFamily,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  static TextTheme textTheme(isDark, context) {
    return TextTheme(
      displayLarge: GoogleFonts.poppins(
          fontSize: 34.sp,
          fontWeight: FontWeight.w700,
          textStyle: TextStyle(color: AppColors.white)),
      displayMedium: GoogleFonts.poppins(
          fontSize: 30.sp,
          fontWeight: FontWeight.w600,
          textStyle:
              TextStyle(color: isDark ? AppColors.white : AppColors.black)),
      displaySmall: TextStyle(
          fontSize: 9,
          fontFamily: AppFont.fontFamily,
          color: AppColors.lightGrey,
          letterSpacing: 0,
          height: 1.7,
          fontWeight: FontWeight.w500),
      headlineLarge: TextStyle(
          fontSize: 19.5,
          fontFamily: AppFont.fontMedium,
          color: AppColors.darkPrimaryColor,
          letterSpacing: 0,
          fontWeight: FontWeight.w500),
      headlineMedium: TextStyle(
        fontSize: 14,
        color: isDark ? AppColors.darkPrimaryColor : AppColors.white,
        fontWeight: FontWeight.w600,
        fontFamily: AppFont.fontFamily,
      ),
      headlineSmall: TextStyle(
          fontSize: 13,
          fontFamily: AppFont.fontMedium,
          height: 1.4,
          letterSpacing: 0,
          color: AppColors.grey,
          fontWeight: FontWeight.w500),
      titleLarge: TextStyle(
          fontSize: 40.sp,
          fontFamily: AppFont.fontMedium,
          height: 1.4,
          letterSpacing: 0,
          color: isDark ? Colors.white : AppColors.black,
          fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(
        fontSize: 20.sp,
        fontFamily: AppFont.fontMedium,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : AppColors.dark,
      ),
      bodyMedium: TextStyle(
        fontSize: 15,
        fontFamily: AppFont.fontMedium,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : AppColors.darkPrimaryColor,
      ),
      bodySmall: TextStyle(
        fontSize: 12.5,
        fontFamily: AppFont.fontMedium,
        letterSpacing: 0,
        fontWeight: FontWeight.w500,
        color: isDark ? Colors.white : AppColors.grey,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFont.fontMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        fontSize: 15,
        color: isDark ? Colors.white : AppColors.darkPrimaryColor,
      ),
      titleSmall: TextStyle(
        fontSize: 11,
        fontFamily: AppFont.fontFamily,
        fontWeight: FontWeight.bold,
        letterSpacing: 0,
        color: isDark ? Colors.white : AppColors.darkPrimaryColor,
      ),
      labelSmall: TextStyle(
          fontSize: 13,
          fontFamily: AppFont.fontMedium,
          fontWeight: FontWeight.w600,
          letterSpacing: 0,
          color: AppColors.grey),
      labelLarge: TextStyle(
        fontSize: 15.5,
        fontFamily: AppFont.fontFamily,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: isDark ? Colors.white : AppColors.black,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontFamily: AppFont.fontMedium,
        fontWeight: FontWeight.w600,
        letterSpacing: 0,
        color: isDark ? AppColors.darkPrimaryColor : AppColors.primaryColor,
      ),
      //caption: TextStyle(color: Colors.white),
    );
  }
}
