// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/assets.dart';
import 'package:pverify/utils/images.dart';
import 'package:pverify/utils/strings.dart';
import 'package:pverify/utils/theme/colors.dart';

Widget baseHeaderView(String title, bool isVersionShow) {
  return Container(
    color: AppColors.primary,
    child: Row(
      children: [
        Image.asset(
          AppImages.appLogo,
          width: 90.w,
          height: 90.w,
        ),
        SizedBox(
          width: 15.w,
        ),
        Text(
          title,
          style: GoogleFonts.poppins(
              fontSize: 40.sp,
              fontWeight: FontWeight.bold,
              textStyle: TextStyle(color: AppColors.white)),
        ),
        Spacer(),
        isVersionShow
            ? Text(
                '10.19.7',
                style: GoogleFonts.poppins(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.bold,
                    textStyle: TextStyle(color: AppColors.white)),
              )
            : Container(),
        SizedBox(
          width: 40.w,
        ),
        Image.asset(
          AppImages.ic_Wifi,
          width: 70.w,
          height: 70.w,
        ),
      ],
    ),
  );
}
