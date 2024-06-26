// ignore_for_file: non_constant_identifier_names

import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:pverify/utils/app_const.dart';
import 'package:pverify/utils/enumeration.dart';

class GradientThemeColors {
  static List<Color> purpleGradient = [
    const Color(0xffCE9FFC),
    const Color(0xff7367F0),
  ];
  static List<Color> greenGradient = [
    const Color(0xff20BF55),
    const Color(0xff01BAEF),
  ];
  static List<Color> pinkGradient = [
    const Color(0xffC701E1),
    const Color(0xffC901E9),
  ];
  static List<Color> orangegradient = [
    const Color(0xffFCCF31),
    const Color(0xffF55555),
  ];
}

class AppColors {
  static Color sampleColorTheme = AppConst.AppTheme == ThemeType.dark
      ? const Color(0xffF29D38)
      : const Color(0xffABABAB); // Sample Color for Dark / Light Theme
  static Color primaryBlack = const Color.fromARGB(255, 0, 0, 0);
  static Color primary = const Color(0xff0ba900);
  static Color accentColor = const Color(0xff0ba900);
  static Color greenButtonColor = const Color(0xff138909);
  static Color textInput = const Color(0xffFFFFFD);
  static Color textColor = const Color(0xffFFFFFF);
  static Color hintColor = const Color(0xffABABAB);
  static Color notificationOff = const Color.fromARGB(186, 255, 0, 0);
  static Color darkBlue = const Color(0xff09262D);
  static Color searchbar = const Color(0xFFE7E7E7);

  static Color primaryColor = const Color(0xffF29D38);
  static Color secondaryColor = const Color(0xffF29D38);
  static Color backgroundColor = const Color(0xffEBF9F6);
  static Color darkPrimaryColor = const Color(0xff0D0D0D);
  static Color dark = const Color(0xff474747);
  static Color grey2 = const Color(0xff818181);
  static Color grey = const Color(0xff0d0d0d);
  static Color lightBackgroundGrey = const Color(0xff787878);
  static Color darkBackgroundGrey = const Color(0xff5f5f5f);
  static Color lightGrey = const Color(0xffBABABA);
  static Color darkGrey = const Color(0xdd4B5665);
  static Color lightSky = const Color(0xffE8F5F5);
  static Color red = const Color(0xffFA0000);
  static Color blue = const Color(0xff0064B2);
  static Color purple = const Color(0xff5D5DFF);
  static Color darkSkyBlue = const Color(0xff007AFF);

  static Color textFieldBorderColor = const Color(0xffE5E8E9);
  static Color lightButtonBackground = const Color(0xffEBF9F6);
  static Color chatBackgroundColor = const Color(0xffFFFFFF);
  static Color alertBoxTextColot = const Color(0xff007AFF);
  static Color textBlue = const Color(0xFF347CF6);
  static Color searchfieldColor = const Color(0xffF8F8F9);
  static Color warningColor = const Color(0xFFFF0101);
  static Color graniteGray = const Color(0xff5F646C);
  static Color scoreCardRowColor = const Color(0xffa6cbff);

  // Login Screen Colors

  static Color black = const Color(0xff180E02);
  static Color white = const Color(0xffffffff);
  static Color primaryColor_Green = const Color(0xff303F9F);
  static Color loginTextField_UnderlineColor = const Color(0xff680000);
  static Color textFieldText_Color = const Color(0xff912688);
  static Color sky = const Color(0xff00B2CB);
  static Color uploadBG = const Color(0xffFFC0CB);
  static Color brightGrey = const Color(0xFFE6E6E6);

  static Color background = AppConst.AppTheme == ThemeType.dark
      ? const Color(0xff5f5f5f)
      : const Color(0xff5f5f5f);

  static Color orange = const Color(0xffF29D38);
  static Color yellow = const Color(0xffFFFF00);
  static Color iconBlue = const Color(0xff5acdf1);

  static Color defectOrange = const Color(0xffFECE9E);
  static Color defectGreen = const Color(0xffE4FFB5);
  static Color defectBlue = const Color(0xffC1DCFF);

  static Color shareifyGold = const Color(0xffFFD632);
  static Color shareifyGreen = const Color(0xff2BB558);
}
