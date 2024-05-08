import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget customButton({
  required Color backgroundColor,
  required String title,
  required double width,
  required double height,
  required TextStyle fontStyle,
  Function? onClickAction,
}) {
  return InkWell(
    onTap: () {
      onClickAction!();
    },
    child: Container(
      alignment: Alignment.center,
      height: height.h,
      width: width,
      decoration: BoxDecoration(
          color: backgroundColor, borderRadius: BorderRadius.circular(45.r)),
      child: Text(
        textAlign: TextAlign.center,
        title,
        style: fontStyle,
      ),
    ),
  );
}
