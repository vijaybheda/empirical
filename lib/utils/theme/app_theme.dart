import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/theme/colors.dart';
import 'package:pverify/utils/theme/font_family.dart';
import 'package:pverify/utils/theme/text_theme.dart';

class ThemeColor {
  ThemeData getThemeData({required bool isDark}) {
    return ThemeData(
        useMaterial3: true,
        primaryColor: AppColors.primaryColor,
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        colorScheme: ColorScheme.fromSwatch()
            .copyWith(secondary: AppColors.secondaryColor),
        scaffoldBackgroundColor: AppColors.backgroundColor,
        fontFamily: FontFamily.fontFamilyName,
        canvasColor: AppColors.backgroundColor,
        iconTheme: IconThemeData(color: AppColors.textColor),
        inputDecorationTheme: getInputDecorationTheme(isDark: isDark),
        sliderTheme: const SliderThemeData(
          thumbShape: RoundSliderThumbShape(
              enabledThumbRadius: 5, disabledThumbRadius: 5),
        ),
        appBarTheme: AppBarTheme(backgroundColor: AppColors.primaryColor),
        radioTheme: RadioThemeData(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: VisualDensity.compact,
            fillColor: MaterialStateColor.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return AppColors.warningColor;
              }
              return AppColors.textColor;
            })),
        textTheme: GoogleFonts.getTextTheme(FontFamily.fontFamilyName),
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.black.withOpacity(0.24)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            shape: MaterialStatePropertyAll<OutlinedBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(21)),
            ),
            backgroundColor:
                MaterialStateProperty.all<Color>(AppColors.primaryColor),
            foregroundColor: MaterialStateProperty.all<Color>(AppColors.white),
            padding: const MaterialStatePropertyAll<EdgeInsetsGeometry>(
              EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            elevation: MaterialStateProperty.all<double>(0),
            enableFeedback: true,
          ),
        ),
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: AppColors.white.withOpacity(0.7),
          dividerColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          labelColor: AppColors.white,
          indicatorColor: AppColors.white,
          unselectedLabelStyle: AppFontStyle.bodyMedium
              ?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
          labelStyle: AppFontStyle.bodyMedium
              ?.copyWith(fontWeight: FontWeight.w600, fontSize: 14),
        ));
  }

  InputDecorationTheme getInputDecorationTheme({
    required bool isDark,
  }) {
    return InputDecorationTheme(
      contentPadding: const EdgeInsets.all(14),
      errorMaxLines: 2,
      filled: true,
      fillColor: AppColors.textColor,
      disabledBorder: getTextFieldBorder(isDark: isDark),
      errorBorder: getTextFieldBorder(isDark: isDark).copyWith(
        borderSide: const BorderSide(color: Colors.grey, width: 1),
      ),
      enabledBorder: getTextFieldBorder(isDark: isDark),
      isDense: true,
      focusedBorder: getTextFieldBorder(isDark: isDark),
      border: getTextFieldBorder(isDark: isDark),
      errorStyle: getErrorStyle(isDark: isDark),
      hintStyle: getHintText(isDark: isDark),
      labelStyle: getHintText(isDark: isDark),
      focusColor: AppColors.textColor,
      alignLabelWithHint: false,
    );
  }

  OutlineInputBorder getTextFieldBorder({
    required bool isDark,
  }) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: AppColors.textColor, width: 1),
      borderRadius: BorderRadius.circular(8),
      gapPadding: 0,
    );
  }

  TextStyle getHintText({
    required bool isDark,
  }) {
    return TextStyle(
      color: AppColors.textColor,
    );
  }

  TextStyle getErrorStyle({
    required bool isDark,
  }) {
    return const TextStyle(color: Colors.grey);
  }
}
