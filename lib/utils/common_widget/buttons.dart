import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Widget customButton(
  Color? backgroundColor,
  String title,
  double width,
  double height,
  TextStyle fontStyle, {
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
