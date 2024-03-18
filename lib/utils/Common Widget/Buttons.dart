import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pverify/utils/theme/colors.dart';

Widget customButton(String title, double width, double height, {onbuttonTap}) {
  return InkWell(
    onTap: () {
      onbuttonTap();
    },
    child: Container(
      alignment: Alignment.center,
      height: height.h,
      width: width.w,
      decoration: BoxDecoration(
          color: AppColors.primary, borderRadius: BorderRadius.circular(45.r)),
      child: Text(
        title,
        style: GoogleFonts.poppins(
            fontSize: 25.sp,
            fontWeight: FontWeight.w500,
            textStyle: TextStyle(color: AppColors.white)),
      ),
    ),
  );
}
